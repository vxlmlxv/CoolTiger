import 'package:flutter/material.dart';

import 'app.dart';
import 'bootstrap/firebase_bootstrap.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await bootstrapFirebase(TargetFlavor.guardianWeb);
  runApp(const CoolTigerApp(targetFlavor: TargetFlavor.guardianWeb));
}
