import 'package:cloud_firestore/cloud_firestore.dart';

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
    final entry = hasId ? log : log.copyWith(id: docRef.id);

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
}
