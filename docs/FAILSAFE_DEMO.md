# Failsafe Demo Plan — SIH 2026 Judging

## Purpose
If live internet fails during judging, we play a pre-recorded video demonstrating the complete SOS flow. This ensures judges see the working system regardless of venue connectivity.

---

## Recording Specification

### What to Record
**Complete End-to-End Flow (Target: 60-90 seconds)**

| Scene | Duration | Description |
|-------|----------|-------------|
| 1. App Launch | 5s | Open Flutter app, show home screen |
| 2. Start Journey | 10s | Tap "Start Journey" → "Journey Home" → show live GPS + sensor bars |
| 3. Off-Route Alert | 10s | Simulate route deviation → Dashboard shows yellow marker |
| 4. Distress Simulation | 15s | Shake phone (motion) + play loud audio → sensor bars spike |
| 5. AI Detection | 10s | Backend terminal: "CRITICAL incident created: INC-xxx" |
| 6. Dashboard Alert | 15s | Dashboard: Red marker flashes + sound → Member 2 clicks → detail view |
| 7. AI Summary | 10s | Show Gemini-generated summary in detail view |
| 8. Notifications | 10s | Toast: "Police + Parents + Security notified" |
| 9. Key Message | 5s | Text overlay: **"Victim never pressed SOS. System detected danger automatically."** |

### Technical Recording Setup

