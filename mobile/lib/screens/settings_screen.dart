import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart';
import '../models/telemetry.dart';
import '../services/api.dart';
import '../utils/constants.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late AppSettings _settings;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _settings = context.read<AppState>().settings;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, _) {
        _settings = appState.settings;
        return Scaffold(
          appBar: AppBar(
            title: const Text('Settings'),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: SafeArea(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Guardian Contacts
                        _GuardianContactsSection(
                          guardians: _settings.guardianContacts,
                          onAdd: _showAddGuardianDialog,
                          onRemove: _removeGuardian,
                          onSetPrimary: _setPrimaryGuardian,
                        ),
                        
                        const SizedBox(height: 32),
                        
                        // Monitoring Settings
                        _MonitoringSettingsSection(
                          settings: _settings,
                          onChanged: _updateSettings,
                        ),
                        
                        const SizedBox(height: 32),
                        
                        // Alert Settings
                        _AlertSettingsSection(
                          settings: _settings,
                          onChanged: _updateSettings,
                        ),
                        
                        const SizedBox(height: 32),
                        
                        // API Configuration
                        _ApiConfigSection(
                          apiService: appState.apiService,
                          onChanged: _updateApiUrl,
                        ),
                        
                        const SizedBox(height: 32),
                        
                        // App Info
                        _AppInfoSection(),
                        
                        const SizedBox(height: 32),
                        
                        // Danger Zone
                        _DangerZoneSection(appState: appState),
                      ],
                    ),
                  ),
          ),
        );
      },
    );
  }

  Future<void> _updateSettings(AppSettings newSettings) async {
    setState(() => _isLoading = true);
    await context.read<AppState>().updateSettings(newSettings);
    setState(() {
      _settings = newSettings;
      _isLoading = false;
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppConstants.successSettingsSaved)),
      );
    }
  }

  Future<void> _updateApiUrl(String url) async {
    await context.read<AppState>().apiService.setBaseUrl(url);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('API URL updated')),
      );
    }
  }

  void _showAddGuardianDialog() {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final relationshipController = TextEditingController();
    bool isPrimary = _settings.guardianContacts.isEmpty;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Add Guardian Contact'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Name *',
                    hintText: 'e.g., Mom, Dad, Friend',
                    prefixIcon: Icon(Icons.person),
                  ),
                  validator: (v) => v?.trim().isEmpty == true ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Phone Number *',
                    hintText: '+91 98765 43210',
                    prefixIcon: Icon(Icons.phone),
                  ),
                  keyboardType: TextInputType.phone,
                  validator: (v) {
                    if (v?.trim().isEmpty == true) return 'Required';
                    final cleaned = v!.replaceAll(RegExp(r'[^\d+]'), '');
                    if (cleaned.length < 10) return 'Invalid phone number';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: relationshipController,
                  decoration: const InputDecoration(
                    labelText: 'Relationship (Optional)',
                    hintText: 'e.g., Mother, Father, Friend',
                    prefixIcon: Icon(Icons.family_restroom),
                  ),
                ),
                const SizedBox(height: 16),
                if (_settings.guardianContacts.isEmpty)
                  const Text(
                    'This will be set as primary guardian',
                    style: TextStyle(color: Colors.blue, fontSize: 12),
                  )
                else
                  CheckboxListTile(
                    title: const Text('Set as primary guardian'),
                    value: isPrimary,
                    onChanged: (v) => setDialogState(() => isPrimary = v ?? false),
                    contentPadding: EdgeInsets.zero,
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                if (nameController.text.trim().isEmpty || phoneController.text.trim().isEmpty) return;
                
                final contact = GuardianContact(
                  name: nameController.text.trim(),
                  phoneNumber: phoneController.text.trim(),
                  relationship: relationshipController.text.trim().isEmpty 
                      ? null 
                      : relationshipController.text.trim(),
                  isPrimary: isPrimary,
                );
                
                Navigator.pop(context);
                await _addGuardian(contact);
              },
              child: const Text('Add Guardian'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _addGuardian(GuardianContact contact) async {
    final newContacts = List<GuardianContact>.from(_settings.guardianContacts);
    
    // If setting as primary, unset others
    if (contact.isPrimary) {
      for (int i = 0; i < newContacts.length; i++) {
        newContacts[i] = newContacts[i].copyWith(isPrimary: false);
      }
    }
    
    newContacts.add(contact);
    await _updateSettings(_settings.copyWith(guardianContacts: newContacts));
  }

  Future<void> _removeGuardian(String contactId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Guardian?'),
        content: const Text('This guardian will no longer receive emergency alerts.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final newContacts = _settings.guardianContacts
          .where((c) => c.id != contactId)
          .toList();
      await _updateSettings(_settings.copyWith(guardianContacts: newContacts));
    }
  }

  Future<void> _setPrimaryGuardian(String contactId) async {
    final newContacts = _settings.guardianContacts.map((c) {
      return c.copyWith(isPrimary: c.id == contactId);
    }).toList();
    await _updateSettings(_settings.copyWith(guardianContacts: newContacts));
  }
}

