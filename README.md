# Proactive Guard - Women's Safety Platform

A comprehensive women's safety platform with AI-powered risk detection, real-time monitoring dashboard, and cross-platform mobile app.

## Architecture

```
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│   Mobile App    │────▶│   Backend API   │────▶│   Dashboard     │
│   (Flutter)     │     │   (FastAPI)     │     │   (Next.js)     │
└─────────────────┘     └─────────────────┘     └─────────────────┘
        │                       │                       │
        │              ┌─────────────────┐              │
        │              │  AI Risk Engine │              │
        │              │  (Gemini + ML)  │              │
        │              └─────────────────┘              │
        │                       │                       │
        ▼                       ▼                       ▼
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│  Background     │     │    Supabase     │     │   WebSocket     │
│  Location/Audio │     │  (PostgreSQL)   │     │  (Real-time)    │
└─────────────────┘     └─────────────────┘     └─────────────────┘
```

## Services

| Service | Tech Stack | Port | Description |
|---------|------------|------|-------------|
| **Backend** | FastAPI, Python 3.11, Uvicorn | 8000 | REST API + WebSocket + AI Engine |
| **Dashboard** | Next.js 16, React 19, TypeScript | 3000 | Real-time incident monitoring |
| **Mobile** | Flutter 3.13, Dart | N/A | Cross-platform (iOS/Android/Web/Windows) |
| **Database** | Supabase (PostgreSQL) | 5432 | Persistent storage + real-time |
| **AI** | Google Gemini 2.5 Flash | - | Multi-language risk summaries |

## Quick Start

### Prerequisites

- **Backend**: Python 3.11+, `pip`
- **Dashboard**: Node.js 20+, `npm`
- **Mobile**: Flutter 3.13+, Dart SDK
- **Database**: Supabase account (free tier works)

### 1. Clone & Configure

```bash
cd proactive-guard
cp .env.example .env
# Edit .env with your API keys
```

Required environment variables:
```env
# Backend
GEMINI_API_KEY=your_gemini_key          # Get from https://aistudio.google.com/
GEMINI_MODEL=gemini-2.5-flash
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your_anon_key

# Dashboard
NEXT_PUBLIC_API_URL=http://localhost:8000
NEXT_PUBLIC_WS_URL=ws://localhost:8000
```

### 2. Run with Docker (Recommended)

```bash
docker-compose up --build
```

Services available at:
- Backend API: http://localhost:8000
- API Docs: http://localhost:8000/docs
- Dashboard: http://localhost:3000

### 3. Run Locally (Development)

**Backend:**
```bash
cd backend
pip install -r requirements.txt
cp .env.example .env
# Edit .env
uvicorn app.main:app --reload --port 8000
```

**Dashboard:**
```bash
cd dashboard
npm install
cp .env.example .env.local
# Edit .env.local
npm run dev
```

**Mobile:**
```bash
cd mobile
flutter pub get
flutter run -d chrome     # Web
flutter run -d windows    # Windows desktop
flutter run -d android    # Android (requires emulator/device)
```

## API Endpoints

### Telemetry
- `POST /api/v1/telemetry` - Submit sensor data, get risk assessment
- `GET /incidents` - Fetch all incidents (with Supabase fallback)

### Journeys
- `POST /api/v1/journey/start` - Start a safety journey
- `POST /api/v1/journey/stop` - End journey safely

### Incidents
- `DELETE /api/v1/incidents/{id}` - Resolve incident
- `PATCH /api/v1/incidents/{id}/assign` - Assign responder

### WebSocket
- `WS /ws/incidents` - Real-time incident broadcasts

### AI Metrics
- `GET /api/v1/metrics/ai` - Model performance metrics
- `GET /api/v1/health/ai` - AI component health check

### Auth (Mock)
- `POST /api/v1/auth/register` - Register user
- `POST /api/v1/auth/login` - Login (returns JWT)

## AI Risk Engine

The backend evaluates risk using multiple factors:

| Factor | Weight | Description |
|--------|--------|-------------|
| Audio Level | 25% | Microphone amplitude (screams, distress) |
| Motion Speed | 20% | Accelerometer/gyroscope anomalies |
| Route Deviation | 20% | GPS off-route distance (>500m) |
| Time of Day | 15% | Night hours (22:00-05:00) higher risk |
| Struggle Detection | 10% | Temporal motion pattern analysis |
| Audio Transcript | 10% | NLP threat detection on speech |

**Risk Levels:** `SAFE` (0-30) → `MONITOR` (31-50) → `HIGH RISK` (51-75) → `CRITICAL` (76-100)

