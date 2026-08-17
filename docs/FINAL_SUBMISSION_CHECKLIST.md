# Final Submission Checklist — SIH 2026

## Overview
Complete this checklist before final submission. Every item must be ✅ checked.

---

## Repository & Code

### GitHub Repository
- [ ] Repository clean: no merge conflicts, no untracked junk
- [ ] `main` branch protected, only PR merges
- [ ] **No secrets/API keys committed** (verify with `git log --all --full-history -- .env`)
- [ ] `.gitignore` includes: `.env`, `.env.*`, `*.key`, `*.secret`, `node_modules`, `__pycache__`, `.venv`, `venv`, `build`, `.dart_tool`
- [ ] All team members have write access
- [ ] Repository URL documented in `QR_CODES.md`

### Version Tag
- [ ] `v1.0-submission` tag created on `main`/`develop`
- [ ] Tag message: "SIH 2026 Submission - Proactive Guard"
- [ ] Tag pushed: `git push origin v1.0-submission`

---

## Deployed Services

### Vercel Dashboard
- [ ] Dashboard URL working: `https://<name>.vercel.app`
- [ ] Loads without console errors
- [ ] Incident list displays (fetches from Supabase)
- [ ] LiveMap renders with markers
- [ ] Realtime updates work (new incident appears <2s)
- [ ] Detail page `/incidents/[id]` works
- [ ] Mobile responsive
- [ ] Environment variables set in Vercel Dashboard

### Render Backend
- [ ] Backend URL working: `https://<name>.onrender.com`
- [ ] `GET /ping` returns 200
- [ ] `GET /docs` shows Swagger UI
- [ ] `POST /api/v1/telemetry` accepts test payload
- [ ] `GET /api/v1/incidents` returns data
- [ ] CORS allows Vercel origin
- [ ] Environment variables set in Render Dashboard
- [ ] Service stays awake (ping before demo)

### Supabase Database
- [ ] `incidents` table accessible
- [ ] `journeys` table accessible
- [ ] Realtime enabled for `incidents`
- [ ] RLS policies configured
- [ ] Sample data visible
- [ ] Backend reads/writes successfully

---

## Demo & Media

### Demo Video
- [ ] `video/demo_30s.mp4` exists, plays offline
- [ ] `video/full_walkthrough_3min.mp4` exists, plays offline
- [ ] Both videos tested on Windows/Mac/Linux
- [ ] Videos uploaded to Google Drive (backup)
- [ ] Video files <500MB each
- [ ] Audio narration clear

### APK Build
- [ ] `flutter build apk --release` succeeds
- [ ] `app-release.apk` generated
- [ ] APK installs on test device (Android 8+)
- [ ] App connects to production backend
- [ ] SOS flow works end-to-end
- [ ] APK copied to `submission/apk/app-release.apk`

### Architecture Diagram
- [ ] `docs/ARCHITECTURE.png` generated (1920x1080)
- [ ] `docs/ARCHITECTURE.svg` generated (vector)
- [ ] Both files in `submission/docs/`
- [ ] Diagram matches `ARCHITECTURE_FINAL.md`
- [ ] All 6 components clearly labeled

---

## QR Codes
- [ ] QR 1: Vercel Dashboard URL
- [ ] QR 2: Render Backend Health URL
- [ ] QR 3: Render Backend Swagger URL
- [ ] QR 4: GitHub Repository URL
- [ ] QR 5: Demo Video 30s (Google Drive)
- [ ] QR 6: Demo Video 3min (Google Drive)
- [ ] QR 7: Supabase Dashboard URL
- [ ] QR 8: Architecture Diagram URL
- [ ] All QR codes tested: scan → correct URL
- [ ] QR codes inserted in presentation slides

---

## Presentation Materials

### Pitch Deck
- [ ] `docs/PITCH_DECK.md` complete (Slides 1-6)
- [ ] `ppt/Proactive_Guard_SIH2026.pptx` created from markdown
- [ ] All 6 slides present
- [ ] Slide 4 references live demo
- [ ] Timing: Pitch ≤5min, Demo ≤2min, Q&A ≤3min
- [ ] Speaker notes in presenter view

