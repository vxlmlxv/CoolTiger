import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/models.dart';

class FirestoreService {
  FirestoreService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  late final CollectionReference<ConversationLog> _conversationLogsRef =
      _firestore.collection('conversation_logs').withConverter(
            fromFirestore: (snapshot, _) => ConversationLog.fromJson(
              _decodeTimestampFields(snapshot.data(), snapshot.id),
            ),
            toFirestore: (log, _) => _encodeTimestampFields(log.toJson()),
          );

  late final CollectionReference<AnalysisReport> _analysisReportsRef =
      _firestore.collection('analysis_reports').withConverter(
            fromFirestore: (snapshot, _) => AnalysisReport.fromJson(
              _decodeTimestampFields(snapshot.data(), snapshot.id),
            ),
            toFirestore: (report, _) => _encodeTimestampFields(report.toJson()),
          );

  late final CollectionReference<Senior> _seniorsRef = _firestore.collection('seniors').withConverter(
        fromFirestore: (snapshot, _) => Senior.fromJson(
          _decodeTimestampFields(snapshot.data(), snapshot.id),
        ),
        toFirestore: (senior, _) => senior.toJson(),
      );

  Stream<List<ConversationLog>> conversationStream(String seniorId) {
    // TODO: Enforce role-based read restrictions via Firestore security rules.
    return _conversationLogsRef
        .where('seniorId', isEqualTo: seniorId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  Future<void> saveConversationLog(ConversationLog log) async {
    final bool hasId = log.id.isNotEmpty;
    final docRef = hasId ? _conversationLogsRef.doc(log.id) : _conversationLogsRef.doc();
    final entry = hasId
        ? log
        : ConversationLog(
            id: docRef.id,
            seniorId: log.seniorId,
            guardianId: log.guardianId,
            timestamp: log.timestamp,
            speaker: log.speaker,
            transcript: log.transcript,
            audioUrl: log.audioUrl,
            analysisStatus: log.analysisStatus,
          );

    // TODO: Restrict write access so only backend service accounts can call this endpoint.
    await docRef.set(entry);
  }

  Future<List<AnalysisReport>> fetchReports(String guardianId) async {
    final querySnapshot = await _analysisReportsRef
        .where('guardianId', isEqualTo: guardianId)
        .orderBy('date', descending: true)
        .get();
    return querySnapshot.docs.map((doc) => doc.data()).toList();
  }

  Stream<List<AnalysisReport>> watchAnalysisReports(String guardianId) {
    return _analysisReportsRef
        .where('guardianId', isEqualTo: guardianId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  Stream<List<ConversationLog>> watchRecentConversations({
    required String guardianId,
    required DateTime cutoff,
  }) {
    return _conversationLogsRef
        .where('guardianId', isEqualTo: guardianId)
        .where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(cutoff))
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  Stream<List<Senior>> watchGuardianSeniors(String guardianId) {
    return _seniorsRef
        .where('guardianId', isEqualTo: guardianId)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  Map<String, dynamic> _decodeTimestampFields(
      Map<String, dynamic>? data, String docId) {
    final payload = <String, dynamic>{'id': docId, ...?data};

    if (payload['timestamp'] is Timestamp) {
      payload['timestamp'] = (payload['timestamp'] as Timestamp).toDate().toIso8601String();
    }
    if (payload['date'] is Timestamp) {
      payload['date'] = (payload['date'] as Timestamp).toDate().toIso8601String();
    }
    return payload;
  }

  Map<String, dynamic> _encodeTimestampFields(Map<String, dynamic> data) {
    final encoded = Map<String, dynamic>.from(data);
    if (encoded['timestamp'] is String) {
      encoded['timestamp'] = Timestamp.fromDate(DateTime.parse(encoded['timestamp'] as String));
    }
    if (encoded['date'] is String) {
      encoded['date'] = Timestamp.fromDate(DateTime.parse(encoded['date'] as String));
    }
    return encoded;
  }

  Future<void> saveTrainingResult({
    required String seniorId,
    required String guardianId,
    required String moduleType,
    required Map<String, dynamic> metrics,
    String? moduleId,
  }) async {
    final payload = {
      'seniorId': seniorId,
      'guardianId': guardianId,
      'moduleType': moduleType,
      'metrics': metrics,
      'moduleId': moduleId,
      'completedAt': Timestamp.fromDate(DateTime.now()),
    };
    await _firestore.collection('training_results').add(payload);
  }
}

final firestoreServiceProvider = Provider<FirestoreService>((ref) {
  return FirestoreService();
});
