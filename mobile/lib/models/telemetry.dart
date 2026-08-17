import 'package:uuid/uuid.dart';

class TelemetryData {
  final String userId;
  final double latitude;
  final double longitude;
  final double motionScore;
  final double audioScore;
  final DateTime timestamp;
  final String? journeyId;

  TelemetryData({
    required this.userId,
    required this.latitude,
    required this.longitude,
    required this.motionScore,
    required this.audioScore,
    DateTime? timestamp,
    this.journeyId,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'latitude': latitude,
      'longitude': longitude,
      'motion_score': motionScore,
      'audio_score': audioScore,
      'timestamp': timestamp.toIso8601String(),
      if (journeyId != null) 'journey_id': journeyId,
    };
  }

  factory TelemetryData.fromJson(Map<String, dynamic> json) {
    return TelemetryData(
      userId: json['user_id'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      motionScore: (json['motion_score'] as num).toDouble(),
      audioScore: (json['audio_score'] as num).toDouble(),
      timestamp: DateTime.parse(json['timestamp'] as String),
      journeyId: json['journey_id'] as String?,
    );
  }

  TelemetryData copyWith({
    String? userId,
    double? latitude,
    double? longitude,
    double? motionScore,
    double? audioScore,
    DateTime? timestamp,
    String? journeyId,
  }) {
    return TelemetryData(
      userId: userId ?? this.userId,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      motionScore: motionScore ?? this.motionScore,
      audioScore: audioScore ?? this.audioScore,
      timestamp: timestamp ?? this.timestamp,
      journeyId: journeyId ?? this.journeyId,
    );
  }
}

class IncidentResponse {
  final String incidentId;
  final String severity;
  final int riskScore;
  final String summary;

  IncidentResponse({
    required this.incidentId,
    required this.severity,
    required this.riskScore,
    required this.summary,
  });

  factory IncidentResponse.fromJson(Map<String, dynamic> json) {
    return IncidentResponse(
      incidentId: json['incident_id'] as String,
      severity: json['severity'] as String,
      riskScore: json['risk_score'] as int,
      summary: json['summary'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'incident_id': incidentId,
      'severity': severity,
      'risk_score': riskScore,
      'summary': summary,
    };
  }

  bool get isCritical => severity == 'CRITICAL';
  bool get isHigh => severity == 'HIGH';
  bool get isMonitor => severity == 'MONITOR';
  bool get isSafe => severity == 'SAFE';
}

class Journey {
  final String id;
  final String userId;
  final DateTime startTime;
  DateTime? endTime;
  final List<TelemetryData> telemetryPoints;
  JourneyStatus status;

  Journey({
    String? id,
    required this.userId,
    DateTime? startTime,
    this.endTime,
    List<TelemetryData>? telemetryPoints,
    this.status = JourneyStatus.active,
  })  : id = id ?? const Uuid().v4(),
        startTime = startTime ?? DateTime.now(),
        telemetryPoints = telemetryPoints ?? [];

  Duration get duration => (endTime ?? DateTime.now()).difference(startTime);

  bool get isActive => status == JourneyStatus.active;

  void addTelemetry(TelemetryData data) {
    telemetryPoints.add(data);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime?.toIso8601String(),
      'status': status.name,
      'telemetry_count': telemetryPoints.length,
    };
  }

  factory Journey.fromJson(Map<String, dynamic> json) {
    return Journey(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      startTime: DateTime.parse(json['start_time'] as String),
      endTime: json['end_time'] != null 
          ? DateTime.parse(json['end_time'] as String) 
          : null,
      status: JourneyStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => JourneyStatus.active,
      ),
      telemetryPoints: [],
    );
  }
}

enum JourneyStatus {
  active,
  stopped,
  completed,
  error,
}

class GuardianContact {
  final String id;
  final String name;
  final String phoneNumber;
  final String? relationship;
  final bool isPrimary;
  final bool isActive;

  GuardianContact({
    String? id,
    required this.name,
    required this.phoneNumber,
    this.relationship,
    this.isPrimary = false,
    this.isActive = true,
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone_number': phoneNumber,
      'relationship': relationship,
      'is_primary': isPrimary,
      'is_active': isActive,
    };
  }

