'use client';

interface MapLegendProps {
  darkMode?: boolean;
}

const legendItems = [
  { label: 'Critical Incident', color: 'red', icon: '🚨' },
  { label: 'High Risk', color: 'orange', icon: '⚡' },
  { label: 'Monitor', color: 'yellow', icon: '⚠' },
  { label: 'Safe', color: 'green', icon: '✓' },
  { label: 'Safe Zone', color: 'green', icon: '🟢', dashed: true },
  { label: 'User Route', color: 'blue', icon: '━━', dashed: true },
  { label: 'Latest Location', color: 'red', icon: '●', pulse: true },
];

export function MapLegend({ darkMode = false }: MapLegendProps) {
  return (
    <div
      className={`absolute bottom-4 right-4 z-20 p-3 rounded-lg shadow-lg backdrop-blur-sm transition-colors ${
        darkMode
          ? 'bg-gray-800/90 text-white border border-gray-700'
          : 'bg-white/90 text-gray-900 border border-gray-200'
      }`}
      style={{ minWidth: '200px' }}
    >
      <div className="flex items-center gap-2 mb-2">
        <span className="font-semibold text-sm">Map Legend</span>
      </div>
      <div className="space-y-1.5">
        {legendItems.map((item, i) => (
          <div key={i} className="flex items-center gap-2 text-xs">
            {item.dashed ? (
              <div
                className="w-6 h-1 rounded"
                style={{
                  background: `repeating-linear-gradient(90deg, ${item.color} 0, ${item.color} 4px, transparent 4px, transparent 8px)`,
                }}
              />
            ) : item.pulse ? (
              <div
                className="w-3 h-3 rounded-full"
                style={{
                  backgroundColor: item.color,
                  animation: 'pulse 2s infinite',
                }}
              />
            ) : (
              <div className="w-3 h-3 rounded-full" style={{ backgroundColor: item.color }} />
            )}
            <span className="flex items-center gap-1">
              <span aria-hidden="true">{item.icon}</span>
              {item.label}
            </span>
          </div>
        ))}
      </div>
      <style jsx>{`
        @keyframes pulse {
          0%, 100% { opacity: 1; transform: scale(1); }
          50% { opacity: 0.5; transform: scale(1.2); }
        }
      `}</style>
    </div>
  );
}