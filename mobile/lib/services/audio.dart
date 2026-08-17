import 'dart:async';
import 'dart:math' as math;
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart';
import '../utils/constants.dart';

class AudioPermissionStatus {
  final bool isGranted;
  final bool isDenied;
  final bool isPermanentlyDenied;
  final String? errorMessage;

  AudioPermissionStatus({
    required this.isGranted,
    required this.isDenied,
    required this.isPermanentlyDenied,
    this.errorMessage,
  });

  factory AudioPermissionStatus.granted() => AudioPermissionStatus(
    isGranted: true,
    isDenied: false,
    isPermanentlyDenied: false,
  );

  factory AudioPermissionStatus.denied({String? message}) => AudioPermissionStatus(
    isGranted: false,
    isDenied: true,
    isPermanentlyDenied: false,
    errorMessage: message ?? AppConstants.errorMicrophonePermissionDenied,
  );

  factory AudioPermissionStatus.permanentlyDenied({String? message}) => AudioPermissionStatus(
    isGranted: false,
    isDenied: true,
    isPermanentlyDenied: true,
    errorMessage: message ?? 'Microphone permission permanently denied. Please enable it from app settings.',
  );
}

class AudioData {
  final double decibelLevel;
  final double normalizedScore;
  final DateTime timestamp;

  AudioData({
    required this.decibelLevel,
    required this.normalizedScore,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'decibel_level': decibelLevel,
      'normalized_score': normalizedScore,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'AudioData(db: ${decibelLevel.toStringAsFixed(1)}, score: ${normalizedScore.toStringAsFixed(2)})';
  }
}

class AudioMonitorService {
  static final AudioMonitorService _instance = AudioMonitorService._internal();
  factory AudioMonitorService() => _instance;
  AudioMonitorService._internal();

  StreamController<AudioData>? _audioStreamController;
  Timer? _samplingTimer;
  bool _isMonitoring = false;
  String? _activeJourneyId;
  double _lastDecibelLevel = 0.0;
  final math.Random _random = math.Random();

  Stream<AudioData> get audioStream {
    _audioStreamController ??= StreamController<AudioData>.broadcast();
    return _audioStreamController!.stream;
  }

  bool get isMonitoring => _isMonitoring;
  double get lastDecibelLevel => _lastDecibelLevel;
  String? get activeJourneyId => _activeJourneyId;

  Future<AudioPermissionStatus> checkPermissionStatus() async {
    try {
      final status = await Permission.microphone.status;
      
      switch (status) {
        case PermissionStatus.granted:
          return AudioPermissionStatus.granted();
        case PermissionStatus.denied:
          return AudioPermissionStatus.denied();
        case PermissionStatus.permanentlyDenied:
          return AudioPermissionStatus.permanentlyDenied();
        case PermissionStatus.restricted:
        case PermissionStatus.limited:
        case PermissionStatus.provisional:
          return AudioPermissionStatus.denied(
            message: 'Microphone permission is restricted.',
          );
      }
    } catch (e) {
      if (AppConstants.enableDebugLogs) {
        debugPrint('AudioMonitorService: Error checking permission - $e');
      }
      return AudioPermissionStatus.denied(
        message: 'Error checking microphone permission: $e',
      );
    }
  }

  Future<AudioPermissionStatus> requestPermission() async {
    try {
      final status = await Permission.microphone.request();
      
      switch (status) {
        case PermissionStatus.granted:
          return AudioPermissionStatus.granted();
        case PermissionStatus.denied:
          return AudioPermissionStatus.denied();
        case PermissionStatus.permanentlyDenied:
          return AudioPermissionStatus.permanentlyDenied();
        case PermissionStatus.restricted:
        case PermissionStatus.limited:
        case PermissionStatus.provisional:
          return AudioPermissionStatus.denied(
            message: 'Microphone permission is restricted.',
          );
      }
    } catch (e) {
      if (AppConstants.enableDebugLogs) {
        debugPrint('AudioMonitorService: Error requesting permission - $e');
      }
      return AudioPermissionStatus.denied(
        message: 'Error requesting microphone permission: $e',
      );
    }
  }

