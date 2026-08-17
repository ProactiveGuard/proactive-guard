# Demo Script — SIH 2026 Live Demonstration

## Overview
**Duration:** 2 minutes exactly  
**Participants:** Member 1 (Mobile), Member 2 (Dashboard), Member 6 (Narrator)  
**Setup:** Phone → Projector (scrcpy), Dashboard → Projector, Backend terminal visible (optional)

---

## Pre-Demo Checklist (T-5 min)
- [ ] Backend warmed: `curl https://api.guard.in/ping` ✅
- [ ] Dashboard loaded: `https://dash.guard.in` ✅
- [ ] Phone: App open, logged in, GPS on, permissions granted ✅
- [ ] Phone: Do Not Disturb ON, battery >50% ✅
- [ ] Projector: Phone screen mirrored (scrcpy), Dashboard full-screen ✅
- [ ] Timer: 2-min countdown visible to Member 6 ✅
- [ ] Failsafe video: Queued in VLC, paused at start ✅

---

## Demo Flow (120 Seconds)

### 0:00-0:10 | Journey Start
| Time | Action | Visual | Narrator (Member 6) |
|------|--------|--------|---------------------|
| 0:00 | Member 1 taps **"Start Journey"** → **"Home"** | Phone: Journey screen loads, GPS dot appears, sensor bars at baseline | **"Priya is walking home. She starts a journey in Proactive Guard."** |
| 0:05 | Member 1 walks (simulated) | Phone: GPS updates, audio/motion bars show normal | **"Sensors active: GPS every 10 seconds, audio monitoring, motion analysis — all streaming to our AI."** |
| 0:10 | Dashboard shows journey | Dashboard: LiveMap shows blue position dot, journey polyline | **"Command center sees her live position. Route tracked in real-time."** |

### 0:10-0:25 | Route Deviation (Yellow Alert)
| Time | Action | Visual | Narrator |
|------|--------|--------|----------|
| 0:10 | Member 1 taps **"Simulate Off-Route"** (or walks off-path) | Phone: Yellow banner "Off-route detected" | **"She takes a shortcut — off-route detected."** |
| 0:15 | Dashboard updates | Dashboard: Yellow marker 🟡 appears on map, incident list shows MONITOR | **"Yellow alert on command center. Risk score increased. Security notified."** |
| 0:20 | Member 6 points to dashboard | Projector: Map zoom to show deviation | **"Notice: No button pressed. The system *knows* she deviated."** |

### 0:25-0:45 | Distress Event (Red Alert)
| Time | Action | Visual | Narrator |
|------|--------|--------|----------|
| 0:25 | Member 1: **Shakes phone vigorously** + **plays loud audio** (pre-recorded scream on second phone) | Phone: Audio bar 🔴 spikes to 9/10, Motion bar 🔴 spikes to 8/10 | **"Suddenly — distress. Audio spikes to 9. Motion spikes to 8. It's 10:15 PM — night bonus applies."** |
| 0:30 | Backend terminal | Terminal: `CRITICAL incident created: INC-1723456789 | Risk: 94` | **"AI Risk Engine: 94 out of 100. CRITICAL."** |
| 0:35 | Dashboard: Red alert | Dashboard: Red marker 🔴 flashes + alert sound, incident list updates | **"Real-time on dashboard. Red marker. Zero latency — Supabase Realtime."** |
| 0:40 | Member 2 clicks red marker | Dashboard: Detail panel opens, shows AI summary, GPS, severity | **"Member 2 opens detail. Gemini AI summary generated instantly."** |
| 0:45 | Member 2 clicks **"Dispatch Police"** | Dashboard: Toast "Police + Parents + Security notified" | **"One click: Police dispatched. Parents notified. Campus security alerted. Simultaneous."** |

### 0:45-1:00 | Key Message & Close
| Time | Action | Visual | Narrator |
|------|--------|--------|----------|
| 0:45 | Member 6 steps forward, gestures to phone | Phone: Still on journey screen, no SOS pressed | **"Critical point: Priya never pressed SOS. She couldn't. The system *saw* the danger."** |
| 0:55 | Member 6 walks to dashboard | Dashboard: Incident list shows CRITICAL resolved | **"From anomaly to alert in 20 seconds. Proactive, not reactive."** |
| 1:00 | **END DEMO** | Title slide or "Thank You" | **"That's Proactive Guard. Safety that sees what you can't."** |

---

## Exact Narrator Script (Member 6)

