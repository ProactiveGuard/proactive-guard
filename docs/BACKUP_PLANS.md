# Backup Plans — SIH 2026 Judging Day

## Component Backup Matrix

| Component | Primary | Backup | Activation Trigger |
|-----------|---------|--------|-------------------|
| **Backend** | Render (https://api.onrender.com) | Local + ngrok (`ngrok http 8000`) | Render down / 5xx errors > 30s |
| **Dashboard** | Vercel (https://app.vercel.app) | Local + ngrok (`ngrok http 3000`) | Vercel down / build failed |
| **Database** | Supabase Cloud | Local SQLite export (CSV/JSON) | Supabase unreachable / quota exceeded |
| **AI Engine** | Gemini Cloud API | Rule-based fallback (risk.py only) | Gemini API quota / latency / error |
| **Mobile App** | Physical device (Member 1 phone) | Android Emulator + screen recording | Phone broken / battery dead / OS issue |
| **Internet** | Venue WiFi | Mobile hotspot (Member 6 phone) | WiFi down / captive portal / bandwidth |

---

## Detailed Backup Procedures

### 1. Backend: Render → Local + ngrok

**When to Activate:** Render returns 502/503/504 for >30 seconds, or deployment failed.

**Prerequisites (Prepare Day Before):**
- [ ] Backend runs locally: `cd backend && uvicorn app.main:app --reload --port 8000`
- [ ] ngrok installed: `npm install -g ngrok` or download binary
- [ ] ngrok authtoken configured (free account)
- [ ] Local `.env` has all secrets (Supabase, Gemini)
- [ ] Supabase allows local IP (or use Supabase local dev)

**Activation Steps:**
```bash
# Terminal 1: Start backend
cd backend
uvicorn app.main:app --host 0.0.0.0 --port 8000

# Terminal 2: Start ngrok tunnel
ngrok http 8000

# Output example:
# Forwarding  https://abc123.ngrok-free.app -> http://localhost:8000
```

**Update Team:**
- Share ngrok URL: `https://abc123.ngrok-free.app`
- Member 1: Update `constants.dart` → `apiBaseUrl = "https://abc123.ngrok-free.app"`
- Member 2: Update Vercel env → `NEXT_PUBLIC_API_BASE_URL = "https://abc123.ngrok-free.app"` (redeploy)
- Member 6: Update `QR_CODES.md`

**Test:** `curl https://abc123.ngrok-free.app/ping`

---

### 2. Dashboard: Vercel → Local + ngrok

**When to Activate:** Vercel deployment failed, or site returns 404/500.

**Prerequisites (Prepare Day Before):**
- [ ] Dashboard runs locally: `cd dashboard && npm run dev` (port 3000)
- [ ] ngrok installed
- [ ] Local `.env.local` has Supabase URL/Anon Key + Backend URL
- [ ] Backend accessible (primary or ngrok backup)

**Activation Steps:**
```bash
# Terminal 1: Start dashboard
cd dashboard
npm run dev

# Terminal 2: Start ngrok tunnel
ngrok http 3000

# Output example:
# Forwarding  https://xyz789.ngrok-free.app -> http://localhost:3000
```

**Update Team:**
- Share ngrok URL for judges to view
- Member 6: Update `QR_CODES.md`
- Backend CORS: Add ngrok URL to `CORS_ORIGINS` (if backend is primary)

**Test:** Open `https://xyz789.ngrok-free.app` in browser

---

### 3. Database: Supabase → Local SQLite Export

**When to Activate:** Supabase completely unreachable (network, outage, quota).

**Note:** This is READ-ONLY backup for demo. Write operations will fail.

**Prerequisites (Prepare Day Before):**
- [ ] Export current incidents: Supabase Dashboard → Table Editor → `incidents` → Export CSV
- [ ] Save as `backup/incidents_backup.csv`
- [ ] Create local SQLite DB with same schema
- [ ] Backend config: `SUPABASE_URL=file:///local.db` (requires code change — only if desperate)

**Simpler Approach (Recommended):**
- Dashboard: Pre-load incident data in localStorage/mock data
- Mobile: Show "Demo Mode" with simulated backend responses
- Backend: Return mock data if Supabase fails (circuit breaker)

**Code Change (Backend - Emergency Only):**
```python
# In app/services/supabase.py
async def get_incidents():
    try:
        return await supabase.table('incidents').select('*').execute()
    except Exception:
        # Return mock data for demo
        return MOCK_INCIDENTS
```

---

### 4. AI Engine: Gemini → Rule-Based Only

**When to Activate:** Gemini API returns 429 (quota), 500, or latency >5s.

**Automatic Fallback (Already in Code):**
- `backend/ai-engine/risk.py` — `evaluate_risk()` works without Gemini
- `generate_ai_summary()` — returns template summary if Gemini fails
- Backend should catch Gemini errors and use rule-based only

**Verify Fallback Works:**
```bash
# Temporarily unset GEMINI_API_KEY
unset GEMINI_API_KEY
cd backend
python -c "from ai_engine.risk import evaluate_risk; print(evaluate_risk(9,8,22,True))"
# Should return risk_score ~94, risk_level "CRITICAL"
```

**No Code Changes Needed** — fallback is built into `risk.py`.

---

### 5. Mobile App: Physical Device → Emulator + Recording

**When to Activate:** Phone broken, battery dead, OS update stuck, USB not recognized.

**Backup Options (Priority Order):**
1. **Spare Phone** — Member 2/3/4/5/6 has Android phone with app installed
2. **Android Emulator** — `flutter emulators --launch <emulator_id>`
3. **Screen Recording** — Play `video/demo_30s.mp4` on laptop

**Emulator Setup (Prepare Day Before):**
```bash
# List emulators
flutter emulators

# Launch
flutter emulators --launch pixel_7_api_34

# Run app
flutter run -d emulator-5554
```

**ngrok for Emulator:**
- Emulator accesses host via `10.0.2.2:8000`
- If backend on ngrok: use ngrok URL directly in `constants.dart`

---

### 6. Internet: WiFi → Mobile Hotspot

**When to Activate:** Venue WiFi down, captive portal blocks APIs, bandwidth too low.

**Setup (Prepare Day Before):**
- [ ] Member 6 phone: Mobile hotspot enabled
- [ ] Data plan: Sufficient for 2 hours (min 2GB)
- [ ] Hotspot name/password shared with team
- [ ] Tested: Laptop + phone connect, can reach Render/Vercel/Supabase

**Connection Priority:**
1. Venue WiFi (primary)
2. Member 6 Hotspot (backup)
3. Member 1 Hotspot (backup-backup)
4. Tether via USB (most stable)

---

## ngrok Quick Reference

### Installation
```bash
# Windows (PowerShell)
irm https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-windows-amd64.zip | iex
# Or: choco install ngrok

# Verify
ngrok version
```

### Authentication (One-time)
```bash
ngrok config add-authtoken <YOUR_TOKEN>
# Get token from: https://dashboard.ngrok.com/get-started/your-authtoken
```

### Commands for Demo Day
```bash
# Backend tunnel (port 8000)
ngrok http 8000

# Dashboard tunnel (port 3000)
ngrok http 3000

# Both simultaneously (different terminals)
# Terminal 1: ngrok http 8000 --subdomain=proactive-guard-api
# Terminal 2: ngrok http 3000 --subdomain=proactive-guard-dash
# Note: Custom subdomains require paid plan. Use random URLs on free tier.
```

### Important ngrok Limits (Free Tier)
- 40 connections/minute
- 1 concurrent tunnel per region
- Random URL each session (update team each time)
- 2-hour session limit

**Tip:** Start ngrok tunnels **before** judging starts, keep terminals open.

---

## Backup Testing Schedule

| Day | Test |
|-----|------|
| **Day 3 (Today)** | Verify all primary deployments work |
| **Day 3 Evening** | Test backend ngrok tunnel locally |
| **Day 3 Evening** | Test dashboard ngrok tunnel locally |
| **Day 4 Morning** | Full failover drill: Simulate Render down → switch to ngrok |
| **Day 4 Morning** | Test mobile hotspot connectivity |
| **Day 4 Evening** | Record failsafe demo video (if not done) |
| **Day 5 Morning** | Final verification: All URLs in QR_CODES.md current |

---

## Decision Tree for Judging Day

```
ISSUE DETECTED
      │
      ▼
┌─────────────┐
│ Can we fix  │──YES──▶ Fix it (restart, redeploy, re-pull)
│ in < 2 min? │
└─────────────┘
      │ NO
      ▼
┌─────────────┐
│ Is backup   │──YES──▶ Activate backup (ngrok, hotspot, emulator)
│ ready?      │
└─────────────┘
      │ NO
      ▼
┌─────────────┐
│ Play failsafe│──▶ Video demo + live narration
│ video?      │
└─────────────┘
      │
      ▼
  Q&A Session
```

---

## Emergency Contacts

| Role | Name | Backup Action |
|------|------|---------------|
| **Integration Lead** | Member 6 | Coordinates all failovers, has all URLs, drives |
| **Backend Lead** | Member 4 | Starts local backend + ngrok |
| **Dashboard Lead** | Member 2 | Starts local dashboard + ngrok |
| **Mobile Lead** | Member 1 | Switches to emulator/spare phone |
| **AI Lead** | Member 5 | Confirms rule-based fallback active |

---

## No-Secrets Policy

**NEVER in backups:**
- `.env` files committed to git
- API keys in ngrok URLs
- Service role keys in frontend code
- Database passwords in documentation

**All secrets in:**
- Render Environment Variables (backend)
- Vercel Environment Variables (dashboard)
- Local `.env` files (gitignored)
- ngrok only tunnels — no secrets in URL

---

*Last Updated: Day 4 — Member 6*
*Version: 1.0*