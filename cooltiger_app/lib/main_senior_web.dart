import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'bootstrap/firebase_bootstrap.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await bootstrapFirebase(TargetFlavor.seniorWeb);
  runApp(
    const ProviderScope(
      child: CoolTigerApp(targetFlavor: TargetFlavor.seniorWeb),
    ),
  );
}