class _GuardianContactsSection extends StatelessWidget {
  final List<GuardianContact> guardians;
  final VoidCallback onAdd;
  final Function(String) onRemove;
  final Function(String) onSetPrimary;
  const _GuardianContactsSection({
    required this.guardians,
    required this.onAdd,
    required this.onRemove,
    required this.onSetPrimary,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Guardian Contacts',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            FilledButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add, size: 20),
              label: const Text('Add'),
              style: FilledButton.styleFrom(
                minimumSize: const Size(100, 40),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Guardians receive emergency alerts and location updates',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 16),
        if (guardians.isEmpty)
          Card(
            color: Colors.blue[50],
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  Icon(Icons.people_outline, size: 48, color: Colors.blue[600]),
                  const SizedBox(height: 16),
                  Text(
                    'No Guardians Added',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.blue[800],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add at least one guardian to enable emergency notifications',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.blue[700],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: onAdd,
                    icon: const Icon(Icons.person_add),
                    label: const Text('Add First Guardian'),
                  ),
                ],
              ),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: guardians.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final guardian = guardians[index];
              return _GuardianContactTile(
                guardian: guardian,
                onRemove: () => onRemove(guardian.id),
                onSetPrimary: () => onSetPrimary(guardian.id),
              );
            },
          ),
      ],
    );
  }
}

