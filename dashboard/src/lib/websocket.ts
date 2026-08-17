import { Incident } from '@/lib/types';

type IncidentCallback = (incident: Incident) => void;

let ws: WebSocket | null = null;
let callbacks: IncidentCallback[] = [];
let reconnectTimeout: NodeJS.Timeout | null = null;
const RECONNECT_DELAY = 5000;

export function createIncidentSocket(onMessage: IncidentCallback): () => void {
  callbacks.push(onMessage);

  if (ws && (ws.readyState === WebSocket.OPEN || ws.readyState === WebSocket.CONNECTING)) {
    return () => {
      callbacks = callbacks.filter((cb) => cb !== onMessage);
    };
  }

  connect();

  return () => {
    callbacks = callbacks.filter((cb) => cb !== onMessage);
    if (callbacks.length === 0 && ws) {
      ws.close();
      ws = null;
      if (reconnectTimeout) {
        clearTimeout(reconnectTimeout);
        reconnectTimeout = null;
      }
    }
  };
}

function connect() {
  const wsUrl = process.env.NEXT_PUBLIC_WS_URL || 
    (process.env.NEXT_PUBLIC_API_BASE_URL?.replace('http', 'ws') + '/ws/incidents') ||
    'ws://localhost:8000/ws/incidents';

  ws = new WebSocket(wsUrl);

  ws.onopen = () => {
    console.log('[WebSocket] Connected to incidents stream');
  };

  ws.onmessage = (event) => {
    try {
      const incident: Incident = JSON.parse(event.data);
      callbacks.forEach((cb) => cb(incident));
    } catch (e) {
      console.error('[WebSocket] Failed to parse message:', e);
    }
  };

  ws.onclose = () => {
    console.log('[WebSocket] Disconnected, reconnecting in 5s...');
    if (reconnectTimeout) clearTimeout(reconnectTimeout);
    reconnectTimeout = setTimeout(connect, RECONNECT_DELAY);
  };

  ws.onerror = (error) => {
    console.error('[WebSocket] Error:', error);
  };
}

export function closeIncidentSocket() {
  if (ws) {
    ws.close();
    ws = null;
  }
  if (reconnectTimeout) {
    clearTimeout(reconnectTimeout);
    reconnectTimeout = null;
  }
  callbacks = [];
}