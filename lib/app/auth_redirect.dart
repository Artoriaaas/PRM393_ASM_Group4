import '../models/auth_state.dart';

/// Keeps only internal destinations; the destination is never an executable URL.
String safeDestination(String? value) {
  final uri = Uri.tryParse(value ?? '');
  if (uri == null ||
      uri.hasScheme ||
      uri.hasAuthority ||
      !uri.path.startsWith('/') ||
      uri.path.startsWith('//') ||
      uri.path.startsWith('/auth') ||
      uri.path.startsWith('/dev') ||
      uri.path == '/session') {
    return '/discover';
  }
  return uri.toString();
}

String? authRedirect(AuthState auth, Uri location, bool development) {
  final path = location.path;
  if (development && path == '/dev/components') return null;
  final inAuth = path.startsWith('/auth/');
  final destination = safeDestination(
    location.queryParameters['from'] ?? (inAuth ? null : location.toString()),
  );
  String target(String path) =>
      Uri(path: path, queryParameters: {'from': destination}).toString();
  if (auth.isRestoring) {
    return path == '/session' ? null : target('/session');
  }
  if (auth.isSignedOut) {
    if (inAuth && path != '/auth/verify-email') return null;
    return target('/auth/login');
  }
  if (auth.isUnverified) {
    return path == '/auth/verify-email' ? null : target('/auth/verify-email');
  }
  if (inAuth || path == '/session') return destination;
  return null;
}