  factory GuardianContact.fromJson(Map<String, dynamic> json) {
    return GuardianContact(
      id: json['id'] as String,
      name: json['name'] as String,
      phoneNumber: json['phone_number'] as String,
      relationship: json['relationship'] as String?,
      isPrimary: json['is_primary'] as bool? ?? false,
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  String get formattedPhone {
    final cleaned = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
    if (cleaned.startsWith('+91')) {
      return '+91 ${cleaned.substring(3, 8)} ${cleaned.substring(8)}';
    } else if (cleaned.length == 10) {
      return '+91 ${cleaned.substring(0, 5)} ${cleaned.substring(5)}';
    }
    return phoneNumber;
  }

  bool get isValidPhone {
    final cleaned = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
    return cleaned.length >= 10 && cleaned.length <= 13;
  }

  GuardianContact copyWith({
    String? id,
    String? name,
    String? phoneNumber,
    String? relationship,
    bool? isPrimary,
    bool? isActive,
  }) {
    return GuardianContact(
      id: id ?? this.id,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      relationship: relationship ?? this.relationship,
      isPrimary: isPrimary ?? this.isPrimary,
      isActive: isActive ?? this.isActive,
    );
  }
}

class AppSettings {
  final bool locationSharingEnabled;
  final bool autoCallGuardian;
  final String alertSensitivity;
  final bool audioMonitoringEnabled;
  final bool motionMonitoringEnabled;
  final List<GuardianContact> guardianContacts;

  AppSettings({
    this.locationSharingEnabled = true,
    this.autoCallGuardian = false,
    this.alertSensitivity = 'medium',
    this.audioMonitoringEnabled = true,
    this.motionMonitoringEnabled = true,
    List<GuardianContact>? guardianContacts,
  }) : guardianContacts = guardianContacts ?? [];

  Map<String, dynamic> toJson() {
    return {
      'location_sharing_enabled': locationSharingEnabled,
      'auto_call_guardian': autoCallGuardian,
      'alert_sensitivity': alertSensitivity,
      'audio_monitoring_enabled': audioMonitoringEnabled,
      'motion_monitoring_enabled': motionMonitoringEnabled,
      'guardian_contacts': guardianContacts.map((c) => c.toJson()).toList(),
    };
  }

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      locationSharingEnabled: json['location_sharing_enabled'] as bool? ?? true,
      autoCallGuardian: json['auto_call_guardian'] as bool? ?? false,
      alertSensitivity: json['alert_sensitivity'] as String? ?? 'medium',
      audioMonitoringEnabled: json['audio_monitoring_enabled'] as bool? ?? true,
      motionMonitoringEnabled: json['motion_monitoring_enabled'] as bool? ?? true,
      guardianContacts: (json['guardian_contacts'] as List<dynamic>?)
              ?.map((c) => GuardianContact.fromJson(c as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  AppSettings copyWith({
    bool? locationSharingEnabled,
    bool? autoCallGuardian,
    String? alertSensitivity,
    bool? audioMonitoringEnabled,
    bool? motionMonitoringEnabled,
    List<GuardianContact>? guardianContacts,
  }) {
    return AppSettings(
      locationSharingEnabled: locationSharingEnabled ?? this.locationSharingEnabled,
      autoCallGuardian: autoCallGuardian ?? this.autoCallGuardian,
      alertSensitivity: alertSensitivity ?? this.alertSensitivity,
      audioMonitoringEnabled: audioMonitoringEnabled ?? this.audioMonitoringEnabled,
      motionMonitoringEnabled: motionMonitoringEnabled ?? this.motionMonitoringEnabled,
      guardianContacts: guardianContacts ?? this.guardianContacts,
    );
  }

  GuardianContact? get primaryGuardian {
    try {
      return guardianContacts.firstWhere((c) => c.isPrimary && c.isActive);
    } catch (_) {
      return guardianContacts.isNotEmpty ? guardianContacts.first : null;
    }
  }

  List<GuardianContact> get activeGuardians => guardianContacts.where((c) => c.isActive).toList();
}