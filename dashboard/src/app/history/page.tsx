"use client";

import { useEffect, useState, useCallback } from "react";
import { Toaster, toast } from "sonner";
import Link from "next/link";

const API_URL = process.env.NEXT_PUBLIC_API_BASE_URL || "http://127.0.0.1:8000";

interface Incident {
  incident_id: string;
  user_id: string;
  severity: string;
  risk_score: number;
  latitude: number;
  longitude: number;
  summary: string;
  ai_summary?: string;
  responder?: string;
  status?: string;
  created_at: string;
  updated_at?: string;
}

export default function HistoryPage() {
  const [incidents, setIncidents] = useState<Incident[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [filters, setFilters] = useState({
    severity: "",
    userId: "",
    dateFrom: "",
    dateTo: "",
  });
  const [darkMode, setDarkMode] = useState(true);

  useEffect(() => {
    const saved = localStorage.getItem("darkMode");
    if (saved !== null) setDarkMode(saved === "true");
  }, []);

  const fetchIncidents = useCallback(async () => {
    setLoading(true);
    setError(null);
    try {
      const params = new URLSearchParams();
      if (filters.severity) params.append("severity", filters.severity);
      if (filters.userId) params.append("user_id", filters.userId);
      params.append("limit", "100");
      const res = await fetch(`${API_URL}/incidents?${params}`);
      if (!res.ok) throw new Error("Failed to fetch");
      const data = await res.json();
      setIncidents(data);
    } catch (e) {
      setError(e instanceof Error ? e.message : "Unknown error");
    } finally {
      setLoading(false);
    }
  }, [filters]);

  useEffect(() => {
    fetchIncidents();
  }, [fetchIncidents]);

  const filtered = incidents.filter((h) => {
    if (filters.dateFrom && new Date(h.created_at) < new Date(filters.dateFrom)) return false;
    if (filters.dateTo && new Date(h.created_at) > new Date(filters.dateTo)) return false;
    return true;
  });

  const handleResolve = async (id: string) => {
    try {
      const res = await fetch(`${API_URL}/incidents/${id}`, { method: "DELETE" });
      if (res.ok) {
        toast.success("Incident resolved");
        fetchIncidents();
      } else {
        toast.error("Failed to resolve");
      }
    } catch {
      toast.error("Network error");
    }
  };

  const severityColors: Record<string, string> = {
    CRITICAL: "bg-red-900/50 text-red-300 border-red-700",
    "HIGH RISK": "bg-orange-900/50 text-orange-300 border-orange-700",
    MONITOR: "bg-yellow-900/50 text-yellow-300 border-yellow-700",
    SAFE: "bg-green-900/50 text-green-300 border-green-700",
  };

  const statusColors: Record<string, string> = {
    resolved: "text-green-400",
    assigned: "text-blue-400",
    active: "text-yellow-400",
  };

  return (
    <main className={`min-h-screen p-8 transition-colors ${darkMode ? "bg-gray-900 text-white" : "bg-gray-100 text-gray-900"}`}>
      <Toaster position="top-right" theme={darkMode ? "dark" : "light"} />

      <div className="max-w-7xl mx-auto">
        <div className="flex justify-between items-center mb-8">
          <div>
            <h1 className="text-3xl font-bold text-red-500">Incident History</h1>
            <p className={darkMode ? "text-gray-400 mt-1" : "text-gray-600 mt-1"}>
              View and manage resolved incidents
            </p>
          </div>
          <Link
            href="/"
            className={`px-4 py-2 rounded transition-colors ${
              darkMode ? "bg-gray-800 hover:bg-gray-700 text-white" : "bg-gray-200 hover:bg-gray-300 text-gray-900"
            }`}
          >
            ← Back to Live Dashboard
          </Link>
        </div>

        {error && (
          <div className="mb-6 p-4 bg-red-900/30 border border-red-700 rounded text-red-300 flex justify-between items-center">
            <span>⚠ {error}</span>
            <button onClick={fetchIncidents} className="underline hover:text-white">Retry</button>
          </div>
        )}

        <div className={`mb-6 p-4 rounded-lg ${darkMode ? "bg-gray-800" : "bg-white"}`}>
          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
            <select
              value={filters.severity}
              onChange={(e) => setFilters((f) => ({ ...f, severity: e.target.value }))}
              className={`p-2 rounded border ${darkMode ? "bg-gray-700 text-white border-gray-600" : "bg-gray-100 border-gray-300"}`}
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
              className={`p-2 rounded border ${darkMode ? "bg-gray-700 text-white border-gray-600" : "bg-gray-100 border-gray-300"}`}
            />

            <input
              type="date"
              value={filters.dateFrom}
              onChange={(e) => setFilters((f) => ({ ...f, dateFrom: e.target.value }))}
              className={`p-2 rounded border ${darkMode ? "bg-gray-700 text-white border-gray-600" : "bg-gray-100 border-gray-300"}`}
            />

            <input
              type="date"
              value={filters.dateTo}
              onChange={(e) => setFilters((f) => ({ ...f, dateTo: e.target.value }))}
              className={`p-2 rounded border ${darkMode ? "bg-gray-700 text-white border-gray-600" : "bg-gray-100 border-gray-300"}`}
            />
          </div>
        </div>

        {loading ? (
          <div className="space-y-4">
            {[1, 2, 3, 4, 5].map((i) => (
              <div key={i} className={`h-20 rounded-lg animate-pulse ${darkMode ? "bg-gray-800" : "bg-gray-200"}`} />
            ))}
          </div>
        ) : filtered.length === 0 ? (
          <div className="text-center py-16">
            <div className="text-6xl mb-4">📭</div>
            <h3 className="text-xl font-semibold mb-2">No Incidents Found</h3>
            <p className={darkMode ? "text-gray-500" : "text-gray-400"}>Try adjusting your filters</p>
          </div>
        ) : (
          <div className="overflow-x-auto">
            <table className="w-full text-sm" role="table">
              <thead>
                <tr className={darkMode ? "bg-gray-800" : "bg-gray-100"}>
                  <th className="p-3 text-left">Time</th>
                  <th className="p-3 text-left">Severity</th>
                  <th className="p-3 text-left">User</th>
                  <th className="p-3 text-left">Risk Score</th>
                  <th className="p-3 text-left">Summary</th>
                  <th className="p-3 text-left">Status</th>
                  <th className="p-3 text-left">Responder</th>
                  <th className="p-3 text-left">Actions</th>
                </tr>
              </thead>
              <tbody>
                {filtered.map((incident) => (
                  <tr key={incident.incident_id} className={`border-t ${darkMode ? "border-gray-700" : "border-gray-200"} hover:bg-gray-800/50`}>
                    <td className="p-3 font-mono whitespace-nowrap">
                      {new Date(incident.created_at).toLocaleString()}
                    </td>
                    <td className="p-3">
                      <span className={`px-2 py-1 rounded text-xs font-semibold border ${severityColors[incident.severity] || ""}`}>
                        {incident.severity}
                      </span>
                    </td>
                    <td className="p-3">{incident.user_id}</td>
                    <td className="p-3 font-mono">{incident.risk_score}/100</td>
                    <td className="p-3 max-w-xs truncate" title={incident.summary}>
                      {incident.summary}
                    </td>
                    <td className="p-3">
                      <span className={statusColors[incident.status || "active"] || statusColors.active}>
                        {incident.status || "active"}
                      </span>
                    </td>
                    <td className="p-3">
                      {incident.responder ? (
                        <span className="text-green-400">{incident.responder}</span>
                      ) : (
                        <span className={darkMode ? "text-gray-500" : "text-gray-400"}>Unassigned</span>
                      )}
                    </td>
                    <td className="p-3">
                      <div className="flex gap-2">
                        <Link
                          href={`/incidents/${incident.incident_id}`}
                          className="px-3 py-1 text-xs rounded bg-blue-600 hover:bg-blue-700 text-white"
                        >
                          View
                        </Link>
                        {incident.status !== "resolved" && (
                          <button
                            onClick={() => handleResolve(incident.incident_id)}
                            className="px-3 py-1 text-xs rounded bg-red-600 hover:bg-red-700 text-white"
                          >
                            Resolve
                          </button>
                        )}
                      </div>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}
      </div>
    </main>
  );
}