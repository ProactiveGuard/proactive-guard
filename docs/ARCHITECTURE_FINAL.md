# Proactive Guard — Final Architecture Diagram & Document

## Overview
This is the polished, presentation-ready architecture document for SIH 2026 submission. It clearly labels all six components and provides export instructions for PNG/SVG.

---

## Labeled Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         PROACTIVE GUARD SYSTEM ARCHITECTURE                 │
└─────────────────────────────────────────────────────────────────────────────┘

    ┌──────────────────┐
    │  MOBILE / FLUTTER │ ◄──────────────────────────────────────────────────┐
    │                  │                                                      │
    │  • SOS Button    │   Encrypted Telemetry (HTTPS/REST)                  │
    │  • Live Journey  │   ────────────────────────────────────────────────   │
    │  • GPS Tracker   │   • User ID + Location (lat/lng)                    │
    │  • Audio Monitor │   • Audio Level (0-10 scale)                        │
    │  • Motion Sensor │   • Motion Score (0-10 scale)                       │
    │  • Offline Cache │   • Timestamp + Journey Context                     │
    └────────┬─────────┘                                                      │
             │                                                                 │
             ▼                                                                 │
    ┌──────────────────┐                                                      │
    │  BACKEND / FASTAPI│                                                      │
    │                  │   REST API Endpoints:                                 │
    │  • /api/v1/      │   ────────────────────────────────────────────────   │
    │    telemetry     │   POST   /api/v1/telemetry      ← Sensor data       │
    │  • /api/v1/      │   POST   /api/v1/incidents/sos   ← Manual SOS       │
    │    incidents     │   GET    /api/v1/incidents        ← List incidents  │
    │  • /api/v1/      │   GET    /api/v1/incidents/{id}   ← Incident detail │
    │    journeys      │   POST   /api/v1/journeys         ← Start journey   │
    │  • Auth (JWT)    │   GET    /ping                    ← Health check    │
    │  • CORS Config   │                                                      │
    └────────┬─────────┘                                                      │
             │                                                                 │
             ▼                                                                 │
    ┌──────────────────┐                                                      │
    │  AI / GEMINI      │   Risk Evaluation Pipeline:                         │
    │                  │   ────────────────────────────────────────────────   │
    │  • Rule Engine   │   1. Input: audio(60%) + motion(40%)                │
    │    (risk.py)     │   2. Context: time-of-day bonus (22:00-06:00)       │
    │  • Gemini LLM    │   3. Route: off-route penalty (+1.5)                │
    │    (llm.py)      │   4. Score: 0-100 → SAFE/MONITOR/HIGH/CRITICAL      │
    │  • Fallback:     │   5. Gemini: Human-readable summary                 │
    │    Rules Only    │   6. Output: {risk_score, severity, summary, actions}│
    └────────┬─────────┘                                                      │
             │                                                                 │
             ▼                                                                 │
    ┌──────────────────┐                                                      │
    │  DATABASE /       │   Supabase (PostgreSQL) Tables:                     │
    │  SUPABASE         │   ────────────────────────────────────────────────   │
    │                  │   • incidents       — Core incident records          │
    │  • PostgreSQL    │   • journeys          — Journey tracking             │
    │  • Realtime      │   • telemetry_log     — Analytics (optional)         │
    │  • Auth          │   • users             — Future auth                  │
    │  • REST API      │                                                      │
    │  • Row Level     │   Realtime: Live incident broadcast to Dashboard    │
    │    Security      │                                                      │
    └────────┬─────────┘                                                      │
             │                                                                 │
      ┌──────┴──────┐                                                          │
      ▼             ▼                                                          │
┌──────────┐ ┌──────────────────┐                                             │
│ DASHBOARD│ │  MOBILE / FLUTTER │                                             │
│ / NEXT.JS│ │  (Push/Notif)    │                                             │
│          │ │                  │                                             │
│ • Live   │ │ • Alert Receive  │                                             │
│   Map    │ │ • Status Update  │                                             │
│ • List   │ │ • Journey View   │                                             │
│ • Realtime│ │ • SOS History    │                                             │
│ • Detail │ │                  │                                             │
└──────────┘ └──────────────────┘                                             │
      │             │                                                          │
      ▼             ▼                                                          │
