# Render Deployment Guide — FastAPI Backend

## Overview
Deploy the Proactive Guard FastAPI Backend to Render.

**Repository:** `https://github.com/<your-org>/proactive-guard`
**Backend Root:** `backend/`
**Build Command:** `pip install -r requirements.txt`
**Start Command:** `uvicorn app.main:app --host 0.0.0.0 --port 10000`

---

## Prerequisites

- [ ] GitHub repository with `backend/` folder
- [ ] Render account (free tier sufficient for SIH)
- [ ] Supabase project URL and Service Role Key
- [ ] Google Gemini API Key
- [ ] Vercel Dashboard URL (for CORS)

---

## Required Environment Variables

Configure these in **Render Dashboard → Environment**:

| Variable | Description | Example | Required |
|----------|-------------|---------|----------|
| `SUPABASE_URL` | Supabase project URL | `https://abcxyz.supabase.co` | ✅ |
| `SUPABASE_SERVICE_KEY` | Supabase service role key (secret!) | `eyJhbGciOiJIUzI1NiIs...` | ✅ |
| `GEMINI_API_KEY` | Google Gemini API key | `AIzaSy...` | ✅ |
| `CORS_ORIGINS` | Comma-separated allowed origins | `https://proactive-guard.vercel.app,http://localhost:3000` | ✅ |
| `ENVIRONMENT` | Deployment environment | `production` | ✅ |
| `LOG_LEVEL` | Logging verbosity | `info` | ❌ |

**⚠️ SECURITY:** Never commit these to Git. Use Render's Environment Variables UI only.

---

## Deployment Steps

### Option 1: Render Dashboard (Recommended)

1. **Login to Render**
   - Go to https://dashboard.render.com
   - Sign in with GitHub

2. **Create New Web Service**
   - Click "New +" → "Web Service"
   - Connect GitHub repo: `proactive-guard`
   - Click "Connect"

3. **Configure Service**
   ```
   Name: proactive-guard-api
   Region: Singapore (or closest to team)
   Branch: main
   Root Directory: backend
   Runtime: Python 3
   Build Command: pip install -r requirements.txt
   Start Command: uvicorn app.main:app --host 0.0.0.0 --port 10000
   ```

4. **Environment Variables**
   - Click "Advanced" → "Add Environment Variable"
   - Add each variable from table above
   - **Important:** Mark `SUPABASE_SERVICE_KEY` and `GEMINI_API_KEY` as "Secret"

5. **Deploy**
   - Click "Create Web Service"
   - Wait 3-5 minutes for build + deploy

6. **Verify**
   - Visit: `https://proactive-guard-api.onrender.com/ping`
   - Expected: `{"status": "I am ok", "message": "Proactive Guard API is running..."}`
   - Visit: `https://proactive-guard-api.onrender.com/docs` (Swagger UI)

### Option 2: Render Blueprint (render.yaml)

Create `backend/render.yaml`:

```yaml
services:
  - type: web
    name: proactive-guard-api
    runtime: python
    region: singapore
    plan: free
    rootDir: backend
    buildCommand: pip install -r requirements.txt
    startCommand: uvicorn app.main:app --host 0.0.0.0 --port 10000
    envVars:
      - key: ENVIRONMENT
        value: production
      - key: LOG_LEVEL
        value: info
      - key: SUPABASE_URL
        sync: false
      - key: SUPABASE_SERVICE_KEY
        sync: false
      - key: GEMINI_API_KEY
        sync: false
      - key: CORS_ORIGINS
        value: "https://proactive-guard.vercel.app,http://localhost:3000"
```

Then in Render Dashboard → "New +" → "Blueprint" → Select repo.

---

## Required Files Checklist

### `backend/requirements.txt` (Verify Complete)
```text
fastapi==0.109.0
uvicorn[standard]==0.27.0
pydantic==2.5.3
pydantic-settings==2.1.0
supabase==2.3.4
google-generativeai==0.3.2
python-dotenv==1.0.0
httpx==0.26.0
python-multipart==0.0.6
```

### `backend/app/core/config.py` (Verify Exists)
```python
from pydantic_settings import BaseSettings
from typing import List
import os

class Settings(BaseSettings):
    ENVIRONMENT: str = "development"
    LOG_LEVEL: str = "info"
    
    # Supabase
    SUPABASE_URL: str
    SUPABASE_SERVICE_KEY: str
    
    # Gemini
    GEMINI_API_KEY: str
    
    # CORS
    CORS_ORIGINS: List[str] = [
        "http://localhost:3000",
        "http://localhost:8000",
    ]
    
    class Config:
        env_file = ".env"
        case_sensitive = True

settings = Settings()
```

### `backend/app/main.py` (Verify CORS Configured)
```python
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.core.config import settings

app = FastAPI(title="Proactive Guard API")

app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.CORS_ORIGINS,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# ... rest of your routes
```

### `backend/Dockerfile` (Optional - for reference)
```dockerfile
FROM python:3.11-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

EXPOSE 10000

CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "10000"]
```

---

## Post-Deployment Verification

