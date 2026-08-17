"use client";

import dynamic from "next/dynamic";
import { useEffect, useState, useCallback } from "react";

const LiveMap = dynamic(
  () => import("../components/LiveMap"),
  {
    ssr: false,
  }
);

type Incident = {
  incident_id: string;
  severity: string;
  risk_score: number;
  latitude: number;
  longitude: number;
  summary: string;
};

export default function CommandCenter() {
  const [incidents, setIncidents] = useState<Incident[]>([]);
  const [dispatching, setDispatching] = useState<string | null>(null);
  const [dispatched, setDispatched] = useState<string[]>([]);
  const [darkMode, setDarkMode] = useState(true);
  const [showSafeZones, setShowSafeZones] = useState(false);

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

  const fetchIncidents = useCallback(async () => {
    try {
      const response = await fetch("http://127.0.0.1:8000/incidents");
      const data = await response.json();
      setIncidents(data);
    } catch (error) {
      console.error("Failed to connect to backend:", error);
    }
  }, []);

  useEffect(() => {
    fetchIncidents();
  }, [fetchIncidents]);

  const handleDispatch = (incidentId: string) => {
    setDispatching(incidentId);

    setTimeout(() => {
      setDispatching(null);
      setDispatched((previous) => [...previous, incidentId]);
    }, 1000);
  };

  const handleResolve = async (incidentId: string) => {
    try {
      await fetch(`http://127.0.0.1:8000/incidents/${incidentId}`, { method: "DELETE" });
      setIncidents((prev) => prev.filter((i) => i.incident_id !== incidentId));
    } catch (e) {
      console.error("Resolve failed", e);
    }
  };

  const safeZones = showSafeZones
    ? [
        { lat: 28.6139, lng: 77.209, radius: 500 },
        { lat: 28.62, lng: 77.215, radius: 300 },
        { lat: 28.605, lng: 77.2, radius: 400 }
      ]
    : [];

  return (
    <main className={`min-h-screen text-white p-8 transition-colors ${darkMode ? "bg-gray-900" : "bg-gray-100 text-gray-900"}`}>
      <div className="flex justify-between items-center mb-8">
        <div>
          <h1 className="text-3xl font-bold text-red-500">
            Proactive Guard Command Center
          </h1>
          <p className={darkMode ? "text-gray-400 mt-2" : "text-gray-600 mt-2"}>Live Monitoring Dashboard</p>
        </div>
        <div className="flex items-center gap-4">
          <button
            onClick={toggleDarkMode}
            className={darkMode ? "bg-gray-800 text-white px-4 py-2 rounded hover:bg-gray-700 transition-colors" : "bg-gray-200 text-gray-900 px-4 py-2 rounded hover:bg-gray-300 transition-colors"}
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
            Show Safe Zones
          </label>
        </div>
      </div>

      <h2 className="text-xl font-semibold mt-8 mb-4">
        Active Alerts ({incidents.length})
      </h2>

      {incidents.map((incident) => {
        const isDispatching = dispatching === incident.incident_id;
        const isDispatched = dispatched.includes(incident.incident_id);

        return (
          <div
            key={incident.incident_id}
            className={`border-l-8 p-6 rounded-md max-w-2xl mb-4 transition-colors ${
              darkMode
                ? "bg-gray-800 border-red-600 text-white"
                : "bg-white border-red-600 text-gray-900 shadow"
            }`}
          >
            <div className="flex justify-between items-start">
              <div>
                <h3 className="text-2xl font-bold text-red-400">
                  {incident.severity}: Threat Detected
                </h3>
                <p className={darkMode ? "text-gray-300 mt-2" : "text-gray-600 mt-2"}>Incident ID: {incident.incident_id}</p>
                <p className={darkMode ? "text-gray-300" : "text-gray-600"}>Risk Score: {incident.risk_score}/100</p>
                <p className={darkMode ? "text-gray-400 mt-4 italic" : "text-gray-500 mt-4 italic"}>"{incident.summary}"</p>
              </div>
              <div className="flex flex-col gap-2 ml-4">
                <button
                  onClick={() => handleDispatch(incident.incident_id)}
                  disabled={isDispatching || isDispatched}
                  className={
                    isDispatched
                      ? "bg-green-600 text-white font-bold py-2 px-4 rounded"
                      : isDispatching
                      ? "bg-gray-600 text-white font-bold py-2 px-4 rounded cursor-wait"
                      : "bg-red-600 hover:bg-red-700 text-white font-bold py-2 px-4 rounded"
                  }
                >
                  {isDispatched
                    ? "Help Dispatched ✓"
                    : isDispatching
                    ? "Dispatching..."
                    : "Dispatch Help"}
                </button>
                <button
                  onClick={() => handleResolve(incident.incident_id)}
                  className={darkMode ? "bg-gray-600 hover:bg-gray-700 text-white font-bold py-2 px-4 rounded" : "bg-gray-300 hover:bg-gray-400 text-gray-900 font-bold py-2 px-4 rounded"}
                >
                  Resolve
                </button>
              </div>
            </div>
          </div>
        );
      })}

      <section className="mt-8 max-w-5xl">
        <div className="flex justify-between items-center mb-4">
          <h2 className="text-xl font-semibold">Live Location</h2>
        </div>
        <LiveMap
          targetLat={incidents[0]?.latitude || 28.6139}
          targetLng={incidents[0]?.longitude || 77.209}
          incidents={incidents}
          routeCoords={[
            [28.611, 77.205],
            [28.6125, 77.2075],
            [28.6139, 77.209]
          ]}
          safeZones={safeZones}
          darkMode={darkMode}
        />
      </section>
    </main>
  );
}