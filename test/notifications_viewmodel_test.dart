import 'package:eventhub/app/event_providers.dart';
import 'package:eventhub/app/providers.dart';
import 'package:eventhub_core/eventhub_core.dart';
import 'package:eventhub/viewmodels/notifications_viewmodel.dart';
import 'package:eventhub/viewmodels/session_viewmodel.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
class _Session extends SessionViewModel {@override AuthState build()=>const AuthState.signedIn(uid:'u',email:'a@b.c');}
class _Notifications implements NotificationService {final seen=<String>[];bool fail=false;@override Stream<List<AppNotification>> watch(String uid)=>Stream.value([]);@override Future<void> markRead(String uid,String id)async{if(fail)throw StateError('offline');seen.add('$uid/$id');}}
void main(){
 test('opens current registration and marks unread notification once',()async{final service=_Notifications();final c=ProviderContainer(overrides:[sessionViewModelProvider.overrideWith(_Session.new),notificationServiceProvider.overrideWithValue(service)]);addTearDown(c.dispose);final listener=c.listen(notificationsActionProvider,(_,_){});addTearDown(listener.close);final vm=c.read(notificationsActionProvider.notifier);const n=AppNotification(id:'n',title:'T',body:'B',eventId:'e',type:'register',registrationId:'r');expect(await vm.open(n),'/registrations/r');expect(service.seen,['u/n']);final read=AppNotification(id:'n',title:'T',body:'B',eventId:'e',type:'register',registrationId:'r',readAt:DateTime.utc(2026));await vm.open(read);expect(service.seen,hasLength(1));});
 test('mark-read failure preserves navigation and reports safe feedback',()async{final service=_Notifications()..fail=true;final c=ProviderContainer(overrides:[sessionViewModelProvider.overrideWith(_Session.new),notificationServiceProvider.overrideWithValue(service)]);addTearDown(c.dispose);final listener=c.listen(notificationsActionProvider,(_,_){});addTearDown(listener.close);expect(await c.read(notificationsActionProvider.notifier).open(const AppNotification(id:'n',title:'T',body:'B',eventId:'e',type:'event')),'/events/e');expect(c.read(notificationsActionProvider),contains('Chưa đánh dấu'));});
}
