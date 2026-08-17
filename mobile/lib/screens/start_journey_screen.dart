import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../main.dart';
import '../models/telemetry.dart';
import '../utils/constants.dart';

class StartJourneyScreen extends StatefulWidget {
  const StartJourneyScreen({super.key});

  @override
  State<StartJourneyScreen> createState() => _StartJourneyScreenState();
}

class _StartJourneyScreenState extends State<StartJourneyScreen> {
  final _formKey = GlobalKey<FormState>();
  final _destinationController = TextEditingController();
  final _notesController = TextEditingController();
  bool _shareLocation = true;
  bool _enableAudio = true;
  bool _enableMotion = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  @override
  void dispose() {
    _destinationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _loadSettings() {
    final appState = context.read<AppState>();
    _shareLocation = appState.settings.locationSharingEnabled;
    _enableAudio = appState.settings.audioMonitoringEnabled;
    _enableMotion = appState.settings.motionMonitoringEnabled;
  }

  Future<void> _startJourney() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _errorMessage = null);

    final appState = context.read<AppState>();
    
    // Update settings based on user choices
    await appState.updateSettings(appState.settings.copyWith(
      locationSharingEnabled: _shareLocation,
      audioMonitoringEnabled: _enableAudio,
      motionMonitoringEnabled: _enableMotion,
    ));

    final success = await appState.startJourney();
    
    if (success && mounted) {
      Navigator.pushReplacementNamed(context, '/live_journey');
    } else if (mounted) {
      setState(() {
        _errorMessage = appState.journeyError ?? AppConstants.errorJourneyStartFailed;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final appState = context.watch<AppState>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Start Journey'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                _HeaderSection(),
                
                const SizedBox(height: 32),
                
                // Destination Input
                _DestinationInput(
                  controller: _destinationController,
                  notesController: _notesController,
                ),
                
                const SizedBox(height: 24),
                
                // Monitoring Options
                _MonitoringOptions(
                  shareLocation: _shareLocation,
                  enableAudio: _enableAudio,
                  enableMotion: _enableMotion,
                  onShareLocationChanged: (value) => setState(() => _shareLocation = value),
                  onEnableAudioChanged: (value) => setState(() => _enableAudio = value),
                  onEnableMotionChanged: (value) => setState(() => _enableMotion = value),
                ),
                
                const SizedBox(height: 24),
                
                // Guardian Preview
                _GuardianPreviewSection(),
                
                const SizedBox(height: 24),
                
                // Error Message
                if (_errorMessage != null || appState.journeyError != null)
                  _ErrorBanner(message: _errorMessage ?? appState.journeyError!),
                
                const SizedBox(height: 24),
                
                // Start Button
                FilledButton.icon(
                  onPressed: appState.isLoading ? null : _startJourney,
                  icon: appState.isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Icon(Icons.play_circle_outline, size: 28),
                  label: Text(
                    appState.isLoading ? 'Starting...' : 'Start Journey',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(double.infinity, 56),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Info
                Text(
                  'Your guardians will be notified when you start your journey.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.grey[500],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HeaderSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            children: [
              Icon(
                Icons.directions_walk,
                size: 48,
                color: colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                'Start New Journey',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Enable safety monitoring and share your location with trusted contacts',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onPrimaryContainer.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DestinationInput extends StatelessWidget {
  final TextEditingController controller;
  final TextEditingController notesController;
  const _DestinationInput({
    required this.controller,
    required this.notesController,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Journey Details',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Destination (Optional)',
            hintText: 'e.g., Home, Work, Gym',
            prefixIcon: Icon(Icons.location_on_outlined),
          ),
          validator: (value) {
            if (value != null && value.length > 100) {
              return 'Destination too long';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: notesController,
          decoration: const InputDecoration(
            labelText: 'Notes (Optional)',
            hintText: 'Any additional information...',
            prefixIcon: Icon(Icons.note_outlined),
          ),
          maxLines: 3,
          validator: (value) {
            if (value != null && value.length > 500) {
              return 'Notes too long';
            }
            return null;
          },
        ),
      ],
    );
  }
}

class _MonitoringOptions extends StatelessWidget {
  final bool shareLocation;
  final bool enableAudio;
  final bool enableMotion;
  final ValueChanged<bool> onShareLocationChanged;
  final ValueChanged<bool> onEnableAudioChanged;
  final ValueChanged<bool> onEnableMotionChanged;
  const _MonitoringOptions({
    required this.shareLocation,
    required this.enableAudio,
    required this.enableMotion,
    required this.onShareLocationChanged,
    required this.onEnableAudioChanged,
    required this.onEnableMotionChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Monitoring Options',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Column(
            children: [
              _OptionTile(
                title: 'Location Sharing',
                subtitle: 'Share real-time GPS location with guardians',
                icon: Icons.location_on,
                value: shareLocation,
                onChanged: onShareLocationChanged,
                isRequired: true,
              ),
              const Divider(height: 1),
              _OptionTile(
                title: 'Audio Monitoring',
                subtitle: 'Detect ambient sound levels for safety alerts',
                icon: Icons.mic,
                value: enableAudio,
                onChanged: onEnableAudioChanged,
              ),
              const Divider(height: 1),
              _OptionTile(
                title: 'Motion Detection',
                subtitle: 'Monitor unusual movement patterns',
                icon: Icons.directions_run,
                value: enableMotion,
                onChanged: onEnableMotionChanged,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _OptionTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool isRequired;
  const _OptionTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.value,
    required this.onChanged,
    this.isRequired = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SwitchListTile(
      title: Row(
        children: [
          Icon(icon, color: value ? colorScheme.primary : Colors.grey, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
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
      value: value,
      onChanged: isRequired ? null : onChanged,
      activeColor: colorScheme.primary,
      inactiveThumbColor: Colors.grey[400],
      inactiveTrackColor: Colors.grey[300],
    );
  }
}

class _GuardianPreviewSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, _) {
        final guardians = appState.settings.activeGuardians;
        
        if (guardians.isEmpty) {
          return Card(
            color: Colors.amber[50],
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Icon(Icons.warning_amber_outlined, color: Colors.amber[700]),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'No Guardian Contacts',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: Colors.amber[800],
                          ),
                        ),
                        Text(
                          'Add guardians in Settings to enable emergency notifications',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.amber[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pushNamed(context, '/settings'),
                    child: const Text('Add Now'),
                  ),
                ],
              ),
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Guardians Notified (${guardians.length})',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 70,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: guardians.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final guardian = guardians[index];
                  return _GuardianChip(guardian: guardian);
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

class _GuardianChip extends StatelessWidget {
  final GuardianContact guardian;
  const _GuardianChip({required this.guardian});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isPrimary = guardian.isPrimary;

    return Container(
      width: 120,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isPrimary ? theme.colorScheme.primaryContainer : Colors.grey[100],
        border: isPrimary 
            ? Border.all(color: theme.colorScheme.primary, width: 2)
            : Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: isPrimary 
                ? theme.colorScheme.primary 
                : Colors.grey[300],
            child: Text(
              guardian.name.isNotEmpty ? guardian.name[0].toUpperCase() : '?',
              style: TextStyle(
                color: isPrimary ? Colors.white : Colors.grey[600],
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            guardian.name,
            style: theme.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          if (isPrimary)
            Text(
              'PRIMARY',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
                fontSize: 10,
              ),
            ),
        ],
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String message;
  const _ErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red[200]!),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red[700], size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.red[700],
              ),
            ),
          ),
        ],
      ),
    );
  }
}