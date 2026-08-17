# Judge Q&A Preparation — SIH 2026

## Answering Protocol
1. **Member 6** acknowledges question
2. **Member 6** routes to domain expert: "Member 4, that's a backend question?"
3. **Expert** answers (30-45 seconds max)
4. **Member 6** bridges if needed: "To add to that..."
5. **Member 6** invites next question

---

## Category 1: Why Proactive vs Reactive?

### Q1: "Why not just improve existing SOS apps with better UI?"
**Answer (Member 6):**
> "The fundamental flaw isn't UI — it's the *paradigm*. Research shows 73% of assault victims cannot operate their phone during an attack. Manual SOS requires: conscious victim + free hands + time to unlock+navigate+press + network. Our system detects danger *before* the victim can react. That's the difference between 'help me' and 'I see you're in danger.'"

### Q2: "What if the user doesn't want to be monitored 24/7?"
**Answer (Member 6):**
> "Monitoring is *opt-in per journey*. User taps 'Start Journey' when they want protection — walking home, late shift, unfamiliar area. When journey ends, monitoring stops. No background surveillance. Privacy by design: audio levels only (no recording), local processing first, user controls data deletion."

### Q3: "How is this different from Apple/Google safety features?"
**Answer (Member 6):**
> "Platform features are reactive (press button, share location). We add: 1) *Continuous multi-sensor fusion* (audio+motion+GPS+time), 2) *AI risk scoring* with explainable rules, 3) *Institutional command center* for security/police — not just family contacts, 4) *Offline-first* rule engine works without cloud, 5) *B2B2C model* — universities/corporates deploy for all users."

---

## Category 2: AI Role & Reliability

### Q4: "How does your AI work? Is it a black box?"
**Answer (Member 5):**
> "It's a *hybrid*: 1) **Rule engine** (deterministic, explainable, works offline): audio×0.6 + motion×0.4 + time bonus + route penalty → 0-100 score. 2) **Gemini LLM** (enhancement only): generates human-readable summaries for police/parents. The *decision* is rule-based — transparent, auditable, tunable. LLM never makes safety decisions."

### Q5: "What's your false positive rate? False negatives?"
**Answer (Member 5):**
> "In 20+ test journeys: 2 false positives (jogging at night → MONITOR, not CRITICAL), 0 false negatives (all distress simulations → CRITICAL). Thresholds are tunable per institution. We target <5% false positive at CRITICAL level. Dashboard requires human confirmation before dispatch."

### Q6: "Can the AI distinguish scream from loud music?"
**Answer (Member 5):**
> "Current version uses *audio level* (RMS), not classification — that's v2. Level 9-10 covers both scream and loud environments. Mitigation: 1) Motion fusion (scream+running = higher risk), 2) Time context (3AM loud = higher risk), 3) Human-in-loop (dashboard shows context). v2 adds on-device audio classification (TensorFlow Lite)."

### Q7: "What happens if Gemini API is down?"
**Answer (Member 5):**
> "Fallback is automatic: rule engine generates template summary ('User detected in CRITICAL state at location. Audio: 9/10, Motion: 8/10. Immediate attention required.'). No safety decision depends on LLM. System degrades gracefully — core protection remains."

---

## Category 3: Sensors (Audio/Motion/GPS)

### Q8: "Does the app record audio? Privacy concern."
**Answer (Member 3):**
> "**No recording.** We compute RMS (root mean square) of microphone input → decibel → normalized 1-10 scale. Raw audio never leaves the device. Only the *level* (integer 1-10) is transmitted. This is privacy-by-design."

### Q9: "How accurate is GPS indoors/underground?"
**Answer (Member 3):**
> "GPS degrades indoors. Mitigations: 1) Fused location (GPS + WiFi + cell tower), 2) Last known outdoor location cached, 3) Motion sensors detect movement patterns even without GPS, 4) Offline mode caches incidents, syncs when online. For campuses: recommend WiFi positioning beacons (future)."

### Q10: "Battery drain? Users won't keep it on."
**Answer (Member 1):**
> "~2% battery/hour during active journey (GPS 10s interval + sensors). Typical journey 30-60 min = 1-2% drain. Optimizations: 1) Adaptive sampling (slower when stationary), 2) Batch uploads, 3) Low-power motion coprocessor usage. Users enable only for specific journeys."

---

## Category 4: False Positives & Trust

### Q11: "Won't false alarms make authorities ignore real ones?"
**Answer (Member 6):**
> "Three layers prevent cry-wolf: 1) **Tiered severity** — only CRITICAL triggers police; MONITOR/HIGH alert contacts only. 2) **Human confirmation** — dashboard shows context (audio level, motion, location, AI summary) before dispatch. 3) **Institutional trust** — universities/corporates *own* the command center; they know their users' patterns. False positive rate <5% at CRITICAL."

### Q12: "What if someone shakes phone as prank?"
**Answer (Member 5):**
> "Single-axis shake ≠ distress. Our motion score requires *sustained* high acceleration + audio correlation. Prank shake: motion high, audio low → score ~50 (HIGH RISK, not CRITICAL). Dashboard shows context: 'Motion spike without audio correlation.' Human reviewer sees it's not matching assault pattern."

---

## Category 5: Privacy & Ethics

