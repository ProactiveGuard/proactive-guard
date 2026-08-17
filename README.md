# Proactive Guard — SIH 2026 Submission

## Project Overview

**Proactive Guard** is an AI-powered personal safety platform that shifts the paradigm from *reactive* SOS buttons to *proactive* threat detection. By continuously monitoring audio, motion, and GPS sensors on a user's smartphone, our system detects danger **before the victim can press a button** — automatically alerting police, family, and security with live location, AI-generated incident summary, and sensor evidence.

### The Problem
- **Every 16 minutes**, a woman reports a crime in India (NCRB 2022)
- **73% of assault victims** cannot operate their phone during an attack (ICRW)
- Existing solutions: Manual SOS only, no context, single recipient, no evidence

### Our Solution
```
Mobile Sensors (Flutter) → FastAPI Backend → AI Risk Engine (Rules + Gemini) → Supabase → Next.js Command Center
                                                              ↓
                                              Auto-alerts: Police + Family + Security
```

### Key Innovation
| Traditional Apps | Proactive Guard |
|------------------|-----------------|
| Wait for button press | Monitors sensors 24/7 |
| User triggers alert | AI detects anomaly automatically |
| Single recipient | Multi-channel simultaneous escalation |
| No context | Audio + Motion + GPS + Time evidence |
| Post-incident report | Live command center for authorities |

---

## Quick Start

### Prerequisites
- Python 3.11+
- Node.js 18+
- Flutter 3.19+
- Supabase account
- Google Gemini API key

### 1. Backend Setup
```bash
cd backend
python -m venv venv
source venv/bin/activate  # Windows: venv\Scripts\activate
pip install -r requirements.txt

# Configure environment
cp .env.example .env
# Edit .env with: SUPABASE_URL, SUPABASE_SERVICE_KEY, GEMINI_API_KEY, CORS_ORIGINS

# Run
uvicorn app.main:app --reload --port 8000
```

### 2. Dashboard Setup
```bash
cd dashboard
npm install

# Configure environment
cp .env.example .env.local
# Edit .env.local with: NEXT_PUBLIC_SUPABASE_URL, NEXT_PUBLIC_SUPABASE_ANON_KEY, NEXT_PUBLIC_API_BASE_URL

# Run
npm run dev
# Open http://localhost:3000
```

### 3. Mobile App Setup
```bash
cd mobile
flutter pub get

# Configure constants.dart with backend URL
# lib/utils/constants.dart → apiBaseUrl = "http://localhost:8000" (or ngrok URL)

# Run
flutter run
```

---

## Environment Variables

### Backend (`backend/.env`)
| Variable | Description | Required |
|----------|-------------|----------|
| `SUPABASE_URL` | Supabase project URL | ✅ |
| `SUPABASE_SERVICE_KEY` | Service role key (secret) | ✅ |
| `GEMINI_API_KEY` | Google Gemini API key | ✅ |
| `CORS_ORIGINS` | Comma-separated allowed origins | ✅ |
| `ENVIRONMENT` | `development` or `production` | ✅ |
| `LOG_LEVEL` | `debug`, `info`, `warning`, `error` | ❌ |

### Dashboard (`dashboard/.env.local`)
| Variable | Description | Required |
|----------|-------------|----------|
| `NEXT_PUBLIC_SUPABASE_URL` | Supabase project URL | ✅ |
| `NEXT_PUBLIC_SUPABASE_ANON_KEY` | Supabase anonymous key | ✅ |
| `NEXT_PUBLIC_API_BASE_URL` | Backend API base URL | ✅ |
| `NEXT_PUBLIC_MAP_TILE_URL` | Map tile server URL | ❌ |

### Mobile (`mobile/lib/utils/constants.dart`)
```dart
static const String apiBaseUrl = 'http://localhost:8000';  // or ngrok/production URL
static const String dashboardBaseUrl = 'http://localhost:3000';
```

---

## Deployment Information

### Backend → Render
- **Root Directory:** `backend`
- **Build Command:** `pip install -r requirements.txt`
- **Start Command:** `uvicorn app.main:app --host 0.0.0.0 --port 10000`
- **Environment Variables:** Set in Render Dashboard (see `docs/RENDER_DEPLOYMENT.md`)

### Dashboard → Vercel
- **Root Directory:** `dashboard`
- **Framework:** Next.js (auto-detected)
- **Build Command:** `npm run build`
- **Environment Variables:** Set in Vercel Dashboard (see `docs/VERCEL_DEPLOYMENT.md`)

### Database → Supabase
- **Tables:** `incidents`, `journeys`, `telemetry_log`
- **Realtime:** Enabled for `incidents` table
- **RLS:** Policies configured for secure access

---

## Team Members

