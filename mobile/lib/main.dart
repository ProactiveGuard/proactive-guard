import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/start_journey_screen.dart';
import 'screens/live_journey_screen.dart';
import 'screens/safety_status_screen.dart';
import 'screens/settings_screen.dart';
import 'services/api.dart';
import 'services/location.dart';
import 'services/audio.dart';
import 'services/motion.dart';
import 'theme/app_theme.dart';
import 'models/telemetry.dart';
import 'utils/constants.dart';

class AppState extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  final LocationService _locationService = LocationService();
  final AudioMonitorService _audioService = AudioMonitorService();
  final MotionService _motionService = MotionService();

  ApiService get apiService => _apiService;
  LocationService get locationService => _locationService;
  AudioMonitorService get audioService => _audioService;
  MotionService get motionService => _motionService;

  String? _userId;
  String? _userName;
  bool _isLoggedIn = false;
  bool _isLoading = false;
  String? _errorMessage;

  // Journey State
  Journey? _activeJourney;
  bool _isJourneyActive = false;
  String? _journeyError;

  // Telemetry State
  LocationData? _lastLocation;
  AudioData? _lastAudioData;
  MotionData? _lastMotionData;
  IncidentResponse? _lastIncidentResponse;
  int _telemetrySentCount = 0;
  int _telemetryFailedCount = 0;

  // Settings
  AppSettings _settings = AppSettings();

  // Streams
  StreamSubscription<LocationData>? _locationSubscription;
  StreamSubscription<AudioData>? _audioSubscription;
  StreamSubscription<MotionData>? _motionSubscription;
  Timer? _telemetryTimer;

  String? get userId => _userId;
  String? get userName => _userName;
  bool get isLoggedIn => _isLoggedIn;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Journey? get activeJourney => _activeJourney;
  bool get isJourneyActive => _isJourneyActive;
  String? get journeyError => _journeyError;

  LocationData? get lastLocation => _lastLocation;
  AudioData? get lastAudioData => _lastAudioData;
  MotionData? get lastMotionData => _lastMotionData;
  IncidentResponse? get lastIncidentResponse => _lastIncidentResponse;
  int get telemetrySentCount => _telemetrySentCount;
  int get telemetryFailedCount => _telemetryFailedCount;

  AppSettings get settings => _settings;

  AppState() {
    _initialize();
  }

  Future<void> _initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _apiService.initialize();
      await _loadSettings();
      await _checkExistingJourney();
      
      _userId = _apiService.userId;
      _isLoggedIn = true;
    } catch (e) {
      _errorMessage = 'Failed to initialize: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final settingsJson = prefs.getString('app_settings');
    if (settingsJson != null) {
      _settings = AppSettings.fromJson(
        Map<String, dynamic>.from(json.decode(settingsJson))
      );
    }
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('app_settings', json.encode(_settings.toJson()));
  }

  Future<void> _checkExistingJourney() async {
    final prefs = await SharedPreferences.getInstance();
    final journeyId = prefs.getString(AppConstants.journeyIdKey);
    final isActive = prefs.getBool(AppConstants.isJourneyActiveKey) ?? false;
    
    if (isActive && journeyId != null) {
      // Journey was active, but we need to verify with backend
      // For now, reset the state as we can't resume without backend support
      await prefs.setBool(AppConstants.isJourneyActiveKey, false);
      await prefs.remove(AppConstants.journeyIdKey);
    }
  }

  Future<bool> login(String name) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      if (name.trim().isEmpty) {
        throw Exception('Please enter your name');
      }
      
      _userName = name.trim();
      _userId = 'user_${DateTime.now().millisecondsSinceEpoch}';
      await _apiService.setUserId(_userId!);
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppConstants.userNameKey, _userName!);
      
      _isLoggedIn = true;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await stopJourney();
    _isLoggedIn = false;
    _userName = null;
    _userId = null;
    _activeJourney = null;
    notifyListeners();
  }

  Future<bool> startJourney() async {
    if (_isJourneyActive) return false;
    
    _isLoading = true;
    _journeyError = null;
    notifyListeners();

    try {
      // Check location permission
      final locStatus = await _locationService.checkPermissionStatus();
      if (!locStatus.isGranted) {
        final requestStatus = await _locationService.requestPermission();
        if (!requestStatus.isGranted) {
          throw Exception(requestStatus.errorMessage ?? AppConstants.errorLocationPermissionDenied);
        }
      }

      // Check audio permission if enabled
      if (_settings.audioMonitoringEnabled) {
        final audioStatus = await _audioService.checkPermissionStatus();
        if (!audioStatus.isGranted) {
          final requestStatus = await _audioService.requestPermission();
          if (!requestStatus.isGranted) {
            // Don't block journey start, just log warning
            if (AppConstants.enableDebugLogs) {
              debugPrint('Audio permission not granted: ${requestStatus.errorMessage}');
            }
          }
        }
      }

      // Create new journey
      _activeJourney = Journey(userId: _userId!);
      _isJourneyActive = true;

      // Save journey state
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppConstants.journeyIdKey, _activeJourney!.id);
      await prefs.setBool(AppConstants.isJourneyActiveKey, true);

      // Start monitoring services
      await _locationService.startMonitoring(journeyId: _activeJourney!.id);
      if (_settings.audioMonitoringEnabled) {
        await _audioService.startMonitoring(journeyId: _activeJourney!.id);
      }
      if (_settings.motionMonitoringEnabled) {
        await _motionService.startMonitoring(journeyId: _activeJourney!.id);
      }

      // Subscribe to streams
      _subscribeToStreams();

      // Start periodic telemetry sending
      _startTelemetryTimer();

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _journeyError = e.toString();
      _isLoading = false;
      _isJourneyActive = false;
      _activeJourney = null;
      notifyListeners();
      return false;
    }
  }

  Future<void> stopJourney() async {
    if (!_isJourneyActive) return;

    _isLoading = true;
    _journeyError = null;
    notifyListeners();

    try {
      // Stop telemetry timer
      _telemetryTimer?.cancel();
      _telemetryTimer = null;

      // Unsubscribe from streams
      _unsubscribeFromStreams();

      // Stop monitoring services
      await _locationService.stopMonitoring();
      await _audioService.stopMonitoring();
      await _motionService.stopMonitoring();

      // Clear journey state
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(AppConstants.isJourneyActiveKey, false);
      await prefs.remove(AppConstants.journeyIdKey);

      _activeJourney = null;
      _isJourneyActive = false;
      _lastLocation = null;
      _lastAudioData = null;
      _lastMotionData = null;
      _lastIncidentResponse = null;
      _telemetrySentCount = 0;
      _telemetryFailedCount = 0;

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _journeyError = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  void _subscribeToStreams() {
    _locationSubscription?.cancel();
    _locationSubscription = _locationService.locationStream.listen((data) {
      _lastLocation = data;
      _activeJourney?.addTelemetry(TelemetryData(
        userId: _userId!,
        latitude: data.latitude,
        longitude: data.longitude,
        motionScore: _lastMotionData?.normalizedScore ?? 0.0,
        audioScore: _lastAudioData?.normalizedScore ?? 0.0,
        journeyId: _activeJourney?.id,
      ));
      notifyListeners();
    });

    _audioSubscription?.cancel();
    _audioSubscription = _audioService.audioStream.listen((data) {
      _lastAudioData = data;
      notifyListeners();
    });

    _motionSubscription?.cancel();
    _motionSubscription = _motionService.motionStream.listen((data) {
      _lastMotionData = data;
      notifyListeners();
    });
  }

  void _unsubscribeFromStreams() {
    _locationSubscription?.cancel();
    _locationSubscription = null;
    _audioSubscription?.cancel();
    _audioSubscription = null;
    _motionSubscription?.cancel();
    _motionSubscription = null;
  }

  void _startTelemetryTimer() {
    _telemetryTimer?.cancel();
    _telemetryTimer = Timer.periodic(AppConstants.telemetrySendInterval, (_) {
      _sendTelemetry();
    });
  }

  Future<void> _sendTelemetry() async {
    if (!_isJourneyActive || _lastLocation == null) return;

    try {
      final telemetry = TelemetryData(
        userId: _userId!,
        latitude: _lastLocation!.latitude,
        longitude: _lastLocation!.longitude,
        motionScore: _lastMotionData?.normalizedScore ?? 0.0,
        audioScore: _lastAudioData?.normalizedScore ?? 0.0,
        journeyId: _activeJourney?.id,
      );

      final response = await _apiService.sendTelemetry(telemetry);
      _lastIncidentResponse = response;
      _telemetrySentCount++;
      
      if (AppConstants.enableDebugLogs) {
        debugPrint('Telemetry sent: ${response.severity} (Risk: ${response.riskScore})');
      }
    } catch (e) {
      _telemetryFailedCount++;
      if (AppConstants.enableDebugLogs) {
        debugPrint('Telemetry failed: $e');
      }
    }
    notifyListeners();
  }

  // Public method to manually trigger telemetry send
  Future<void> sendTelemetryNow() async {
    await _sendTelemetry();
  }

  Future<void> updateSettings(AppSettings newSettings) async {
    _settings = newSettings;
    await _saveSettings();
    notifyListeners();
  }

  Future<void> addGuardianContact(GuardianContact contact) async {
    final contacts = List<GuardianContact>.from(_settings.guardianContacts);
    contacts.add(contact);
    await updateSettings(_settings.copyWith(guardianContacts: contacts));
  }

  Future<void> removeGuardianContact(String contactId) async {
    final contacts = _settings.guardianContacts
        .where((c) => c.id != contactId)
        .toList();
    await updateSettings(_settings.copyWith(guardianContacts: contacts));
  }

  Future<void> setPrimaryGuardian(String contactId) async {
    final contacts = _settings.guardianContacts.map((c) {
      return c.copyWith(isPrimary: c.id == contactId);
    }).toList();
    await updateSettings(_settings.copyWith(guardianContacts: contacts));
  }

  void clearError() {
    _errorMessage = null;
    _journeyError = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _telemetryTimer?.cancel();
    _unsubscribeFromStreams();
    _locationService.dispose();
    _audioService.dispose();
    _motionService.dispose();
    _apiService.close();
    super.dispose();
  }
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ChangeNotifierProvider(
      create: (_) => AppState(),
      child: const ProactiveGuardApp(),
    ),
  );
}

class ProactiveGuardApp extends StatelessWidget {
  const ProactiveGuardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const AuthWrapper(),
      routes: {
        '/home': (_) => const HomeScreen(),
        '/start_journey': (_) => const StartJourneyScreen(),
        '/live_journey': (_) => const LiveJourneyScreen(),
        '/safety_status': (_) => const SafetyStatusScreen(),
        '/settings': (_) => const SettingsScreen(),
      },
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, _) {
        if (appState.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        
        if (appState.isLoggedIn) {
          return const HomeScreen();
        }
        
        return const LoginScreen();
      },
    );
  }
}
