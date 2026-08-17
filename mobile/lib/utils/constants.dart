import 'package:flutter/foundation.dart';

class AppConstants {
  static const String appName = 'Proactive Guard';
  
  // API Configuration
  static const String apiBaseUrl = 'http://10.0.2.2:8000';
  static const String apiVersion = 'v1';
  static const Duration apiTimeout = Duration(seconds: 15);
  
  // API Endpoints
  static const String telemetryEndpoint = '/api/v1/telemetry';
  static const String incidentsEndpoint = '/incidents';
  static const String healthEndpoint = '/ping';
  
  // Journey Configuration
  static const Duration locationUpdateInterval = Duration(seconds: 10);
  static const Duration telemetrySendInterval = Duration(seconds: 15);
  static const int maxTelemetryRetries = 3;
  
  // Audio Configuration
  static const Duration audioSampleInterval = Duration(seconds: 5);
  static const double audioThresholdDb = 70.0;
  
  // Motion Configuration
  static const Duration motionUpdateInterval = Duration(seconds: 5);
  static const double motionThreshold = 0.5;
  
  // Storage Keys
  static const String userIdKey = 'user_id';
  static const String userNameKey = 'user_name';
  static const String journeyIdKey = 'active_journey_id';
  static const String isJourneyActiveKey = 'is_journey_active';
  static const String guardianContactsKey = 'guardian_contacts';
  static const String locationSharingEnabledKey = 'location_sharing_enabled';
  static const String autoCallGuardianKey = 'auto_call_guardian';
  static const String alertSensitivityKey = 'alert_sensitivity';
  static const String audioMonitoringEnabledKey = 'audio_monitoring_enabled';
  static const String motionMonitoringEnabledKey = 'motion_monitoring_enabled';
  
  // Default Settings
  static const bool defaultLocationSharing = true;
  static const bool defaultAutoCallGuardian = false;
  static const String defaultAlertSensitivity = 'medium';
  static const bool defaultAudioMonitoring = true;
  static const bool defaultMotionMonitoring = true;
  
  // Alert Sensitivity Levels
  static const List<String> alertSensitivityLevels = ['low', 'medium', 'high'];
  
  // Error Messages
  static const String errorLocationPermissionDenied = 'Location permission is required for safety tracking. Please enable it in settings.';
  static const String errorLocationPermissionPermanentlyDenied = 'Location permission was permanently denied. Please enable it from app settings.';
  static const String errorGpsDisabled = 'GPS is disabled. Please enable location services.';
  static const String errorMicrophonePermissionDenied = 'Microphone permission is required for audio monitoring. Please enable it in settings.';
  static const String errorNetworkUnavailable = 'Network unavailable. Please check your internet connection.';
  static const String errorServerUnavailable = 'Server is unavailable. Please try again later.';
  static const String errorJourneyStartFailed = 'Failed to start journey. Please try again.';
  static const String errorJourneyStopFailed = 'Failed to stop journey. Please try again.';
  static const String errorInvalidResponse = 'Invalid response from server.';
  static const String errorUnknown = 'An unknown error occurred. Please try again.';
  
  // Success Messages
  static const String successJourneyStarted = 'Journey started successfully. Stay safe!';
  static const String successJourneyStopped = 'Journey stopped successfully.';
  static const String successSettingsSaved = 'Settings saved successfully.';
  
  // Telemetry Batch Size
  static const int telemetryBatchSize = 10;
  
  // Background Service
  static const String backgroundServiceName = 'ProactiveGuardBackgroundService';
  static const int backgroundNotificationId = 888;
  
  // Debug
  static const bool enableDebugLogs = kDebugMode;
}