### Checklist
- [ ] `GET /ping` returns 200 with status message
- [ ] `GET /docs` shows Swagger UI
- [ ] `POST /api/v1/telemetry` accepts test payload
- [ ] `GET /api/v1/incidents` returns incidents from Supabase
- [ ] Supabase connection works (check logs)
- [ ] Gemini API works (check logs for AI summary generation)
- [ ] CORS allows Vercel dashboard origin
- [ ] Health check passes (Render auto-monitors `/ping`)

### Test Commands
```bash
# Health check
curl https://proactive-guard-api.onrender.com/ping

# Test telemetry endpoint
curl -X POST https://proactive-guard-api.onrender.com/api/v1/telemetry \
  -H "Content-Type: application/json" \
  -d '{"user_id":"test-user","latitude":19.123,"longitude":72.891,"motion_score":0.5,"audio_score":0.7}'

# List incidents
curl https://proactive-guard-api.onrender.com/api/v1/incidents
```

---

## Updating Member 1 & Member 2 with Backend URL

After deployment, share:

| Member | What They Need | Where to Update |
|--------|----------------|-----------------|
| **Member 1 (Mobile)** | Backend API base URL | `mobile/lib/utils/constants.dart` — `apiBaseUrl` |
| **Member 2 (Dashboard)** | Backend API base URL | Vercel env: `NEXT_PUBLIC_API_BASE_URL` |
| **Member 6 (Integration)** | For QR codes, docs | `docs/QR_CODES.md` |

**Communication Template:**
```
🚀 Backend Deployed!
URL: https://proactive-guard-api.onrender.com
Health: https://proactive-guard-api.onrender.com/ping
Swagger: https://proactive-guard-api.onrender.com/docs

Member 1: Update constants.dart → apiBaseUrl = "https://proactive-guard-api.onrender.com"
Member 2: Update Vercel env → NEXT_PUBLIC_API_BASE_URL = "https://proactive-guard-api.onrender.com"
Member 6: Update QR_CODES.md
```

---

## Member 1: Mobile App Configuration

### `mobile/lib/utils/constants.dart`
```dart
class AppConstants {
  // UPDATE THIS after backend deployment
  static const String apiBaseUrl = 'https://proactive-guard-api.onrender.com';
  static const String dashboardBaseUrl = 'https://proactive-guard.vercel.app';
  
  // API Endpoints
  static const String telemetryEndpoint = '/api/v1/telemetry';
  static const String sosEndpoint = '/api/v1/incidents/sos';
  static const String incidentsEndpoint = '/api/v1/incidents';
  static const String journeysEndpoint = '/api/v1/journeys';
  static const String healthEndpoint = '/ping';
}
```

### `mobile/lib/services/api.dart` (Verify Uses Constant)
```dart
class ApiService {
  final String baseUrl = AppConstants.apiBaseUrl;
  
  Future<IncidentResponse> sendTelemetry(TelemetryData data) async {
    final response = await http.post(
      Uri.parse('$baseUrl${AppConstants.telemetryEndpoint}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data.toJson()),
    );
    // ...
  }
}
```

---

## Troubleshooting

| Issue | Cause | Fix |
|-------|-------|-----|
| Build fails: "Module not found" | Missing deps in requirements.txt | Add missing packages, push |
| Start command fails | Wrong module path | Verify `app.main:app` matches `backend/app/main.py` |
| Port binding error | Hardcoded port | Use `--port 10000` (Render sets PORT env var) |
| Supabase connection timeout | Wrong URL/Key | Verify `SUPABASE_URL` and `SUPABASE_SERVICE_KEY` |
| Gemini API error | Invalid/Quota exceeded | Check `GEMINI_API_KEY`, verify quota in Google Cloud |
| CORS errors from dashboard | Origin not allowed | Add Vercel URL to `CORS_ORIGINS` in Render env |
| 502 Bad Gateway | App crashed | Check Render logs → Fix error → Auto-redeploy |
| Free tier spins down | Inactivity > 15 min | First request after spin-down takes 30-60s (normal) |

---

## Render Free Tier Limits

| Resource | Limit |
|----------|-------|
| **Build Minutes** | 500/month |
| **Runtime Hours** | 750/month (spins down after 15min inactivity) |
| **Bandwidth** | 100 GB/month |
| **Disk** | 1 GB ephemeral |
| **Custom Domains** | Unlimited |

**For SIH Demo:** Service spins down after 15 min inactivity. Ping `/ping` before demo to warm up.

---

## Custom Domain (Optional)

1. Render Dashboard → Service → Settings → Custom Domains
2. Add: `api.proactiveguard.in`
3. DNS: CNAME `api` → `proactive-guard-api.onrender.com`
4. SSL auto-provisioned

---

## Rollback

```bash
# Render Dashboard: Deploys → Select previous → "Rollback to this deploy"
# Or: Trigger new deploy from GitHub commit
```

---

## Costs
- **Render Free Tier:** Sufficient for SIH demo and light testing
- **Paid Plans:** $7/month for always-on, more resources (not needed)

---

*Last Updated: Day 3 — Member 6*
*Version: 1.0*