**Features:**
- Temporal smoothing (prevents flickering)
- Confidence thresholds
- Multi-language summaries (English, Hindi, Tamil, Telugu)
- Gemini AI for natural language police reports

## Mobile App Features

- **Login/Registration** - Persistent user sessions
- **Start Journey** - One-tap safety monitoring activation
- **Live Journey** - Real-time location, audio, motion tracking
- **Safety Status** - Current risk level, telemetry stats
- **Background Tracking** - Continues monitoring when app closed
- **Guardian Contacts** - Emergency contacts with auto-alert
- **Settings** - Sensitivity, audio/motion toggles, API URL config

### Permissions Required
- **Location**: Always (foreground + background)
- **Microphone**: For audio threat detection
- **Motion/Sensors**: For struggle detection
- **Notifications**: For background alerts

## Dashboard Features

- **Live Incident Map** - Leaflet with marker clustering
- **Active Alerts Panel** - Severity-sorted incident list
- **Real-time Updates** - WebSocket + Supabase subscriptions
- **Keyboard Shortcuts** - R (resolve), A (assign), D (dispatch), N (refresh)
- **Dark/Light Mode** - Persisted preference
- **History View** - Filterable incident archive
- **Safe Zones** - Visual geofence overlay

## Project Structure

```
proactive-guard/
├── backend/                    # FastAPI Backend
│   ├── app/
│   │   ├── main.py            # API routes & WebSocket
│   │   ├── api/routes/        # Telemetry, journeys, incidents
│   │   ├── auth.py            # JWT authentication
│   │   ├── dependencies.py    # Auth dependencies
│   │   ├── services/          # Supabase, LLM clients
│   │   └── websockets.py      # Connection manager
│   ├── ai_engine/
│   │   ├── risk.py            # Risk evaluation logic
│   │   ├── geo.py             # Haversine distance calc
│   │   └── test_risk.py       # Unit tests
│   ├── requirements.txt
│   └── Dockerfile
│
├── dashboard/                  # Next.js Dashboard
│   ├── src/
│   │   ├── app/               # Pages (/, /history, /incidents/[id])
│   │   ├── components/        # LiveMap, IncidentList, MapLegend
│   │   ├── hooks/             # useIncidents (WebSocket + REST)
│   │   └── lib/               # Types, Supabase, WebSocket client
│   ├── package.json
│   └── Dockerfile
│
├── mobile/                     # Flutter Mobile App
│   ├── lib/
│   │   ├── main.dart          # App entry + state management
│   │   ├── models/            # Telemetry, Incident, Journey
│   │   ├── screens/           # Login, Home, LiveJourney, etc.
│   │   ├── services/          # API, Location, Audio, Motion
│   │   └── utils/             # Constants
│   └── pubspec.yaml
│
├── windows/                    # Flutter Windows build
├── ios/ macos/                 # Flutter iOS/macOS builds
├── docker-compose.yml          # Full stack orchestration
├── .env.example                # Root environment template
└── docs/                       # Architecture, API, deployment guides
```

## Deployment

### Render (Backend + Dashboard)
```bash
# Backend: Connect GitHub repo, set build command:
pip install -r backend/requirements.txt
# Start command: uvicorn backend.app.main:app --host 0.0.0.0 --port $PORT

# Dashboard: Static site or Node service
# Build: cd dashboard && npm run build
# Start: npm start
```

### Vercel (Dashboard)
```bash
# Import dashboard/ folder
# Set environment variables in Vercel dashboard
```

### Docker (Any Cloud)
```bash
docker-compose -f docker-compose.yml up -d
```

### Mobile Builds
```bash
# Android APK
cd mobile && flutter build apk --release

# iOS (requires macOS)
cd mobile && flutter build ios --release

# Windows
cd mobile && flutter build windows --release
```

## Testing

```bash
# Backend tests
cd backend && pytest tests/ -v

# Dashboard tests
cd dashboard && npm run lint

# Mobile tests
cd mobile && flutter test
```

## Contributing

1. Fork the repository
2. Create feature branch (`git checkout -b feature/amazing-feature`)
3. Commit changes (`git commit -m 'Add amazing feature'`)
4. Push to branch (`git push origin feature/amazing-feature`)
5. Open Pull Request

## License

MIT License - see LICENSE file for details.

## Team

- **Backend & AI**: FastAPI, Gemini, Risk Engine
- **Dashboard**: Next.js, React, Leaflet Maps
- **Mobile**: Flutter, Background Services, Sensors
- **Database**: Supabase, PostgreSQL, Real-time

## Support

- **Documentation**: `/docs` folder
- **API Reference**: http://localhost:8000/docs (when running)
- **Issues**: GitHub Issues