import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart';
import '../utils/constants.dart';

class LocationPermissionStatus {
  final bool isGranted;
  final bool isDenied;
  final bool isPermanentlyDenied;
  final bool isServiceEnabled;
  final String? errorMessage;

  LocationPermissionStatus({
    required this.isGranted,
    required this.isDenied,
    required this.isPermanentlyDenied,
    required this.isServiceEnabled,
    this.errorMessage,
  });

  factory LocationPermissionStatus.granted() => LocationPermissionStatus(
    isGranted: true,
    isDenied: false,
    isPermanentlyDenied: false,
    isServiceEnabled: true,
  );

  factory LocationPermissionStatus.denied({String? message}) => LocationPermissionStatus(
    isGranted: false,
    isDenied: true,
    isPermanentlyDenied: false,
    isServiceEnabled: true,
    errorMessage: message ?? AppConstants.errorLocationPermissionDenied,
  );

  factory LocationPermissionStatus.permanentlyDenied({String? message}) => LocationPermissionStatus(
    isGranted: false,
    isDenied: true,
    isPermanentlyDenied: true,
    isServiceEnabled: true,
    errorMessage: message ?? AppConstants.errorLocationPermissionPermanentlyDenied,
  );

  factory LocationPermissionStatus.serviceDisabled({String? message}) => LocationPermissionStatus(
    isGranted: false,
    isDenied: false,
    isPermanentlyDenied: false,
    isServiceEnabled: false,
    errorMessage: message ?? AppConstants.errorGpsDisabled,
  );
}

class LocationData {
  final double latitude;
  final double longitude;
  final double accuracy;
  final double? altitude;
  final double? speed;
  final double? heading;
  final DateTime timestamp;

  LocationData({
    required this.latitude,
    required this.longitude,
    required this.accuracy,
    this.altitude,
    this.speed,
    this.heading,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'accuracy': accuracy,
      'altitude': altitude,
      'speed': speed,
      'heading': heading,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'LocationData(lat: $latitude, lng: $longitude, accuracy: $accuracy, time: $timestamp)';
  }
}

class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  StreamController<LocationData>? _locationStreamController;
  StreamSubscription<Position>? _positionStreamSubscription;
  bool _isMonitoring = false;
  String? _activeJourneyId;
  Timer? _periodicTimer;

  Stream<LocationData> get locationStream {
    _locationStreamController ??= StreamController<LocationData>.broadcast();
    return _locationStreamController!.stream;
  }

  bool get isMonitoring => _isMonitoring;
  String? get activeJourneyId => _activeJourneyId;

