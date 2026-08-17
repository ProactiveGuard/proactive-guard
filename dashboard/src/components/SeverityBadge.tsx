'use client';

interface SeverityBadgeProps {
  severity: 'SAFE' | 'MONITOR' | 'HIGH RISK' | 'CRITICAL';
  className?: string;
}

const severityConfig: Record<
  'SAFE' | 'MONITOR' | 'HIGH RISK' | 'CRITICAL',
  { label: string; bg: string; text: string; border: string; icon: string }
> = {
  SAFE: {
    label: 'SAFE',
    bg: 'bg-green-100',
    text: 'text-green-800',
    border: 'border-green-300',
    icon: '✓',
  },
  MONITOR: {
    label: 'MONITOR',
    bg: 'bg-yellow-100',
    text: 'text-yellow-800',
    border: 'border-yellow-300',
    icon: '⚠',
  },
  'HIGH RISK': {
    label: 'HIGH RISK',
    bg: 'bg-orange-100',
    text: 'text-orange-800',
    border: 'border-orange-300',
    icon: '⚡',
  },
  CRITICAL: {
    label: 'CRITICAL',
    bg: 'bg-red-100',
    text: 'text-red-800',
    border: 'border-red-300',
    icon: '🚨',
  },
};

export function SeverityBadge({ severity, className = '' }: SeverityBadgeProps) {
  const config = severityConfig[severity] || severityConfig.SAFE;

  return (
    <span
      className={`inline-flex items-center gap-1.5 px-3 py-1 rounded-full text-sm font-semibold border ${config.bg} ${config.text} ${config.border} ${className}`}
    >
      <span aria-hidden="true">{config.icon}</span>
      <span>{config.label}</span>
    </span>
  );
}

export function RiskScoreBadge({ score }: { score: number }) {
  let color = 'bg-gray-100 text-gray-800';
  if (score >= 75) color = 'bg-red-100 text-red-800';
  else if (score >= 55) color = 'bg-orange-100 text-orange-800';
  else if (score >= 35) color = 'bg-yellow-100 text-yellow-800';
  else color = 'bg-green-100 text-green-800';

  return (
    <span className={`inline-flex items-center px-2.5 py-1 rounded-full text-sm font-mono font-bold ${color}`}>
      {score}/100
    </span>
  );
}