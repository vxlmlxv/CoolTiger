import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';

import '../../models/models.dart';
import '../../services/firestore_service.dart';

class TrainingModuleEngine extends ConsumerStatefulWidget {
  const TrainingModuleEngine({
    super.key,
    required this.module,
    required this.seniorId,
    required this.guardianId,
    this.onCompleted,
  });

  final TrainingModuleResponse module;
  final String seniorId;
  final String guardianId;
  final VoidCallback? onCompleted;

  @override
  ConsumerState<TrainingModuleEngine> createState() => _TrainingModuleEngineState();
}

class _TrainingModuleEngineState extends ConsumerState<TrainingModuleEngine> {
  late final AudioPlayer _player;
  bool _completed = false;
  Map<String, dynamic> _metrics = const {};

  late String _moduleType;

  @override
  void initState() {
    super.initState();
    _moduleType = widget.module.moduleType.name;
    _player = AudioPlayer();
    _playIntro();
  }

  Future<void> _playIntro() async {
    if (widget.module.ttsAudioUrl.isEmpty) {
      return;
    }
    try {
      await _player.setUrl(widget.module.ttsAudioUrl);
      await _player.play();
    } catch (_) {
      // ignore playback errors for now
    }
  }

  Future<void> _complete(Map<String, dynamic> metrics) async {
    if (_completed) return;
    final service = ref.read(firestoreServiceProvider);
    await service.saveTrainingResult(
      seniorId: widget.seniorId,
      guardianId: widget.guardianId,
      moduleType: _moduleType,
      moduleId: widget.module.moduleId,
      metrics: metrics,
    );
    setState(() {
      _completed = true;
      _metrics = metrics;
    });
    widget.onCompleted?.call();
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.module.moduleData;
    final child = switch (widget.module.moduleType) {
      TrainingModuleType.cardMatch => _CardMatchModule(onFinish: _complete, data: data),
      TrainingModuleType.memoryRecall => _MemoryRecallModule(onFinish: _complete, data: data),
      _ => _UnsupportedModule(onFinish: _complete),
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.module.ttsPrompt, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 16),
        Expanded(child: child),
        if (_completed)
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Text('Module completed! Metrics: $_metrics'),
          ),
      ],
    );
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }
}

class _CardMatchModule extends StatefulWidget {
  const _CardMatchModule({required this.onFinish, required this.data});

  final Future<void> Function(Map<String, dynamic>) onFinish;
  final Map<String, dynamic> data;

  @override
  State<_CardMatchModule> createState() => _CardMatchModuleState();
}

class _CardMatchModuleState extends State<_CardMatchModule> {
  late List<_CardEntry> _cards;
  _CardEntry? _firstSelection;
  int _matches = 0;
  int _attempts = 0;

  @override
  void initState() {
    super.initState();
    final pairs = (widget.data['pairs'] as List?) ?? [];
    _cards = [
      for (final pair in pairs)
        ...[
          _CardEntry(id: pair['id'].toString(), label: pair['a'] as String? ?? ''),
          _CardEntry(id: pair['id'].toString(), label: pair['b'] as String? ?? ''),
        ]
    ]..shuffle(Random());
  }

  void _tapCard(_CardEntry entry) {
    if (entry.matched || entry == _firstSelection) return;
    setState(() {
      _attempts++;
      if (_firstSelection == null) {
        _firstSelection = entry;
      } else {
        if (_firstSelection!.id == entry.id) {
          entry.matched = true;
          _firstSelection!.matched = true;
          _matches++;
        }
        _firstSelection = null;
      }
    });
    if (_matches * 2 == _cards.length) {
      widget.onFinish({'matches': _matches, 'attempts': _attempts});
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final crossAxisCount = constraints.maxWidth > 500 ? 4 : 2;
      return GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
        ),
        itemCount: _cards.length,
        itemBuilder: (context, index) {
          final entry = _cards[index];
          final selected = _firstSelection == entry;
          return GestureDetector(
            onTap: () => _tapCard(entry),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                color: entry.matched
                    ? Colors.green.shade300
                    : selected
                        ? Theme.of(context).colorScheme.secondaryContainer
                        : Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Text(
                  entry.matched || selected ? entry.label : '?',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
            ),
          );
        },
      );
    });
  }
}

class _CardEntry {
  _CardEntry({required this.id, required this.label});
  final String id;
  final String label;
  bool matched = false;
}

class _MemoryRecallModule extends StatefulWidget {
  const _MemoryRecallModule({required this.onFinish, required this.data});

  final Future<void> Function(Map<String, dynamic>) onFinish;
  final Map<String, dynamic> data;

  @override
  State<_MemoryRecallModule> createState() => _MemoryRecallModuleState();
}

class _MemoryRecallModuleState extends State<_MemoryRecallModule> {
  int _questionIndex = 0;
  int _correct = 0;

  List<Map<String, dynamic>> get _questions =>
      (widget.data['questions'] as List?)?.cast<Map<String, dynamic>>() ??
      [
        {
          'prompt': 'What did we talk about yesterday?',
          'options': ['Weather', 'Movies', 'Gardening'],
          'answer': 'Gardening',
        }
      ];

  void _select(String option) {
    final current = _questions[_questionIndex];
    if (option == current['answer']) {
      _correct++;
    }
    if (_questionIndex + 1 >= _questions.length) {
      widget.onFinish({'correct': _correct, 'total': _questions.length});
    } else {
      setState(() => _questionIndex++);
    }
  }

  @override
  Widget build(BuildContext context) {
    final question = _questions[_questionIndex];
    final options = (question['options'] as List?)?.cast<String>() ?? const [];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Question ${_questionIndex + 1}/${_questions.length}',
            style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        Text(question['prompt'] as String? ?? '', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 16),
        ...options.map(
          (option) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: FilledButton(
              onPressed: () => _select(option),
              style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(56)),
              child: Text(option, style: const TextStyle(fontSize: 18)),
            ),
          ),
        ),
      ],
    );
  }
}

class _UnsupportedModule extends StatelessWidget {
  const _UnsupportedModule({required this.onFinish});
  final Future<void> Function(Map<String, dynamic>) onFinish;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('This training module type is not supported yet.'),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: () => onFinish({'status': 'skipped'}),
            child: const Text('Skip Module'),
          ),
        ],
      ),
    );
  }
}
