import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../main.dart';
import '../models/telemetry.dart';
import '../utils/constants.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, _) {
        return Scaffold(
          appBar: AppBar(
            title: Text(AppConstants.appName),
            actions: [
              IconButton(
                icon: const Icon(Icons.settings_outlined),
                onPressed: () => Navigator.pushNamed(context, '/settings'),
                tooltip: 'Settings',
              ),
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () => _showLogoutDialog(context, appState),
                tooltip: 'Logout',
              ),
            ],
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Welcome Section
                  _WelcomeSection(userName: appState.userName ?? 'User'),
                  
                  const SizedBox(height: 32),
                  
                  // Journey Status Card
                  _JourneyStatusCard(appState: appState),
                  
                  const SizedBox(height: 24),
                  
                  // Primary Action Button
                  _PrimaryActionButton(appState: appState),
                  
                  const SizedBox(height: 24),
                  
                  // Quick Stats (if journey active)
                  if (appState.isJourneyActive) ...[
                    _QuickStatsSection(appState: appState),
                    const SizedBox(height: 24),
                  ],
                  
                  // Guardian Contacts Preview
                  if (appState.settings.activeGuardians.isNotEmpty) ...[
                    _GuardianPreviewSection(appState: appState),
                    const SizedBox(height: 24),
                  ],
                  
                  // Safety Features Info
                  _SafetyFeaturesSection(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showLogoutDialog(BuildContext context, AppState appState) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              appState.logout();
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}

class _WelcomeSection extends StatelessWidget {
  final String userName;
  const _WelcomeSection({required this.userName});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hour = DateTime.now().hour;
    final greeting = hour < 12 
        ? 'Good morning' 
        : hour < 17 
            ? 'Good afternoon' 
            : 'Good evening';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$greeting,',
          style: theme.textTheme.titleMedium?.copyWith(
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          userName,
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Stay safe. Stay connected.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: Colors.grey[500],
          ),
        ),
      ],
    );
  }
}

class _JourneyStatusCard extends StatelessWidget {
  final AppState appState;
  const _JourneyStatusCard({required this.appState});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (appState.isJourneyActive) {
      return _ActiveJourneyCard(appState: appState);
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Icon(
              Icons.directions_walk_outlined,
              size: 64,
              color: colorScheme.primary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No Active Journey',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Start a journey to enable safety monitoring and location sharing with your guardians.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            if (appState.journeyError != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: Colors.red[700], size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        appState.journeyError!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.red[700],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ActiveJourneyCard extends StatelessWidget {
  final AppState appState;
  const _ActiveJourneyCard({required this.appState});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final duration = appState.activeJourney?.duration ?? Duration.zero;

    return Card(
      color: colorScheme.primaryContainer.withOpacity(0.3),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colorScheme.primary,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.shield_outlined,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Journey Active',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onPrimaryContainer,
                        ),
                      ),
                      Text(
                        'Monitoring your safety',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onPrimaryContainer.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                _StatusIndicator(
                  isActive: true,
                  label: 'LIVE',
                  color: colorScheme.primary,
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _StatItem(
                    label: 'Duration',
                    value: _formatDuration(duration),
                    icon: Icons.timer_outlined,
                  ),
                ),
                Expanded(
                  child: _StatItem(
                    label: 'Telemetry Sent',
                    value: '${appState.telemetrySentCount}',
                    icon: Icons.cloud_upload_outlined,
                  ),
                ),
                Expanded(
                  child: _StatItem(
                    label: 'Last Update',
                    value: appState.lastLocation != null 
                        ? _formatTimeAgo(appState.lastLocation!.timestamp)
                        : 'Waiting...',
                    icon: Icons.location_on_outlined,
                  ),
                ),
              ],
            ),
            if (appState.lastIncidentResponse != null) ...[
              const SizedBox(height: 16),
              _IncidentStatusBanner(response: appState.lastIncidentResponse!),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration d) {
    final hours = d.inHours;
    final minutes = d.inMinutes.remainder(60);
    final seconds = d.inSeconds.remainder(60);
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m ${seconds}s';
  }

