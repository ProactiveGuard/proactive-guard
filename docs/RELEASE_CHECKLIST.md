# Release Checklist — Proactive Guard SIH 2026

## Purpose
Final integration checks and commands to run before submission. This is the "go/no-go" checklist.

---

## Pre-Release Commands (Run in Order)

### 1. Repository Sanity
```bash
# Check git status
git status

# Verify current branch
git branch

# Check for uncommitted secrets
git log --all --full-history --oneline -- .env .env.* *.key *.secret service-account.json google-services.json

# Should return NO RESULTS. If results found → ROTATE SECRETS IMMEDIATELY
```

### 2. Backend Verification
```bash
cd backend

# Install deps
pip install -r requirements.txt

# Run tests
python -m ai_engine.risk

# Start server (background)
uvicorn app.main:app --host 0.0.0.0 --port 8000 &
BACKEND_PID=$!

# Wait for startup
sleep 3

# Health check
curl -s http://localhost:8000/ping | jq .

# Test telemetry endpoint
curl -s -X POST http://localhost:8000/api/v1/telemetry \
  -H "Content-Type: application/json" \
  -d '{"user_id":"test","latitude":19.123,"longitude":72.891,"motion_score":0.8,"audio_score":0.9}' | jq .

# Test incidents list
curl -s http://localhost:8000/api/v1/incidents | jq .

# Kill test server
kill $BACKEND_PID
```

**Expected:** All commands return 200, valid JSON, risk_score >75 for test payload.

### 3. Dashboard Verification
```bash
cd dashboard

# Install deps
npm ci

# Build (catches TypeScript errors)
npm run build

# Start dev server (background)
npm run dev &
DASHBOARD_PID=$!

# Wait for startup
sleep 5

# Health check
curl -s -o /dev/null -w "%{http_code}" http://localhost:3000
# Should return 200

# Kill test server
kill $DASHBOARD_PID
```

**Expected:** Build succeeds, dev server returns 200.

### 4. Mobile Verification
```bash
cd mobile

# Get dependencies
flutter pub get

# Analyze (catches Dart errors)
flutter analyze

# Build release APK
flutter build apk --release

# Verify APK exists
ls -la build/app/outputs/flutter-apk/app-release.apk

# Optional: Install on connected device
# flutter install
```

**Expected:** `flutter analyze` shows no errors, APK builds successfully.

### 5. Supabase Verification
```bash
# Check tables exist (run in Supabase SQL Editor)
# SELECT * FROM incidents LIMIT 5;
# SELECT * FROM journeys LIMIT 5;

# Check realtime publication
# SELECT * FROM pg_publication_tables WHERE pubname = 'supabase_realtime';
# Should show 'incidents' table
```

**Expected:** Tables accessible, realtime enabled.

### 6. End-to-End Integration Test
```bash
# 1. Start backend (terminal 1)
cd backend && uvicorn app.main:app --reload --port 8000

# 2. Start dashboard (terminal 2)
cd dashboard && npm run dev

# 3. Run mobile (terminal 3)
cd mobile && flutter run -d <device-id>

# 4. In mobile app:
#    - Start journey
#    - Simulate distress (shake + audio)
#    - Verify: Backend logs show CRITICAL incident
#    - Verify: Dashboard shows red marker
#    - Verify: Supabase has new incident row

# 5. Run full checklist: docs/INTEGRATION_TEST_CHECKLIST.md
```

---

## Release Gates (All Must Pass)

