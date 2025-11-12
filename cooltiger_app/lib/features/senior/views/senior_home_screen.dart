import 'package:flutter/material.dart';

/// Placeholder for the native Senior app home experience.
/// Includes microphone permission stubs and accessibility-first UI.
class SeniorHomeScreen extends StatelessWidget {
  const SeniorHomeScreen({super.key});

  static const routeName = 'senior-home';
  static const routePath = '/';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'CoolTiger Walkie-Talkie',
                style: Theme.of(context)
                    .textTheme
                    .headlineMedium
                    ?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 24),
              const Text(
                'Hold the button to speak. Release when finished and the AI companion replies automatically.',
              ),
              const Spacer(),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 90),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                onPressed: () {
                  // TODO: Wire up press-and-hold recording logic.
                  debugPrint('Press-to-talk stub tapped');
                },
                icon: const Icon(Icons.mic, size: 36),
                label: const Text(
                  'Hold to Talk',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: () {
                  // TODO: Request microphone permission via permission_handler.
                  debugPrint('Microphone permission request stub');
                },
                child: const Text('Request Microphone Permission'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
