import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/coach_persona.dart';
import '../services/preferences_service.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final TextEditingController _llmApiKeyController = TextEditingController();
  final TextEditingController _ttsApiKeyController = TextEditingController();
  late CoachPersonaId _selectedCoach;
  late int _defaultCheckInMinutes;
  late String _selectedTheme;
  late bool _notificationsEnabled;
  late bool _ttsEnabled;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  @override
  void dispose() {
    _llmApiKeyController.dispose();
    _ttsApiKeyController.dispose();
    super.dispose();
  }

  void _loadSettings() {
    _llmApiKeyController.text = PreferencesService.llmApiKey ?? '';
    _ttsApiKeyController.text = PreferencesService.ttsApiKey ?? '';
    _selectedCoach = PreferencesService.defaultCoachPersonaId;
    _defaultCheckInMinutes = PreferencesService.defaultCheckInMinutes;
    _selectedTheme = PreferencesService.appTheme;
    _notificationsEnabled = PreferencesService.notificationsEnabled;
    _ttsEnabled = PreferencesService.ttsEnabled;
  }

  Future<void> _saveSettings() async {
    await PreferencesService.setLlmApiKey(_llmApiKeyController.text);
    await PreferencesService.setTtsApiKey(_ttsApiKeyController.text);
    await PreferencesService.setDefaultCoachPersonaId(_selectedCoach);
    await PreferencesService.setDefaultCheckInMinutes(_defaultCheckInMinutes);
    await PreferencesService.setAppTheme(_selectedTheme);
    await PreferencesService.setNotificationsEnabled(_notificationsEnabled);
    await PreferencesService.setTtsEnabled(_ttsEnabled);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Settings saved')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        actions: [
          TextButton(
            onPressed: _saveSettings,
            child: const Text('Save'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // API Keys Section
            const Text(
              'API Keys',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _llmApiKeyController,
              decoration: const InputDecoration(
                labelText: 'LLM API Key',
                hintText: 'Enter your LLM service API key',
                border: OutlineInputBorder(),
                helperText: 'Required for AI coach responses',
              ),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _ttsApiKeyController,
              decoration: const InputDecoration(
                labelText: 'TTS API Key (Optional)',
                hintText: 'Enter your premium TTS API key',
                border: OutlineInputBorder(),
                helperText: 'Optional - fallback to system TTS if not provided',
              ),
              obscureText: true,
            ),
            
            const SizedBox(height: 32),
            
            // Coach Selection
            const Text(
              'Default Coach',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<CoachPersonaId>(
              value: _selectedCoach,
              decoration: const InputDecoration(
                labelText: 'Select Default Coach',
                border: OutlineInputBorder(),
              ),
              items: CoachPersonaId.values.map((coach) {
                final persona = CoachPersona.getPersona(coach);
                return DropdownMenuItem(
                  value: coach,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(persona.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text(persona.description, style: const TextStyle(fontSize: 12)),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (CoachPersonaId? value) {
                if (value != null) {
                  setState(() {
                    _selectedCoach = value;
                  });
                }
              },
            ),
            
            const SizedBox(height: 32),
            
            // Task Defaults
            const Text(
              'Task Defaults',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('Default Check-in Duration'),
              subtitle: Text('$_defaultCheckInMinutes minutes'),
              trailing: const Icon(Icons.edit),
              onTap: () async {
                final result = await showDialog<int>(
                  context: context,
                  builder: (context) => _CheckInDurationDialog(
                    initialValue: _defaultCheckInMinutes,
                  ),
                );
                if (result != null) {
                  setState(() {
                    _defaultCheckInMinutes = result;
                  });
                }
              },
            ),
            
            const SizedBox(height: 32),
            
            // Appearance
            const Text(
              'Appearance',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedTheme,
              decoration: const InputDecoration(
                labelText: 'Theme',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'light', child: Text('Light')),
                DropdownMenuItem(value: 'dark', child: Text('Dark')),
                DropdownMenuItem(value: 'system', child: Text('System')),
              ],
              onChanged: (String? value) {
                if (value != null) {
                  setState(() {
                    _selectedTheme = value;
                  });
                }
              },
            ),
            
            const SizedBox(height: 32),
            
            // Notifications & Audio
            const Text(
              'Notifications & Audio',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Enable Notifications'),
              subtitle: const Text('Allow check-in notifications'),
              value: _notificationsEnabled,
              onChanged: (bool value) {
                setState(() {
                  _notificationsEnabled = value;
                });
              },
            ),
            SwitchListTile(
              title: const Text('Enable Text-to-Speech'),
              subtitle: const Text('Coach responses will be spoken aloud'),
              value: _ttsEnabled,
              onChanged: (bool value) {
                setState(() {
                  _ttsEnabled = value;
                });
              },
            ),
            
            const SizedBox(height: 32),
            
            // Data Management
            const Text(
              'Data Management',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('Reset All Data'),
              subtitle: const Text('Clear all tasks and chat history'),
              leading: const Icon(Icons.warning, color: Colors.red),
              onTap: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Reset All Data'),
                    content: const Text(
                      'This will permanently delete all tasks, chat history, and settings. This action cannot be undone.',
                    ),
                    actions: [
                      TextButton(
                        child: const Text('Cancel'),
                        onPressed: () => Navigator.of(context).pop(false),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                        child: const Text('Reset'),
                        onPressed: () => Navigator.of(context).pop(true),
                      ),
                    ],
                  ),
                );
                
                if (confirmed == true) {
                  // TODO: Implement data reset functionality
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Data reset functionality not yet implemented')),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _CheckInDurationDialog extends StatefulWidget {
  final int initialValue;

  const _CheckInDurationDialog({required this.initialValue});

  @override
  State<_CheckInDurationDialog> createState() => _CheckInDurationDialogState();
}

class _CheckInDurationDialogState extends State<_CheckInDurationDialog> {
  late int _value;

  @override
  void initState() {
    super.initState();
    _value = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Check-in Duration'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('$_value minutes'),
          Slider(
            value: _value.toDouble(),
            min: 5,
            max: 120,
            divisions: 23,
            label: '$_value min',
            onChanged: (value) {
              setState(() {
                _value = value.round();
              });
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          child: const Text('Cancel'),
          onPressed: () => Navigator.of(context).pop(),
        ),
        ElevatedButton(
          child: const Text('Save'),
          onPressed: () => Navigator.of(context).pop(_value),
        ),
      ],
    );
  }
}