> **[0:00]** "Priya is walking home. She starts a journey in Proactive Guard."
>
> **[0:05]** "Sensors active: GPS every 10 seconds, audio monitoring, motion analysis — all streaming to our AI."
>
> **[0:10]** "Command center sees her live position. Route tracked in real-time."
>
> **[0:10]** "She takes a shortcut — off-route detected."
>
> **[0:15]** "Yellow alert on command center. Risk score increased. Security notified."
>
> **[0:20]** "Notice: No button pressed. The system *knows* she deviated."
>
> **[0:25]** "Suddenly — distress. Audio spikes to 9. Motion spikes to 8. It's 10:15 PM — night bonus applies."
>
> **[0:30]** "AI Risk Engine: 94 out of 100. CRITICAL."
>
> **[0:35]** "Real-time on dashboard. Red marker. Zero latency — Supabase Realtime."
>
> **[0:40]** "Member 2 opens detail. Gemini AI summary generated instantly."
>
> **[0:45]** "One click: Police dispatched. Parents notified. Campus security alerted. Simultaneous."
>
> **[0:45]** "Critical point: Priya never pressed SOS. She couldn't. The system *saw* the danger."
>
> **[0:55]** "From anomaly to alert in 20 seconds. Proactive, not reactive."
>
> **[1:00]** "That's Proactive Guard. Safety that sees what you can't."

---

## Member Actions Cheat Sheet

### Member 1 (Mobile)
| Cue | Action | Backup if Fails |
|-----|--------|-----------------|
| "Priya starts a journey" | Tap "Start Journey" → "Home" | Spare phone / Emulator |
| "Off-route detected" | Tap "Simulate Off-Route" button | Pre-recorded video |
| "Audio spikes... Motion spikes" | Shake phone + play audio (2nd phone) | Pre-recorded video |
| End | Hold phone visible | N/A |

### Member 2 (Dashboard)
| Cue | Action | Backup if Fails |
|-----|--------|-----------------|
| "Command center sees..." | Dashboard already loaded, map centered | Refresh if needed |
| "Yellow alert..." | Point to yellow marker | N/A |
| "Red marker..." | Click red marker immediately | N/A |
| "Opens detail..." | Detail panel auto-opens on click | N/A |
| "One click: Dispatch..." | Click "Dispatch Police" button | N/A |

### Member 6 (Narrator)
| Cue | Action |
|-----|--------|
| Timer start | Start 2-min countdown |
| Each segment | Deliver script line, gesture to relevant screen |
| "Member 2 clicks..." | Step back, let Member 2 take focus |
| End | "That's Proactive Guard..." → Transition to Q&A |

---

## Failure Recovery (During Demo)

| Failure | Immediate Action | Fallback |
|---------|------------------|----------|
| Phone won't connect | "Let me show the recorded demo" → Play `demo_30s.mp4` | Member 6 narrates over video |
| Dashboard not loading | Refresh browser (Ctrl+R), wait 5s | "Dashboard shows..." → Describe from memory |
| Backend 500 error | "Backend had a hiccup, but here's what happened" → Play video | Member 6 narrates |
| Projector fails | Gather judges around laptop | Continue with laptop screen |
| Audio not heard | Speak louder, repeat key points | N/A |
| Time running over | Skip detail view, go straight to "Dispatch" | Cut to key message |

---

## Timing Benchmarks (Practice Targets)

| Segment | Target | Max |
|---------|--------|-----|
| Journey Start | 10s | 15s |
| Route Deviation | 15s | 20s |
| Distress Event | 20s | 25s |
| Dashboard Interaction | 10s | 15s |
| Key Message | 15s | 20s |
| **Total** | **70s** | **95s** |

**Buffer:** 25-50 seconds for transitions, judge reactions, unexpected delays.

---

## Post-Demo Immediate Actions

1. **Member 6:** "We'd love to take your questions. Team, over to you."
2. **All:** Stand ready for Q&A (see `JUDGE_QA.md`)
3. **Member 1:** Put phone on silent, keep accessible
4. **Member 2:** Keep dashboard open for reference
5. **Member 6:** Moderate Q&A, route questions

---

## Equipment Positions

```
┌─────────────────────────────────────────────────────────────┐
│                     JUDGES TABLE                            │
└─────────────────────────────────────────────────────────────┘
                              ▲
                              │ 3-4 meters
                              ▼
┌─────────────────────────────────────────────────────────────┐
│  PROJECTOR SCREEN                                           │
│  ┌──────────────────┐  ┌──────────────────┐                 │
│  │   PHONE (scrcpy) │  │  DASHBOARD       │                 │
│  │   (Left half)    │  │  (Right half)    │                 │
│  └──────────────────┘  └──────────────────┘                 │
└─────────────────────────────────────────────────────────────┘
                              ▲
                              │
              ┌───────────────┼───────────────┐
              ▼               ▼               ▼
         ┌─────────┐    ┌─────────┐    ┌─────────┐
         │Member 1 │    │Member 6 │    │Member 2 │
         │(Phone)  │    │(Center) │    │(Laptop) │
         └─────────┘    └─────────┘    └─────────┘
```

---

*Practice this exact flow 2x before judging day.*
*Last Updated: Day 5 — Member 6*