import 'dart:async';
import 'dart:math' as math;
import 'package:sensors_plus/sensors_plus.dart';
import 'package:flutter/foundation.dart';
import '../utils/constants.dart';

class MotionData {
  final double x;
  final double y;
  final double z;
  final double magnitude;
  final double normalizedScore;
  final DateTime timestamp;

  MotionData({
    required this.x,
    required this.y,
    required this.z,
    required this.magnitude,
    required this.normalizedScore,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'x': x,
      'y': y,
      'z': z,
      'magnitude': magnitude,
      'normalized_score': normalizedScore,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'MotionData(mag: ${magnitude.toStringAsFixed(2)}, score: ${normalizedScore.toStringAsFixed(2)})';
  }
}

class MotionService {
  static final MotionService _instance = MotionService._internal();
  factory MotionService() => _instance;
  MotionService._internal();

  StreamController<MotionData>? _motionStreamController;
  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;
  Timer? _samplingTimer;
  bool _isMonitoring = false;
  String? _activeJourneyId;
  double _lastMagnitude = 0.0;
  double _baselineMagnitude = 9.81; // Earth's gravity
  final List<double> _recentMagnitudes = [];
  static const int _maxSamples = 50;

  Stream<MotionData> get motionStream {
    _motionStreamController ??= StreamController<MotionData>.broadcast();
    return _motionStreamController!.stream;
  }

  bool get isMonitoring => _isMonitoring;
  double get lastMagnitude => _lastMagnitude;
  String? get activeJourneyId => _activeJourneyId;

  Future<void> startMonitoring({String? journeyId}) async {
    if (_isMonitoring) {
      if (AppConstants.enableDebugLogs) {
        debugPrint('MotionService: Already monitoring');
      }
      return;
    }

    _activeJourneyId = journeyId;
    _isMonitoring = true;
    _motionStreamController ??= StreamController<MotionData>.broadcast();
    _recentMagnitudes.clear();

    // Start accelerometer stream
    _startAccelerometerStream();

    // Start periodic sampling for score calculation
    _startPeriodicSampling();

    // Get initial reading after a short delay
    await Future.delayed(const Duration(milliseconds: 500));
    _calculateAndEmitScore();

    if (AppConstants.enableDebugLogs) {
      debugPrint('MotionService: Started monitoring for journey: $journeyId');
    }
  }

  void _startAccelerometerStream() {
    _accelerometerSubscription?.cancel();
    
    _accelerometerSubscription = accelerometerEvents
        .listen(
      (AccelerometerEvent event) {
        if (!_isMonitoring) return;
        
        final magnitude = math.sqrt(
          event.x * event.x + 
          event.y * event.y + 
          event.z * event.z
        );
        
        _lastMagnitude = magnitude;
        _recentMagnitudes.add(magnitude);
        
        // Keep only recent samples
        if (_recentMagnitudes.length > _maxSamples) {
          _recentMagnitudes.removeAt(0);
        }
      },
      onError: (error) {
        if (AppConstants.enableDebugLogs) {
          debugPrint('MotionService: Accelerometer stream error - $error');
        }
      },
      cancelOnError: false,
    );
  }

  void _startPeriodicSampling() {
    _samplingTimer?.cancel();
    _samplingTimer = Timer.periodic(AppConstants.motionUpdateInterval, (_) {
      if (!_isMonitoring) return;
      _calculateAndEmitScore();
    });
  }

  void _calculateAndEmitScore() {
    if (_recentMagnitudes.isEmpty) return;

    // Calculate average magnitude
    final avgMagnitude = _recentMagnitudes.reduce((a, b) => a + b) / _recentMagnitudes.length;
    
    // Calculate variance to detect unusual movement
    final variance = _recentMagnitudes
        .map((m) => math.pow(m - avgMagnitude, 2))
        .reduce((a, b) => a + b) / _recentMagnitudes.length;
    
    final stdDev = math.sqrt(variance);
    
    // Normalize score based on deviation from gravity
    // Higher deviation = more movement = higher score
    final deviation = (avgMagnitude - _baselineMagnitude).abs() + stdDev;
    final normalizedScore = _normalizeMotionScore(deviation);
    
    final motionData = MotionData(
      x: 0, // Not tracking individual axes for score
      y: 0,
      z: 0,
      magnitude: avgMagnitude,
      normalizedScore: normalizedScore,
    );
    
    _motionStreamController?.add(motionData);
    
    if (AppConstants.enableDebugLogs) {
      debugPrint('MotionService: Sample - $motionData (dev: ${deviation.toStringAsFixed(2)})');
    }
  }

  double _normalizeMotionScore(double deviation) {
    // Normalize to 0.0-1.0
    // Low deviation (stationary) = low score
    // High deviation (vigorous movement) = high score
    if (deviation <= 1.0) return 0.0;
    if (deviation >= 10.0) return 1.0;
    return (deviation - 1.0) / 9.0;
  }

  Future<void> stopMonitoring() async {
    _isMonitoring = false;
    _activeJourneyId = null;
    
    _samplingTimer?.cancel();
    _samplingTimer = null;
    
    await _accelerometerSubscription?.cancel();
    _accelerometerSubscription = null;
    _recentMagnitudes.clear();

    if (AppConstants.enableDebugLogs) {
      debugPrint('MotionService: Stopped monitoring');
    }
  }

  void dispose() {
    stopMonitoring();
    _motionStreamController?.close();
    _motionStreamController = null;
  }
}