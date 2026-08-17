# PERSON 1 - Mobile App Demo Guide

## Proactive Guard SIH 2026 - Mobile Demo Flow

### Prerequisites
- Android device/emulator with API level 24+
- Backend API running on `http://10.0.2.2:8000` (for emulator) or actual IP
- Flutter app installed via `flutter build apk --release`

---

## Demo Steps

### 1. Open App
- Launch **Proactive Guard** from app drawer
- App shows login screen

### 2. Login / Enter Name
- Enter your name (e.g., "Priya Sharma")
- Tap **Continue**
- App navigates to Home screen

### 3. Grant Permissions (First Run)
When prompted, grant:
- **Location** → "Allow all the time" (required for GPS tracking)
- **Microphone** → "Allow" (for audio level monitoring)
- **Notifications** → "Allow" (for guardian alerts)

### 4. Configure Guardians (Optional but Recommended)
- Tap **Settings** (gear icon) → **Add Guardian**
- Enter name, phone number, relationship
- Set one as **Primary Guardian**
- Tap back to return to Home

### 5. Start Journey
- Tap **Start Journey** button
- (Optional) Enter destination and notes
- Review monitoring options (Location, Audio, Motion)
- Tap **Start Journey**
- App shows "Journey Active" with live pulse animation

### 6. Live Journey Screen
Auto-navigates to **Live Journey** showing:
- **LIVE MONITORING** badge with pulsing indicator
- Journey duration timer
- Telemetry sent counter
- **Live Telemetry Grid**:
  - GPS Location (lat/lng, accuracy)
  - Audio Level (dB, normalized %)
  - Motion (magnitude, activity %)
  - Network status
- **Risk Assessment** card (if backend returns risk)
- **Guardian Status** - shows configured guardians with "Notified" status
- **Emergency Actions**:
  - Call Primary Guardian
  - Send SOS Alert (shows confirmation dialog)

### 7. Backend Receives Data
- Backend API receives telemetry at `POST /api/v1/telemetry`
- Returns risk assessment: SAFE / MONITOR / HIGH / CRITICAL
- Dashboard (Person 3/4) shows real-time incidents

### 8. Stop Journey
- Tap **Stop Journey** button
- Confirm in dialog
- All monitoring stops
- Returns to Home screen with "No Active Journey"

### 9. Verify Monitoring Stops
- Check Home screen shows "No Active Journey"
- No more telemetry being sent
- Location/Audio/Motion services stopped

---

## Demo Scenarios

### Scenario A: Normal Journey
1. Start journey
2. Walk around - GPS updates, audio/motion show normal levels
3. Risk stays **SAFE**
4. Stop journey

### Scenario B: High Audio Alert
1. Start journey
2. Make loud noise near phone (clap, shout)
3. Audio level spikes > 70 dB
4. Backend may return **MONITOR** or **HIGH**
5. Risk card appears on Live Journey screen

### Scenario C: Emergency SOS
1. Start journey
2. Tap **Send SOS Alert**
3. Confirm dialog
4. Snackbar shows "SOS Alert sent to all guardians!"
4. (In production: triggers actual SMS/call to guardians)

### Scenario D: Permission Denied
1. Deny location permission
2. Try to start journey
3. App shows error: "Location permission is required..."
4. Tap "Open Settings" to grant permission
5. Retry journey start

### Scenario E: Network Failure
1. Start journey
2. Turn on Airplane mode
3. Telemetry fails silently (counter increments)
4. Turn off Airplane mode
5. Telemetry resumes automatically

---

## Key Features to Highlight

| Feature | Implementation |
|---------|---------------|
| Real GPS | `geolocator` package, high accuracy, 10s updates |
| Audio Monitoring | Simulated dB levels (30-85), 5s sampling |
| Motion Detection | Accelerometer, magnitude + variance scoring |
| Telemetry | HTTP POST to `/api/v1/telemetry` every 15s |
| Permissions | Proper handling: denied, permanently denied, service disabled |
| Background | Foreground service + periodic timer |
| Guardians | Local storage, primary guardian, phone validation |
| Settings | Persistent via `shared_preferences` |
| Error Handling | User-friendly messages, no stack traces |

---

## Commands for Manual Testing

```bash
# Run on device/emulator
cd mobile
flutter run --release

# Build APK
flutter build apk --release

# Install APK
flutter install --release

# Run tests
flutter test

# Analyze code
flutter analyze
```

---

## Troubleshooting

| Issue | Solution |
|-------|----------|
| GPS not updating | Enable "Location" in quick settings, grant "Allow all the time" |
| Audio not working | Grant microphone permission, check if other apps use mic |
| Backend connection failed | Check API URL in Settings, ensure backend running on port 8000 |
| Build fails | Run `flutter clean && flutter pub get && flutter build apk` |
| Permissions not persisting | Check Android settings > Apps > Proactive Guard > Permissions |

---

## Files Modified/Created by Person 1

### Core Files
- `mobile/pubspec.yaml` - Dependencies
- `mobile/lib/main.dart` - App entry, navigation, AppState
- `mobile/lib/utils/constants.dart` - Configuration
- `mobile/lib/models/telemetry.dart` - Data models

### Services
- `mobile/lib/services/api.dart` - API communication
- `mobile/lib/services/location.dart` - GPS + permissions
- `mobile/lib/services/audio.dart` - Microphone + decibel simulation
- `mobile/lib/services/motion.dart` - Accelerometer monitoring
- `mobile/lib/services/background_location.dart` - Background tracking

### Screens
- `mobile/lib/screens/login_screen.dart`
- `mobile/lib/screens/home_screen.dart`
- `mobile/lib/screens/start_journey_screen.dart`
- `mobile/lib/screens/live_journey_screen.dart`
- `mobile/lib/screens/safety_status_screen.dart`
- `mobile/lib/screens/settings_screen.dart`

### Android
- `mobile/android/app/src/main/AndroidManifest.xml` - Permissions

---

## Integration Points

| Component | Interface |
|-----------|-----------|
| Backend API | `POST /api/v1/telemetry` with `{user_id, latitude, longitude, motion_score, audio_score, journey_id}` |
| Dashboard | Reads incidents from `GET /incidents` |
| AI Engine | Backend calculates risk from telemetry scores |

---

**Demo Ready!** ✅