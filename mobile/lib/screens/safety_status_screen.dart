import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../main.dart';
import '../models/telemetry.dart';
import '../utils/constants.dart';

class SafetyStatusScreen extends StatelessWidget {
  const SafetyStatusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Safety Status'),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Overall Safety Score
                  _OverallSafetyScore(appState: appState),
                  
                  const SizedBox(height: 24),
                  
                  // Permissions Status
                  _PermissionsStatusSection(appState: appState),
                  
                  const SizedBox(height: 24),
                  
                  // Monitoring Status
                  _MonitoringStatusSection(appState: appState),
                  
                  const SizedBox(height: 24),
                  
                  // Network & API Status
                  _NetworkStatusSection(appState: appState),
                  
                  const SizedBox(height: 24),
                  
                  // Recent Incidents
                  _RecentIncidentsSection(appState: appState),
                  
                  const SizedBox(height: 24),
                  
                  // Device Health
                  _DeviceHealthSection(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _OverallSafetyScore extends StatelessWidget {
  final AppState appState;
  const _OverallSafetyScore({required this.appState});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Calculate safety score based on various factors
    int score = 100;
    List<String> issues = [];

    if (!appState.settings.locationSharingEnabled) {
      score -= 30;
      issues.add('Location sharing disabled');
    }
    if (!appState.settings.audioMonitoringEnabled) {
      score -= 15;
      issues.add('Audio monitoring disabled');
    }
    if (!appState.settings.motionMonitoringEnabled) {
      score -= 15;
      issues.add('Motion monitoring disabled');
    }
    if (appState.settings.activeGuardians.isEmpty) {
      score -= 20;
      issues.add('No guardians configured');
    }
    if (appState.telemetryFailedCount > appState.telemetrySentCount && appState.telemetrySentCount > 0) {
      score -= 20;
      issues.add('Network issues detected');
    }
    if (appState.lastLocation == null && appState.isJourneyActive) {
      score -= 25;
      issues.add('No GPS fix');
    }

    score = score.clamp(0, 100);

    Color scoreColor;
    String scoreLabel;
    IconData scoreIcon;

    if (score >= 80) {
      scoreColor = Colors.green;
      scoreLabel = 'Excellent';
      scoreIcon = Icons.shield;
    } else if (score >= 60) {
      scoreColor = Colors.amber;
      scoreLabel = 'Good';
      scoreIcon = Icons.shield_outlined;
    } else if (score >= 40) {
      scoreColor = Colors.orange;
      scoreLabel = 'Fair';
      scoreIcon = Icons.warning_amber;
    } else {
      scoreColor = Colors.red;
      scoreLabel = 'Poor';
      scoreIcon = Icons.warning;
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: scoreColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(scoreIcon, color: scoreColor, size: 36),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Safety Score',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        scoreLabel,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: scoreColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '$score/100',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: scoreColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: score / 100,
              backgroundColor: scoreColor.withOpacity(0.1),
              valueColor: AlwaysStoppedAnimation<Color>(scoreColor),
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),
            if (issues.isNotEmpty) ...[
              const SizedBox(height: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: issues.map((issue) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Icon(Icons.circle, size: 8, color: scoreColor),
                      const SizedBox(width: 12),
                      Text(
                        issue,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                )).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _PermissionsStatusSection extends StatelessWidget {
  final AppState appState;
  const _PermissionsStatusSection({required this.appState});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Permissions Status',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Column(
            children: [
              _PermissionTile(
                title: 'Location Access',
                subtitle: 'Required for GPS tracking',
                icon: Icons.location_on,
                isGranted: appState.settings.locationSharingEnabled,
                isRequired: true,
                onTap: () => _openLocationSettings(context),
              ),
              const Divider(height: 1, indent: 16, endIndent: 16),
              _PermissionTile(
                title: 'Microphone Access',
                subtitle: 'Required for audio level monitoring',
                icon: Icons.mic,
                isGranted: appState.settings.audioMonitoringEnabled,
                onTap: () => _openAppSettings(context),
              ),
              const Divider(height: 1, indent: 16, endIndent: 16),
              _PermissionTile(
                title: 'Motion Sensors',
                subtitle: 'Required for movement detection',
                icon: Icons.directions_run,
                isGranted: appState.settings.motionMonitoringEnabled,
                onTap: () => _openAppSettings(context),
              ),
              const Divider(height: 1, indent: 16, endIndent: 16),
              _PermissionTile(
                title: 'Notification Access',
                subtitle: 'Required for guardian alerts',
                icon: Icons.notifications,
                isGranted: true, // Assume granted for demo
                onTap: () => _openAppSettings(context),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _openLocationSettings(BuildContext context) {
    appState.locationService.openLocationSettings();
  }

  void _openAppSettings(BuildContext context) {
    appState.locationService.openAppSettings();
  }
}

class _PermissionTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isGranted;
  final bool isRequired;
  final VoidCallback onTap;
  const _PermissionTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isGranted,
    this.isRequired = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isGranted ? colorScheme.primary.withOpacity(0.1) : Colors.grey[100],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          color: isGranted ? colorScheme.primary : Colors.grey,
          size: 24,
        ),
      ),
      title: Row(
        children: [
          Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          if (isRequired) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
              decoration: BoxDecoration(
                color: colorScheme.primary,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'REQUIRED',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
      subtitle: Text(
        subtitle,
        style: theme.textTheme.bodySmall?.copyWith(
          color: Colors.grey[600],
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isGranted ? Icons.check_circle : Icons.cancel,
            color: isGranted ? Colors.green : Colors.red,
            size: 24,
          ),
          const SizedBox(width: 8),
          Icon(Icons.chevron_right, color: Colors.grey[400]),
        ],
      ),
    );
  }
}

class _MonitoringStatusSection extends StatelessWidget {
  final AppState appState;
  const _MonitoringStatusSection({required this.appState});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Monitoring Status',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Column(
            children: [
              _MonitoringTile(
                title: 'GPS Tracking',
                subtitle: appState.lastLocation != null
                    ? 'Last update: ${_formatTimeAgo(appState.lastLocation!.timestamp)}'
                    : appState.isJourneyActive ? 'Acquiring signal...' : 'Inactive',
                icon: Icons.gps_fixed,
                isActive: appState.lastLocation != null && appState.isJourneyActive,
                color: Colors.blue,
                lastUpdate: appState.lastLocation?.timestamp,
              ),
              const Divider(height: 1, indent: 16, endIndent: 16),
              _MonitoringTile(
                title: 'Audio Monitoring',
                subtitle: appState.lastAudioData != null
                    ? '${appState.lastAudioData!.decibelLevel.toStringAsFixed(1)} dB • ${(appState.lastAudioData!.normalizedScore * 100).toStringAsFixed(0)}%'
                    : appState.isJourneyActive && appState.settings.audioMonitoringEnabled ? 'Initializing...' : 'Inactive',
                icon: Icons.mic,
                isActive: appState.lastAudioData != null && appState.isJourneyActive,
                color: Colors.purple,
                lastUpdate: appState.lastAudioData?.timestamp,
                progress: appState.lastAudioData?.normalizedScore,
              ),
              const Divider(height: 1, indent: 16, endIndent: 16),
              _MonitoringTile(
                title: 'Motion Detection',
                subtitle: appState.lastMotionData != null
                    ? '${appState.lastMotionData!.magnitude.toStringAsFixed(2)} m/s² • ${(appState.lastMotionData!.normalizedScore * 100).toStringAsFixed(0)}%'
                    : appState.isJourneyActive && appState.settings.motionMonitoringEnabled ? 'Initializing...' : 'Inactive',
                icon: Icons.directions_run,
                isActive: appState.lastMotionData != null && appState.isJourneyActive,
                color: Colors.orange,
                lastUpdate: appState.lastMotionData?.timestamp,
                progress: appState.lastMotionData?.normalizedScore,
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatTimeAgo(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inSeconds < 60) return '${diff.inSeconds}s ago';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    return '${diff.inHours}h ago';
  }
}

class _MonitoringTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isActive;
  final Color color;
  final DateTime? lastUpdate;
  final double? progress;
  const _MonitoringTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isActive,
    required this.color,
    this.lastUpdate,
    this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isActive ? color.withOpacity(0.1) : Colors.grey[100],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          color: isActive ? color : Colors.grey,
          size: 24,
        ),
      ),
      title: Row(
        children: [
          Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: isActive ? Colors.green : Colors.grey,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            subtitle,
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          if (progress != null) ...[
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: color.withOpacity(0.1),
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 4,
              borderRadius: BorderRadius.circular(2),
            ),
          ],
        ],
      ),
      trailing: isActive
          ? Icon(Icons.check_circle, color: Colors.green, size: 24)
          : Icon(Icons.radio_button_unchecked, color: Colors.grey[400], size: 24),
    );
  }
}

