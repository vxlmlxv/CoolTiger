import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GuardianSettingsScreen extends ConsumerStatefulWidget {
  const GuardianSettingsScreen({super.key});

  @override
  ConsumerState<GuardianSettingsScreen> createState() => _GuardianSettingsScreenState();
}

class _GuardianSettingsScreenState extends ConsumerState<GuardianSettingsScreen> {
  TimeOfDay _checkinTime = const TimeOfDay(hour: 10, minute: 0);
  bool _proactiveCalls = true;

  Future<void> _pickTime(BuildContext context) async {
    final picked = await showTimePicker(context: context, initialTime: _checkinTime);
    if (picked != null) {
      setState(() => _checkinTime = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Guardian Settings')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Scheduling', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('Daily Check-in Time'),
              subtitle: Text(_checkinTime.format(context)),
              trailing: FilledButton(
                onPressed: () => _pickTime(context),
                child: const Text('Adjust'),
              ),
            ),
            SwitchListTile(
              value: _proactiveCalls,
              title: const Text('Enable proactive calls'),
              subtitle: const Text('Disable to pause scheduled check-ins temporarily.'),
              onChanged: (value) => setState(() => _proactiveCalls = value),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Preferences saved (TODO: sync to Firestore).')),
                );
              },
              icon: const Icon(Icons.save),
              label: const Text('Save Preferences'),
            ),
            const SizedBox(height: 24),
            Text(
              'Scheduling updates will sync to the backend job that triggers FCM proactive calls. '
              'Future work: persist these fields to Firestore / Cloud Scheduler.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
