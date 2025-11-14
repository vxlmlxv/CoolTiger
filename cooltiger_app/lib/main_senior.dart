import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'bootstrap/firebase_bootstrap.dart';
import 'features/senior/controllers/press_to_talk_controller.dart';
import 'features/senior/data/transcript_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await bootstrapFirebase(TargetFlavor.seniorMobile);
  final prefs = await SharedPreferences.getInstance();
  final transcriptRepo = TranscriptRepository(prefs);
  runApp(
    ProviderScope(
      overrides: [
        transcriptRepositoryProvider.overrideWithValue(transcriptRepo),
      ],
      child: const CoolTigerApp(targetFlavor: TargetFlavor.seniorMobile),
    ),
  );
}
