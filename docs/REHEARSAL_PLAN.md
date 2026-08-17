# Rehearsal Plan — SIH 2026 Final Presentation

## Presentation Structure (10 Minutes Total)

| Segment | Duration | Speaker | Content |
|---------|----------|---------|---------|
| **Pitch** | 5:00 | Member 6 | Slides 1-6 (Problem → Future) |
| **Live Demo** | 2:00 | Member 1 + 2 + 6 | SOS flow end-to-end |
| **Q&A** | 3:00 | All | Judge questions |
| **Total** | **10:00** | | **Buffer: ±30s** |

---

## Speaker Transitions

### Transition Map
```
[Member 6: Pitch Start]
    │
    ├─ Slide 1-3: Problem, Competition, Solution (Member 6)
    │
    ├─ Slide 4: Live Demo → "Let me show you..." [CUE]
    │       │
    │       ▼
    │   [Member 1: Presses SOS on phone]
    │       │
    │       ▼
    │   [Member 2: Dashboard shows alert]
    │       │
    │       ▼
    │   [Member 6: Narrates what happened]
    │
    ├─ Slide 5: Business Model (Member 6)
    │
    ├─ Slide 6: Future Scope (Member 6)
    │
    └─ Q&A: All members (Member 6 moderates)
```

### Exact Cue Lines

**Member 6 → Demo (Slide 4):**
> **"Let me show you how this works in real time. Member 1, please start a journey."**
> *(Member 1 taps "Start Journey" on phone)*
>
> **"Now watch the command center. Member 1 will simulate a distress event — no button press needed."**
> *(Member 1 shakes phone + plays audio)*
>
> **"There — AI detected CRITICAL. Member 2, show the dashboard."**
> *(Member 2 clicks red marker on projector)*
>
> **"Notice: The victim never pressed SOS. The system *saw* the danger."**

**Member 6 → Business (Slide 5):**
> **"This isn't just a hackathon project. Here's how it scales."**

**Member 6 → Future (Slide 6):**
> **"And this is just the beginning."**

**Member 6 → Q&A:**
> **"We'd love to take your questions. Team, over to you."**

---

## Detailed Timing Script

### Pitch Segment (5:00)

| Slide | Time | Key Points | Visual Cue |
|-------|------|------------|------------|
| **Title** | 0:00-0:10 | "Proactive Guard — AI-Powered Personal Safety" | Logo + Tagline |
| **1. Problem** | 0:10-1:10 | NCRB stats, reactive failures, "Help before I ask" | Stats table |
| **2. Competition** | 1:10-2:10 | Comparison table, 73% can't press button, scenario | Competitor matrix |
| **3. Solution** | 2:10-3:40 | 3-layer arch, Priya's journey, tech stack, metrics | Architecture + Timeline |
| **4. Demo** | 3:40-4:00 | **CUE: "Let me show you..."** | Transition to live |
| **Buffer** | 4:00-5:00 | Demo runs here (see below) | Live action |

### Live Demo Segment (2:00) — Overlaps with Slide 4 Time

| Time | Action | Who | Notes |
|------|--------|-----|-------|
| 0:00 | Member 1: Open app, tap "Start Journey" | M1 | Show phone screen via scrcpy/projector |
| 0:15 | Member 1: Walk sim (or shake) → off-route | M1 | Dashboard shows yellow |
| 0:30 | Member 1: Distress sim (shake + audio) | M1 | Audio/motion bars spike |
| 0:35 | Backend: CRITICAL incident created | M4/M6 | Terminal log visible |
| 0:40 | Dashboard: Red marker flashes + sound | M2 | Projector shows map |
| 0:45 | Member 2: Click marker → detail view | M2 | AI summary visible |
| 0:55 | Member 2: Click "Dispatch Police" | M2 | Toast: notifications sent |
| 1:00 | Member 6: "Victim never pressed button" | M6 | **Key message** |
| 1:10 | Member 6: Transition to Slide 5 | M6 | "This scales..." |

### Q&A Segment (3:00)

| Time | Activity |
|------|----------|
| 0:00-0:30 | Judges ask first question |
| 0:30-1:30 | 2-3 questions answered |
| 1:30-2:30 | Deeper technical/business questions |
| 2:30-3:00 | Closing statement by Member 6 |

---

## Two Full Rehearsals Required

### Rehearsal 1: Technical Run-Through (Day 4 Evening)
**Goal:** Verify all tech works, fix bugs, time each segment

**Setup:**
- [ ] Projector/monitor connected
- [ ] Phone → scrcpy → laptop → projector
- [ ] Dashboard on browser → projector
- [ ] Backend terminal visible
- [ ] Timer visible (phone stopwatch)
- [ ] Recording: OBS capturing everything

