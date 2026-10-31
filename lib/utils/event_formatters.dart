import '../models/event.dart';

String eventDate(DateTime date) {
  final d = date.toUtc().add(const Duration(hours: 7));
  String z(int n) => n.toString().padLeft(2, '0');
  return '${z(d.day)}/${z(d.month)}/${d.year}';
}

String eventTime(DateTime date) {
  final d = date.toUtc().add(const Duration(hours: 7));
  return '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
}

String eventWhen(Event e) =>
    '${eventTime(e.startsAt)}–${eventTime(e.endsAt)} · ${eventDate(e.startsAt)}';