  Future<LocationPermissionStatus> checkPermissionStatus() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return LocationPermissionStatus.serviceDisabled();
      }

      LocationPermission permission = await Geolocator.checkPermission();
      
      switch (permission) {
        case LocationPermission.denied:
          return LocationPermissionStatus.denied();
        case LocationPermission.deniedForever:
          return LocationPermissionStatus.permanentlyDenied();
        case LocationPermission.whileInUse:
        case LocationPermission.always:
          return LocationPermissionStatus.granted();
        case LocationPermission.unableToDetermine:
          return LocationPermissionStatus.denied(
            message: 'Unable to determine location permission status.',
          );
      }
    } catch (e) {
      if (AppConstants.enableDebugLogs) {
        debugPrint('LocationService: Error checking permission - $e');
      }
      return LocationPermissionStatus.denied(
        message: 'Error checking location permission: $e',
      );
    }
  }

  Future<LocationPermissionStatus> requestPermission() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return LocationPermissionStatus.serviceDisabled();
      }

      LocationPermission permission = await Geolocator.requestPermission();
      
      switch (permission) {
        case LocationPermission.denied:
          return LocationPermissionStatus.denied();
        case LocationPermission.deniedForever:
          return LocationPermissionStatus.permanentlyDenied();
        case LocationPermission.whileInUse:
        case LocationPermission.always:
          return LocationPermissionStatus.granted();
        case LocationPermission.unableToDetermine:
          return LocationPermissionStatus.denied(
            message: 'Unable to determine location permission status.',
          );
      }
    } catch (e) {
      if (AppConstants.enableDebugLogs) {
        debugPrint('LocationService: Error requesting permission - $e');
      }
      return LocationPermissionStatus.denied(
        message: 'Error requesting location permission: $e',
      );
    }
  }

  Future<LocationData?> getCurrentLocation() async {
    final status = await checkPermissionStatus();
    if (!status.isGranted) {
      if (AppConstants.enableDebugLogs) {
        debugPrint('LocationService: Cannot get location - ${status.errorMessage}');
      }
      return null;
    }

    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );
      return _positionToLocationData(position);
    } catch (e) {
      if (AppConstants.enableDebugLogs) {
        debugPrint('LocationService: Error getting current location - $e');
      }
      return null;
    }
  }

  LocationData _positionToLocationData(Position position) {
    return LocationData(
      latitude: position.latitude,
      longitude: position.longitude,
      accuracy: position.accuracy,
      altitude: position.altitude,
      speed: position.speed,
      heading: position.heading,
      timestamp: DateTime.fromMillisecondsSinceEpoch(position.timestamp.millisecondsSinceEpoch),
    );
  }

  Future<void> startMonitoring({String? journeyId}) async {
    if (_isMonitoring) {
      if (AppConstants.enableDebugLogs) {
        debugPrint('LocationService: Already monitoring');
      }
      return;
    }

    final status = await requestPermission();
    if (!status.isGranted) {
      if (AppConstants.enableDebugLogs) {
        debugPrint('LocationService: Cannot start monitoring - ${status.errorMessage}');
      }
      throw Exception(status.errorMessage ?? AppConstants.errorLocationPermissionDenied);
    }

    _activeJourneyId = journeyId;
    _isMonitoring = true;
    _locationStreamController ??= StreamController<LocationData>.broadcast();

    // Start periodic location updates
    _startPeriodicUpdates();
    
    // Start continuous stream
    _startLocationStream();

    // Get initial location
    final initialLocation = await getCurrentLocation();
    if (initialLocation != null) {
      _locationStreamController!.add(initialLocation);
    }

    if (AppConstants.enableDebugLogs) {
      debugPrint('LocationService: Started monitoring for journey: $journeyId');
    }
  }

  void _startPeriodicUpdates() {
    _periodicTimer?.cancel();
    _periodicTimer = Timer.periodic(AppConstants.locationUpdateInterval, (_) async {
      if (!_isMonitoring) return;
      final location = await getCurrentLocation();
      if (location != null) {
        _locationStreamController?.add(location);
      }
    });
  }

  void _startLocationStream() {
    _positionStreamSubscription?.cancel();
    
    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10,
    );

    _positionStreamSubscription = Geolocator.getPositionStream(locationSettings: locationSettings)
        .listen(
      (Position position) {
        if (!_isMonitoring) return;
        final locationData = _positionToLocationData(position);
        _locationStreamController?.add(locationData);
      },
      onError: (error) {
        if (AppConstants.enableDebugLogs) {
          debugPrint('LocationService: Stream error - $error');
        }
      },
      cancelOnError: false,
    );
  }

  Future<void> stopMonitoring() async {
    _isMonitoring = false;
    _activeJourneyId = null;
    
    _periodicTimer?.cancel();
    _periodicTimer = null;
    
    await _positionStreamSubscription?.cancel();
    _positionStreamSubscription = null;

    if (AppConstants.enableDebugLogs) {
      debugPrint('LocationService: Stopped monitoring');
    }
  }

  Future<void> openAppSettings() async {
    await openAppSettings();
  }

  Future<void> openLocationSettings() async {
    await Geolocator.openLocationSettings();
  }

  void dispose() {
    stopMonitoring();
    _locationStreamController?.close();
    _locationStreamController = null;
  }
}