  Future<void> startMonitoring({String? journeyId}) async {
    if (_isMonitoring) {
      if (AppConstants.enableDebugLogs) {
        debugPrint('AudioMonitorService: Already monitoring');
      }
      return;
    }

    final status = await requestPermission();
    if (!status.isGranted) {
      if (AppConstants.enableDebugLogs) {
        debugPrint('AudioMonitorService: Cannot start monitoring - ${status.errorMessage}');
      }
      throw Exception(status.errorMessage ?? AppConstants.errorMicrophonePermissionDenied);
    }

    _activeJourneyId = journeyId;
    _isMonitoring = true;
    _audioStreamController ??= StreamController<AudioData>.broadcast();

    // Start periodic audio sampling (simulated)
    _startPeriodicSampling();

    // Get initial reading
    await _sampleAudio();

    if (AppConstants.enableDebugLogs) {
      debugPrint('AudioMonitorService: Started monitoring for journey: $journeyId');
    }
  }

  void _startPeriodicSampling() {
    _samplingTimer?.cancel();
    _samplingTimer = Timer.periodic(AppConstants.audioSampleInterval, (_) async {
      if (!_isMonitoring) return;
      await _sampleAudio();
    });
  }

  Future<void> _sampleAudio() async {
    try {
      // Simulate audio sampling without actual recording
      // In a real implementation, you would use the record package or platform channels
      // For demo purposes, we generate simulated decibel levels
      final decibelLevel = _generateSimulatedDecibelLevel();
      _lastDecibelLevel = decibelLevel;
      
      // Normalize score (0.0 to 1.0) based on threshold
      final normalizedScore = _normalizeDecibelLevel(decibelLevel);
      
      final audioData = AudioData(
        decibelLevel: decibelLevel,
        normalizedScore: normalizedScore,
      );
      
      _audioStreamController?.add(audioData);
      
      if (AppConstants.enableDebugLogs) {
        debugPrint('AudioMonitorService: Sample - $audioData');
      }
    } catch (e) {
      if (AppConstants.enableDebugLogs) {
        debugPrint('AudioMonitorService: Error sampling audio - $e');
      }
    }
  }

  double _generateSimulatedDecibelLevel() {
    // Generate realistic ambient noise levels
    // Most of the time: 30-50 dB (quiet to normal conversation)
    // Occasionally: 50-70 dB (loud environment)
    // Rarely: 70-85 dB (very loud - potential safety concern)
    
    final roll = _random.nextDouble();
    if (roll < 0.7) {
      // 70% chance: quiet to normal (30-50 dB)
      return 30.0 + _random.nextDouble() * 20.0;
    } else if (roll < 0.95) {
      // 25% chance: loud environment (50-70 dB)
      return 50.0 + _random.nextDouble() * 20.0;
    } else {
      // 5% chance: very loud (70-85 dB)
      return 70.0 + _random.nextDouble() * 15.0;
    }
  }

  double _normalizeDecibelLevel(double decibelLevel) {
    // Normalize to 0.0-1.0 based on threshold
    // Below threshold = low score, above threshold = high score
    if (decibelLevel <= 30) return 0.0;
    if (decibelLevel >= AppConstants.audioThresholdDb) return 1.0;
    return (decibelLevel - 30) / (AppConstants.audioThresholdDb - 30);
  }

  Future<void> stopMonitoring() async {
    _isMonitoring = false;
    _activeJourneyId = null;
    
    _samplingTimer?.cancel();
    _samplingTimer = null;

    if (AppConstants.enableDebugLogs) {
      debugPrint('AudioMonitorService: Stopped monitoring');
    }
  }

  Future<void> openAppSettings() async {
    await openAppSettings();
  }

  void dispose() {
    stopMonitoring();
    _audioStreamController?.close();
    _audioStreamController = null;
  }
}