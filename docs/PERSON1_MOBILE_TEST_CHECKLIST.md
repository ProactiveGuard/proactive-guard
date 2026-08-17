# PERSON 1 - Mobile App Test Checklist

## Proactive Guard SIH 2026 - Day 3, 4, 5 Mobile Testing

---

## Test Categories

### ✅ App Launch & Navigation
- [ ] App launches without crash
- [ ] Login screen displays correctly
- [ ] Name input validation works (empty, too short)
- [ ] Successful login navigates to Home
- [ ] Home screen shows welcome message
- [ ] Navigation drawer/menu works
- [ ] Settings accessible from Home
- [ ] Back navigation works on all screens
- [ ] App state persists after background/foreground

### ✅ GPS / Location Permission
- [ ] Location permission requested on first journey start
- [ ] "Allow all the time" option available
- [ ] Permission granted → GPS acquires fix
- [ ] Permission denied → User-friendly error
- [ ] Permission permanently denied → Opens app settings
- [ ] GPS disabled → Prompts to enable location services
- [ ] Location accuracy displayed (meters)
- [ ] Location updates every ~10 seconds
- [ ] Background location works (app in background)

### ✅ GPS Disabled / Unavailable
- [ ] Location services OFF → Clear error message
- [ ] "Open Location Settings" button works
- [ ] Re-enabling GPS resumes tracking
- [ ] Indoor/weak GPS → Handles gracefully

### ✅ Audio / Microphone Permission
- [ ] Microphone permission requested (if audio monitoring enabled)
- [ ] Permission granted → Audio monitoring starts
- [ ] Permission denied → Graceful degradation (journey continues without audio)
- [ ] Permission permanently denied → Opens settings
- [ ] Audio sampling every ~5 seconds
- [ ] Decibel level displayed (simulated 30-85 dB)
- [ ] Normalized score 0.0-1.0 displayed
- [ ] Audio monitoring can be toggled in Settings

### ✅ Motion Detection
- [ ] Motion monitoring starts with journey
- [ ] Accelerometer data read
- [ ] Magnitude displayed (m/s²)
- [ ] Normalized score 0.0-1.0 displayed
- [ ] Stationary → Low score (~0.0-0.1)
- [ ] Walking → Medium score (~0.3-0.5)
- [ ] Running/shaking → High score (~0.6-1.0)
- [ ] Motion monitoring can be toggled in Settings

### ✅ Journey Start/Stop Lifecycle
- [ ] Start Journey button on Home
- [ ] Start Journey screen with options
- [ ] Destination/notes optional
- [ ] Monitoring toggles (Location required, Audio/Motion optional)
- [ ] Guardian preview shown
- [ ] Start Journey → API call to backend
- [ ] Journey ID saved locally
- [ ] Live Journey screen auto-opens
- [ ] Pulse animation on "LIVE MONITORING"
- [ ] Journey duration timer running
- [ ] Telemetry counter incrementing
- [ ] Stop Journey button on Live Journey
- [ ] Stop confirmation dialog
- [ ] Stop Journey → All monitoring stops
- [ ] Returns to Home with "No Active Journey"
- [ ] Journey state cleared (ID, telemetry, timers)

### ✅ Telemetry Transmission
- [ ] Telemetry sent every ~15 seconds
- [ ] Payload includes: user_id, lat, lng, motion_score, audio_score, journey_id
- [ ] Success counter increments
- [ ] Backend response displayed (severity, risk score)
- [ ] Risk card appears on Live Journey
- [ ] Network failure → Failure counter increments
- [ ] Network recovery → Auto-resume sending
- [ ] Invalid response → Handled gracefully
- [ ] Server error (5xx) → Handled gracefully
- [ ] Timeout (15s) → Handled gracefully

### ✅ Backend API Integration
- [ ] Health check endpoint works
- [ ] Telemetry endpoint returns risk assessment
- [ ] Incidents endpoint returns list
- [ ] API URL configurable in Settings
- [ ] Test Connection button works
- [ ] Custom API URL persists after restart

### ✅ Settings Screen
- [ ] Guardian contacts list
- [ ] Add Guardian: name, phone, relationship
- [ ] Phone validation (Indian format +91)
- [ ] Set primary guardian
- [ ] Remove guardian with confirmation
- [ ] Primary guardian badge shown
- [ ] Location sharing toggle (required)
- [ ] Auto-call guardian toggle
- [ ] Alert sensitivity dropdown (Low/Medium/High)
- [ ] Audio monitoring toggle
- [ ] Motion monitoring toggle
- [ ] API Configuration section
- [ ] App Info section (version, Flutter version)
- [ ] Danger Zone: Reset all settings
- [ ] Danger Zone: Logout & clear data
- [ ] All settings persist after app restart

