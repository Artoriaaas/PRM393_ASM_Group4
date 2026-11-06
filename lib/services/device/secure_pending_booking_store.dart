import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:eventhub_core/eventhub_core.dart';

class SecurePendingBookingStore implements PendingBookingStore {
  const SecurePendingBookingStore(this.storage);
  final FlutterSecureStorage storage;
  String _key(String uid) => 'pending_booking_$uid';
  @override
  Future<Map<String, dynamic>?> read(String uid) async {
    final raw = await storage.read(key: _key(uid));
    return raw == null
        ? null
        : Map<String, dynamic>.from(jsonDecode(raw) as Map);
  }

  @override
  Future<void> write(String uid, Map<String, dynamic> c) =>
      storage.write(key: _key(uid), value: jsonEncode(c));
  @override
  Future<void> clear(String uid) => storage.delete(key: _key(uid));
}
