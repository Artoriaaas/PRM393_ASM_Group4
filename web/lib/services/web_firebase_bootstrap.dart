import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';

/// Reads public Firebase Web client identifiers from `--dart-define`.
/// Never fabricates demo keys or fallback project IDs.
class WebFirebaseEnvironment {
  WebFirebaseEnvironment._();

  static const String apiKey = String.fromEnvironment('FIREBASE_WEB_API_KEY');
  static const String appId = String.fromEnvironment('FIREBASE_WEB_APP_ID');
  static const String messagingSenderId = String.fromEnvironment(
    'FIREBASE_WEB_MESSAGING_SENDER_ID',
  );
  static const String projectId = String.fromEnvironment(
    'FIREBASE_WEB_PROJECT_ID',
  );
  static const String authDomain = String.fromEnvironment(
    'FIREBASE_WEB_AUTH_DOMAIN',
  );
  static const String storageBucket = String.fromEnvironment(
    'FIREBASE_WEB_STORAGE_BUCKET',
  );
  static const String measurementId = String.fromEnvironment(
    'FIREBASE_WEB_MEASUREMENT_ID',
  );
  static const String recaptchaEnterpriseSiteKey = String.fromEnvironment(
    'FIREBASE_RECAPTCHA_ENTERPRISE_SITE_KEY',
  );

  static bool get hasExplicitOptions =>
      apiKey.isNotEmpty &&
      appId.isNotEmpty &&
      messagingSenderId.isNotEmpty &&
      projectId.isNotEmpty;

  static FirebaseOptions get options => FirebaseOptions(
        apiKey: apiKey,
        appId: appId,
        messagingSenderId: messagingSenderId,
        projectId: projectId,
        authDomain: authDomain.isEmpty ? null : authDomain,
        storageBucket: storageBucket.isEmpty ? null : storageBucket,
        measurementId: measurementId.isEmpty ? null : measurementId,
      );
}

Future<void>? _webCoreInitialization;

Future<bool> initializeWebFirebase() async {
  try {
    if (Firebase.apps.isEmpty) {
      if (!WebFirebaseEnvironment.hasExplicitOptions) {
        return false;
      }
      _webCoreInitialization ??= Firebase.initializeApp(
        options: WebFirebaseEnvironment.options,
      ).then((_) {});
      await _webCoreInitialization!.timeout(const Duration(seconds: 30));
    }

    // Do not persist club participant records in a shared browser IndexedDB cache.
    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: false,
    );

    if (WebFirebaseEnvironment.recaptchaEnterpriseSiteKey.isNotEmpty) {
      await FirebaseAppCheck.instance.activate(
        providerWeb: ReCaptchaEnterpriseProvider(
          WebFirebaseEnvironment.recaptchaEnterpriseSiteKey,
        ),
      );
    }

    return true;
  } catch (_) {
    _webCoreInitialization = null;
    return false;
  }
}
