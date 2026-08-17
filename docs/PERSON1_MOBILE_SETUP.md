# PERSON 1 - Mobile App Setup Guide

## Proactive Guard SIH 2026 - Flutter Mobile App

---

## Requirements

### Flutter Version
- **Flutter SDK**: 3.13.0 or higher
- **Dart SDK**: 3.3.0 or higher (bundled with Flutter)
- **Android SDK**: API level 24+ (Android 7.0)
- **Java**: JDK 17 (for Gradle)

### Verify Installation
```bash
flutter doctor
flutter --version
```

Expected output:
```
Flutter 3.13.x • channel stable • ...
Framework • revision ...
Engine • revision ...
Tools • Dart 3.3.x • DevTools 2.x.x
```

---

## Installation

### 1. Clone Repository
```bash
git clone <repository-url>
cd women_safety_app
```

### 2. Install Dependencies
```bash
flutter pub get
```

### 3. Configure API Endpoint (Optional)
The app defaults to `http://10.0.2.2:8000` for Android emulator.
To change:
1. Open app → Settings → API Configuration
2. Enter your backend IP (e.g., `http://192.168.1.100:8000`)
3. Tap "Test Connection" to verify
4. Tap "Save"

---

## Android Permissions

The following permissions are declared in `AndroidManifest.xml`:

### Required (App will not work without these)
| Permission | Purpose |
|------------|---------|
| `ACCESS_FINE_LOCATION` | Precise GPS tracking |
| `ACCESS_COARSE_LOCATION` | Fallback location |
| `ACCESS_BACKGROUND_LOCATION` | Background tracking |
| `FOREGROUND_SERVICE` | Foreground service for monitoring |
| `FOREGROUND_SERVICE_LOCATION` | Location foreground service type |
| `INTERNET` | API communication |
| `ACCESS_NETWORK_STATE` | Network detection |
| `RECORD_AUDIO` | Microphone access for audio monitoring |
| `POST_NOTIFICATIONS` | Guardian alerts (Android 13+) |

### Optional
| Permission | Purpose |
|------------|---------|
| `CALL_PHONE` | Auto-call primary guardian |
| `READ_CONTACTS` | Import contacts as guardians |
| `BODY_SENSORS` | Motion sensor access |
| `ACTIVITY_RECOGNITION` | Activity detection |
| `VIBRATE` | Haptic feedback on alerts |
| `WAKE_LOCK` | Keep CPU awake during monitoring |
| `RECEIVE_BOOT_COMPLETED` | Auto-start on boot |

---

## Running the App

### Development Mode (Hot Reload)
```bash
flutter run
```

### Release Mode (Production Build)
```bash
flutter run --release
```

### On Physical Device
1. Enable **USB Debugging** in Developer Options
2. Connect via USB
3. Run `flutter devices` to verify
4. Run `flutter run --release`

### On Emulator
```bash
flutter emulators --launch <emulator_id>
flutter run --release
```

---

## Building APK

### Release APK
```bash
flutter build apk --release
```

**Output**: `build/app/outputs/flutter-apk/app-release.apk` (~44 MB)

### Install APK on Device
```bash
flutter install --release
# OR manually transfer and install the APK
```

### App Bundle (for Play Store)
```bash
flutter build appbundle --release
```

**Output**: `build/app/outputs/bundle/release/app-release.aab`

---

## Project Structure

```
mobile/
├── android/                 # Android native code
│   └── app/src/main/
│       └── AndroidManifest.xml
├── lib/
│   ├── main.dart           # App entry point, navigation, AppState
│   ├── utils/
│   │   └── constants.dart  # API URLs, intervals, thresholds
│   ├── models/
│   │   └── telemetry.dart  # Data models (Telemetry, Journey, Guardian, Settings)
│   ├── services/
│   │   ├── api.dart        # HTTP client, auth, error handling
│   │   ├── location.dart   # GPS, permissions, background
│   │   ├── audio.dart      # Microphone, decibel simulation
│   │   ├── motion.dart     # Accelerometer, movement scoring
│   │   └── background_location.dart  # Background tracking wrapper
│   └── screens/
│       ├── login_screen.dart
│       ├── home_screen.dart
│       ├── start_journey_screen.dart
│       ├── live_journey_screen.dart
│       ├── safety_status_screen.dart
│       └── settings_screen.dart
├── pubspec.yaml            # Dependencies
└── test/                   # Unit/widget tests
```

---

## Key Dependencies

