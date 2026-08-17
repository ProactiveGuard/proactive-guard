import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import '../utils/constants.dart';
import 'location.dart';

/// A simplified background location service that uses the existing LocationService
/// for foreground tracking. For true background tracking, a native platform channel
/// or flutter_background_service would be needed.
class BackgroundLocationService {
  static final BackgroundLocationService _instance = BackgroundLocationService._internal();
  factory BackgroundLocationService() => _instance;
  BackgroundLocationService._internal();

  final LocationService _locationService = LocationService();
  Timer? _backgroundTimer;
  bool _isRunning = false;

  bool get isRunning => _isRunning;

  Future<void> startBackgroundMonitoring({required String journeyId, required String userId}) async {
    if (_isRunning) return;
    
    _isRunning = true;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.isJourneyActiveKey, true);
    await prefs.setString(AppConstants.journeyIdKey, journeyId);
    await prefs.setString(AppConstants.userIdKey, userId);

    // Start the location service for continuous tracking
    await _locationService.startMonitoring(journeyId: journeyId);
    
    // Also start a periodic timer for additional background-like updates
    _backgroundTimer = Timer.periodic(AppConstants.locationUpdateInterval, (_) async {
      if (!_isRunning) return;
      final location = await _locationService.getCurrentLocation();
      if (location != null && kDebugMode) {
        debugPrint('Background location update: ${location.latitude}, ${location.longitude}');
      }
    });
  }

  Future<void> stopBackgroundMonitoring() async {
    _isRunning = false;
    
    _backgroundTimer?.cancel();
    _backgroundTimer = null;
    
    await _locationService.stopMonitoring();
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.isJourneyActiveKey, false);
    await prefs.remove(AppConstants.journeyIdKey);
  }

  Future<bool> isRunningAsync() async {
    return _isRunning;
  }
}