import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../main.dart';
import '../models/telemetry.dart';
import '../utils/constants.dart';

class LiveJourneyScreen extends StatefulWidget {
  const LiveJourneyScreen({super.key});

  @override
  State<LiveJourneyScreen> createState() => _LiveJourneyScreenState();
}

class _LiveJourneyScreenState extends State<LiveJourneyScreen> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, _) {
        if (!appState.isJourneyActive) {
          return const _JourneyEndedView();
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Live Journey'),
            automaticallyImplyLeading: false,
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () => _sendManualTelemetry(appState),
                tooltip: 'Send Update Now',
              ),
              IconButton(
                icon: const Icon(Icons.stop_circle_outlined),
                onPressed: () => _showStopDialog(context, appState),
                tooltip: 'Stop Journey',
              ),
            ],
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Status Header
                  _StatusHeader(appState: appState, pulseAnimation: _pulseAnimation),
                  
                  const SizedBox(height: 24),
                  
                  // Duration & Journey Info
                  _JourneyInfoCard(appState: appState),
                  
                  const SizedBox(height: 24),
                  
                  // Live Telemetry Grid
                  _LiveTelemetryGrid(appState: appState),
                  
                  const SizedBox(height: 24),
                  
                  // Risk Assessment
                  if (appState.lastIncidentResponse != null)
                    _RiskAssessmentCard(response: appState.lastIncidentResponse!),
                  
                  const SizedBox(height: 24),
                  
                  // Guardian Status
                  _GuardianStatusSection(appState: appState),
                  
                  const SizedBox(height: 24),
                  
                  // Emergency Actions
                  _EmergencyActionsSection(appState: appState),
                  
                  const SizedBox(height: 24),
                  
                  // Stop Journey Button
                  _StopJourneyButton(appState: appState),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showStopDialog(BuildContext context, AppState appState) {
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
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Stop Journey'),
          ),
        ],
      ),
    );
  }

  Future<void> _sendManualTelemetry(AppState appState) async {
    // Trigger immediate telemetry send
    await appState.sendTelemetryNow();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Telemetry sent manually')),
      );
    }
  }
}