  String _formatTimeAgo(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inSeconds < 60) return '${diff.inSeconds}s ago';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    return '${diff.inHours}h ago';
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  const _StatItem({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Icon(icon, size: 24, color: Colors.grey[600]),
        const SizedBox(height: 8),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
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

class _IncidentStatusBanner extends StatelessWidget {
  final IncidentResponse response;
  const _IncidentStatusBanner({required this.response});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    Color bgColor;
    Color textColor;
    IconData icon;

    switch (response.severity) {
      case 'CRITICAL':
        bgColor = Colors.red[100]!;
        textColor = Colors.red[800]!;
        icon = Icons.warning_amber_rounded;
        break;
      case 'HIGH':
        bgColor = Colors.orange[100]!;
        textColor = Colors.orange[800]!;
        icon = Icons.warning_outlined;
        break;
      case 'MONITOR':
        bgColor = Colors.yellow[100]!;
        textColor = Colors.yellow[800]!;
        icon = Icons.monitor_outlined;
        break;
      default:
        bgColor = Colors.green[100]!;
        textColor = Colors.green[800]!;
        icon = Icons.check_circle_outline;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: textColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: textColor, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Risk Level: ${response.severity}',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                Text(
                  'Risk Score: ${response.riskScore}/100',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: textColor.withOpacity(0.8),
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

class _PrimaryActionButton extends StatelessWidget {
  final AppState appState;
  const _PrimaryActionButton({required this.appState});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (appState.isJourneyActive) {
      return FilledButton.tonal(
        onPressed: appState.isLoading ? null : () => _showStopJourneyDialog(context, appState),
        style: FilledButton.styleFrom(
          backgroundColor: Colors.red[50],
          foregroundColor: Colors.red[700],
          side: BorderSide(color: Colors.red[200]!),
          minimumSize: const Size(double.infinity, 56),
        ),
        child: appState.isLoading
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.stop_circle_outlined, size: 24),
                  const SizedBox(width: 12),
                  Text(
                    'Stop Journey',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
      );
    }

    return FilledButton.icon(
      onPressed: appState.isLoading ? null : () => Navigator.pushNamed(context, '/start_journey'),
      icon: const Icon(Icons.play_circle_outline, size: 28),
      label: Text(
        'Start Journey',
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  void _showStopJourneyDialog(BuildContext context, AppState appState) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Stop Journey?'),
        content: const Text('This will stop all safety monitoring and location sharing. Are you sure?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              appState.stopJourney();
            },
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Stop Journey'),
          ),
        ],
      ),
    );
  }
}

class _QuickStatsSection extends StatelessWidget {
  final AppState appState;
  const _QuickStatsSection({required this.appState});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Live Telemetry',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _TelemetryCard(
                title: 'Location',
                value: appState.lastLocation != null
                    ? '${appState.lastLocation!.latitude.toStringAsFixed(4)}, ${appState.lastLocation!.longitude.toStringAsFixed(4)}'
                    : 'Acquiring...',
                icon: Icons.location_on,
                color: Colors.blue,
                accuracy: appState.lastLocation?.accuracy,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _TelemetryCard(
                title: 'Audio Level',
                value: appState.lastAudioData != null
                    ? '${appState.lastAudioData!.decibelLevel.toStringAsFixed(1)} dB'
                    : 'Measuring...',
                icon: Icons.mic,
                color: Colors.purple,
                score: appState.lastAudioData?.normalizedScore,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _TelemetryCard(
                title: 'Motion',
                value: appState.lastMotionData != null
                    ? '${(appState.lastMotionData!.normalizedScore * 100).toStringAsFixed(0)}%'
                    : 'Measuring...',
                icon: Icons.directions_run,
                color: Colors.orange,
                score: appState.lastMotionData?.normalizedScore,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _TelemetryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final double? accuracy;
  final double? score;
  const _TelemetryCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.accuracy,
    this.score,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            if (accuracy != null) ...[
              const SizedBox(height: 4),
              Text(
                'Accuracy: ±${accuracy!.toStringAsFixed(0)}m',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.grey[500],
                ),
              ),
            ],
            if (score != null) ...[
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: score,
                backgroundColor: color.withOpacity(0.1),
                valueColor: AlwaysStoppedAnimation<Color>(color),
                minHeight: 4,
                borderRadius: BorderRadius.circular(2),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _GuardianPreviewSection extends StatelessWidget {
  final AppState appState;
  const _GuardianPreviewSection({required this.appState});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final guardians = appState.settings.activeGuardians;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Guardian Contacts',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pushNamed(context, '/settings'),
              child: const Text('Manage'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 80,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: guardians.length + 1,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              if (index == guardians.length) {
                return _AddGuardianCard();
              }
              final guardian = guardians[index];
              return _GuardianCard(guardian: guardian, isPrimary: guardian.isPrimary);
            },
          ),
        ),
      ],
    );
  }
}

class _GuardianCard extends StatelessWidget {
  final GuardianContact guardian;
  final bool isPrimary;
  const _GuardianCard({required this.guardian, required this.isPrimary});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: 140,
      decoration: BoxDecoration(
        color: isPrimary ? Theme.of(context).colorScheme.primaryContainer : null,
        border: isPrimary 
            ? Border.all(color: Theme.of(context).colorScheme.primary, width: 2)
            : null,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: isPrimary 
                ? Theme.of(context).colorScheme.primary 
                : Colors.grey[300],
            child: Text(
              guardian.name.isNotEmpty ? guardian.name[0].toUpperCase() : '?',
              style: TextStyle(
                color: isPrimary ? Colors.white : Colors.grey[600],
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            guardian.name,
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          if (isPrimary) ...[
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'PRIMARY',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _AddGuardianCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!, width: 2, strokeAlign: BorderSide.strokeAlignInside),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => Navigator.pushNamed(context, '/settings'),
          child: const Padding(
            padding: EdgeInsets.all(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add_circle_outline, size: 40, color: Colors.grey),
                SizedBox(height: 8),
                Text('Add Guardian', style: TextStyle(color: Colors.grey)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SafetyFeaturesSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final features = [
      ('Real-time Location', 'GPS tracking during journeys', Icons.gps_fixed),
      ('Audio Monitoring', 'Ambient sound level detection', Icons.mic),
      ('Motion Detection', 'Unusual movement alerts', Icons.directions_run),
      ('Guardian Alerts', 'Automatic emergency notifications', Icons.contacts),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Safety Features',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        ...features.map((feature) => _FeatureTile(
          title: feature.$1,
          subtitle: feature.$2,
          icon: feature.$3,
        )),
      ],
    );
  }
}

class _FeatureTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  const _FeatureTile({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: theme.colorScheme.primary, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
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

class _StatusIndicator extends StatelessWidget {
  final bool isActive;
  final String label;
  final Color color;
  const _StatusIndicator({
    required this.isActive,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isActive ? color : Colors.grey,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isActive)
            Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.only(right: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}