┌─────────────────────────────────────────────────────────────────────────────┐
│                         MAP / LEAFLET (Shared Visualization)                │
│                                                                             │
│   • OpenStreetMap Tiles (Free, No API Key)                                 │
│   • Color-Coded Circle Markers:                                            │
│       🔴 CRITICAL (#EF4444)    🟠 HIGH RISK (#F97316)                      │
│       🟡 MONITOR (#EAB308)     🟢 SAFE (#22C55E)                           │
│   • Popup: Incident ID, Severity, Risk Score, Summary, Time                │
│   • Auto-Fit Bounds • Legend Overlay • Responsive                          │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## Component Specification Table

| # | Component | Label | Technology | Repository Path | Key Responsibility |
|---|-----------|-------|------------|-----------------|-------------------|
| 1 | **Mobile** | `MOBILE / FLUTTER` | Flutter 3.19+, Dart | `mobile/` | Sensor collection, SOS UI, journey tracking, offline cache |
| 2 | **Backend** | `BACKEND / FASTAPI` | FastAPI, Python 3.11+, Uvicorn | `backend/` | REST API, telemetry ingestion, incident management, CORS |
| 3 | **AI Engine** | `AI / GEMINI` | Custom Rules + Gemini 1.5 Flash | `backend/ai-engine/`, `backend/app/services/llm.py` | Risk scoring (0-100), severity classification, AI summaries |
| 4 | **Database** | `DATABASE / SUPABASE` | PostgreSQL (Supabase Cloud) | `backend/app/services/supabase.py` | Persistent storage, Realtime subscriptions, Auth |
| 5 | **Dashboard** | `DASHBOARD / NEXT.JS` | Next.js 14, Tailwind, Leaflet | `dashboard/` | Command center, realtime map, incident management |
| 6 | **Map** | `MAP / LEAFLET` | Leaflet 1.9+, React-Leaflet | `dashboard/src/components/LiveMap.tsx`, `maps-realtime/` | Interactive visualization, severity markers, popups |

---

## Data Flow Sequences

### Sequence 1: Proactive SOS (Auto-Detection)
```
Mobile Sensors → Backend /telemetry → AI Risk Engine → Supabase (incident)
                                                    ↓
                                    ┌───────────────┴───────────────┐
                                    ▼                               ▼
                            Dashboard (Realtime)              Mobile (Push)
                            • Map marker 🔴                   • Alert notify
                            • List update                      • Status change
```

### Sequence 2: Manual SOS (Button Press)
```
Mobile SOS Button → Backend /incidents/sos → AI Risk Engine → Supabase
                                                    ↓
                                    ┌───────────────┴───────────────┐
                                    ▼                               ▼
                            Dashboard (Realtime)              Contacts (SMS/Call)
                            • Immediate CRITICAL                • Live map link
                            • Dispatch options                  • AI summary
```

### Sequence 3: Journey Tracking
```
Mobile GPS (10s) → Backend /journeys/{id} → Supabase (journey)
                                      ↓
                            Dashboard LiveMap
                            • Live position dot
                            • Route polyline
                            • Deviation alerts
```

---

## Network Architecture

### Development (Local)
```
┌─────────────┐     ngrok      ┌─────────────┐
│   Mobile    │ ─────────────▶ │  Backend    │
│  (Device)   │  https://      │  :8000      │
└─────────────┘   abc.ngrok.io └──────┬──────┘
                                      │
                    ┌─────────────────┼─────────────────┐
                    ▼                 ▼                 ▼
              ┌──────────┐    ┌──────────────┐  ┌──────────┐
              │Supabase  │    │   Gemini     │  │Dashboard │
              │Cloud     │    │   API        │  │:3000     │
              └──────────┘    └──────────────┘  └──────────┘
```

### Production (Deployed)
```
┌─────────────┐     HTTPS      ┌──────────────────────┐
│   Mobile    │ ─────────────▶ │  Render:             │
│  (Device)   │   api.guard.in │  proactive-guard-api │
└─────────────┘                └──────────┬───────────┘
                                          │
                    ┌─────────────────────┼─────────────────────┐
                    ▼                     ▼                     ▼
              ┌──────────┐          ┌──────────────┐      ┌──────────┐
              │Supabase  │          │   Gemini     │      │ Vercel:  │
              │Cloud     │          │   API        │      │dash.grd.in│
              └──────────┘          └──────────────┘      └──────────┘
```

---

## Security Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                        SECURITY LAYERS                          │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  TRANSPORT          │  TLS 1.2+ everywhere (HTTPS, WSS)        │
│  ───────────────────┼────────────────────────────────────────── │
│  AUTHENTICATION     │  JWT (planned) + Supabase Auth           │
│  ───────────────────┼────────────────────────────────────────── │
│  AUTHORIZATION      │  Row Level Security (Supabase)           │
│  ───────────────────┼────────────────────────────────────────── │
│  SECRETS            │  Render/Vercel Env Vars (never in code)  │
│  ───────────────────┼────────────────────────────────────────── │
│  CORS               │  Strict origins (Vercel + localhost)     │
│  ───────────────────┼────────────────────────────────────────── │
│  DATA PRIVACY       │  Audio levels only (no recording)        │
│  ───────────────────┼────────────────────────────────────────── │
│  AUDIT LOG          │  All incidents immutable in Supabase     │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## Scalability Architecture

| Component | Current (SIH) | Scale Target | Strategy |
|-----------|---------------|--------------|----------|
| **Backend** | 1 Render instance | 10+ instances | Horizontal scaling, stateless |
| **Database** | Supabase Free | Pro/Enterprise | Read replicas, connection pooling |
| **Realtime** | 100 concurrent | 10,000+ | Supabase handles |
| **AI Engine** | Sync in request | Async queue | Celery + Redis (future) |
| **Dashboard** | Vercel Edge | Global CDN | Automatic |
| **Mobile** | Direct API | CDN + Edge | Future: API Gateway |

---

## Mermaid Source (For Diagram Generation)

```mermaid
graph TD
    subgraph Mobile["MOBILE / FLUTTER"]
        M1[SOS Button]
        M2[Live Journey]
        M3[GPS Tracker]
        M4[Audio Monitor]
        M5[Motion Sensor]
        M6[Offline Cache]
    end

    subgraph Backend["BACKEND / FASTAPI"]
        B1[/api/v1/telemetry]
        B2[/api/v1/incidents/sos]
        B3[/api/v1/incidents]
        B4[/api/v1/journeys]
        B5[Auth / CORS]
    end

    subgraph AI["AI / GEMINI"]
        A1[Rule Engine<br/>risk.py]
        A2[Gemini LLM<br/>llm.py]
        A3[Fallback: Rules Only]
    end

    subgraph DB["DATABASE / SUPABASE"]
        D1[(incidents)]
        D2[(journeys)]
        D3[(telemetry_log)]
        D4[Realtime Engine]
        D5[RLS Policies]
    end

    subgraph Dash["DASHBOARD / NEXT.JS"]
        H1[Live Map]
        H2[Incident List]
        H3[Realtime Feed]
        H4[Detail View]
    end

    subgraph MapLib["MAP / LEAFLET"]
        L1[OpenStreetMap Tiles]
        L2[Severity Markers]
        L3[Popups + Legend]
    end

    Mobile -->|HTTPS/REST<br/>Telemetry| Backend
    Backend -->|Risk Evaluation| AI
    AI -->|Incident + Summary| DB
    DB -->|Realtime Broadcast| Dash
    DB -->|Push/Realtime| Mobile
    Dash -->|Visualization| MapLib
    Mobile -->|Visualization| MapLib

    classDef mobile fill:#1976D2,color:#fff;
    classDef backend fill:#388E3C,color:#fff;
    classDef ai fill:#F57C00,color:#fff;
    classDef db fill:#7B1FA2,color:#fff;
    classDef dash fill:#D32F2F,color:#fff;
    classDef map fill:#546E7A,color:#fff;

    class Mobile mobile;
    class Backend backend;
    class AI ai;
    class DB db;
    class Dash dash;
    class MapLib map;
```

---

## Export Instructions (PNG & SVG)

### Method 1: Mermaid Live Editor (Easiest, No Install)
1. Open https://mermaid.live/
2. Copy the **Mermaid Source** above
3. Paste into editor
4. Click **"Download"** → Choose **PNG** or **SVG**
5. Save as `docs/ARCHITECTURE.png` and `docs/ARCHITECTURE.svg`

### Method 2: VS Code + Mermaid Preview
1. Install extension: **"Markdown Preview Mermaid Support"**
2. Open `ARCHITECTURE_FINAL.md` in VS Code
3. Open Preview: `Ctrl+Shift+V` (or `Cmd+Shift+V` on Mac)
4. Right-click diagram → **"Save Image As..."** → PNG or SVG

### Method 3: CLI (mmdc) — For CI/CD
```bash
# Install
npm install -g @mermaid-js/mermaid-cli

# Generate PNG
mmdc -i docs/ARCHITECTURE_FINAL.md -o docs/ARCHITECTURE.png -w 1920 -H 1080

# Generate SVG (crisp, scalable)
mmdc -i docs/ARCHITECTURE_FINAL.md -o docs/ARCHITECTURE.svg

# With custom theme
mmdc -i docs/ARCHITECTURE_FINAL.md -o docs/ARCHITECTURE.png -t dark
```

### Method 4: GitHub Native Rendering
1. Push `ARCHITECTURE_FINAL.md` to GitHub
2. View on GitHub.com — Mermaid renders automatically
3. Right-click diagram → **"Save image as..."** → PNG

### Method 5: HackMD / Notion / Obsidian
- Paste Mermaid code into any Mermaid-supported editor
- Export as image

---

## Recommended Export Settings

| Format | Use Case | Settings |
|--------|----------|----------|
| **PNG** | Slide decks, documents, web | 1920x1080, transparent background |
| **SVG** | Print, scaling, editing | Vector, editable in Illustrator/Figma |

**For SIH Submission:** Include both `ARCHITECTURE.png` (for PPT) and `ARCHITECTURE.svg` (for documentation).

---

## File Placement for Submission

```
submission/
├── docs/
│   ├── ARCHITECTURE.png      ← For presentation slides
│   ├── ARCHITECTURE.svg      ← For documentation
│   └── ARCHITECTURE_FINAL.md ← Source (this file)
```

---

## Version History

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | Day 2 | Member 6 | Initial architecture |
| 2.0 | Day 4 | Member 6 | Final polish, labels, export instructions |

---

*Last Updated: Day 4 — Member 6 (Integration Lead)*
*Proactive Guard — SIH 2026*