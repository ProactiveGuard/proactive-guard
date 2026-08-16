"use client";

import dynamic from "next/dynamic";
import { useEffect, useState } from "react";

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

  useEffect(() => {
    const fetchIncidents = async () => {
      try {
        const response = await fetch("http://127.0.0.1:8000/incidents");
        const data = await response.json();
        setIncidents(data);
      } catch (error) {
        console.error("Failed to connect to backend:", error);
      }
    };

    fetchIncidents();
  }, []);

  const handleDispatch = (incidentId: string) => {
    setDispatching(incidentId);

    setTimeout(() => {
      setDispatching(null);
      setDispatched((previous) => [...previous, incidentId]);
    }, 1000);
  };

  return (
    <main className="min-h-screen bg-gray-900 text-white p-8">
      <h1 className="text-3xl font-bold text-red-500">
        Proactive Guard Command Center
      </h1>

      <p className="text-gray-400 mt-2">
        Live Monitoring Dashboard
      </p>

      <h2 className="text-xl font-semibold mt-8 mb-4">
        Active Alerts ({incidents.length})
      </h2>

      {incidents.map((incident) => {
        const isDispatching = dispatching === incident.incident_id;
        const isDispatched = dispatched.includes(incident.incident_id);

        return (
          <div
            key={incident.incident_id}
            className="bg-gray-800 border-l-8 border-red-600 p-6 rounded-md max-w-2xl mb-4"
          >
            <h3 className="text-2xl font-bold text-red-400">
              {incident.severity}: Threat Detected
            </h3>

            <p className="text-gray-300 mt-2">
              Incident ID: {incident.incident_id}
            </p>

            <p className="text-gray-300">
              Risk Score: {incident.risk_score}/100
            </p>

            <p className="text-gray-400 mt-4 italic">
              "{incident.summary}"
            </p>

            <button
              onClick={() => handleDispatch(incident.incident_id)}
              disabled={isDispatching || isDispatched}
              className={
                isDispatched
                  ? "bg-green-600 text-white font-bold py-2 px-4 rounded mt-6"
                  : isDispatching
                  ? "bg-gray-600 text-white font-bold py-2 px-4 rounded mt-6 cursor-wait"
                  : "bg-red-600 hover:bg-red-700 text-white font-bold py-2 px-4 rounded mt-6"
              }
            >
              {isDispatched
                ? "Help Dispatched ✓"
                : isDispatching
                ? "Dispatching..."
                : "Dispatch Help"}
            </button>
          </div>
        );
      })}

      <section className="mt-8 max-w-5xl">
        <h2 className="text-xl font-semibold mb-4">
          Live Location
        </h2>

        <LiveMap />
      </section>
    </main>
  );
}