### Demo Script
- [ ] `docs/DEMO_SCRIPT.md` complete
- [ ] Member 1: Phone ready, app open, journey started
- [ ] Member 2: Dashboard loaded, map visible
- [ ] Member 6: Narration script printed
- [ ] Transition cues practiced: "Let me show you..."

### Speaking Notes
- [ ] Member 6: Pitch slides 1-3, 5-6
- [ ] Member 1: Demo phone actions
- [ ] Member 2: Demo dashboard actions
- [ ] All: Q&A domain assignments clear
- [ ] Printed copies for each speaker

---

## Documentation Completeness

| Document | Status | Location |
|----------|--------|----------|
| README.md | ☐ | Root + `submission/docs/` |
| API_DOCS.md | ☐ | `submission/docs/` |
| AI_MODEL_CARD.md | ☐ | `submission/docs/` |
| ARCHITECTURE.png/.svg | ☐ | `submission/docs/` |
| INTEGRATION_TEST_CHECKLIST.md | ☐ | `docs/` |
| GITHUB_WORKFLOW.md | ☐ | `docs/` |
| VERCEL_DEPLOYMENT.md | ☐ | `docs/` |
| RENDER_DEPLOYMENT.md | ☐ | `docs/` |
| BACKUP_PLANS.md | ☐ | `docs/` |
| REHEARSAL_PLAN.md | ☐ | `docs/` |
| ARCHITECTURE_FINAL.md | ☐ | `docs/` |
| QR_CODES.md | ☐ | `docs/` |
| FAILSAFE_DEMO.md | ☐ | `docs/` |
| DEMO_SCRIPT.md | ☐ | `docs/` |
| JUDGE_QA.md | ☐ | `docs/` |
| FINAL_SUBMISSION_CHECKLIST.md | ☐ | `docs/` |
| RELEASE_CHECKLIST.md | ☐ | `docs/` |

---

## Submission Package Structure
```
submission/
├── code/
│   ├── mobile/           # Flutter source
│   ├── backend/          # FastAPI source
│   ├── dashboard/        # Next.js source
│   └── ai-engine/        # AI engine source
├── video/
│   ├── demo_30s.mp4
│   └── full_walkthrough_3min.mp4
├── docs/
│   ├── README.md
│   ├── ARCHITECTURE.png
│   ├── ARCHITECTURE.svg
│   ├── API_DOCS.md
│   └── AI_MODEL_CARD.md
├── ppt/
│   └── Proactive_Guard_SIH2026.pptx
└── apk/
    └── app-release.apk
```
- [ ] All folders exist
- [ ] Code folders contain source (or symlinks to main repo)
- [ ] Video files in place
- [ ] Docs in place
- [ ] PPTX in place
- [ ] APK in place

---

## Final Verification Commands

```bash
# 1. Verify no secrets in repo
git log --all --full-history --oneline -- .env .env.* *.key *.secret

# 2. Verify tag exists
git tag -l v1.0-submission

# 3. Verify backend health
curl https://<backend>.onrender.com/ping

# 4. Verify dashboard
curl -I https://<dashboard>.vercel.app

# 5. Verify APK exists
ls -la submission/apk/app-release.apk

# 6. Verify videos exist
ls -la submission/video/

# 7. Verify docs
ls -la submission/docs/

# 8. Verify architecture images
ls -la submission/docs/ARCHITECTURE.*
```

---

## Sign-Off

| Role | Name | ✅ Verified | Date |
|------|------|-------------|------|
| **Member 6 (Captain)** | | | |
| **Member 4 (Backend)** | | | |
| **Member 2 (Dashboard)** | | | |
| **Member 1 (Mobile)** | | | |
| **Member 5 (AI)** | | | |
| **Member 3 (Sensors)** | | | |

---

## Emergency Contacts (Day of Submission)

| Issue | Contact | Action |
|-------|---------|--------|
| Backend down | Member 4 | Switch to ngrok backup |
| Dashboard down | Member 2 | Switch to ngrok backup |
| Phone/app fails | Member 1 | Use emulator / failsafe video |
| Internet fails | Member 6 | Mobile hotspot |
| Video won't play | Member 6 | Play from USB / Google Drive |

---

*Final check: All items ✅ = Ready for submission*
*Last Updated: Day 5 — Member 6*