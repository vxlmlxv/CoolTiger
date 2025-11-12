import 'package:flutter/material.dart';

class ShowcaseScreen extends StatelessWidget {
  const ShowcaseScreen({super.key});

  static const routeName = 'senior-showcase';
  static const routePath = '/';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Senior Showcase Demo')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Try the conversation loop instantly',
                  style: Theme.of(context).textTheme.headlineLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  'Tap record to share a short message. The AI response and cognitive training modules render here.',
                  style: Theme.of(context).textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                FilledButton.icon(
                  onPressed: () {
                    // TODO: Implement browser-based audio capture and backend call.
                    debugPrint('Showcase recording stub');
                  },
                  icon: const Icon(Icons.fiber_manual_record, size: 28),
                  label: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    child: Text('Start Recording'),
                  ),
                ),
                const SizedBox(height: 24),
                Card(
                  elevation: 0,
                  color: Theme.of(context).colorScheme.surfaceContainerLow,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: const [
                        Text('Cognitive training preview'),
                        SizedBox(height: 8),
                        Text('Modules will appear here after the next update.'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
