import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Android reads resources generated from the team's google-services.json.
/// Never installs a demo project or fabricates FirebaseOptions.
Future<bool> initializeFirebase() async {
  try {
    await Firebase.initializeApp().timeout(const Duration(seconds: 10));
    // Private participation records must not remain in a shared device disk cache.
    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: false,
    );
    return true;
  } catch (_) {
    return false;
  }
}
