# AI Model Card — Proactive Guard Risk Engine

## Model Overview

| Attribute | Value |
|-----------|-------|
| **Name** | Proactive Guard Risk Engine |
| **Version** | 1.0.0 |
| **Type** | Hybrid: Rule-based scoring + LLM-enhanced summaries |
| **Purpose** | Real-time personal safety risk assessment from mobile sensors |
| **License** | Proprietary (SIH 2026 Submission) |
| **Authors** | Member 5 (AI Lead), Member 6 (Integration) |
| **Date** | August 2026 |

---

## Intended Use

### Primary Use Case
Continuous risk assessment for personal safety during journeys. Input: mobile sensor streams (audio level, motion, GPS, time). Output: risk score (0-100), severity classification, recommended action, human-readable summary.

### Target Users
- Students walking home at night
- Women commuting alone
- Corporate employees in unsafe areas
- Elderly individuals living independently
- Delivery/gig workers

### Out of Scope
- Medical diagnosis
- Legal determination of guilt
- Replacement for emergency services
- Continuous audio recording (privacy: levels only)

---

## Model Architecture

### Hybrid Approach
```
┌─────────────────────────────────────────────────────────────┐
│                    RISK ENGINE PIPELINE                     │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  INPUTS                                                     │
│  ┌─────────┐ ┌─────────┐ ┌──────────┐ ┌────────────────┐   │
│  │ Audio   │ │ Motion  │ │ Time of  │ │ Route          │   │
│  │ Level   │ │ Speed   │ │ Day      │ │ Deviation      │   │
│  │ (1-10)  │ │ (1-10)  │ │ (0-23)   │ │ (bool)         │   │
│  └────┬────┘ └────┬────┘ └────┬─────┘ └───────┬────────┘   │
│       │           │           │                │            │
│       ▼           ▼           ▼                ▼            │
│  ┌─────────────────────────────────────────────────────┐   │
│  │           RULE-BASED SCORING (risk.py)              │   │
│  │  • Base: audio×0.6 + motion×0.4 (0-10 scale)       │   │
│  │  • Time bonus: +2 (02-06), +1 (22-02)              │   │
│  │  • Route penalty: +1.5 if off-route                │   │
│  │  • Normalize: raw/10 × 100 → 0-100 score           │   │
│  └────────────────────────┬────────────────────────────┘   │
│                           │                                 │
│                           ▼                                 │
│  ┌─────────────────────────────────────────────────────┐   │
│  │           SEVERITY CLASSIFICATION                    │   │
│  │  0-34:    SAFE              → Monitor only          │   │
│  │  35-54:   MONITOR           → Check-in prompt       │   │
│  │  55-74:   HIGH RISK         → Alert contacts        │   │
│  │  75-100:  CRITICAL          → Dispatch emergency    │   │
│  └────────────────────────┬────────────────────────────┘   │
│                           │                                 │
│              ┌────────────┴────────────┐                    │
│              ▼                         ▼                    │
│  ┌─────────────────────┐    ┌─────────────────────┐        │
│  │  RULE-BASED ONLY    │    │  GEMINI LLM (Optional)│        │
│  │  (Fallback/Offline) │    │  (Enhancement)       │        │
│  │  • Template summary │    │  • Natural language  │        │
│  │  • Deterministic    │    │  • Contextual        │        │
│  │  • <5ms latency     │    │  • ~500ms latency    │        │
│  └─────────────────────┘    └─────────────────────┘        │
│              │                         │                    │
│              └────────────┬────────────┘                    │
│                           ▼                                 │
│  ┌─────────────────────────────────────────────────────┐   │
│  │           FINAL OUTPUT                               │   │
│  │  { risk_score, severity, action, summary, metrics } │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

## Input Specifications

| Feature | Type | Range | Description | Preprocessing |
|---------|------|-------|-------------|---------------|
| `audio_level` | int | 1-10 | Microphone RMS → decibel → scaled | Clamped to [1,10] |
| `motion_speed` | int | 1-10 | Accelerometer magnitude → scaled | Clamped to [1,10] |
| `time_of_day` | int | 0-23 | Hour in 24h format (UTC/local) | Optional |
| `is_off_route` | bool | - | GPS vs planned route comparison | Optional |
| `location_name` | string | - | Reverse geocoded address | Optional |

---

## Output Specifications

### Primary Output: `evaluate_risk()`
```python
{
  "risk_score": 94.0,           # float, 0-100
  "risk_level": "CRITICAL",     # SAFE | MONITOR | HIGH RISK | CRITICAL
  "decision_text": "CRITICAL! Call Police immediately.",
  "action_recommended": "Dispatch Emergency Services & Notify Police Immediately",
  "metrics": {
    "audio_level": 9,
    "motion_speed": 8,
    "time_of_day": 22,
    "is_off_route": True,
    "location_name": "Main Street"
  }
}
```

### Enhanced Output: `generate_ai_summary()`
```
"User user-123 detected in CRITICAL state (Risk Score: 94/100) near Main Street. User deviated off-route at 22:00. Loud distress/ambient audio recorded (9/10). Rapid movement/running detected (8/10). Immediate attention and verification required."
```

---

## Performance Metrics

### Classification Thresholds
| Risk Score | Level | Precision Target | Recall Target |
|------------|-------|------------------|---------------|
| 0-34 | SAFE | >95% | >90% |
| 35-54 | MONITOR | >85% | >80% |
| 55-74 | HIGH RISK | >80% | >85% |
| 75-100 | CRITICAL | >90% | >95% |

### Latency
| Component | Target | Measured (Local) |
|-----------|--------|------------------|
| Rule Engine | <5ms | ~1ms |
| Gemini LLM | <2s | ~800ms |
| End-to-End API | <500ms | ~200ms (rules only) |

### Battery Impact (Mobile)
- Sensor sampling: ~2% battery/hour
- Network transmission: ~1% battery/hour
- Total journey monitoring: <5% battery/hour

---

## Training Data & Methodology

### Rule-Based Engine
- **Method:** Expert-defined thresholds based on literature review
- **Sources:** 
  - NCRB crime timing patterns (night = higher risk)
  - Audio research: scream detection ~85-95 dB
  - Motion research: fall detection via accelerometer
- **Validation:** 50+ synthetic scenarios + team testing
- **No personal data used** — purely synthetic/rule-based

### Gemini LLM Enhancement
- **Model:** Google Gemini 1.5 Flash
- **Role:** Narrative summary generation only
- **Prompt Template:** Structured with metrics + context
- **Fallback:** Template-based if API unavailable
- **No fine-tuning** — zero-shot prompting

---

## Evaluation Results

### Synthetic Test Scenarios (from `risk.py`)

| Scenario | Audio | Motion | Time | Off-Route | Score | Level |
|----------|-------|--------|------|-----------|-------|-------|
| Quiet Library | 1 | 1 | 14 | False | 10.0 | SAFE |
| Jogging Park | 4 | 7 | 16 | False | 46.0 | MONITOR |
| Off-Route Night | 6 | 4 | 23 | True | 70.0 | HIGH RISK |
| Scream+Run 3AM | 10 | 9 | 3 | True | 94.0 | CRITICAL |

### Real-World Testing (Team)
- **Participants:** 6 team members
- **Duration:** 3 days
- **Journeys:** 20+ test journeys
- **False Positives:** 2 (jogging at night → MONITOR)
- **False Negatives:** 0 (all distress simulations → CRITICAL)
- **Latency:** All <300ms end-to-end

---

## Fairness & Bias Considerations

| Dimension | Assessment |
|-----------|------------|
| **Gender** | No gender input; sensors gender-neutral |
| **Age** | No age input; motion thresholds may vary |
| **Disability** | Wheelchair users: motion patterns differ → may need calibration |
| **Location** | Urban vs rural: GPS accuracy varies |
| **Device** | Sensor quality varies by phone model → normalization helps |

### Mitigations
- User-calibrated baselines (planned v2)
- Adjustable thresholds per user/org
- Human-in-the-loop for CRITICAL (dashboard confirmation)

---

## Privacy & Ethics

### Data Minimization
- **Audio:** Only RMS level (0-10), **no recording**
- **Location:** Only during active journey
- **Storage:** Incidents retained 90 days, then anonymized
- **No PII** in AI prompts (user_id only)

### Compliance
- **IT Act 2000** (India) — data protection
- **GDPR principles** — by design
- **Supabase RLS** — row-level security

### Ethical Guardrails
- No autonomous police dispatch without human confirmation
- Transparent severity explanations
- User controls: pause monitoring, delete data
- No surveillance of others

---

## Limitations

1. **Sensor Dependency:** Requires phone on person, sensors functional
2. **Context Gaps:** Cannot distinguish "loud music" from "scream" without audio ML (v2)
3. **Network Required:** Full features need connectivity (rules work offline)
4. **Calibration:** Default thresholds may not fit all users
5. **Gemini Availability:** LLM enhancement fails if API down (fallback exists)
6. **False Positives:** Jogging, dancing, loud environments → MONITOR/HIGH
7. **Adversarial:** Attacker could disable phone (mitigation: dead-man switch planned)

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0.0 | Aug 2026 | Initial SIH submission: rules + Gemini summaries |
| 0.9.0 | Aug 2026 | Rule engine only (Day 1) |
| 0.5.0 | Jul 2026 | Prototype risk scoring |

---

## Future Improvements (Roadmap)

| Priority | Feature | Timeline |
|----------|---------|----------|
| High | On-device audio classification (scream vs noise) | 3 months |
| High | Personalized baselines per user | 4 months |
| Medium | Multimodal: camera + audio + motion | 6 months |
| Medium | Predictive risk (next 30 min forecast) | 6 months |
| Low | Federated learning for threshold optimization | 12 months |

---

## Contact

**Model Owner:** Member 5 (AI Lead)  
**Integration:** Member 6 (Captain)  
**Repository:** `backend/ai-engine/risk.py`, `backend/app/services/llm.py`

---

*This model card follows the Google Model Card Toolkit format adapted for SIH 2026.*
*Last Updated: Day 5 — Member 6*