**Checklist:**
- [ ] Slide deck loads, animations work
- [ ] Member 1 phone: App installed, logged in, journey works
- [ ] Backend: `/ping` OK, SOS endpoint responds
- [ ] Dashboard: Loads, realtime works, map renders
- [ ] Supabase: Incidents table accessible
- [ ] Demo flow: SOS → Dashboard alert < 10 seconds
- [ ] Failsafe video: Plays offline, audio works
- [ ] **Timing:** Full run = 9:30 - 10:30 (adjust)

**Issues to Fix:**
- [ ] _______________________________________
- [ ] _______________________________________
- [ ] _______________________________________

### Rehearsal 2: Full Dress Rehearsal (Day 5 Morning)
**Goal:** Polish delivery, smooth transitions, handle Q&A

**Setup:** Same as Rehearsal 1 + formal attire optional

**Focus:**
- [ ] Member 6: Eye contact, pacing, voice projection
- [ ] Transitions: Verbal cues crisp, no dead air
- [ ] Member 1: Phone handling smooth, screen visible
- [ ] Member 2: Dashboard navigation confident
- [ ] Q&A: Each member knows their domain answers
- [ ] **Timing:** Must hit 9:45 - 10:15

**Record:** Full video for review
**Review:** Watch recording, note improvements

---

## Q&A Preparation

### Assigned Domains
| Member | Domain | Sample Questions |
|--------|--------|------------------|
| **Member 6** | Overall, Integration, Business, Future | Scaling, partnerships, roadmap |
| **Member 4** | Backend, API, Database, Deployment | Architecture, Supabase, Render, scaling |
| **Member 2** | Dashboard, Frontend, Map, Realtime | Next.js, Leaflet, Supabase Realtime |
| **Member 1** | Mobile, Sensors, Flutter, Offline | Battery, permissions, background execution |
| **Member 5** | AI, Risk Engine, Gemini, ML | False positives, thresholds, multimodal |
| **Member 3** | Audio/Motion sensors, Signal processing | Sampling rates, noise filtering, accuracy |

### Answer Protocol
1. **Member 6** acknowledges question
2. **Member 6** routes: "Member 4, backend question?"
3. **Assigned member** answers (30-45 seconds max)
4. **Member 6** summarizes/bridges if needed
5. **Member 6** invites next question

---

## Equipment Checklist

### Must Bring (Day of Judging)
- [ ] Laptop (presenter) + charger
- [ ] HDMI/USB-C adapter for projector
- [ ] Member 1 Phone + USB cable + charger
- [ ] Member 6 Phone (hotspot) + charger
- [ ] 2 USB drives (failsafe videos)
- [ ] Clicker/pointer for slides
- [ ] Printed: This plan, Q&A sheet, narration script
- [ ] Pen + notebook

### Backup Equipment
- [ ] Spare Android phone (Member 2/3/4/5) with app
- [ ] Portable power bank (20,000 mAh)
- [ ] Ethernet adapter (if venue has wired)
- [ ] Second laptop (Member 4) for backend terminal

---

## Day-of Schedule

| Time | Activity |
|------|----------|
| **T-120 min** | Arrive, setup equipment, test projector |
| **T-90 min** | Run quick tech check: phone → dashboard → backend |
| **T-60 min** | Warm up backend (`curl /ping`), load dashboard |
| **T-45 min** | Team huddle: Review transitions, Q&A assignments |
| **T-30 min** | Final bathroom break, water, calm breathing |
| **T-15 min** | In position, slides on title screen, phone ready |
| **T-0** | **PRESENTATION START** |
| **T+10 min** | Q&A, thank judges, pack up |

---

## Risk Mitigation During Presentation

| Risk | Mitigation |
|------|------------|
| Projector fails | Present from laptop screen (gather judges close) |
| Phone dies | Switch to spare phone / emulator / failsafe video |
| Internet dies | Switch to mobile hotspot (pre-tested) |
| Backend 500 | "Let me show the recorded demo" → play video |
| Demo takes too long | Skip detail view, go straight to "notifications sent" |
| Judge interrupts | "Great question — let me address that in Q&A" |
| Time warning (8 min) | Skip Slide 6 details, jump to Q&A |

---

## Post-Rehearsal Action Items

### After Rehearsal 1
- [ ] Fix all technical bugs
- [ ] Adjust slide content if timing off
- [ ] Update `DEMO_SCRIPT.md` with actual working flow
- [ ] Confirm all URLs in `QR_CODES.md` current

### After Rehearsal 2
- [ ] Final polish on delivery
- [ ] Confirm Q&A answers rehearsed
- [ ] Pack all equipment per checklist
- [ ] Good night's sleep!

---

## Success Criteria

- [ ] Full presentation ≤ 10:00
- [ ] Pitch segment ≤ 5:00
- [ ] Demo segment ≤ 2:00
- [ ] Zero technical failures in rehearsal
- [ ] All transitions smooth (<3 seconds)
- [ ] Each member speaks at least once
- [ ] Key message delivered: "Proactive, not reactive"
- [ ] Team confident and synchronized

---

*Last Updated: Day 4 — Member 6*
*Version: 1.0*