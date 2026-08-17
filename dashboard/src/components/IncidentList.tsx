'use client';

import { Incident } from '@/lib/types';
import { IncidentCard } from './IncidentCard';

interface IncidentListProps {
  incidents: Incident[];
  onResolve: (id: string) => void;
  onAssign: (id: string, responder: string) => void;
  onDispatch: (id: string) => void;
  dispatching?: string | null;
  dispatched?: string[];
  darkMode?: boolean;
  loading?: boolean;
}

export function IncidentList({
  incidents,
  onResolve,
  onAssign,
  onDispatch,
  dispatching,
  dispatched = [],
  darkMode = true,
  loading = false,
}: IncidentListProps) {
  if (loading) {
    return (
      <div className="space-y-4">
        {[1, 2, 3].map((i) => (
          <div key={i} className={`border-l-8 p-6 rounded-md max-w-2xl mb-4 animate-pulse ${darkMode ? 'bg-gray-800' : 'bg-gray-100'}`}>
            <div className="h-6 bg-gray-700 w-1/4 rounded mb-4" />
            <div className="h-4 bg-gray-700 w-1/2 rounded mb-2" />
            <div className="h-4 bg-gray-700 w-3/4 rounded mb-2" />
            <div className="h-4 bg-gray-700 w-full rounded" />
          </div>
        ))}
      </div>
    );
  }

  if (incidents.length === 0) {
    return (
      <div className={`text-center py-12 ${darkMode ? 'text-gray-500' : 'text-gray-400'}`}>
        <div className="text-6xl mb-4">🛡️</div>
        <h3 className="text-xl font-semibold mb-2">No Active Incidents</h3>
        <p>All clear. Monitoring for threats...</p>
      </div>
    );
  }

  return (
    <div className="space-y-4" role="list" aria-label="Active incidents">
      {incidents.map((incident) => (
        <IncidentCard
          key={incident.incident_id}
          incident={incident}
          onResolve={onResolve}
          onAssign={onAssign}
          onDispatch={onDispatch}
          dispatching={dispatching}
          dispatched={dispatched}
          darkMode={darkMode}
        />
      ))}
    </div>
  );
}