# Final Deployment Checklist — Day 3 Complete

## Overview
This checklist confirms all deployment configurations are ready for SIH 2026 submission. Run through each item before final submission.

---

## Backend Deployment (Render) ✅

### Configuration
- [ ] Repository connected to Render
- [ ] Root Directory: `backend`
- [ ] Build Command: `pip install -r requirements.txt`
- [ ] Start Command: `uvicorn app.main:app --host 0.0.0.0 --port 10000`
- [ ] Region: Singapore (or closest)
- [ ] Plan: Free (sufficient for demo)

### Environment Variables (Render Dashboard)
- [ ] `SUPABASE_URL` = `https://<project>.supabase.co`
- [ ] `SUPABASE_SERVICE_KEY` = `<service-role-key>` (Secret)
- [ ] `GEMINI_API_KEY` = `<gemini-key>` (Secret)
- [ ] `CORS_ORIGINS` = `https://<vercel-app>.vercel.app,http://localhost:3000`
- [ ] `ENVIRONMENT` = `production`
- [ ] `LOG_LEVEL` = `info`

### Verification
- [ ] `GET /ping` returns 200
- [ ] `GET /docs` shows Swagger UI
- [ ] `POST /api/v1/telemetry` works
- [ ] `GET /api/v1/incidents` returns data from Supabase
- [ ] CORS allows Vercel origin
- [ ] Backend URL: `https://<name>.onrender.com` recorded

---

## Dashboard Deployment (Vercel) ✅

### Configuration
- [ ] Repository connected to Vercel
- [ ] Root Directory: `dashboard`
- [ ] Framework: Next.js (auto-detected)
- [ ] Build Command: `npm run build`
- [ ] Output Directory: `.next`

### Environment Variables (Vercel Dashboard)
- [ ] `NEXT_PUBLIC_SUPABASE_URL` = `https://<project>.supabase.co`
- [ ] `NEXT_PUBLIC_SUPABASE_ANON_KEY` = `<anon-key>`
- [ ] `NEXT_PUBLIC_API_BASE_URL` = `https://<render-backend>.onrender.com`
- [ ] `NEXT_PUBLIC_MAP_TILE_URL` = `https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png`

### Verification
- [ ] Dashboard loads at `https://<name>.vercel.app`
- [ ] Incident list displays
- [ ] LiveMap renders with markers
- [ ] Realtime updates work (Supabase Realtime)
- [ ] Detail page `/incidents/[id]` works
- [ ] Dashboard URL recorded

---

## Mobile App Configuration ✅

### Constants Updated (`mobile/lib/utils/constants.dart`)
- [ ] `apiBaseUrl` = `https://<render-backend>.onrender.com`
- [ ] `dashboardBaseUrl` = `https://<vercel-app>.vercel.app`
- [ ] All endpoints correct

### Build Verification
- [ ] `flutter build apk --release` succeeds
- [ ] APK installs on test device
- [ ] App connects to deployed backend
- [ ] SOS flow works end-to-end

---

## Database (Supabase) ✅

### Tables Created
- [ ] `incidents` table with all columns
- [ ] `journeys` table with all columns
- [ ] `telemetry_log` table (optional)
- [ ] RLS policies configured
- [ ] Realtime enabled: `ALTER PUBLICATION supabase_realtime ADD TABLE incidents;`

### Verification
- [ ] Backend can read/write incidents
- [ ] Dashboard receives realtime updates
- [ ] Sample data visible in both

---

## AI Engine ✅

### Configuration
- [ ] `backend/ai-engine/risk.py` integrated in backend
- [ ] `app/services/llm.py` calls Gemini API
- [ ] Fallback: Rule-based works without Gemini key
- [ ] Risk scoring: 0-100, 4 severity levels

### Verification
- [ ] `python -m backend.ai-engine.risk` runs test scenarios
- [ ] Live telemetry → risk score → incident creation works
- [ ] AI summary generated for CRITICAL incidents

---

## Integration Verification ✅

### End-to-End Test (Run INTEGRATION_TEST_CHECKLIST.md)
- [ ] Step 1: Backend starts, health check passes
- [ ] Step 2: Dashboard loads, shows incidents
- [ ] Step 3: Flutter app launches, connects to backend
- [ ] Step 4: Press SOS / Simulate distress
- [ ] Step 5: Backend receives request, logs show processing
- [ ] Step 6: New incident in Supabase with correct data
- [ ] Step 7: Dashboard shows new incident + map marker

---

## Failsafe Demo ✅

### Video Recording
- [ ] `video/demo_30s.mp4` recorded and verified
- [ ] `video/full_walkthrough_3min.mp4` recorded and verified
- [ ] Videos play offline on laptop
- [ ] Videos copied to 2 USB drives
- [ ] Videos uploaded to Google Drive
- [ ] Narration script printed

---

## Team Communication ✅

### URLs Shared
| Member | Backend URL | Dashboard URL | Status |
|--------|-------------|---------------|--------|
| Member 1 (Mobile) | ✅ | ✅ | |
| Member 2 (Dashboard) | ✅ | ✅ (self) | |
| Member 4 (Backend) | ✅ (self) | ✅ | |
| Member 6 (Integration) | ✅ | ✅ | |

### CORS Updated
- [ ] Backend `CORS_ORIGINS` includes Vercel dashboard URL
- [ ] Verified: No CORS errors in browser console

---

## Documentation ✅

### Deployment Docs Created
- [ ] `docs/VERCEL_DEPLOYMENT.md` complete
- [ ] `docs/RENDER_DEPLOYMENT.md` complete
- [ ] `docs/FAILSAFE_DEMO.md` complete
- [ ] This checklist complete

---

## Sign-Off

| Role | Name | Signature | Date |
|------|------|-----------|------|
| **Member 6 (Integration Lead)** | | | |
| **Member 4 (Backend Lead)** | | | |
| **Member 2 (Dashboard Lead)** | | | |
| **Member 1 (Mobile Lead)** | | | |

---

## Deployment URLs Record

```
BACKEND_URL=https://<name>.onrender.com
BACKEND_HEALTH=https://<name>.onrender.com/ping
BACKEND_DOCS=https://<name>.onrender.com/docs

DASHBOARD_URL=https://<name>.vercel.app
DASHBOARD_INCIDENTS=https://<name>.vercel.app

SUPABASE_URL=https://<project>.supabase.co
SUPABASE_DASHBOARD=https://supabase.com/dashboard/project/<project>

GITHUB_REPO=https://github.com/<org>/proactive-guard
```

---

*Last Updated: Day 3 — Member 6*
*Status: Ready for Day 4*