class _GuardianContactTile extends StatelessWidget {
  final GuardianContact guardian;
  final VoidCallback onRemove;
  final VoidCallback onSetPrimary;
  const _GuardianContactTile({
    required this.guardian,
    required this.onRemove,
    required this.onSetPrimary,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isPrimary = guardian.isPrimary;

    return Card(
      color: isPrimary ? theme.colorScheme.primaryContainer : null,
      shape: RoundedRectangleBorder(
        side: isPrimary 
            ? BorderSide(color: theme.colorScheme.primary, width: 2)
            : BorderSide.none,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: isPrimary 
                  ? theme.colorScheme.primary 
                  : Colors.grey[300],
              child: Text(
                guardian.name.isNotEmpty ? guardian.name[0].toUpperCase() : '?',
                style: TextStyle(
                  color: isPrimary ? Colors.white : Colors.grey[600],
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        guardian.name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (isPrimary) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary,
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
                  if (guardian.relationship != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      guardian.relationship!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                  const SizedBox(height: 4),
                  Text(
                    guardian.formattedPhone,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ),
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'primary') onSetPrimary();
                if (value == 'remove') onRemove();
              },
              itemBuilder: (context) => [
                if (!isPrimary)
                  const PopupMenuItem(
                    value: 'primary',
                    child: Row(
                      children: [
                        Icon(Icons.star, size: 20),
                        SizedBox(width: 8),
                        Text('Set as Primary'),
                      ],
                    ),
                  ),
                const PopupMenuItem(
                  value: 'remove',
                  child: Row(
                    children: [
                      Icon(Icons.delete_outline, size: 20, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Remove', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MonitoringSettingsSection extends StatelessWidget {
  final AppSettings settings;
  final Function(AppSettings) onChanged;
  const _MonitoringSettingsSection({
    required this.settings,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Monitoring Settings',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Column(
            children: [
              _SettingSwitchTile(
                title: 'Location Sharing',
                subtitle: 'Share real-time GPS location with guardians during journeys',
                icon: Icons.location_on,
                value: settings.locationSharingEnabled,
                onChanged: (v) => onChanged(settings.copyWith(locationSharingEnabled: v)),
                isRequired: true,
              ),
              const Divider(height: 1, indent: 16, endIndent: 16),
              _SettingSwitchTile(
                title: 'Audio Monitoring',
                subtitle: 'Monitor ambient sound levels for safety alerts',
                icon: Icons.mic,
                value: settings.audioMonitoringEnabled,
                onChanged: (v) => onChanged(settings.copyWith(audioMonitoringEnabled: v)),
              ),
              const Divider(height: 1, indent: 16, endIndent: 16),
              _SettingSwitchTile(
                title: 'Motion Detection',
                subtitle: 'Detect unusual movement patterns during journeys',
                icon: Icons.directions_run,
                value: settings.motionMonitoringEnabled,
                onChanged: (v) => onChanged(settings.copyWith(motionMonitoringEnabled: v)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AlertSettingsSection extends StatelessWidget {
  final AppSettings settings;
  final Function(AppSettings) onChanged;
  const _AlertSettingsSection({
    required this.settings,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Alert Settings',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Column(
            children: [
              _SettingSwitchTile(
                title: 'Auto-Call Primary Guardian',
                subtitle: 'Automatically call primary guardian on critical alerts',
                icon: Icons.call,
                value: settings.autoCallGuardian,
                onChanged: (v) => onChanged(settings.copyWith(autoCallGuardian: v)),
              ),
              const Divider(height: 1, indent: 16, endIndent: 16),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.tune, color: theme.colorScheme.primary),
                ),
                title: const Text('Alert Sensitivity'),
                subtitle: Text(
                  'Adjust how sensitive the system is to potential threats',
                  style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                ),
                trailing: DropdownButton<String>(
                  value: settings.alertSensitivity,
                  items: AppConstants.alertSensitivityLevels.map((level) {
                    return DropdownMenuItem(
                      value: level,
                      child: Text(level.toUpperCase()),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      onChanged(settings.copyWith(alertSensitivity: value));
                    }
                  },
                  underline: const SizedBox(),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SettingSwitchTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool isRequired;
  const _SettingSwitchTile({
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
      secondary: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: value ? colorScheme.primary.withOpacity(0.1) : Colors.grey[100],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          color: value ? colorScheme.primary : Colors.grey,
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
      value: value,
      onChanged: isRequired ? null : onChanged,
      activeColor: colorScheme.primary,
      inactiveThumbColor: Colors.grey[400],
      inactiveTrackColor: Colors.grey[300],
    );
  }
}

class _ApiConfigSection extends StatelessWidget {
  final ApiService apiService;
  final Function(String) onChanged;
  const _ApiConfigSection({
    required this.apiService,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final controller = TextEditingController(text: apiService.baseUrl);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'API Configuration',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: controller,
                  decoration: const InputDecoration(
                    labelText: 'API Base URL',
                    hintText: 'http://10.0.2.2:8000',
                    prefixIcon: Icon(Icons.link),
                  ),
                  onFieldSubmitted: onChanged,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          final isHealthy = await apiService.healthCheck();
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  isHealthy ? 'API is reachable' : 'API is unreachable',
                                ),
                                backgroundColor: isHealthy ? Colors.green : Colors.red,
                              ),
                            );
                          }
                        },
                        icon: const Icon(Icons.health_and_safety),
                        label: const Text('Test Connection'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () => onChanged(controller.text),
                        icon: const Icon(Icons.save),
                        label: const Text('Save'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Use 10.0.2.2 for Android emulator localhost access',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _AppInfoSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'App Information',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Column(
            children: [
              _InfoTile(
                title: 'App Version',
                value: '1.0.0+1',
                icon: Icons.info,
              ),
              const Divider(height: 1, indent: 16, endIndent: 16),
              _InfoTile(
                title: 'Flutter Version',
                value: '3.13+',
                icon: Icons.flutter_dash,
              ),
              const Divider(height: 1, indent: 16, endIndent: 16),
              _InfoTile(
                title: 'Build Type',
                value: 'Debug',
                icon: Icons.build,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _InfoTile extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  const _InfoTile({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: theme.colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: theme.colorScheme.primary, size: 24),
      ),
      title: Text(
        title,
        style: theme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      trailing: Text(
        value,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: Colors.grey[600],
          fontFamily: 'monospace',
        ),
      ),
    );
  }
}

class _DangerZoneSection extends StatelessWidget {
  final AppState appState;
  const _DangerZoneSection({required this.appState});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Danger Zone',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.red[700],
          ),
        ),
        const SizedBox(height: 16),
        Card(
          color: Colors.red[50],
          child: Column(
            children: [
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.red[100],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.delete_forever, color: Colors.red[700], size: 24),
                ),
                title: Text(
                  'Reset All Settings',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.red[800],
                  ),
                ),
                subtitle: Text(
                  'Clear all guardian contacts, API settings, and preferences',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.red[700],
                  ),
                ),
                trailing: Icon(Icons.chevron_right, color: Colors.red[700]),
                onTap: () => _showResetDialog(context),
              ),
              const Divider(height: 1, indent: 16, endIndent: 16),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.red[100],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.logout, color: Colors.red[700], size: 24),
                ),
                title: Text(
                  'Logout & Clear Data',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.red[800],
                  ),
                ),
                subtitle: Text(
                  'Sign out and remove all local data',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.red[700],
                  ),
                ),
                trailing: Icon(Icons.chevron_right, color: Colors.red[700]),
                onTap: () => _showLogoutDialog(context, appState),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showResetDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning, color: Colors.red[700]),
            const SizedBox(width: 12),
            const Text('Reset All Settings?'),
          ],
        ),
        content: const Text(
          'This will permanently delete all guardian contacts, API configuration, and preferences. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(context);
              final prefs = await SharedPreferences.getInstance();
              await prefs.clear();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('All settings reset. Please restart the app.')),
                );
              }
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Reset Everything'),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, AppState appState) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout & Clear Data?'),
        content: const Text('This will sign you out and clear all local data including guardian contacts and settings.'),
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
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}