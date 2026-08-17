"use client";

import dynamic from "next/dynamic";
import { useEffect, useState, useCallback } from "react";
import { Toaster, toast } from "sonner";
import { IncidentList } from "@/components/IncidentList";
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
  const criticalCount = incidents.filter((incident) => incident.severity === "CRITICAL").length;
  const highRiskCount = incidents.filter((incident) => incident.severity === "HIGH RISK").length;
  const averageRisk = incidents.length
    ? Math.round(incidents.reduce((total, incident) => total + incident.risk_score, 0) / incidents.length)
    : 0;

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
    <main className={`min-h-screen p-4 text-slate-50 transition-colors sm:p-6 lg:p-8 ${darkMode ? "" : "bg-slate-50 text-slate-950"}`}>
      <Toaster
        position="top-right"
        theme={darkMode ? "dark" : "light"}
        toastOptions={{
          duration: 3000,
          style: darkMode ? { background: '#1f2937', color: '#fff' } : {},
        }}
      />

      <div className="mx-auto flex w-full max-w-7xl flex-col gap-6">
        <header className={`overflow-hidden rounded-2xl border p-5 shadow-glow sm:p-6 ${darkMode ? "border-white/10 bg-slate-950/72" : "border-slate-200 bg-white"}`}>
          <div className="flex flex-col gap-5 lg:flex-row lg:items-center lg:justify-between">
            <div className="max-w-3xl">
              <div className={`mb-3 inline-flex items-center gap-2 rounded-full border px-3 py-1 text-xs font-semibold uppercase tracking-[0.18em] ${darkMode ? "border-red-400/30 bg-red-400/10 text-red-200" : "border-red-200 bg-red-50 text-red-700"}`}>
                <span className="h-2 w-2 rounded-full bg-emerald-400 shadow-[0_0_18px_rgba(52,211,153,0.9)]" />
                Live safety operations
              </div>
              <h1 className="text-3xl font-black tracking-tight sm:text-4xl">
                Proactive Guard Command Center
              </h1>
              <p className={`mt-2 max-w-2xl text-sm sm:text-base ${darkMode ? "text-slate-300" : "text-slate-600"}`}>
                AI-assisted women safety monitoring with live risk scoring, responder assignment, and location intelligence.
              </p>
            </div>
            <div className="flex flex-wrap items-center gap-3">
              <button
                onClick={toggleDarkMode}
                className={darkMode
                  ? "rounded-lg border border-white/10 bg-white/10 px-4 py-2 text-sm font-semibold text-white transition hover:bg-white/15"
                  : "rounded-lg border border-slate-200 bg-slate-100 px-4 py-2 text-sm font-semibold text-slate-900 transition hover:bg-slate-200"}
                aria-label={darkMode ? "Switch to light mode" : "Switch to dark mode"}
              >
                {darkMode ? "Light mode" : "Dark mode"}
              </button>
              <label className={`flex items-center gap-2 rounded-lg border px-3 py-2 text-sm font-medium ${darkMode ? "border-white/10 bg-white/10" : "border-slate-200 bg-slate-100"}`}>
                <input
                  type="checkbox"
                  checked={showSafeZones}
                  onChange={(e) => setShowSafeZones(e.target.checked)}
                  className="h-4 w-4 accent-red-500"
                />
                Safe zones
              </label>
              <button
                onClick={() => setShowHistory(!showHistory)}
                className={`rounded-lg px-4 py-2 text-sm font-semibold transition ${
                  showHistory
                    ? "bg-red-600 text-white hover:bg-red-500"
                    : darkMode
                    ? "border border-white/10 bg-white/10 text-white hover:bg-white/15"
                    : "border border-slate-200 bg-slate-100 text-slate-900 hover:bg-slate-200"
                }`}
              >
                {showHistory ? "Live view" : "History"}
              </button>
              <button
                onClick={() => setKeyboardHelp(true)}
                className={`rounded-lg px-4 py-2 text-sm font-semibold transition ${
                  darkMode ? "border border-white/10 bg-white/10 text-white hover:bg-white/15" : "border border-slate-200 bg-slate-100 text-slate-900 hover:bg-slate-200"
                }`}
              >
                Shortcuts
              </button>
            </div>
          </div>
        </header>

        {!showHistory && (
          <section className="grid gap-4 sm:grid-cols-2 xl:grid-cols-4">
            <MetricCard title="Active alerts" value={incidents.length.toString()} tone="red" darkMode={darkMode} />
            <MetricCard title="Critical" value={criticalCount.toString()} tone="rose" darkMode={darkMode} />
            <MetricCard title="High risk" value={highRiskCount.toString()} tone="amber" darkMode={darkMode} />
            <MetricCard title="Average risk" value={`${averageRisk}/100`} tone="teal" darkMode={darkMode} />
          </section>
        )}

        {error && !showHistory && (
          <div className={`flex flex-col gap-3 rounded-xl border px-4 py-3 text-sm sm:flex-row sm:items-center sm:justify-between ${darkMode ? "border-amber-300/20 bg-amber-300/10 text-amber-100" : "border-amber-200 bg-amber-50 text-amber-900"}`}>
            <span>Connection issue detected. The dashboard is showing the latest cached incident state.</span>
            <button onClick={refetch} className="font-bold underline underline-offset-4">Retry connection</button>
          </div>
        )}

        {!showHistory ? (
          <section className="grid gap-6 xl:grid-cols-[minmax(360px,0.88fr)_minmax(520px,1.12fr)]">
            <div className={`rounded-2xl border p-4 ${darkMode ? "border-white/10 bg-slate-950/72" : "border-slate-200 bg-white"}`}>
              <div className="mb-4 flex items-center justify-between gap-3">
                <div>
                  <h2 className="text-xl font-bold">Active Alerts</h2>
                  <p className={`text-sm ${darkMode ? "text-slate-400" : "text-slate-500"}`}>Severity sorted incident queue</p>
                </div>
                <button
                  onClick={refetch}
                  className={`rounded-lg px-3 py-2 text-sm font-semibold transition ${darkMode ? "bg-white/10 hover:bg-white/15" : "bg-slate-100 hover:bg-slate-200"}`}
                >
                  Refresh
                </button>
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
            </div>

            <div className={`rounded-2xl border p-4 ${darkMode ? "border-white/10 bg-slate-950/72" : "border-slate-200 bg-white"}`}>
              <div className="mb-4 flex flex-col gap-3 sm:flex-row sm:items-center sm:justify-between">
                <div>
                  <h2 className="text-xl font-bold">Live Location</h2>
                  <p className={`text-sm ${darkMode ? "text-slate-400" : "text-slate-500"}`}>Delhi demo route with alert radius and safe-zone overlays</p>
                </div>
                <MapLegend darkMode={darkMode} />
              </div>
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
        ) : (
          <HistoryView onBack={() => setShowHistory(false)} darkMode={darkMode} />
        )}

        {keyboardHelp && (
          <KeyboardShortcutsModal onClose={() => setKeyboardHelp(false)} />
        )}
      </div>
    </main>
  );
}

function MetricCard({
  title,
  value,
  tone,
  darkMode,
}: {
  title: string;
  value: string;
  tone: "red" | "rose" | "amber" | "teal";
  darkMode: boolean;
}) {
  const toneClasses = {
    red: "from-red-500/18 to-red-500/5 text-red-200",
    rose: "from-rose-500/18 to-rose-500/5 text-rose-200",
    amber: "from-amber-500/18 to-amber-500/5 text-amber-200",
    teal: "from-teal-500/18 to-teal-500/5 text-teal-200",
  };

  return (
    <div className={`rounded-2xl border bg-gradient-to-br p-4 ${toneClasses[tone]} ${darkMode ? "border-white/10" : "border-slate-200 bg-white text-slate-900"}`}>
      <p className={`text-sm font-semibold ${darkMode ? "text-slate-300" : "text-slate-500"}`}>{title}</p>
      <p className="mt-2 text-3xl font-black tracking-tight">{value}</p>
    </div>
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
                        onClick={() => fetch(`${API_URL}/api/v1/incidents/${incident.incident_id}`, { method: 'DELETE' }).then(fetchHistory)}
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
