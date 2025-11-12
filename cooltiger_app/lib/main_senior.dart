import 'package:flutter/material.dart';

import 'app.dart';
import 'bootstrap/firebase_bootstrap.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await bootstrapFirebase(TargetFlavor.seniorMobile);
  runApp(const CoolTigerApp(targetFlavor: TargetFlavor.seniorMobile));
}