class _JourneyEndedView extends StatelessWidget {
  const _JourneyEndedView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Journey Ended')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check_circle_outline, size: 80, color: Colors.green[600]),
              const SizedBox(height: 24),
              Text(
                'Journey Completed',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Your journey has ended. Safety monitoring is now stopped.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              FilledButton(
                onPressed: () => Navigator.pushNamedAndRemoveUntil(
                  context, '/home', (route) => false),
                child: const Text('Back to Home'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusHeader extends StatelessWidget {
  final AppState appState;
  final Animation<double> pulseAnimation;
  const _StatusHeader({
    required this.appState,
    required this.pulseAnimation,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AnimatedBuilder(
      animation: pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: pulseAnimation.value,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: colorScheme.primary.withOpacity(0.2),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'LIVE MONITORING',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'Journey Active',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Your safety is being monitored',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onPrimaryContainer.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _JourneyInfoCard extends StatelessWidget {
  final AppState appState;
  const _JourneyInfoCard({required this.appState});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final journey = appState.activeJourney;
    final duration = journey?.duration ?? Duration.zero;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Journey Information',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _InfoItem(
                    label: 'Duration',
                    value: _formatDuration(duration),
                    icon: Icons.timer,
                  ),
                ),
                Expanded(
                  child: _InfoItem(
                    label: 'Started',
                    value: _formatStartTime(journey?.startTime),
                    icon: Icons.play_circle,
                  ),
                ),
                Expanded(
                  child: _InfoItem(
                    label: 'Telemetry',
                    value: '${appState.telemetrySentCount} sent',
                    icon: Icons.cloud_upload,
                  ),
                ),
              ],
            ),
            if (appState.telemetryFailedCount > 0) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning_amber_outlined, color: Colors.orange[700], size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        '${appState.telemetryFailedCount} telemetry transmissions failed',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.orange[700],
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

  String _formatDuration(Duration d) {
    final hours = d.inHours;
    final minutes = d.inMinutes.remainder(60);
    final seconds = d.inSeconds.remainder(60);
    if (hours > 0) return '${hours}h ${minutes}m ${seconds}s';
    if (minutes > 0) return '${minutes}m ${seconds}s';
    return '${seconds}s';
  }

  String _formatStartTime(DateTime? time) {
    if (time == null) return 'Unknown';
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}

class _InfoItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  const _InfoItem({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Icon(icon, color: theme.colorScheme.primary, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _LiveTelemetryGrid extends StatelessWidget {
  final AppState appState;
  const _LiveTelemetryGrid({required this.appState});

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
                title: 'GPS Location',
                value: appState.lastLocation != null
                    ? '${appState.lastLocation!.latitude.toStringAsFixed(6)}, ${appState.lastLocation!.longitude.toStringAsFixed(6)}'
                    : 'Acquiring...',
                subtitle: appState.lastLocation != null
                    ? 'Accuracy: ±${appState.lastLocation!.accuracy.toStringAsFixed(0)}m'
                    : 'Waiting for GPS fix',
                icon: Icons.gps_fixed,
                color: Colors.blue,
                isActive: appState.lastLocation != null,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _TelemetryCard(
                title: 'Audio Level',
                value: appState.lastAudioData != null
                    ? '${appState.lastAudioData!.decibelLevel.toStringAsFixed(1)} dB'
                    : 'Measuring...',
                subtitle: appState.lastAudioData != null
                    ? 'Level: ${(appState.lastAudioData!.normalizedScore * 100).toStringAsFixed(0)}%'
                    : 'Initializing microphone',
                icon: Icons.mic,
                color: Colors.purple,
                isActive: appState.lastAudioData != null,
                progress: appState.lastAudioData?.normalizedScore ?? 0,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _TelemetryCard(
                title: 'Motion',
                value: appState.lastMotionData != null
                    ? '${appState.lastMotionData!.magnitude.toStringAsFixed(2)} m/s²'
                    : 'Measuring...',
                subtitle: appState.lastMotionData != null
                    ? 'Activity: ${(appState.lastMotionData!.normalizedScore * 100).toStringAsFixed(0)}%'
                    : 'Initializing sensors',
                icon: Icons.directions_run,
                color: Colors.orange,
                isActive: appState.lastMotionData != null,
                progress: appState.lastMotionData?.normalizedScore ?? 0,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _TelemetryCard(
                title: 'Network',
                value: appState.telemetrySentCount > 0 ? 'Connected' : 'Connecting...',
                subtitle: '${appState.telemetrySentCount} successful, ${appState.telemetryFailedCount} failed',
                icon: Icons.wifi,
                color: Colors.green,
                isActive: appState.telemetrySentCount > 0,
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
  final String subtitle;
  final IconData icon;
  final Color color;
  final bool isActive;
  final double? progress;
  const _TelemetryCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.isActive,
    this.progress,
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
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isActive ? color.withOpacity(0.1) : Colors.grey[100],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
                    color: isActive ? color : Colors.grey,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: isActive ? Colors.green : Colors.grey,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            isActive ? 'Active' : 'Inactive',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: isActive ? Colors.green : Colors.grey,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              value,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            if (progress != null) ...[
              const SizedBox(height: 12),
              LinearProgressIndicator(
                value: progress,
                backgroundColor: color.withOpacity(0.1),
                valueColor: AlwaysStoppedAnimation<Color>(color),
                minHeight: 6,
                borderRadius: BorderRadius.circular(3),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _RiskAssessmentCard extends StatelessWidget {
  final IncidentResponse response;
  const _RiskAssessmentCard({required this.response});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    Color severityColor;
    IconData severityIcon;
    String severityLabel;

    switch (response.severity) {
      case 'CRITICAL':
        severityColor = Colors.red;
        severityIcon = Icons.dangerous;
        severityLabel = 'CRITICAL RISK';
        break;
      case 'HIGH':
        severityColor = Colors.orange;
        severityIcon = Icons.warning;
        severityLabel = 'HIGH RISK';
        break;
      case 'MONITOR':
        severityColor = Colors.amber;
        severityIcon = Icons.monitor;
        severityLabel = 'MONITORING';
        break;
      default:
        severityColor = Colors.green;
        severityIcon = Icons.check_circle;
        severityLabel = 'SAFE';
    }

    return Card(
      color: severityColor.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        side: BorderSide(color: severityColor.withOpacity(0.3), width: 2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(severityIcon, color: severityColor, size: 28),
                const SizedBox(width: 12),
                Text(
                  'Risk Assessment',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: severityColor,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: severityColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    severityLabel,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              response.summary,
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _RiskMetric(
                    label: 'Risk Score',
                    value: '${response.riskScore}/100',
                    icon: Icons.analytics,
                    color: severityColor,
                  ),
                ),
                Expanded(
                  child: _RiskMetric(
                    label: 'Incident ID',
                    value: response.incidentId,
                    icon: Icons.fingerprint,
                    color: Colors.grey[600]!,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: response.riskScore / 100,
              backgroundColor: severityColor.withOpacity(0.1),
              valueColor: AlwaysStoppedAnimation<Color>(severityColor),
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),
          ],
        ),
      ),
    );
  }
}

class _RiskMetric extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  const _RiskMetric({
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
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
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

class _GuardianStatusSection extends StatelessWidget {
  final AppState appState;
  const _GuardianStatusSection({required this.appState});

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
              'Guardian Status',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            if (guardians.isNotEmpty)
              _SyncStatusBadge(lastSync: appState.lastLocation?.timestamp),
          ],
        ),
        const SizedBox(height: 16),
        if (guardians.isEmpty)
          Card(
            color: Colors.grey[50],
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: [
                  Icon(Icons.people_outline, color: Colors.grey[400], size: 32),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      'No guardians configured. Add them in Settings to enable notifications.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          Column(
            children: guardians.map((guardian) => _GuardianStatusTile(guardian: guardian)).toList(),
          ),
      ],
    );
  }
}

class _GuardianStatusTile extends StatelessWidget {
  final GuardianContact guardian;
  const _GuardianStatusTile({required this.guardian});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isPrimary = guardian.isPrimary;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isPrimary 
              ? theme.colorScheme.primary 
              : Colors.grey[300],
          child: Text(
            guardian.name.isNotEmpty ? guardian.name[0].toUpperCase() : '?',
            style: TextStyle(
              color: isPrimary ? Colors.white : Colors.grey[600],
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Row(
          children: [
            Text(
              guardian.name,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            if (isPrimary) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(4),
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
        subtitle: Text(
          guardian.formattedPhone,
          style: theme.textTheme.bodySmall?.copyWith(
            color: Colors.grey[600],
          ),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle,
              color: Colors.green[600],
              size: 20,
            ),
            Text(
              'Notified',
              style: theme.textTheme.labelSmall?.copyWith(
                color: Colors.green[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SyncStatusBadge extends StatelessWidget {
  final DateTime? lastSync;
  const _SyncStatusBadge({this.lastSync});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isRecent = lastSync != null && DateTime.now().difference(lastSync!).inMinutes < 5;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isRecent ? Colors.green[50] : Colors.orange[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isRecent ? Colors.green[200]! : Colors.orange[200]!,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: isRecent ? Colors.green : Colors.orange,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            isRecent ? 'Synced' : 'Pending',
            style: theme.textTheme.labelSmall?.copyWith(
              color: isRecent ? Colors.green[700] : Colors.orange[700],
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmergencyActionsSection extends StatelessWidget {
  final AppState appState;
  const _EmergencyActionsSection({required this.appState});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Emergency Actions',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _EmergencyActionButton(
                title: 'Call Primary Guardian',
                subtitle: appState.settings.primaryGuardian?.name ?? 'No primary guardian',
                icon: Icons.call,
                color: Colors.green,
                onTap: () => _callGuardian(context, appState.settings.primaryGuardian),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _EmergencyActionButton(
                title: 'Send SOS Alert',
                subtitle: 'Notify all guardians immediately',
                icon: Icons.sos,
                color: Colors.red,
                onTap: () => _sendSOSAlert(context, appState),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _callGuardian(BuildContext context, GuardianContact? guardian) {
    if (guardian == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No primary guardian set')),
      );
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Calling ${guardian.name}... (Demo)')),
    );
  }

  void _sendSOSAlert(BuildContext context, AppState appState) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.sos, color: Colors.red[700]),
            const SizedBox(width: 12),
            const Text('Send SOS Alert'),
          ],
        ),
        content: const Text(
          'This will send an emergency alert to all your guardians with your current location. Are you sure?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('SOS Alert sent to all guardians! (Demo)'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Send SOS'),
          ),
        ],
      ),
    );
  }
}

class _EmergencyActionButton extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _EmergencyActionButton({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StopJourneyButton extends StatelessWidget {
  final AppState appState;
  const _StopJourneyButton({required this.appState});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: appState.isLoading ? null : () {
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
                style: FilledButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('Stop Journey'),
              ),
            ],
          ),
        );
      },
      icon: const Icon(Icons.stop_circle_outlined, size: 24),
      label: const Text('Stop Journey'),
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.red,
        side: BorderSide(color: Colors.red[300]!),
        minimumSize: const Size(double.infinity, 56),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    );
  }
}