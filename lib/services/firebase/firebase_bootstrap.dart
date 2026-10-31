import 'package:firebase_core/firebase_core.dart';

/// Android reads resources generated from the team's google-services.json.
/// Never installs a demo project or fabricates FirebaseOptions.
Future<bool> initializeFirebase() async {
  try {
    await Firebase.initializeApp().timeout(const Duration(seconds: 10));
    return true;
  } catch (_) {
    return false;
  }
}