**Equipment:**
- Phone: Android device running Flutter app (Member 1's phone)
- Screen Recording: `scrcpy` (USB) or built-in screen recorder
- Dashboard: Laptop with browser (Member 2)
- Backend Terminal: Visible in recording (split screen or separate clip)
- Audio: Narrate key moments (Member 6 voiceover)

**Recording Tools:**
```bash
# Option 1: scrcpy (best quality, USB)
scrcpy --record=demo_raw.mp4 --max-size=1080 --bit-rate=8M

# Option 2: Android built-in (Settings → Developer → Screen Record)
# Option 3: OBS Studio (composite: phone + dashboard + terminal)
```

**Recommended: OBS Studio Composite**
```
┌─────────────────────────────────────────────────────────┐
│  OBS Scene: "SIH Demo"                                  │
│  ┌─────────────┐  ┌─────────────────────────────────┐  │
│  │  Phone      │  │  Dashboard (Browser)            │  │
│  │  (scrcpy)   │  │  + Backend Terminal (small)     │  │
│  └─────────────┘  └─────────────────────────────────┘  │
│  Audio: Member 6 microphone (narration)                │
└─────────────────────────────────────────────────────────┘
```

---

## Video Files Required

### Primary: `video/demo_30s.mp4`
- **Duration:** 30-45 seconds (highlight reel)
- **Use Case:** Quick intro, judge walkthrough, backup
- **Content:** Journey start → Distress → Red alert → Notifications

### Full: `video/full_walkthrough_3min.mp4`
- **Duration:** 2-3 minutes (complete narrative)
- **Use Case:** Detailed viewing, Q&A reference, submission package
- **Content:** Full flow with narration explaining each step

---

## Recording Checklist

### Pre-Recording
- [ ] Backend deployed and warmed up (`curl /ping`)
- [ ] Dashboard loaded and connected to Supabase
- [ ] Flutter app installed on phone (release build preferred)
- [ ] Test data: Supabase has 2-3 sample incidents
- [ ] Phone: GPS on, microphone permission granted, motion permission granted
- [ ] Phone: Do Not Disturb mode ON
- [ ] Phone: Battery > 80% or plugged in
- [ ] Internet: Primary WiFi + Mobile hotspot backup ready
- [ ] OBS/scrcpy tested and configured
- [ ] Member 6 narration script printed

### During Recording
- [ ] Record multiple takes (minimum 3)
- [ ] Verify each take: all steps visible, no errors
- [ ] Check audio: narration clear, no background noise
- [ ] Check video: 1080p, 30fps, readable text
- [ ] Note timestamp of best take

### Post-Recording
- [ ] Edit: Trim to 30s and 3min versions
- [ ] Add: Text overlays for key metrics (Risk Score: 94, CRITICAL, etc.)
- [ ] Add: Subtitles for narration (judges may watch without audio)
- [ ] Export: H.264, MP4, <100MB each
- [ ] Verify: Plays on Windows/Mac/Linux (test on judge laptop if possible)
- [ ] Backup: Copy to 2 USB drives + Google Drive + GitHub release

---

## Failsafe Demo Execution Plan

### Scenario A: Live Demo Works (Preferred)
1. Run live demo as per `docs/DEMO_SCRIPT.md`
2. Failsafe video not needed

### Scenario B: Partial Failure (Dashboard loads, phone fails)
1. Show live dashboard with pre-seeded incidents
2. Play `demo_30s.mp4` for phone-side flow
3. Narrate: "Here's the mobile side working..."

### Scenario C: Complete Internet Failure
1. **Immediately** switch to `full_walkthrough_3min.mp4`
2. Play full video on laptop (pre-loaded, no streaming)
3. Member 6 narrates live over video (pause/resume as needed)
4. After video: "This was recorded yesterday on our deployed system. Happy to answer questions."

### Scenario D: Projector/Display Failure
1. Gather judges around laptop
2. Play video on laptop screen
3. Continue with Q&A

---

## Video Storage Locations

| Location | Path/URL | Access |
|----------|----------|--------|
| **GitHub Repo** | `video/demo_30s.mp4`, `video/full_walkthrough_3min.mp4` | Team (clone) |
| **Google Drive** | Shared folder: "Proactive Guard SIH Demo" | Team + Member 6 |
| **USB Drive 1** | Member 6 pocket | Offline backup |
| **USB Drive 2** | Member 1 bag | Redundancy |
| **Laptop Local** | `~/Videos/sih-demo/` | Immediate access |

**Do NOT rely on cloud streaming during judging.**

---

## Narration Script (Member 6)

> **[0:00-0:05]** "This is Proactive Guard. Priya starts her journey home."
>
> **[0:05-0:15]** "Sensors active: GPS tracking, audio monitoring, motion analysis. All streaming to our AI."
>
> **[0:15-0:25]** "She takes a shortcut — off-route detected. Yellow alert on command center."
>
> **[0:25-0:35]** "Suddenly — distress. Audio spikes. Motion spikes. It's 10 PM."
>
> **[0:35-0:45]** "Our AI Risk Engine: 94 out of 100. CRITICAL. Incident auto-created. No button pressed."
>
> **[0:45-0:55]** "Real-time on dashboard. Red marker. Gemini AI summary: 'Loud distress audio, rapid movement, off-route.'"
>
> **[0:55-1:05]** "One click: Police dispatched. Parents notified. Security alerted. Simultaneous."
>
> **[1:05-1:10]** "The victim never touched her phone. The system *saw* the danger. That's Proactive Guard."

---

## Video Encoding Specs

| Parameter | Value |
|-----------|-------|
| Container | MP4 |
| Video Codec | H.264 (AVC) |
| Audio Codec | AAC |
| Resolution | 1920x1080 (1080p) |
| Frame Rate | 30 fps |
| Video Bitrate | 8-12 Mbps |
| Audio Bitrate | 128-192 kbps |
| Max File Size | 100 MB (30s), 300 MB (3min) |

**FFmpeg Commands:**
```bash
# 30s highlight reel
ffmpeg -i demo_raw.mp4 -ss 00:00:05 -t 30 -c:v libx264 -crf 20 -preset fast -c:a aac -b:a 128k video/demo_30s.mp4

# 3min full walkthrough
ffmpeg -i demo_raw.mp4 -c:v libx264 -crf 22 -preset medium -c:a aac -b:a 192k video/full_walkthrough_3min.mp4
```

---

## Day-of-Judging Checklist

### Morning (Before Venue)
- [ ] Copy both videos to laptop SSD (not external drive)
- [ ] Test playback in VLC / Windows Media Player / QuickTime
- [ ] Verify audio works on laptop speakers
- [ ] Pack: Laptop, charger, 2 USB drives, phone, hotspot device
- [ ] Verify hotspot has data balance

### At Venue (Setup)
- [ ] Connect laptop to projector (HDMI/USB-C)
- [ ] Test display: Clone or Extend mode
- [ ] Open video files in player, pause at start
- [ ] Test audio level
- [ ] Position phone for live demo (charging, Do Not Disturb)
- [ ] Open dashboard in browser, verify loaded
- [ ] Ping backend: `curl https://api-url/ping`

### During Demo
- [ ] Member 6: Laptop ready with video player (VLC recommended — spacebar pause/play)
- [ ] Member 1: Phone in hand, app open
- [ ] Member 2: Dashboard on projector
- [ ] Member 4: Backend logs visible (optional)

### Emergency Contacts
- Member 6 (Integration Lead): Has all videos, drives, narration script
- Member 1 (Mobile): Has phone, can run live if needed
- Member 2 (Dashboard): Can show dashboard offline (cached)

---

## Post-Judging
- [ ] Upload final videos to GitHub Release v1.0-submission
- [ ] Share Google Drive link with team
- [ ] Archive raw footage for future reference

---

*Last Updated: Day 3 — Member 6*
*Version: 1.0*