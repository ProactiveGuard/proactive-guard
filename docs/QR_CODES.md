# QR Codes & Links Checklist — SIH 2026

## Overview
This document tracks all URLs that need QR codes for the presentation. **DO NOT invent URLs** — use placeholders until actual deployed URLs are available.

---

## Required QR Codes

| # | Label | Placeholder URL | Actual URL (Fill After Deploy) | QR Generated? |
|---|-------|-----------------|--------------------------------|---------------|
| 1 | **Vercel Dashboard** | `https://proactive-guard.vercel.app` | `https://<actual>.vercel.app` | ☐ |
| 2 | **Render Backend Health** | `https://proactive-guard-api.onrender.com/ping` | `https://<actual>.onrender.com/ping` | ☐ |
| 3 | **Render Backend Swagger** | `https://proactive-guard-api.onrender.com/docs` | `https://<actual>.onrender.com/docs` | ☐ |
| 4 | **GitHub Repository** | `https://github.com/<org>/proactive-guard` | `https://github.com/<actual-org>/proactive-guard` | ☐ |
| 5 | **Demo Video (30s)** | `https://drive.google.com/file/d/<id>/view` | `https://drive.google.com/file/d/<actual-id>/view` | ☐ |
| 6 | **Demo Video (3min)** | `https://drive.google.com/file/d/<id>/view` | `https://drive.google.com/file/d/<actual-id>/view` | ☐ |
| 7 | **Supabase Dashboard** | `https://supabase.com/dashboard/project/<ref>` | `https://supabase.com/dashboard/project/<actual-ref>` | ☐ |
| 8 | **Architecture Diagram** | `https://github.com/<org>/proactive-guard/blob/main/docs/ARCHITECTURE.png` | `https://github.com/<actual-org>/proactive-guard/blob/main/docs/ARCHITECTURE.png` | ☐ |

---

## QR Code Generation

### Online Generators (Free)
- **QR Code Monkey:** https://www.qrcode-monkey.com/
- **QRickit:** https://qrickit.com/
- **GoQR.me:** https://goqr.me/
- **Google Chart API:** `https://chart.googleapis.com/chart?cht=qr&chl=<URL>&chs=300x300`

### CLI (Python)
```bash
pip install qrcode[pil]

# Generate
python -c "
import qrcode
img = qrcode.make('https://proactive-guard.vercel.app')
img.save('qr_dashboard.png')
"
```

### CLI (Node)
```bash
npm install -g qrcode-terminal
# Or for image:
npx qrcode "https://proactive-guard.vercel.app" -o qr_dashboard.png
```

---

## QR Code Specifications

| Parameter | Value |
|-----------|-------|
| **Size** | 300x300 px minimum (for projector visibility) |
| **Format** | PNG (for slides), SVG (for print) |
| **Error Correction** | Level M (15%) or Q (25%) |
| **Margin** | 4 modules (quiet zone) |
| **Colors** | Black on white (high contrast) |
| **Label** | Include human-readable label below QR |

---

## QR Code Layout for Slides

### Slide: "Live Demo URLs" (During Demo)
```
┌─────────────────────────────────────────────┐
│  SCAN TO VIEW LIVE                          │
│                                             │
│  ┌──────────┐         ┌──────────┐         │
│  │   QR 1   │         │   QR 2   │         │
│  │Dashboard │         │  Backend │         │
│  └──────────┘         └──────────┘         │
│                                             │
│  Dashboard: proactive-guard.vercel.app      │
│  API Health: api.guard.in/ping              │
└─────────────────────────────────────────────┘
```

### Slide: "Repository & Resources" (End)
```
┌─────────────────────────────────────────────┐
│  RESOURCES & SOURCE CODE                    │
│                                             │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  │
│  │   QR 3   │  │   QR 4   │  │   QR 5   │  │
│  │ GitHub   │  │ 30s Vid  │  │ 3min Vid │  │
│  └──────────┘  └──────────┘  └──────────┘  │
│                                             │
│  GitHub: github.com/org/proactive-guard     │
│  Videos: drive.google.com/folder/xyz        │
└─────────────────────────────────────────────┘
```

