"use client";

import dynamic from "next/dynamic";
import { useEffect, useState, useCallback, useRef } from "react";
import { Toaster, toast } from "sonner";
import { IncidentList } from "@/components/IncidentList";
import LiveMap from "@/components/LiveMap";
import { MapLegend } from "@/components/MapLegend";
import { useIncidents } from "@/hooks/useIncidents";

const LiveMapDynamic = dynamic(() => import("@/components/LiveMap"), { ssr: false });

const API_URL = process.env.NEXT_PUBLIC_API_BASE_URL || "http://127.0.0.1:8000";

export default function CommandCenter() {
  const {
    incidents,
    loading,
    error,
    refetch,
    resolveIncident,
    assignResponder,
    dispatchHelp,
  } = useIncidents();

  const [dispatching, setDispatching] = useState<string | null>(null);
  const [dispatched, setDispatched] = useState<string[]>([]);
  const [darkMode, setDarkMode] = useState(true);
  const [showSafeZones, setShowSafeZones] = useState(false);
  const [showHistory, setShowHistory] = useState(false);
  const [keyboardHelp, setKeyboardHelp] = useState(false);

  useEffect(() => {
    const savedDarkMode = localStorage.getItem("darkMode");
    if (savedDarkMode !== null) {
      setDarkMode(savedDarkMode === "true");
    }
  }, []);

  const toggleDarkMode = useCallback(() => {
    const newMode = !darkMode;
    setDarkMode(newMode);
    localStorage.setItem("darkMode", String(newMode));
  }, [darkMode]);

  const handleDispatch = useCallback((incidentId: string) => {
    setDispatching(incidentId);
    dispatchHelp(incidentId);
    toast.loading("Dispatching help...", { id: incidentId });

    setTimeout(() => {
      setDispatching(null);
      setDispatched((prev) => [...prev, incidentId]);
      toast.success("Help dispatched successfully!", { id: incidentId });
    }, 1000);
  }, [dispatchHelp]);

  const handleResolve = useCallback(async (incidentId: string) => {
    const success = await resolveIncident(incidentId);
    if (success) {
      toast.success("Incident resolved");
    } else {
      toast.error("Failed to resolve incident");
    }
  }, [resolveIncident]);

  const handleAssign = useCallback(async (incidentId: string, responder: string) => {
    const success = await assignResponder(incidentId, responder);
    if (success) {
      toast.success(responder ? `Assigned to ${responder}` : "Responder unassigned");
    } else {
      toast.error("Failed to assign responder");
    }
  }, [assignResponder]);

  const safeZones = showSafeZones
    ? [
        { lat: 28.6139, lng: 77.209, radius: 500 },
        { lat: 28.62, lng: 77.215, radius: 300 },
        { lat: 28.605, lng: 77.2, radius: 400 },
      ]
    : [];

  const latestIncident = incidents[0];

  const handleKeyDown = useCallback((e: KeyboardEvent) => {
    if (e.target instanceof HTMLInputElement || e.target instanceof HTMLTextAreaElement || e.target instanceof HTMLSelectElement) {
      return;
    }

    switch (e.key.toLowerCase()) {
      case 'r':
        if (latestIncident) handleResolve(latestIncident.incident_id);
        break;
      case 'a':
        if (latestIncident) handleAssign(latestIncident.incident_id, 'police');
        break;
      case 'd':
        if (latestIncident) handleDispatch(latestIncident.incident_id);
        break;
      case 'n':
        refetch();
        break;
      case 'h':
        setKeyboardHelp(true);
        break;
      case 'escape':
        setKeyboardHelp(false);
        break;
      case 'm':
        toggleDarkMode();
        break;
    }
  }, [latestIncident, handleResolve, handleAssign, handleDispatch, refetch, toggleDarkMode]);

  useEffect(() => {
    window.addEventListener('keydown', handleKeyDown);
    return () => window.removeEventListener('keydown', handleKeyDown);
  }, [handleKeyDown]);

  return (
    <main className={`min-h-screen text-white p-8 transition-colors ${darkMode ? "bg-gray-900" : "bg-gray-100 text-gray-900"}`}>
      <Toaster
        position="top-right"
        theme={darkMode ? "dark" : "light"}
        toastOptions={{
          duration: 3000,
          style: darkMode ? { background: '#1f2937', color: '#fff' } : {},
        }}
      />

      <div className="flex flex-col sm:flex-row sm:justify-between sm:items-center mb-8 gap-4">
        <div>
          <h1 className="text-3xl font-bold text-red-500">Proactive Guard Command Center</h1>
          <p className={darkMode ? "text-gray-400 mt-2" : "text-gray-600 mt-2"}>Live Monitoring Dashboard</p>
        </div>
        <div className="flex flex-wrap items-center gap-3">
          <button
            onClick={toggleDarkMode}
            className={darkMode
              ? "bg-gray-800 text-white px-4 py-2 rounded hover:bg-gray-700 transition-colors"
              : "bg-gray-200 text-gray-900 px-4 py-2 rounded hover:bg-gray-300 transition-colors"}
            aria-label={darkMode ? "Switch to light mode" : "Switch to dark mode"}
          >
            {darkMode ? "☀️ Light" : "🌙 Dark"}
          </button>
          <label className="flex items-center gap-2 text-sm">
            <input
              type="checkbox"
              checked={showSafeZones}
              onChange={(e) => setShowSafeZones(e.target.checked)}
              className="w-4 h-4 accent-red-500"
            />
            Safe Zones
          </label>
          <button
            onClick={() => setShowHistory(!showHistory)}
            className={`px-4 py-2 rounded transition-colors ${
              showHistory
                ? "bg-red-600 text-white"
                : darkMode
                ? "bg-gray-800 hover:bg-gray-700 text-white"
                : "bg-gray-200 hover:bg-gray-300 text-gray-900"
            }`}
          >
            {showHistory ? "📋 Live" : "📜 History"}
          </button>
          <button
            onClick={() => setKeyboardHelp(true)}
            className={`px-4 py-2 rounded transition-colors text-sm ${
              darkMode ? "bg-gray-800 hover:bg-gray-700 text-white" : "bg-gray-200 hover:bg-gray-300 text-gray-900"
            }`}
          >
            ⌨ Shortcuts
          </button>
        </div>
      </div>

      {!showHistory ? (
        <>
          <div className="mb-4 flex items-center justify-between">
            <h2 className="text-xl font-semibold">Active Alerts ({incidents.length})</h2>
            {error && (
              <span className="text-red-400 text-sm flex items-center gap-2">
                ⚠ Connection issue - using cached data
                <button onClick={refetch} className="underline hover:text-white">Retry</button>
              </span>
            )}
          </div>

          <IncidentList
            incidents={incidents}
            onResolve={handleResolve}
            onAssign={handleAssign}
            onDispatch={handleDispatch}
            dispatching={dispatching}
            dispatched={dispatched}
            darkMode={darkMode}
            loading={loading}
          />

          <section className="mt-8 max-w-5xl">
            <div className="flex justify-between items-center mb-4">
              <h2 className="text-xl font-semibold">Live Location</h2>
              <MapLegend darkMode={darkMode} />
            </div>
            <div className="relative">
              <LiveMapDynamic
                targetLat={latestIncident?.latitude || 28.6139}
                targetLng={latestIncident?.longitude || 77.209}
                incidents={incidents}
                routeCoords={[
                  [28.611, 77.205],
                  [28.6125, 77.2075],
                  [28.6139, 77.209],
                ]}
                safeZones={safeZones}
                darkMode={darkMode}
              />
            </div>
          </section>
        </>
      ) : (
        <HistoryView onBack={() => setShowHistory(false)} darkMode={darkMode} />
      )}

      {keyboardHelp && (
        <KeyboardShortcutsModal onClose={() => setKeyboardHelp(false)} />
      )}
    </main>
  );
}

