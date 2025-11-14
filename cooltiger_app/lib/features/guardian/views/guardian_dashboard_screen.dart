import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../models/models.dart';
import '../../../services/auth_providers.dart';
import '../controllers/guardian_dashboard_providers.dart';
import 'guardian_sign_in_screen.dart';

class GuardianDashboardScreen extends ConsumerWidget {
  const GuardianDashboardScreen({super.key});

  static const routeName = 'guardian-dashboard';
  static const routePath = '/guardian';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    return authState.when(
      data: (user) {
        if (user == null) {
          return const GuardianSignInScreen();
        }
        return _DashboardView(user: user);
      },
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (err, stack) => Scaffold(body: Center(child: Text('Auth error: $err'))),
    );
  }
}

class _DashboardView extends ConsumerWidget {
  const _DashboardView({required this.user});

  final User user;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analysisAsync = ref.watch(analysisReportsProvider);
    final conversationsAsync = ref.watch(conversationLogsProvider);
    final seniorsAsync = ref.watch(guardianSeniorsProvider);
    final anomalies = ref.watch(anomalyAlertsProvider);
    final filter = ref.watch(conversationFilterProvider);

    final seniorNames = {
      for (final senior in seniorsAsync.value ?? const <Senior>[]) senior.id: senior.name,
    };

    final latestReports = _collapseLatestReports(analysisAsync.value ?? const []);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Guardian Console'),
        actions: [
          IconButton(
            tooltip: 'Settings',
            onPressed: () => context.push('settings'),
            icon: const Icon(Icons.settings),
          ),
          IconButton(
            tooltip: 'Sign Out',
            onPressed: () => FirebaseAuth.instance.signOut(),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 12,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text('Conversation Window:', style: Theme.of(context).textTheme.titleMedium),
                ChoiceChip(
                  label: const Text('Last 24h'),
                  selected: filter.window == const Duration(hours: 24),
                  onSelected: (_) => ref
                      .read(conversationFilterProvider.notifier)
                      .state = ConversationFilter(window: const Duration(hours: 24)),
                ),
                ChoiceChip(
                  label: const Text('Last 7d'),
                  selected: filter.window == const Duration(days: 7),
                  onSelected: (_) => ref
                      .read(conversationFilterProvider.notifier)
                      .state = ConversationFilter(window: const Duration(days: 7)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Latest Analysis Reports', style: Theme.of(context).textTheme.titleLarge),
                        const SizedBox(height: 12),
                        Expanded(
                          child: analysisAsync.when(
                            data: (_) {
                              if (latestReports.isEmpty) {
                                return const Center(child: Text('No analysis data yet.'));
                              }
                              return GridView.count(
                                crossAxisCount: 2,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                                childAspectRatio: 1.4,
                                children: latestReports.values.map((report) {
                                  final name = seniorNames[report.seniorId] ?? report.seniorId;
                                  return _AnalysisCard(name: name, report: report);
                                }).toList(),
                              );
                            },
                            loading: () => const Center(child: CircularProgressIndicator()),
                            error: (err, _) => Center(child: Text('Error: $err')),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Recent Conversations', style: Theme.of(context).textTheme.titleLarge),
                        const SizedBox(height: 12),
                        Expanded(
                          child: conversationsAsync.when(
                            data: (logs) {
                              if (logs.isEmpty) {
                                return const Center(child: Text('No conversations in this window.'));
                              }
                              return ListView.builder(
                                itemCount: logs.length,
                                itemBuilder: (context, index) {
                                  final log = logs[index];
                                  final name = seniorNames[log.seniorId] ?? log.seniorId;
                                  return ListTile(
                                    title: Text(name),
                                    subtitle: Text(log.transcript),
                                    trailing: Text(_relativeTime(log.timestamp)),
                                  );
                                },
                              );
                            },
                            loading: () => const Center(child: CircularProgressIndicator()),
                            error: (err, _) => Center(child: Text('Error: $err')),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _AnomalyStrip(anomalies: anomalies),
            const SizedBox(height: 16),
            Text('Signed in as ${user.email ?? user.uid}', style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}

class _AnomalyStrip extends StatelessWidget {
  const _AnomalyStrip({required this.anomalies});

  final List<String> anomalies;

  @override
  Widget build(BuildContext context) {
    if (anomalies.isEmpty) {
      return DecoratedBox(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Padding(
          padding: EdgeInsets.all(16),
          child: Text('No anomalies detected in the selected window.'),
        ),
      );
    }
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Alerts', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            ...anomalies.map((alert) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text('• $alert\n  Recommendation: Schedule a manual check-in and share conversation tips with the caregiver.'),
                )),
          ],
        ),
      ),
    );
  }
}

class _AnalysisCard extends StatelessWidget {
  const _AnalysisCard({required this.name, required this.report});

  final String name;
  final AnalysisReport report;

  @override
  Widget build(BuildContext context) {
    final metrics = report.metrics;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(name, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: [
                _MetricChip(label: 'Sentiment', value: metrics.sentiment),
                _MetricChip(label: 'Words', value: metrics.wordCount.toString()),
                _MetricChip(label: 'WPM', value: metrics.speakingRate.toString()),
                _MetricChip(label: 'TTR', value: metrics.ttr.toStringAsFixed(2)),
              ],
            ),
            const Spacer(),
            Text(report.summary, maxLines: 2, overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }
}

class _MetricChip extends StatelessWidget {
  const _MetricChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Chip(label: Text('$label: $value'));
  }
}

Map<String, AnalysisReport> _collapseLatestReports(List<AnalysisReport> reports) {
  final Map<String, AnalysisReport> latest = {};
  for (final report in reports) {
    latest.putIfAbsent(report.seniorId, () => report);
  }
  return latest;
}

String _relativeTime(DateTime timestamp) {
  final delta = DateTime.now().difference(timestamp);
  if (delta.inMinutes < 60) return '${delta.inMinutes}m ago';
  if (delta.inHours < 24) return '${delta.inHours}h ago';
  return '${delta.inDays}d ago';
}
