import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../controllers/press_to_talk_controller.dart';
import '../../training/training_module_engine.dart';

class SeniorHomeScreen extends ConsumerStatefulWidget {
  const SeniorHomeScreen({super.key});

  static const routeName = 'senior-home';
  static const routePath = '/';

  @override
  ConsumerState<SeniorHomeScreen> createState() => _SeniorHomeScreenState();
}

class _SeniorHomeScreenState extends ConsumerState<SeniorHomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final controller = ref.read(pressToTalkControllerProvider);
      // TODO: Replace with authenticated senior + guardian IDs.
      await controller.configureIdentity(
        seniorId: 'demo-senior',
        guardianId: 'demo-guardian',
      );
      await controller.ensureFcmListener();
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.watch(pressToTalkControllerProvider);
    final colorScheme = Theme.of(context).colorScheme;

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
                    .headlineLarge
                    ?.copyWith(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 12),
              Text(
                controller.statusLabel,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 24),
              Expanded(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(32),
                    gradient: LinearGradient(
                      colors: [colorScheme.primary, colorScheme.secondary],
                    ),
                  ),
                  child: Center(
                    child: Semantics(
                      button: true,
                      label: 'Press and hold to talk',
                      child: GestureDetector(
                        onTapDown: (_) => controller.startRecording(),
                        onTapUp: (_) => controller.stopRecording(),
                        onTapCancel: () => controller.stopRecording(),
                        child: AnimatedScale(
                          scale: controller.phase == PressToTalkPhase.recording ? 0.9 : 1.0,
                          duration: const Duration(milliseconds: 150),
                          child: Container(
                            width: 220,
                            height: 220,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: controller.phase == PressToTalkPhase.recording
                                  ? colorScheme.error
                                  : colorScheme.onPrimary,
                            ),
                            child: Text(
                              controller.phase == PressToTalkPhase.recording
                                  ? 'Release to Send'
                                  : 'Press to Talk',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                    color: controller.phase == PressToTalkPhase.recording
                                        ? colorScheme.onError
                                        : colorScheme.primary,
                                  ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text('Conversation History', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              SizedBox(
                height: 220,
                child: controller.transcripts.isEmpty
                    ? const Center(child: Text('No conversations yet.'))
                    : ListView.builder(
                        itemCount: controller.transcripts.length,
                        itemBuilder: (context, index) {
                          final entry = controller.transcripts[controller.transcripts.length - 1 - index];
                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: CircleAvatar(
                              backgroundColor: entry.speaker == 'ai'
                                  ? colorScheme.secondaryContainer
                                  : colorScheme.primaryContainer,
                              child: Icon(
                                entry.speaker == 'ai' ? Icons.auto_awesome : Icons.person,
                                color: entry.speaker == 'ai'
                                    ? colorScheme.onSecondaryContainer
                                    : colorScheme.onPrimaryContainer,
                              ),
                            ),
                            title: Text(entry.text),
                            subtitle: Text(entry.timestamp.toLocal().toString()),
                          );
                        },
                      ),
              ),
              if (controller.activeModule != null) ...[
                const SizedBox(height: 16),
                SizedBox(
                  height: 360,
                  child: TrainingModuleEngine(
                    module: controller.activeModule!,
                    seniorId: controller.seniorId ?? 'demo-senior',
                    guardianId: controller.guardianId ?? 'demo-guardian',
                    onCompleted: () => controller.markTrainingComplete(),
                  ),
                ),
              ],
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: controller.isBusy ? null : controller.requestGreeting,
                icon: const Icon(Icons.play_arrow),
                label: const Text('Play Greeting'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
