import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../../models/models.dart';
import '../../../services/firestore_service.dart';
import '../../../services/auth_providers.dart';

final guardianIdProvider = Provider<String?>((ref) {
  final auth = ref.watch(authStateProvider).value;
  return auth?.uid;
});

final guardianSeniorsProvider = StreamProvider<List<Senior>>((ref) {
  final guardianId = ref.watch(guardianIdProvider);
  if (guardianId == null) {
    return Stream<List<Senior>>.empty();
  }
  return ref.watch(firestoreServiceProvider).watchGuardianSeniors(guardianId);
});

final analysisReportsProvider = StreamProvider<List<AnalysisReport>>((ref) {
  final guardianId = ref.watch(guardianIdProvider);
  if (guardianId == null) {
    return Stream<List<AnalysisReport>>.empty();
  }
  return ref.watch(firestoreServiceProvider).watchAnalysisReports(guardianId);
});

class ConversationFilter {
  ConversationFilter({required this.window});
  final Duration window;
}

final conversationFilterProvider = StateProvider<ConversationFilter>((ref) {
  return ConversationFilter(window: const Duration(hours: 24));
});

final conversationLogsProvider =
    StreamProvider<List<ConversationLog>>((ref) {
  final guardianId = ref.watch(guardianIdProvider);
  if (guardianId == null) {
    return Stream<List<ConversationLog>>.empty();
  }
  final filter = ref.watch(conversationFilterProvider);
  final cutoff = DateTime.now().subtract(filter.window);
  return ref
      .watch(firestoreServiceProvider)
      .watchRecentConversations(guardianId: guardianId, cutoff: cutoff);
});

final anomalyAlertsProvider = Provider<List<String>>((ref) {
  final reports = ref.watch(analysisReportsProvider).value ?? const [];
  final Map<String, List<AnalysisReport>> grouped = {};
  for (final report in reports) {
    grouped.putIfAbsent(report.seniorId, () => []).add(report);
  }
  final List<String> alerts = [];
  grouped.forEach((seniorId, list) {
    final negatives = list
        .where((r) => r.metrics.sentiment.toLowerCase() == 'negative')
        .take(3)
        .length;
    if (negatives >= 3) {
      alerts.add('Senior $seniorId showed negative sentiment in the last $negatives calls.');
    }
  });
  return alerts;
});