function HistoryView({ onBack, darkMode }: { onBack: () => void; darkMode: boolean }) {
  const [history, setHistory] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);
  const [filters, setFilters] = useState({ severity: '', userId: '', dateFrom: '', dateTo: '' });

  useEffect(() => {
    fetchHistory();
  }, [filters]);

  const fetchHistory = async () => {
    setLoading(true);
    try {
      const params = new URLSearchParams();
      if (filters.severity) params.append('severity', filters.severity);
      if (filters.userId) params.append('user_id', filters.userId);
      params.append('limit', '100');
      const res = await fetch(`${API_URL}/incidents?${params}`);
      const data = await res.json();
      setHistory(data);
    } catch (e) {
      console.error('Failed to fetch history:', e);
    } finally {
      setLoading(false);
    }
  };

  const filteredHistory = history.filter((h) => {
    if (filters.dateFrom && new Date(h.created_at) < new Date(filters.dateFrom)) return false;
    if (filters.dateTo && new Date(h.created_at) > new Date(filters.dateTo)) return false;
    return true;
  });

  return (
    <div className="max-w-7xl mx-auto">
      <div className="flex justify-between items-center mb-6">
        <h2 className="text-2xl font-bold">Incident History</h2>
        <button onClick={onBack} className="px-4 py-2 rounded bg-gray-600 hover:bg-gray-700 text-white">← Back to Live</button>
      </div>

      <div className={`mb-6 p-4 rounded-lg ${darkMode ? 'bg-gray-800' : 'bg-white'}`}>
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
          <select
            value={filters.severity}
            onChange={(e) => setFilters((f) => ({ ...f, severity: e.target.value }))}
            className={`p-2 rounded ${darkMode ? 'bg-gray-700 text-white' : 'bg-gray-100'}`}
          >
            <option value="">All Severities</option>
            <option value="CRITICAL">Critical</option>
            <option value="HIGH RISK">High Risk</option>
            <option value="MONITOR">Monitor</option>
            <option value="SAFE">Safe</option>
          </select>
          <input
            type="text"
            placeholder="User ID"
            value={filters.userId}
            onChange={(e) => setFilters((f) => ({ ...f, userId: e.target.value }))}
            className={`p-2 rounded ${darkMode ? 'bg-gray-700 text-white' : 'bg-gray-100'}`}
          />
          <input
            type="date"
            value={filters.dateFrom}
            onChange={(e) => setFilters((f) => ({ ...f, dateFrom: e.target.value }))}
            className={`p-2 rounded ${darkMode ? 'bg-gray-700 text-white' : 'bg-gray-100'}`}
          />
          <input
            type="date"
            value={filters.dateTo}
            onChange={(e) => setFilters((f) => ({ ...f, dateTo: e.target.value }))}
            className={`p-2 rounded ${darkMode ? 'bg-gray-700 text-white' : 'bg-gray-100'}`}
          />
        </div>
      </div>

      {loading ? (
        <div className="text-center py-12">Loading history...</div>
      ) : (
        <div className="overflow-x-auto">
          <table className="w-full text-sm" role="table">
            <thead>
              <tr className={darkMode ? 'bg-gray-800' : 'bg-gray-100'}>
                <th className="p-3 text-left">Time</th>
                <th className="p-3 text-left">Severity</th>
                <th className="p-3 text-left">User</th>
                <th className="p-3 text-left">Risk Score</th>
                <th className="p-3 text-left">Summary</th>
                <th className="p-3 text-left">Status</th>
                <th className="p-3 text-left">Actions</th>
              </tr>
            </thead>
            <tbody>
              {filteredHistory.map((incident) => (
                <tr key={incident.incident_id} className="border-t border-gray-700 hover:bg-gray-800/50">
                  <td className="p-3 font-mono">{new Date(incident.created_at).toLocaleString()}</td>
                  <td className="p-3">
                    <span className={`px-2 py-1 rounded text-xs font-semibold ${
                      incident.severity === 'CRITICAL' ? 'bg-red-900/50 text-red-300' :
                      incident.severity === 'HIGH RISK' ? 'bg-orange-900/50 text-orange-300' :
                      incident.severity === 'MONITOR' ? 'bg-yellow-900/50 text-yellow-300' :
                      'bg-green-900/50 text-green-300'
                    }`}>{incident.severity}</span>
                  </td>
                  <td className="p-3">{incident.user_id}</td>
                  <td className="p-3 font-mono">{incident.risk_score}/100</td>
                  <td className="p-3 max-w-xs truncate">{incident.summary}</td>
                  <td className="p-3">
                    <span className={incident.status === 'resolved' ? 'text-green-400' : incident.status === 'assigned' ? 'text-blue-400' : 'text-yellow-400'}>
                      {incident.status || 'active'}
                    </span>
                  </td>
                  <td className="p-3">
                    <button
                      onClick={() => window.open(`/incidents/${incident.incident_id}`, '_blank')}
                      className="px-3 py-1 text-xs rounded bg-blue-600 hover:bg-blue-700 text-white mr-2"
                    >
                      View Details
                    </button>
                    {incident.status !== 'resolved' && (
                      <button
                        onClick={() => fetch(`${API_URL}/incidents/${incident.incident_id}`, { method: 'DELETE' }).then(fetchHistory)}
                        className="px-3 py-1 text-xs rounded bg-red-600 hover:bg-red-700 text-white"
                      >
                        Resolve
                      </button>
                    )}
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
          {filteredHistory.length === 0 && (
            <div className="text-center py-12 text-gray-500">No incidents match your filters</div>
          )}
        </div>
      )}
    </div>
  );
}

function KeyboardShortcutsModal({ onClose }: { onClose: () => void }) {
  const shortcuts = [
    { key: 'R', action: 'Resolve latest incident' },
    { key: 'A', action: 'Assign police to latest incident' },
    { key: 'D', action: 'Dispatch help for latest incident' },
    { key: 'N', action: 'Refresh incidents' },
    { key: 'M', action: 'Toggle dark/light mode' },
    { key: 'H', action: 'Show this help' },
    { key: 'Esc', action: 'Close this modal' },
  ];

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/50" onClick={onClose}>
      <div className="bg-gray-900 rounded-lg p-8 max-w-md w-full mx-4" onClick={(e) => e.stopPropagation()}>
        <div className="flex justify-between items-center mb-6">
          <h3 className="text-xl font-bold">Keyboard Shortcuts</h3>
          <button onClick={onClose} className="text-gray-400 hover:text-white">✕</button>
        </div>
        <div className="space-y-3">
          {shortcuts.map((s, i) => (
            <div key={i} className="flex justify-between py-2 border-b border-gray-700">
              <kbd className="px-3 py-1 bg-gray-800 rounded font-mono text-sm">{s.key}</kbd>
              <span className="text-gray-300">{s.action}</span>
            </div>
          ))}
        </div>
        <button onClick={onClose} className="mt-6 w-full py-2 bg-red-600 hover:bg-red-700 rounded font-bold">Close</button>
      </div>
    </div>
  );
}