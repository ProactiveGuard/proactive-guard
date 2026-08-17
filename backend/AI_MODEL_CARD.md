# AI Model Card: Proactive Guard Risk Engine

## Model Overview
- **Name**: Proactive Guard Multi-Modal Risk Engine
- **Version**: 2.0 (SIH 2026)
- **Type**: Rule-based fusion + LLM (Gemini 2.5 Flash) for summaries
- **Authors**: Team Drama Unlimited - Member 5 (AI & Logic Thinker)
- **Date**: August 2026

## Intended Use
Real-time personal safety risk assessment for women and children using smartphone sensors (microphone, accelerometer, gyroscope, GPS). Transforms raw sensor streams into actionable risk scores (0-100) and severity levels (SAFE, MONITOR, HIGH RISK, CRITICAL) with AI-generated emergency summaries for responders.

## Model Architecture

### 1. Signal Inputs
| Signal | Range | Weight | Description |
|--------|-------|--------|-------------|
| Audio Level | 1-10 | 60% | Ambient sound danger (screaming, sirens, struggle) |
| Motion Speed | 1-10 | 40% | Movement danger (running, falling, sudden spike) |
| Time of Day | 0-23 | Bonus | Night hours (22-02: +1, 02-06: +2) |
| Route Deviation | Boolean | +3 pts | >500m from planned route (Haversine) |
| Struggle Detection | Boolean | Override | Sudden motion spike ≥6 points = instant CRITICAL |
| Audio Transcript Threat | Boolean | Override | NLP detects distress keywords = instant CRITICAL |

### 2. Fusion Logic
```
base_score = (audio × 0.6) + (motion × 0.4)
time_bonus = 2.0 (02-06) or 1.0 (22-02)
route_bonus = 3.0 if off_route else 0.0
raw_total = base_score + time_bonus + route_bonus
risk_score_100 = min(100, (raw_total / 10) × 100)
```

### 3. Temporal Smoothing (Day 4)
- Moving average window: 5 readings
- Trend detection: rising/falling/stable
- Confidence scoring: based on signal availability + variance

### 4. Confidence Thresholds (Day 4)
- 3 signals available: 1.0 base confidence
- 2 signals available: 0.67 base confidence  
- 1 signal available: 0.33 base confidence
- Missing sensors redistribute weights proportionally

### 5. LLM Summary Generation
- **Primary**: Google Gemini 2.5 Flash (via `google-genai` SDK)
- **Fallback**: Deterministic templates (7 languages)
- **Languages**: English, Hindi, Kannada, Tamil, Marathi, Bengali, Telugu
- **Output**: 2-sentence professional emergency dispatch summary

## Training Data
- **Rule-based**: No training data (expert-defined thresholds)
- **LLM**: Pre-trained Gemini 2.5 Flash (Google)
- **Threshold Tuning**: Based on 7 synthetic scenarios + team testing

## Performance Metrics (Day 5)
| Metric | Target | Measurement |
|--------|--------|-------------|
| Latency (rule engine) | < 5ms | Internal benchmark |
| Latency (Gemini) | < 2s | API call timing |
| False Positive Rate | < 15% | Manual review of MONITOR+ alerts |
| Language Coverage | 7 Indian languages | Template + Gemini support |
| Uptime | 99.9% | Render health checks |

## Limitations
1. **Network Dependency**: Gemini requires internet; falls back to templates offline
2. **Sensor Permissions**: Audio/motion/GPS need user consent; missing sensors reduce confidence
3. **Threshold Calibration**: Current thresholds tuned for Indian urban environments; may need adjustment for rural/campus settings
4. **LLM Hallucination Risk**: Mitigated by strict 2-sentence prompt + fallback validation
5. **No On-Device Inference**: All AI runs server-side (Day 4 research documented for future TFLite)

## Ethical Considerations
- **Privacy**: Minimum necessary data (no raw audio storage, only scores)
- **Bias**: Thresholds tested across age/gender scenarios; no demographic data used
- **False Alarms**: Multi-signal fusion + temporal smoothing + confidence thresholds reduce panic
- **Human-in-the-loop**: CRITICAL alerts require responder verification before dispatch

## Future Work (Roadmap)
- P2: On-device TensorFlow Lite for audio classification (scream/siren/struggle)
- P3: Larger real-world evaluation with 100+ users
- P4: Campus/transport pilot deployments
- P5: Responder ecosystem integration (direct police API)
- P6: Large-scale deployment with federated learning

## Contact
Team Drama Unlimited - Thakur College of Engineering and Technology
SIH 2026 - Proactive Guard