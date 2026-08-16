"use client";

import dynamic from "next/dynamic";

const LiveMap = dynamic(
  () => import("../components/LiveMap"),
  {
    ssr: false
  }
);

export default function CommandCenter() {
  return (
    <main className="min-h-screen bg-gray-900 text-white p-8">
      <h1 className="text-3xl font-bold text-red-500">
        Proactive Guard Command Center
      </h1>

      <p className="text-gray-400 mt-2">
        Live Monitoring Dashboard
      </p>

      <h2 className="text-xl font-semibold mt-8 mb-4">
        Active Alerts (1)
      </h2>

      <div className="bg-gray-800 border-l-8 border-red-600 p-6 rounded-md max-w-2xl">
        <h3 className="text-2xl font-bold text-red-400">
          CRITICAL: Physical Distress
        </h3>

        <p className="text-gray-300 mt-2">
          Incident ID: INC-1001
        </p>

        <p className="text-gray-300">
          User: U-047
        </p>

        <p className="text-gray-400 mt-4 italic">
          "Audio score is very high. User deviated from planned route."
        </p>

        <button className="bg-red-600 text-white font-bold py-2 px-4 rounded mt-6">
          Dispatch Help
        </button>
      </div>

      {/* Live Map */}
      <section className="mt-8 max-w-5xl">
        <h2 className="text-xl font-semibold mb-4">
          Live Location
        </h2>

        <LiveMap />
      </section>
    </main>
  );
}