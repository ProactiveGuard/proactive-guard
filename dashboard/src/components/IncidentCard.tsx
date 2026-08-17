'use client';

import { Incident } from '@/lib/types';
import { SeverityBadge, RiskScoreBadge } from './SeverityBadge';

interface IncidentCardProps {
  incident: Incident;
  onResolve: (id: string) => void;
  onAssign: (id: string, responder: string) => void;
  onDispatch: (id: string) => void;
  dispatching?: string | null;
  dispatched?: string[];
  darkMode?: boolean;
}

const responders = [
  { value: '', label: 'Unassigned' },
  { value: 'police', label: '🚔 Police' },
  { value: 'ambulance', label: '🚑 Ambulance' },
  { value: 'guardian', label: '👨‍👩‍👧 Guardian' },
  { value: 'security', label: '🛡️ Security' },
];

export function IncidentCard({
  incident,
  onResolve,
  onAssign,
  onDispatch,
  dispatching,
  dispatched = [],
  darkMode = true,
}: IncidentCardProps) {
  const isDispatching = dispatching === incident.incident_id;
  const isDispatched = dispatched.includes(incident.incident_id);
  const currentResponder = incident.responder || '';

  const cardStyle = darkMode
    ? 'bg-gray-800 border-red-600 text-white'
    : 'bg-white border-red-600 text-gray-900 shadow';

  return (
    <div
      key={incident.incident_id}
      className={`border-l-8 p-6 rounded-md max-w-2xl mb-4 transition-colors ${cardStyle}`}
    >
      <div className="flex flex-col sm:flex-row sm:justify-between sm:items-start gap-4">
        <div className="flex-1 min-w-0">
          <div className="flex items-center gap-3 flex-wrap mb-2">
            <h3 className="text-xl font-bold text-red-400">
              {incident.severity}: Threat Detected
            </h3>
            <SeverityBadge severity={incident.severity} />
            <RiskScoreBadge score={incident.risk_score} />
          </div>
          <p className="text-sm mb-1">Incident ID: <code className="font-mono">{incident.incident_id}</code></p>
          <p className="text-sm mb-2">
            Location: ({incident.latitude.toFixed(6)}, {incident.longitude.toFixed(6)})
          </p>
          <p className={darkMode ? 'text-gray-300 mt-2 italic' : 'text-gray-600 mt-2 italic'}>
            "{incident.summary}"
          </p>
          {incident.ai_summary && (
            <p className={darkMode ? 'text-gray-400 mt-2 text-sm' : 'text-gray-500 mt-2 text-sm'}>
              AI: {incident.ai_summary}
            </p>
          )}
          {incident.responder && (
            <p className={darkMode ? 'text-green-400 mt-1 text-sm' : 'text-green-600 mt-1 text-sm'}>
              Assigned: {responders.find(r => r.value === incident.responder)?.label || incident.responder}
            </p>
          )}
        </div>

        <div className="flex flex-col sm:flex-row gap-2 w-full sm:w-auto">
          <select
            value={currentResponder}
            onChange={(e) => onAssign(incident.incident_id, e.target.value)}
            className={`border rounded px-3 py-2 text-sm font-medium ${
              darkMode ? 'bg-gray-700 text-white border-gray-600' : 'bg-white text-gray-900 border-gray-300'
            }`}
            disabled={isDispatched}
          >
            {responders.map((r) => (
              <option key={r.value} value={r.value}>
                {r.label}
              </option>
            ))}
          </select>

          <button
            onClick={() => onDispatch(incident.incident_id)}
            disabled={isDispatching || isDispatched}
            className={`flex-1 sm:w-auto px-4 py-2 rounded font-bold text-sm transition-colors ${
              isDispatched
                ? 'bg-green-600 text-white cursor-default'
                : isDispatching
                ? 'bg-gray-600 text-white cursor-wait'
                : 'bg-red-600 hover:bg-red-700 text-white'
            }`}
          >
            {isDispatched
              ? '✓ Help Dispatched'
              : isDispatching
              ? '⏳ Dispatching...'
              : '🚨 Dispatch Help'}
          </button>

          <button
            onClick={() => onResolve(incident.incident_id)}
            className={`flex-1 sm:w-auto px-4 py-2 rounded font-bold text-sm transition-colors ${
              darkMode
                ? 'bg-gray-600 hover:bg-gray-700 text-white'
                : 'bg-gray-300 hover:bg-gray-400 text-gray-900'
            }`}
          >
            ✕ Resolve
          </button>
        </div>
      </div>
    </div>
  );
}