class _NetworkStatusSection extends StatelessWidget {
  final AppState appState;
  const _NetworkStatusSection({required this.appState});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final totalRequests = appState.telemetrySentCount + appState.telemetryFailedCount;
    final successRate = totalRequests > 0 
        ? (appState.telemetrySentCount / totalRequests * 100).toStringAsFixed(1)
        : '100';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Network & API Status',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _NetworkStat(
                        label: 'API Endpoint',
                        value: 'Connected',
                        icon: Icons.cloud,
                        color: Colors.blue,
                      ),
                    ),
                    Expanded(
                      child: _NetworkStat(
                        label: 'Success Rate',
                        value: '$successRate%',
                        icon: Icons.check_circle,
                        color: Colors.green,
                      ),
                    ),
                    Expanded(
                      child: _NetworkStat(
                        label: 'Requests',
                        value: '$totalRequests',
                        icon: Icons.sync,
                        color: Colors.purple,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _NetworkStat(
                        label: 'Successful',
                        value: '${appState.telemetrySentCount}',
                        icon: Icons.cloud_done,
                        color: Colors.green,
                      ),
                    ),
                    Expanded(
                      child: _NetworkStat(
                        label: 'Failed',
                        value: '${appState.telemetryFailedCount}',
                        icon: Icons.cloud_off,
                        color: Colors.red,
                      ),
                    ),
                    Expanded(
                      child: _NetworkStat(
                        label: 'Last Response',
                        value: appState.lastIncidentResponse != null
                            ? appState.lastIncidentResponse!.severity
                            : 'None',
                        icon: Icons.assessment,
                        color: appState.lastIncidentResponse != null
                            ? _getSeverityColor(appState.lastIncidentResponse!.severity)
                            : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Color _getSeverityColor(String severity) {
    switch (severity) {
      case 'CRITICAL': return Colors.red;
      case 'HIGH': return Colors.orange;
      case 'MONITOR': return Colors.amber;
      default: return Colors.green;
    }
  }
}

class _NetworkStat extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  const _NetworkStat({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}

class _RecentIncidentsSection extends StatelessWidget {
  final AppState appState;
  const _RecentIncidentsSection({required this.appState});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Incidents',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        if (appState.lastIncidentResponse == null)
          Card(
            color: Colors.grey[50],
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  Icon(Icons.check_circle_outline, size: 48, color: Colors.green[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No Incidents Detected',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'All systems are monitoring normally. No safety incidents have been recorded during this session.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          )
        else
          Card(
            child: Column(
              children: [
                _IncidentTile(response: appState.lastIncidentResponse!),
              ],
            ),
          ),
      ],
    );
  }
}

class _IncidentTile extends StatelessWidget {
  final IncidentResponse response;
  const _IncidentTile({required this.response});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    Color severityColor;
    IconData severityIcon;

    switch (response.severity) {
      case 'CRITICAL':
        severityColor = Colors.red;
        severityIcon = Icons.dangerous;
        break;
      case 'HIGH':
        severityColor = Colors.orange;
        severityIcon = Icons.warning;
        break;
      case 'MONITOR':
        severityColor = Colors.amber;
        severityIcon = Icons.monitor;
        break;
      default:
        severityColor = Colors.green;
        severityIcon = Icons.check_circle;
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: severityColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(severityIcon, color: severityColor, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      response.severity,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: severityColor,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Score: ${response.riskScore}/100',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  response.summary,
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  'ID: ${response.incidentId}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.grey[500],
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DeviceHealthSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Device Health',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Column(
            children: [
              _DeviceHealthTile(
                title: 'Battery Optimization',
                subtitle: 'App may be restricted by battery saver',
                icon: Icons.battery_charging_full,
                status: 'Check Settings',
                color: Colors.amber,
              ),
              const Divider(height: 1, indent: 16, endIndent: 16),
              _DeviceHealthTile(
                title: 'Background Execution',
                subtitle: 'Required for continuous monitoring',
                icon: Icons.play_circle,
                status: 'Enabled',
                color: Colors.green,
              ),
              const Divider(height: 1, indent: 16, endIndent: 16),
              _DeviceHealthTile(
                title: 'Internet Connectivity',
                subtitle: 'Required for telemetry transmission',
                icon: Icons.wifi,
                status: 'Connected',
                color: Colors.blue,
              ),
              const Divider(height: 1, indent: 16, endIndent: 16),
              _DeviceHealthTile(
                title: 'Storage Space',
                subtitle: 'Required for local data caching',
                icon: Icons.storage,
                status: 'Available',
                color: Colors.green,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DeviceHealthTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final String status;
  final Color color;
  const _DeviceHealthTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.status,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color, size: 24),
      ),
      title: Text(
        title,
        style: theme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: theme.textTheme.bodySmall?.copyWith(
          color: Colors.grey[600],
        ),
      ),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          status,
          style: theme.textTheme.labelSmall?.copyWith(
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}