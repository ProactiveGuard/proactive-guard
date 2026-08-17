'use client';

import { useEffect, useState, useCallback } from 'react';
import { Incident } from '@/lib/types';
import { createIncidentSocket, closeIncidentSocket } from '@/lib/websocket';
import { supabase, subscribeToIncidents } from '@/lib/supabase';

const API_URL = process.env.NEXT_PUBLIC_API_BASE_URL || 'http://127.0.0.1:8000';

export function useIncidents() {
  const [incidents, setIncidents] = useState<Incident[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  const fetchIncidents = useCallback(async () => {
    try {
      const response = await fetch(`${API_URL}/incidents`);
      if (!response.ok) throw new Error('Failed to fetch incidents');
      const data = await response.json();
      setIncidents(data);
      setError(null);
    } catch (e) {
      setError(e instanceof Error ? e.message : 'Unknown error');
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => {
    fetchIncidents();

    const wsCleanup = createIncidentSocket((incident) => {
      setIncidents((prev) => {
        const exists = prev.find((i) => i.incident_id === incident.incident_id);
        if (exists) {
          return prev.map((i) => (i.incident_id === incident.incident_id ? incident : i));
        }
        return [incident, ...prev].slice(0, 100);
      });
    });

    const supabaseCleanup = subscribeToIncidents((incident) => {
      if (incident.deleted) {
        setIncidents((prev) => prev.filter((i) => i.incident_id !== incident.incident_id));
      } else {
        setIncidents((prev) => {
          const exists = prev.find((i) => i.incident_id === incident.incident_id);
          if (exists) {
            return prev.map((i) => (i.incident_id === incident.incident_id ? incident : i));
          }
          return [incident, ...prev].slice(0, 100);
        });
      }
    });

    return () => {
      wsCleanup();
      supabaseCleanup();
    };
  }, [fetchIncidents]);

  const resolveIncident = useCallback(async (incidentId: string) => {
    try {
      const response = await fetch(`${API_URL}/api/v1/incidents/${incidentId}`, { method: 'DELETE' });
      if (!response.ok) throw new Error('Failed to resolve incident');
      setIncidents((prev) => prev.filter((i) => i.incident_id !== incidentId));
      return true;
    } catch (e) {
      console.error('Resolve failed:', e);
      return false;
    }
  }, []);

  const assignResponder = useCallback(async (incidentId: string, responder: string) => {
    try {
      const response = await fetch(`${API_URL}/api/v1/incidents/${incidentId}/assign`, {
        method: 'PATCH',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ responder }),
      });
      if (!response.ok) throw new Error('Failed to assign responder');
      setIncidents((prev) =>
        prev.map((i) => (i.incident_id === incidentId ? { ...i, responder, status: 'assigned' } : i))
      );
      return true;
    } catch (e) {
      console.error('Assign failed:', e);
      return false;
    }
  }, []);

  const dispatchHelp = useCallback(async (incidentId: string) => {
    setIncidents((prev) =>
      prev.map((i) => (i.incident_id === incidentId ? { ...i, status: 'assigned', responder: 'police' } : i))
    );
  }, []);

  return {
    incidents,
    loading,
    error,
    refetch: fetchIncidents,
    resolveIncident,
    assignResponder,
    dispatchHelp,
  };
}