---

## Generation Checklist (Day 5 Morning)

### After All Deployments Complete
- [ ] Vercel Dashboard URL known → Generate QR 1
- [ ] Render Backend URL known → Generate QR 2, QR 3
- [ ] GitHub repo URL confirmed → Generate QR 4
- [ ] Demo videos uploaded to Google Drive → Generate QR 5, QR 6
- [ ] Supabase project URL known → Generate QR 7
- [ ] Architecture PNG on GitHub → Generate QR 8

### Verify Each QR
- [ ] Scan with phone → Opens correct URL
- [ ] Test on second phone (different OS)
- [ ] Print test: 3cm x 3cm readable
- [ ] Projector test: 10cm x 10cm readable from 3m

### Add to Presentation
- [ ] Insert QR 1, QR 2 in "Live Demo" slide
- [ ] Insert QR 3, QR 4, QR 5 in "Resources" slide
- [ ] Insert QR 6, QR 7, QR 8 in appendix/handout

---

## Placeholder QR Images (For Draft Slides)

Until real URLs exist, use these placeholder patterns in slides:

### Markdown for Draft Slides
```markdown
![Dashboard QR](https://api.qrserver.com/v1/create-qr-code/?size=300x300&data=https%3A%2F%2Fproactive-guard.vercel.app)
![Backend QR](https://api.qrserver.com/v1/create-qr-code/?size=300x300&data=https%3A%2F%2Fproactive-guard-api.onrender.com%2Fping)
![GitHub QR](https://api.qrserver.com/v1/create-qr-code/?size=300x300&data=https%3A%2F%2Fgithub.com%2Forg%2Fproactive-guard)
```

### Google Chart API URLs (Auto-generate)
| Label | Chart API URL |
|-------|---------------|
| Dashboard | `https://chart.googleapis.com/chart?cht=qr&chl=https://proactive-guard.vercel.app&chs=300x300&chld=M|0` |
| Backend Health | `https://chart.googleapis.com/chart?cht=qr&chl=https://proactive-guard-api.onrender.com/ping&chs=300x300&chld=M|0` |
| GitHub | `https://chart.googleapis.com/chart?cht=qr&chl=https://github.com/org/proactive-guard&chs=300x300&chld=M|0` |

---

## Final URLs Tracker (Update This Table)

| Service | Final URL | QR Filename | Added to Slides? |
|---------|-----------|-------------|------------------|
| Vercel Dashboard | | `qr_dashboard.png` | ☐ |
| Render Backend Health | | `qr_backend_health.png` | ☐ |
| Render Backend Swagger | | `qr_backend_swagger.png` | ☐ |
| GitHub Repository | | `qr_github.png` | ☐ |
| Demo Video 30s | | `qr_video_30s.png` | ☐ |
| Demo Video 3min | | `qr_video_3min.png` | ☐ |
| Supabase Dashboard | | `qr_supabase.png` | ☐ |
| Architecture Diagram | | `qr_architecture.png` | ☐ |

---

## Printing Instructions

### For Handouts (Business Card Size)
- Print QR codes at **3.5cm x 3.5cm** minimum
- Use **300 DPI** minimum
- Include **label text** below each QR
- Print on **matte cardstock** (glare-free)

### For Poster/Standee
- Print QR codes at **10cm x 10cm**
- Test scan from **2-3 meters**

### File Naming Convention
```
qr_<service>_<variant>.png
Examples:
qr_dashboard_main.png
qr_backend_health.png
qr_github_main.png
qr_video_demo_30s.png
```

---

## Emergency: No QR Codes Available

If QR generation fails day-of:
1. **Display URLs as text** on slides (large font, high contrast)
2. **Read URLs aloud** during presentation
3. **Share via chat** if virtual/hybrid
4. **Print URLs on paper** handouts

**Never skip showing the live system** because QR codes aren't ready.

---

*Last Updated: Day 4 — Member 6*
*Version: 1.0 — Placeholders only. Fill actual URLs after deployment.*