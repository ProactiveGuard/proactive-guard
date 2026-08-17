# API Documentation — Proactive Guard

## Base URL
- **Development:** `http://localhost:8000`
- **Production:** `https://proactive-guard-api.onrender.com`

## Authentication
Currently: API key in header (planned: JWT Bearer tokens)
```
Authorization: Bearer <api-key>
```

---

## Endpoints

### Health Check
```
GET /ping
```

**Response:**
```json
{
  "status": "I am ok",
  "message": "Proactive Guard API is running and ready to receive telemetry data."
}
```

---

### Telemetry Ingestion
```
POST /api/v1/telemetry
```

**Description:** Receives sensor data from mobile app, evaluates risk, creates incident if threshold exceeded.

**Request Body:**
```json
{
  "user_id": "string",
  "latitude": "number",
  "longitude": "number",
  "motion_score": "number (0-1)",
  "audio_score": "number (0-1)"
}
```

**Field Details:**
| Field | Type | Range | Description |
|-------|------|-------|-------------|
| `user_id` | string | - | Unique user identifier |
| `latitude` | float | -90 to 90 | GPS latitude |
| `longitude` | float | -180 to 180 | GPS longitude |
| `motion_score` | float | 0.0 to 1.0 | Normalized motion intensity |
| `audio_score` | float | 0.0 to 1.0 | Normalized audio level |

**Response (200):**
```json
{
  "incident_id": "INC-1723456789",
  "severity": "CRITICAL",
  "risk_score": 94,
  "summary": "User user-123 detected in CRITICAL state...",
  "latitude": 19.123456,
  "longitude": 72.891234
}
```

**Severity Levels:** `SAFE` | `MONITOR` | `HIGH RISK` | `CRITICAL`

---

### Manual SOS Trigger
```
POST /api/v1/incidents/sos
```

**Description:** Explicit SOS button press from mobile app.

**Request Body:**
```json
{
  "user_id": "string",
  "latitude": "number",
  "longitude": "number",
  "audio_level": "integer (1-10)",
  "motion_level": "integer (1-10)",
  "note": "string (optional)"
}
```

**Response (200):** Same as telemetry response, with `severity` forced to at least `HIGH RISK`.

---

### List Incidents
```
GET /api/v1/incidents
```

**Query Parameters:**
| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `limit` | integer | 50 | Max results |
| `offset` | integer | 0 | Pagination offset |
| `severity` | string | all | Filter: SAFE, MONITOR, HIGH RISK, CRITICAL |
| `user_id` | string | all | Filter by user |

**Response (200):**
```json
[
  {
    "incident_id": "INC-1723456789",
    "severity": "CRITICAL",
    "risk_score": 94,
    "latitude": 19.123456,
    "longitude": 72.891234,
    "summary": "User detected in CRITICAL state...",
    "created_at": "2026-08-17T10:15:00Z"
  }
]
```

---

### Get Incident Detail
```
GET /api/v1/incidents/{incident_id}
```

**Response (200):**
```json
{
  "incident_id": "INC-1723456789",
  "user_id": "user-123",
  "severity": "CRITICAL",
  "risk_score": 94,
  "latitude": 19.123456,
  "longitude": 72.891234,
  "summary": "User detected in CRITICAL state. Loud distress audio (9/10). Rapid movement (8/10). Off-route at 22:15. Immediate attention required.",
  "audio_level": 9,
  "motion_level": 8,
  "time_of_day": 22,
  "is_off_route": true,
  "location_name": "Main Street",
  "ai_summary": "User user-123 detected in CRITICAL state (Risk Score: 94/100) near Main Street. User deviated off-route at 22:00. Loud distress/ambient audio recorded (9/10). Rapid movement/running detected (8/10). Immediate attention and verification required.",
  "created_at": "2026-08-17T10:15:00Z",
  "updated_at": "2026-08-17T10:15:00Z"
}
```

---

### Start Journey
```
POST /api/v1/journeys
```

**Request Body:**
```json
{
  "user_id": "string",
  "start_lat": "number",
  "start_lng": "number",
  "end_lat": "number",
  "end_lng": "number",
  "planned_route": "object (optional, GeoJSON)"
}
```

**Response (201):**
```json
{
  "journey_id": "JRN-1723456789",
  "user_id": "user-123",
  "status": "active",
  "started_at": "2026-08-17T10:00:00Z"
}
```

---

### Get Journey Status
```
GET /api/v1/journeys/{journey_id}
```

**Response (200):**
```json
{
  "journey_id": "JRN-1723456789",
  "user_id": "user-123",
  "start_lat": 19.123,
  "start_lng": 72.891,
  "end_lat": 19.150,
  "end_lng": 72.900,
  "current_lat": 19.135,
  "current_lng": 72.895,
  "status": "active",
  "is_off_route": false,
  "started_at": "2026-08-17T10:00:00Z",
  "updated_at": "2026-08-17T10:12:00Z"
}
```

---

## Error Responses

| Status | Code | Description |
|--------|------|-------------|
| 400 | `VALIDATION_ERROR` | Invalid request body |
| 401 | `UNAUTHORIZED` | Missing/invalid auth |
| 404 | `NOT_FOUND` | Resource not found |
| 422 | `UNPROCESSABLE_ENTITY` | Validation failed |
| 500 | `INTERNAL_ERROR` | Server error |
| 503 | `SERVICE_UNAVAILABLE` | Dependency down (Supabase, Gemini) |

**Error Format:**
```json
{
  "error": "VALIDATION_ERROR",
  "message": "Invalid latitude: must be between -90 and 90",
  "details": {}
}
```

---

## Rate Limits
- **Telemetry:** 10 requests/second per user
- **SOS:** 5 requests/minute per user
- **Incidents list:** 60 requests/minute
- **Journeys:** 30 requests/minute

---

## Webhooks (Planned)
- `incident.created` → POST to configured URL
- `journey.off_route` → POST to configured URL
- `journey.completed` → POST to configured URL

---

*Generated from FastAPI auto-docs at `/docs`*
*Last Updated: Day 5 — Member 6*