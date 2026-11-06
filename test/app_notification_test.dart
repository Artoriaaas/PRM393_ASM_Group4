import 'package:eventhub_core/eventhub_core.dart';
import 'package:flutter_test/flutter_test.dart';
void main() {
  AppNotification notification(String event, [String? registration]) => AppNotification(id:'n', title:'t', body:'b', eventId:event, registrationId:registration, type:'push_received');
  test('registration receipt opens registration, generic receipt opens inbox', () {
    expect(notification('event', 'user_event').destination, '/registrations/user_event');
    expect(notification('').destination, '/notifications');
  });
  test('rejects path injection and falls back to validated event', () {
    expect(notification('event', '../account').destination, '/events/event');
    expect(notification('../account').destination, '/notifications');
  });
}
