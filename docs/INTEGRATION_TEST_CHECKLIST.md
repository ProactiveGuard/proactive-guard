# Integration Test Checklist

## Overview
This checklist verifies end-to-end integration between all Proactive Guard components:
- Flutter Mobile App (Member 1)
- FastAPI Backend (Member 4)
- Next.js Dashboard (Member 2)
- Supabase Database
- AI Risk Engine (Member 5)

---

## Prerequisites

### Environment Setup
- [ ] All team members have pulled latest `main` branch
- [ ] `.env` files configured for each service (see `.env.example` files)
- [ ] Supabase project created and credentials shared
- [ ] Gemini API key configured in backend

### Service URLs (Local Development)
| Service | Default URL | Health Check |
|---------|-------------|--------------|
| FastAPI Backend | http://localhost:8000 | GET `/ping` |
| Next.js Dashboard | http://localhost:3000 | Load homepage |
| Supabase | https://xxx.supabase.co | Dashboard accessible |
| Flutter App | Physical device/emulator | App launches |

---

## Integration Test Steps

### Step 1: Start Backend + Supabase (Member 4)
- [ ] Run backend: `cd backend && uvicorn app.main:app --reload --port 8000`
- [ ] Verify health: `curl http://localhost:8000/ping`
- [ ] Expected: `{"status": "I am ok", "message": "Proactive Guard API is running..."}`
- [ ] Verify Supabase connection in backend logs
- [ ] Check Supabase dashboard for `incidents` table existence

### Step 2: Start Dashboard (Member 2)
- [ ] Run dashboard: `cd dashboard && npm run dev`
- [ ] Open http://localhost:3000
- [ ] Verify dashboard loads without console errors
- [ ] Check Network tab: dashboard fetches `/incidents` from backend
- [ ] Verify sample incidents display in incident list

### Step 3: Start Flutter App (Member 1)
- [ ] Run Flutter: `cd mobile && flutter run`
- [ ] App launches on device/emulator
- [ ] Verify backend URL in `lib/utils/constants.dart` points to `http://localhost:8000` (or ngrok URL)
- [ ] Login/navigate to journey screen

### Step 4: Press SOS (Member 1)
- [ ] Start a journey in Flutter app
- [ ] Press SOS button
- [ ] Verify app shows "SOS Sent" confirmation
- [ ] Check app logs for POST to `/api/v1/telemetry` or `/api/v1/incidents/sos`

### Step 5: Verify Backend Receives Request
- [ ] Check backend terminal logs
- [ ] Look for: `POST /api/v1/telemetry` or `POST /api/v1/incidents/sos`
- [ ] Verify request payload contains: user_id, latitude, longitude, audio_score, motion_score
- [ ] Verify response returns `incident_id`, `severity`, `risk_score`, `summary`

### Step 6: Verify New Incident in Supabase
- [ ] Open Supabase Dashboard → Table Editor → `incidents`
- [ ] Verify new row inserted with:
  - [ ] `incident_id` matches backend response
  - [ ] `severity` matches risk assessment (SAFE/MONITOR/HIGH RISK/CRITICAL)
  - [ ] `risk_score` numeric value (0-100)
  - [ ] `latitude`, `longitude` populated
  - [ ] `summary` text present
  - [ ] `created_at` timestamp recent

### Step 7: Verify Dashboard Receives/Displays Alert
- [ ] Open Dashboard at http://localhost:3000
- [ ] Verify new incident appears in Incident List (auto-refresh or manual refresh)
- [ ] Click incident → verify detail view shows all fields
- [ ] Check LiveMap component: new marker appears at incident coordinates
- [ ] Verify marker color matches severity (Red=CRITICAL, Orange=HIGH, Yellow=MONITOR, Green=SAFE)

---

## Troubleshooting Connection Failures

### Backend Not Starting
| Symptom | Check | Fix |
|---------|-------|-----|
| Port 8000 in use | `netstat -ano | findstr :8000` | Kill process or change port |
| Module not found | Backend terminal errors | Run `pip install -r requirements.txt` |
| Supabase connection failed | Backend logs | Verify `SUPABASE_URL`, `SUPABASE_KEY` in `.env` |
| Gemini API error | Backend logs | Verify `GEMINI_API_KEY` in `.env` |

### Dashboard Not Connecting to Backend
| Symptom | Check | Fix |
|---------|-------|-----|
| CORS error | Browser console Network tab | Add dashboard origin to backend CORS config |
| 404 on `/incidents` | Network tab | Verify backend route exists at `/incidents` |
| Empty incident list | Supabase has data but dashboard empty | Check dashboard `supabase.ts` client config |

### Flutter App Not Connecting
| Symptom | Check | Fix |
|---------|-------|-----|
| Connection refused | App logs / flipper | Use `10.0.2.2:8000` (Android emulator) or ngrok URL |
| SOS not sending | App logs | Verify API endpoint in `api.dart` matches backend |
| Timeout | App logs | Increase HTTP timeout, check firewall |

### Supabase Not Receiving Data
| Symptom | Check | Fix |
|---------|-------|-----|
| Row not inserted | Supabase logs / Dashboard | Check RLS policies on `incidents` table |
| Permission denied | Backend logs | Verify service role key used in backend |
| Schema mismatch | Backend logs | Align Pydantic model with Supabase table columns |

---

## Sign-Off Checklist

- [ ] All 7 steps completed successfully
- [ ] No console errors in any component
- [ ] Data flows: Mobile → Backend → Supabase → Dashboard
- [ ] Map markers update in real-time
- [ ] Severity colors correct on both Dashboard and Map
- [ ] Team lead notified: "Integration Test PASSED"

---

## Rollback Procedure
If integration fails and blocks other members:
1. Revert to last known working commit on `main`
2. Each member works on feature branches
3. Re-run integration test after each merge