| Package | Version | Purpose |
|---------|---------|---------|
| `flutter` | SDK | Framework |
| `http` | ^1.2.0 | HTTP client |
| `geolocator` | ^13.0.1 | GPS location |
| `permission_handler` | ^11.3.1 | Runtime permissions |
| `shared_preferences` | ^2.3.2 | Local storage |
| `provider` | ^6.1.2 | State management |
| `audioplayers` | ^6.1.0 | Audio playback |
| `flutter_background_service` | ^5.1.0 | Background execution |
| `sensors_plus` | ^6.1.0 | Accelerometer |
| `connectivity_plus` | ^6.1.0 | Network state |
| `uuid` | ^4.4.0 | Unique IDs |
| `intl` | ^0.19.0 | Date formatting |

---

## Configuration

### API Base URL
Default: `http://10.0.2.2:8000` (Android emulator localhost)

Change via:
1. Settings → API Configuration
2. Or set in `lib/utils/constants.dart`:
   ```dart
   static const String apiBaseUrl = 'http://YOUR_IP:8000';
   ```

### Thresholds (in constants.dart)
```dart
static const double audioThresholdDb = 70.0;  // Alert above this
static const double motionThreshold = 0.5;    // Movement sensitivity
static const Duration locationUpdateInterval = Duration(seconds: 10);
static const Duration telemetrySendInterval = Duration(seconds: 15);
```

### Alert Sensitivity Levels
- **Low**: Higher threshold, fewer alerts
- **Medium**: Balanced (default)
- **High**: Lower threshold, more alerts

---

## Backend Integration

### Expected API Endpoints
| Method | Endpoint | Body | Response |
|--------|----------|------|----------|
| POST | `/api/v1/telemetry` | `{user_id, latitude, longitude, motion_score, audio_score, journey_id}` | `{incident_id, severity, risk_score, summary}` |
| GET | `/incidents` | - | `[{incident_id, severity, risk_score, lat, lng, summary}]` |
| GET | `/ping` | - | `{status, message}` |

### Telemetry Format
```json
{
  "user_id": "user_1234567890",
  "latitude": 19.123456,
  "longitude": 72.890123,
  "motion_score": 0.23,
  "audio_score": 0.45,
  "timestamp": "2026-08-17T10:30:00.000Z",
  "journey_id": "journey-uuid"
}
```

### Severity Levels
- **SAFE** (0-30): Normal
- **MONITOR** (31-60): Elevated
- **HIGH** (61-80): Concerning
- **CRITICAL** (81-100): Emergency

---

## Troubleshooting

### Build Issues

| Error | Solution |
|-------|----------|
| `Namespace not specified` | Update record package or remove it |
| `Kotlin Gradle Plugin` warning | Upgrade plugins or ignore (non-blocking) |
| `License not accepted` | Run `flutter doctor --android-licenses` |
| `Gradle build failed` | Run `flutter clean && flutter pub get` |

### Runtime Issues

| Issue | Solution |
|-------|----------|
| GPS not working | Grant "Allow all the time" location permission |
| Audio not monitoring | Grant microphone permission |
| Network errors | Check API URL, backend running, firewall |
| Background not working | Disable battery optimization for app |
| Permissions reset | Check Android Settings > Apps > Permissions |

### Common Commands
```bash
# Clean build
flutter clean && flutter pub get

# Analyze code
flutter analyze

# Run tests
flutter test

# Check dependencies
flutter pub outdated

# Upgrade dependencies
flutter pub upgrade
```

---

## Testing Checklist

See `PERSON1_MOBILE_TEST_CHECKLIST.md` for comprehensive test cases.

---

## Security Notes

- **No hardcoded secrets** - API URL configurable at runtime
- **Local storage only** - Guardian contacts, settings stored locally via `shared_preferences`
- **HTTPS recommended** - Use HTTPS in production (configure in Settings)
- **Permission minimal** - Only requests permissions when needed
- **No audio recording** - Simulates decibel levels, no actual audio stored

---

## Team Integration

| Person | Responsibility | Integration |
|--------|----------------|-------------|
| Person 1 | Mobile App | ✅ Complete |
| Person 2 | Backend API | `POST /api/v1/telemetry` |
| Person 3 | Dashboard | Reads from `GET /incidents` |
| Person 4 | AI Engine | Backend calculates risk |
| Person 5 | Deployment | Docker, CI/CD |
| Person 6 | Integration | Coordinates all |

---

## Support

For issues:
1. Check `flutter doctor` output
2. Review `flutter analyze` warnings
3. Check Android logcat: `adb logcat | grep flutter`
4. Verify backend is running: `curl http://10.0.2.2:8000/ping`

---

**Setup Complete!** ✅