import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../senior/models/transcript_entry.dart';
import '../../training/training_module_engine.dart';
import '../controllers/showcase_controller.dart';

class ShowcaseScreen extends ConsumerWidget {
  const ShowcaseScreen({super.key});

  static const routeName = 'senior-showcase';
  static const routePath = '/';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(showcaseControllerProvider);
    final transcripts = controller.transcripts.reversed.toList();
    final module = controller.activeModule;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Senior Showcase Demo')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Experience CoolTiger in your browser',
                  style: Theme.of(context).textTheme.headlineLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                _SupportBanner(state: controller.state, error: controller.error),
                const SizedBox(height: 24),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  alignment: WrapAlignment.center,
                  children: [
                    FilledButton.icon(
                      onPressed: controller.state == ShowcaseState.unsupported
                          ? null
                          : controller.isRecording
                              ? null
                              : controller.startRecording,
                      icon: const Icon(Icons.mic),
                      label: const Text('Start Recording'),
                    ),
                    OutlinedButton.icon(
                      onPressed:
                          controller.isRecording ? controller.stopAndUpload : null,
                      icon: const Icon(Icons.stop),
                      label: const Text('Stop & Send'),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: _TranscriptPanel(transcripts: transcripts),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: module != null
                            ? _PanelShell(
                                child: SizedBox.expand(
                                  child: TrainingModuleEngine(
                                    module: module,
                                    seniorId: 'showcase-senior',
                                    guardianId: 'showcase-guardian',
                                    onCompleted: () => controller.markTrainingComplete(),
                                  ),
                                ),
                              )
                            : const _TrainingPreview(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Tips: Works best in Chrome or Edge. Allow microphone access when prompted.',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: colorScheme.onSurfaceVariant),
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

class _SupportBanner extends StatelessWidget {
  const _SupportBanner({required this.state, required this.error});

  final ShowcaseState state;
  final String? error;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    String message;
    Color background;
    if (state == ShowcaseState.unsupported) {
      message = 'Your browser does not support MediaRecorder audio/webm. Please switch to Chrome or Edge.';
      background = colorScheme.errorContainer;
    } else if (state == ShowcaseState.recording) {
      message = 'Recording… speak naturally, then press Stop.';
      background = colorScheme.primaryContainer;
    } else if (state == ShowcaseState.thinking) {
      message = 'Thinking… generating AI reply';
      background = colorScheme.secondaryContainer;
    } else if (state == ShowcaseState.training) {
      message = 'Launching cognitive training module';
      background = colorScheme.tertiaryContainer;
    } else if (state == ShowcaseState.error && error != null) {
      message = error!;
      background = colorScheme.errorContainer;
    } else {
      message = 'Press Start Recording to demo the proactive companion.';
      background = colorScheme.surfaceContainerHighest;
    }

    return DecoratedBox(
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          message,
          style: Theme.of(context).textTheme.titleMedium,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class _TranscriptPanel extends StatelessWidget {
  const _TranscriptPanel({required this.transcripts});

  final List<TranscriptEntry> transcripts;

  @override
  Widget build(BuildContext context) {
    if (transcripts.isEmpty) {
      return const _PanelShell(child: Center(child: Text('No transcripts yet.')));
    }
    return _PanelShell(
      child: ListView.builder(
        itemCount: transcripts.length,
        itemBuilder: (context, index) {
          final entry = transcripts[index];
          return ListTile(
            leading: Icon(entry.speaker == 'ai' ? Icons.auto_awesome : Icons.person),
            title: Text(entry.text),
            subtitle: Text(entry.timestamp.toLocal().toString()),
          );
        },
      ),
    );
  }
}

class _TrainingPreview extends StatelessWidget {
  const _TrainingPreview();

  @override
  Widget build(BuildContext context) {
    return _PanelShell(
      child: Center(
        child: Text(
          'Trigger a cognitive training module to see the interactive experience here.',
          style: Theme.of(context).textTheme.bodyLarge,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class _PanelShell extends StatelessWidget {
  const _PanelShell({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: child,
      ),
    );
  }
}
