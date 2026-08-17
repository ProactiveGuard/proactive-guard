export interface Incident {
  incident_id: string;
  user_id: string;
  severity: 'SAFE' | 'MONITOR' | 'HIGH RISK' | 'CRITICAL';
  risk_score: number;
  latitude: number;
  longitude: number;
  summary: string;
  audio_level?: number;
  motion_level?: number;
  time_of_day?: number;
  is_off_route?: boolean;
  location_name?: string;
  ai_summary?: string;
  responder?: string;
  status?: 'active' | 'resolved' | 'assigned';
  created_at: string;
  updated_at?: string;
}

export interface Journey {
  journey_id: string;
  user_id: string;
  status: 'active' | 'completed';
  start_time: string;
  end_time?: string;
  start_lat?: number;
  start_lng?: number;
  end_lat?: number;
  end_lng?: number;
  current_lat?: number;
  current_lng?: number;
  is_off_route?: boolean;
  planned_route?: GeoJSON.LineString;
}

export interface TelemetryData {
  user_id: string;
  latitude: number;
  longitude: number;
  motion_score: number;
  audio_score: number;
  distance_off_route_m?: number;
  previous_motion_score?: number;
  audio_transcript?: string;
}

export interface IncidentResponse {
  incident_id: string;
  severity: string;
  risk_score: number;
  summary: string;
}

export interface JourneyRequest {
  user_id: string;
}

export interface JourneyResponse {
  message: string;
  journey_id: string;
  user_id: string;
  status: string;
  start_time: string;
}

export interface WebSocketMessage {
  type: 'incident_created' | 'incident_updated' | 'incident_resolved';
  data: Incident;
}