### ✅ Guardian Contacts
- [ ] Empty state with "Add Guardian" prompt
- [ ] Primary guardian marked with star/badge
- [ ] Phone number formatting (+91 XXXXX XXXXX)
- [ ] Emergency actions: Call Primary, Send SOS
- [ ] SOS confirmation dialog
- [ ] Guardian notification status shown
- [ ] Guardians persist after app restart

### ✅ Safety Status Screen
- [ ] Overall safety score calculated
- [ ] Score factors: location, audio, motion, guardians, network
- [ ] Permissions status (granted/denied)
- [ ] Monitoring status (active/inactive)
- [ ] Network/API status (success rate, last response)
- [ ] Recent incidents list
- [ ] Device health checks

### ✅ Error Handling
- [ ] Location permission denied → Friendly message
- [ ] GPS disabled → Friendly message + settings link
- [ ] Microphone permission denied → Graceful (no crash)
- [ ] Network unavailable → Friendly message
- [ ] Backend unavailable → Friendly message
- [ ] Invalid server response → Friendly message
- [ ] Journey start failure → Error banner on Home
- [ ] Journey stop failure → Error banner
- [ ] No raw stack traces shown to user

### ✅ Background / App Lifecycle
- [ ] Home → Background → Foreground: Journey continues
- [ ] Live Journey → Background → Foreground: Data updates
- [ ] App restart with active journey → State reset (no orphan)
- [ ] No duplicate timers/streams on navigation
- [ ] Streams/controllers disposed on stop
- [ ] Battery optimization warning shown

### ✅ UI/UX Polish
- [ ] Material 3 design
- [ ] Consistent colors (pink/red theme)
- [ ] Loading states on buttons
- [ ] Empty states with helpful messages
- [ ] Snackbars for actions
- [ ] Dialog confirmations for destructive actions
- [ ] Responsive layout (phone/tablet)
- [ ] Dark mode support (if implemented)
- [ ] Accessibility labels

### ✅ Build & Release
- [ ] `flutter pub get` succeeds
- [ ] `flutter analyze` - no errors (warnings OK)
- [ ] `flutter test` - passes (if tests exist)
- [ ] `flutter build apk --release` succeeds
- [ ] APK installs on device
- [ ] APK runs on device
- [ ] Release mode performance OK

---

## Day-Specific Checks

### Day 3: Core Features
- [ ] Real GPS location with permissions
- [ ] Location telemetry to backend
- [ ] Journey start/stop lifecycle
- [ ] Mobile API service with error handling
- [ ] Mobile error handling (all cases)

### Day 4: Advanced Features
- [ ] Background location monitoring
- [ ] Background audio/decibel monitoring
- [ ] Telemetry integration (GPS + audio + motion)
- [ ] Journey UI (Start, Active, Stop)
- [ ] Guardian settings
- [ ] Settings screen with persistence
- [ ] App state/lifecycle management

### Day 5: Testing & Polish
- [ ] Complete mobile testing (all above)
- [ ] Flutter quality checks (analyze, test)
- [ ] Build Android APK (release)
- [ ] Demo flow documented
- [ ] Setup guide documented
- [ ] Test checklist documented
- [ ] Cleanup: no debug prints, no hardcoded coords, no secrets

---

## Test Results Template

| Test Case | Status | Notes |
|-----------|--------|-------|
| App Launch | [ ] Pass / [ ] Fail | |
| Login Flow | [ ] Pass / [ ] Fail | |
| GPS Permission | [ ] Pass / [ ] Fail | |
| GPS Tracking | [ ] Pass / [ ] Fail | |
| Audio Permission | [ ] Pass / [ ] Fail | |
| Audio Monitoring | [ ] Pass / [ ] Fail | |
| Motion Detection | [ ] Pass / [ ] Fail | |
| Start Journey | [ ] Pass / [ ] Fail | |
| Live Journey UI | [ ] Pass / [ ] Fail | |
| Telemetry Sending | [ ] Pass / [ ] Fail | |
| Backend Response | [ ] Pass / [ ] Fail | |
| Stop Journey | [ ] Pass / [ ] Fail | |
| Settings Persist | [ ] Pass / [ ] Fail | |
| Guardian CRUD | [ ] Pass / [ ] Fail | |
| Background Mode | [ ] Pass / [ ] Fail | |
| Error Handling | [ ] Pass / [ ] Fail | |
| Build Release | [ ] Pass / [ ] Fail | |

---

## Known Issues / Limitations

1. **Audio Recording**: Simulated decibel levels (no actual recording due to build compatibility)
2. **Background Service**: Simplified wrapper; true background needs native implementation
3. **Auto-call Guardian**: UI only; requires `CALL_PHONE` permission and dialer integration
4. **SOS Alert**: UI only; requires SMS gateway or push notification backend
5. **iOS**: Not tested; background modes differ

---

## Sign-off

**Tester**: _______________ **Date**: _______________

**All Critical Tests Pass**: [ ] Yes [ ] No

**Blockers**: ________________________________________

**Ready for Demo**: [ ] Yes [ ] No