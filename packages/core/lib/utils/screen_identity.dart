/// Stable analytics labels. Never include IDs, search terms or query strings.
String? screenIdentity(String path) {
  const fixed = {
    '/auth/login': 'A01a',
    '/auth/register': 'A01b',
    '/auth/verify-email': 'A01c',
    '/auth/change-email': 'A01b',
    '/auth/forgot-password': 'A01d',
    '/discover': 'A02',
    '/discover/search': 'A03',
    '/schedule': 'A07',
    '/notifications': 'A09',
    '/account': 'A10',
    '/account/edit': 'A10',
    '/account/export': 'LAB3_EXPORT',
    '/account/firebase-demo': 'LAB3_FIREBASE',
  };
  if (fixed.containsKey(path)) return fixed[path];
  final parts = Uri.parse(path).pathSegments;
  if (parts.length == 2 && parts.first == 'events') return 'A04';
  if (parts.length == 3 &&
      parts.first == 'events' &&
      parts.last == 'register') {
    return 'A05';
  }
  if (parts.length >= 2 && parts.first == 'registrations') {
    if (parts.length == 2) return 'A08';
    if (parts.length == 3) {
      return switch (parts.last) {
        'success' => 'A06',
        'scan' => 'A11',
        'check-in' => 'A12',
        _ => null,
      };
    }
  }
  return null;
}
