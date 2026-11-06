import 'package:eventhub/utils/screen_identity.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'auth registration and event registration have different identities',
    () {
      expect(screenIdentity('/auth/register'), 'A01b');
      expect(screenIdentity('/events/workshop/register'), 'A05');
    },
  );
  test('scanner is not counted as registration detail', () {
    expect(screenIdentity('/registrations/owned/scan'), 'A11');
    expect(screenIdentity('/registrations/owned'), 'A08');
    expect(screenIdentity('/registrations/owned/check-in'), 'A12');
  });
  test(
    'demo and export are separate from profile; transient routes excluded',
    () {
      expect(screenIdentity('/account/export'), 'LAB3_EXPORT');
      expect(screenIdentity('/account/firebase-demo'), 'LAB3_FIREBASE');
      expect(screenIdentity('/session'), isNull);
      expect(screenIdentity('/dev/components'), isNull);
      expect(screenIdentity('/unknown'), isNull);
    },
  );
}