| Member | Role | Responsibilities |
|--------|------|------------------|
| **Member 1** | Mobile Lead | Flutter app, sensors, SOS UI, offline support |
| **Member 2** | Dashboard Lead | Next.js command center, Leaflet map, realtime UI |
| **Member 3** | Sensor Lead | Audio processing, motion analysis, signal filtering |
| **Member 4** | Backend Lead | FastAPI, Supabase integration, REST API, deployment |
| **Member 5** | AI Lead | Risk engine, Gemini integration, rule-based fallback |
| **Member 6** | Captain & Integration | Architecture, deployment, documentation, pitch, QA |

---

## Main API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| `GET` | `/ping` | Health check |
| `GET` | `/docs` | Swagger UI (auto-generated) |
| `POST` | `/api/v1/telemetry` | Receive sensor data (auto risk eval) |
| `POST` | `/api/v1/incidents/sos` | Manual SOS trigger |
| `GET` | `/api/v1/incidents` | List all incidents |
| `GET` | `/api/v1/incidents/{id}` | Incident detail |
| `POST` | `/api/v1/journeys` | Start new journey |
| `GET` | `/api/v1/journeys/{id}` | Journey status + live position |

### Telemetry Payload
```json
{
  "user_id": "user-123",
  "latitude": 19.123456,
  "longitude": 72.891234,
  "motion_score": 0.7,
  "audio_score": 0.9
}
```

### Incident Response
```json
{
  "incident_id": "INC-1723456789",
  "severity": "CRITICAL",
  "risk_score": 94,
  "summary": "User detected in CRITICAL state...",
  "latitude": 19.123456,
  "longitude": 72.891234,
  "created_at": "2026-08-17T10:15:00Z"
}
```

---

## Testing Instructions

### Integration Test (Full Flow)
1. Start backend: `cd backend && uvicorn app.main:app --reload --port 8000`
2. Start dashboard: `cd dashboard && npm run dev`
3. Start mobile: `cd mobile && flutter run`
4. In mobile: Start journey → Simulate distress (shake + audio)
5. Verify: Backend logs show CRITICAL → Supabase has new incident → Dashboard shows red marker
6. Run: `docs/INTEGRATION_TEST_CHECKLIST.md` for full checklist

### Unit Tests
```bash
# Backend AI Engine
cd backend
python -m ai_engine.risk

# Dashboard (if tests exist)
cd dashboard
npm test

# Mobile (if tests exist)
cd mobile
flutter test
```

---

## Documentation Index

| Document | Location |
|----------|----------|
| Architecture Diagram | `docs/ARCHITECTURE.png` / `docs/ARCHITECTURE.svg` |
| API Documentation | `docs/API_DOCS.md` |
| AI Model Card | `docs/AI_MODEL_CARD.md` |
| Integration Test Checklist | `docs/INTEGRATION_TEST_CHECKLIST.md` |
| GitHub Workflow | `docs/GITHUB_WORKFLOW.md` |
| Vercel Deployment | `docs/VERCEL_DEPLOYMENT.md` |
| Render Deployment | `docs/RENDER_DEPLOYMENT.md` |
| Backup Plans | `docs/BACKUP_PLANS.md` |
| Rehearsal Plan | `docs/REHEARSAL_PLAN.md` |
| Pitch Deck | `docs/PITCH_DECK.md` |
| Failsafe Demo | `docs/FAILSAFE_DEMO.md` |
| Final Submission Checklist | `docs/FINAL_SUBMISSION_CHECKLIST.md` |
| Release Checklist | `docs/RELEASE_CHECKLIST.md` |
| Demo Script | `docs/DEMO_SCRIPT.md` |
| Judge Q&A | `docs/JUDGE_QA.md` |

---

## Submission Package Contents

```
submission/
├── code/
│   ├── mobile/           # Flutter source (symlink or copy)
│   ├── backend/          # FastAPI source (symlink or copy)
│   ├── dashboard/        # Next.js source (symlink or copy)
│   └── ai-engine/        # AI risk engine (symlink or copy)
├── video/
│   ├── demo_30s.mp4      # 30-second highlight reel
│   └── full_walkthrough_3min.mp4  # 3-minute complete demo
├── docs/
│   ├── README.md              # This file
│   ├── ARCHITECTURE.png       # Architecture diagram (PNG)
│   ├── ARCHITECTURE.svg       # Architecture diagram (SVG)
│   ├── API_DOCS.md            # Detailed API reference
│   └── AI_MODEL_CARD.md       # AI model documentation
├── ppt/
│   └── Proactive_Guard_SIH2026.pptx  # Presentation slides
└── apk/
    └── app-release.apk    # Signed release APK (not in repo)
```

**Note:** Binary files (APK, videos, PPTX) are not committed to Git. They are built/generated separately and placed in this structure for submission.

---

## License & Acknowledgments

- **OpenStreetMap** for free map tiles
- **Supabase** for PostgreSQL + Realtime
- **Google Gemini** for AI summaries
- **Flutter, FastAPI, Next.js, Leaflet** communities

---

*Proactive Guard — SIH 2026 Team*
*Member 6 — Integration Lead & Captain*