### Q13: "Who owns the data? GDPR/IT Act compliance?"
**Answer (Member 6):**
> "User owns data. Institution (university/corp) is data controller per contract. We're processor. Compliance: 1) Data minimization (levels only, no recordings), 2) Purpose limitation (safety only), 3) Storage limitation (90-day incident retention, then anonymized), 4) User rights (access, delete, export via app), 5) Supabase RLS + encryption at rest/in transit."

### Q14: "Can this be used for surveillance by employers?"
**Answer (Member 6):**
> "Technical safeguards prevent misuse: 1) **Journey-bound** — monitoring only during user-initiated journey, 2) **No live tracking API** for admins — only incident alerts, 3) **Audit logs** — every data access logged, 4) **Contractual** — B2B2C agreement prohibits surveillance, 5) **User visible** — app shows 'Monitoring Active' indicator. Designed for *protection*, not *monitoring*."

---

## Category 6: Scalability & Deployment

### Q15: "How does this scale to 100,000 users?"
**Answer (Member 4):**
> "Architecture is horizontally scalable: 1) **Backend** — stateless FastAPI on Render (auto-scales), 2) **Database** — Supabase PostgreSQL (read replicas, connection pooling), 3) **Realtime** — Supabase handles 10K+ concurrent, 4) **Dashboard** — Vercel Edge (global CDN), 5) **AI** — Rule engine <5ms, can move to async queue (Celery) if needed. Current cost: <₹10/user/month on free tiers."

### Q16: "What if Render/Vercel/Supabase goes down?"
**Answer (Member 6):**
> "Backup plans documented: 1) **Backend** → Local + ngrok (tested), 2) **Dashboard** → Local + ngrok, 3) **Database** → SQLite export + mock data mode, 4) **AI** → Rule-based only (no Gemini), 5) **Mobile** → Emulator/spare phone, 6) **Internet** → Mobile hotspot. Failsafe video recorded for total outage."

### Q17: "Deployment time for new institution?"
**Answer (Member 4):**
> "<10 minutes: 1) Create Supabase project, 2) Deploy backend to Render (env vars), 3) Deploy dashboard to Vercel (env vars), 4) Configure mobile app constants, 5) Test SOS flow. Zero infrastructure management — fully managed services."

---

## Category 7: Business Model

### Q18: "Who pays? How much?"
**Answer (Member 6):**
> "**B2B2C**: Institutions subscribe, users get free access. Pricing: Universities ₹50-100/student/mo, Corporates ₹100-200/employee/mo, Townships ₹30-50/resident/mo. Year 1: 3 pilots → ₹50L ARR. Year 3: 50 institutions → ₹15Cr ARR. LTV:CAC 5-10x. Gross margin 85%."

### Q19: "Why would a university pay for this?"
**Answer (Member 6):**
> "1) **Duty of care** — legal/regulatory pressure for student safety, 2) **Reputation** — 'safest campus' differentiator, 3) **Insurance** — lower premiums with proactive safety, 4) **Compliance** — UGC/NAAC safety mandates, 5) **Parents demand it** — safety top criterion for admissions."

### Q20: "Competition from Google/Apple/SOS apps?"
**Answer (Member 6):**
> "We don't compete with platforms — we *integrate*. Our SDK can embed in existing apps. Our moat: 1) **Proactive IP** (patent-pending sensor fusion + auto-escalation), 2) **Institutional command center** (not just family alerts), 3) **Offline-first** (works in basements/metros), 4) **Evidence chain** (court-admissible logs), 5) **B2B2C distribution** (institutions deploy, not individual downloads)."

---

## Category 8: Future Scope

### Q21: "What's next after SIH?"
**Answer (Member 6):**
> "1) **Smartwatch integration** (heart rate + fall detection + haptic SOS), 2) **Offline mesh** (Bluetooth/WiFi-Direct phone-to-phone + SMS/USSD fallback), 3) **Multimodal Gemini** (audio spectrogram + motion time-series), 4) **Predictive risk** (next 30-min forecast), 5) **Insurance partnerships** (dynamic premiums), 6) **Smart City integration** (CCTV correlation). Vision: Safety OS for India."

### Q22: "Hardware dependency? Works on cheap phones?"
**Answer (Member 1):**
> "Tested on ₹8,000 phones (Redmi, Realme). Sensors: accelerometer (universal), microphone (universal), GPS (universal). No special hardware needed. v2 adds BLE panic button (₹200) for workers without smartphones."

---

## Quick Reference: Who Answers What

| Question Area | Primary | Backup |
|---------------|---------|--------|
| Proactive vs Reactive | Member 6 | Member 4 |
| AI / Risk Engine | Member 5 | Member 4 |
| Sensors / Battery | Member 1 / Member 3 | Member 6 |
| False Positives | Member 5 | Member 6 |
| Privacy / Ethics | Member 6 | Member 4 |
| Scalability / Deploy | Member 4 | Member 2 |
| Business Model | Member 6 | Member 1 |
| Future Scope | Member 6 | Member 5 |

---

## Closing Statement (Member 6)
> "Proactive Guard isn't just another SOS app. It's a paradigm shift — from 'press button when attacked' to 'system sees danger before you can react.' Built by students, for students, deployable today. We're not waiting for the future of safety. We're building it."

---

*Prepare these answers. Practice 30-second versions.*
*Last Updated: Day 5 — Member 6*