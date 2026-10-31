import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'dev/prototype/prototype_app.dart';

/// Explicit UI-only target. The normal main.dart always uses real auth wiring.
void main() {
  if (!kDebugMode) throw StateError('UI prototype may only run in debug mode.');
  WidgetsFlutterBinding.ensureInitialized();
  runApp(buildPrototypeApp());
}