| Gate | Command/Check | Pass Criteria |
|------|---------------|---------------|
| **Gate 1: Secrets** | `git log --all --full-history -- .env` | No results |
| **Gate 2: Backend Tests** | `python -m ai_engine.risk` | All scenarios pass |
| **Gate 3: Backend Build** | `pip install -r requirements.txt` | No errors |
| **Gate 4: Dashboard Build** | `npm run build` | Exit code 0 |
| **Gate 5: Mobile Analyze** | `flutter analyze` | No errors |
| **Gate 6: Mobile Build** | `flutter build apk --release` | APK generated |
| **Gate 7: E2E Integration** | Manual test per `INTEGRATION_TEST_CHECKLIST.md` | All 7 steps pass |
| **Gate 8: Deployed Backend** | `curl <render-url>/ping` | 200 OK |
| **Gate 9: Deployed Dashboard** | `curl -I <vercel-url>` | 200 OK |
| **Gate 10: Demo Video** | Play `video/demo_30s.mp4` | Plays offline |
| **Gate 11: APK Install** | `adb install submission/apk/app-release.apk` | Success |
| **Gate 12: Tag Created** | `git tag -l v1.0-submission` | Tag exists |

---

## Release Commands (After All Gates Pass)

### Create Release Tag
```bash
# Ensure on main/develop with latest
git checkout develop
git pull origin develop

# Create annotated tag
git tag -a v1.0-submission -m "SIH 2026 Submission - Proactive Guard v1.0

Features:
- Proactive sensor monitoring (audio + motion + GPS)
- AI Risk Engine (rule-based + Gemini LLM)
- Real-time command center (Next.js + Leaflet)
- Supabase PostgreSQL with Realtime
- Flutter mobile app with offline support
- Render + Vercel + Supabase deployment

Team: 6 members (Mobile, Dashboard, Sensors, Backend, AI, Integration)"

# Push tag
git push origin v1.0-submission
```

### Verify Tag on GitHub
- Go to: `https://github.com/<org>/proactive-guard/releases/tag/v1.0-submission`
- Verify tag visible, commit correct

### Create GitHub Release (Optional)
```bash
# Using GitHub CLI
gh release create v1.0-submission \
  --title "Proactive Guard v1.0 - SIH 2026 Submission" \
  --notes-file RELEASE_NOTES.md \
  submission/apk/app-release.apk \
  submission/video/demo_30s.mp4 \
  submission/video/full_walkthrough_3min.mp4
```

---

## Post-Release Verification

### 1. Clone Fresh & Verify
```bash
# In temp directory
git clone https://github.com/<org>/proactive-guard.git verify-release
cd verify-release
git checkout v1.0-submission

# Verify structure
ls -la submission/

# Verify key files
cat submission/docs/README.md | head -20
```

### 2. Deploy from Tag (CI/CD Test)
- Trigger Render deploy from `v1.0-submission` tag
- Trigger Vercel deploy from `v1.0-submission` tag
- Verify both deployments succeed

### 3. Final Demo Run
- Run complete demo from `DEMO_SCRIPT.md`
- Time it: Must be ≤2 minutes
- Record final video if needed

---

## Rollback Plan

If critical issue found after tag:

```bash
# 1. Delete tag locally
git tag -d v1.0-submission

# 2. Delete tag remote
git push origin --delete v1.0-submission

# 3. Fix issue on develop
git checkout develop
# ... fix ...

# 4. Re-tag
git tag -a v1.0-submission -m "SIH 2026 Submission - Proactive Guard v1.0 (fixed)"
git push origin v1.0-submission
```

---

## Sign-Off

| Check | Verified By | ✅ | Timestamp |
|-------|-------------|----|-----------|
| Gate 1: No Secrets | | | |
| Gate 2: Backend Tests | | | |
| Gate 3: Backend Build | | | |
| Gate 4: Dashboard Build | | | |
| Gate 5: Mobile Analyze | | | |
| Gate 6: Mobile Build | | | |
| Gate 7: E2E Integration | | | |
| Gate 8: Deployed Backend | | | |
| Gate 9: Deployed Dashboard | | | |
| Gate 10: Demo Video | | | |
| Gate 11: APK Install | | | |
| Gate 12: Tag Created | | | |
| **RELEASE APPROVED** | **Member 6** | | |

---

*Run this checklist on Day 5 morning before final submission.*
*Last Updated: Day 5 — Member 6*