import 'package:eventhub/app/auth_redirect.dart';
import 'package:eventhub/models/auth_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('protects deep links and resumes after sign in', () {
    final redirect = authRedirect(
      const AuthState.signedOut(),
      Uri.parse('/events/e1?source=push'),
      false,
    )!;
    expect(Uri.parse(redirect).path, '/auth/login');
    expect(
      authRedirect(
        const AuthState.signedIn(uid: 'u', email: 'a@b.c'),
        Uri.parse(redirect),
        false,
      ),
      '/events/e1?source=push',
    );
  });
  test('restoring and verification preserve destination', () {
    final waiting = authRedirect(
      const AuthState.restoring(),
      Uri.parse('/schedule'),
      false,
    )!;
    final verify = authRedirect(
      const AuthState.unverified(uid: 'u', email: 'a@b.c'),
      Uri.parse(waiting),
      false,
    )!;
    expect(Uri.parse(verify).path, '/auth/verify-email');
    expect(Uri.parse(verify).queryParameters['from'], '/schedule');
  });
  test('development bypass is explicit and external redirects rejected', () {
    expect(
      authRedirect(
        const AuthState.signedOut(),
        Uri.parse('/dev/components'),
        true,
      ),
      isNull,
    );
    expect(
      authRedirect(
        const AuthState.signedOut(),
        Uri.parse('/dev/components'),
        false,
      ),
      isNotNull,
    );
    expect(safeDestination('https://example.com'), '/discover');
    expect(safeDestination('//example.com'), '/discover');
  });
}
