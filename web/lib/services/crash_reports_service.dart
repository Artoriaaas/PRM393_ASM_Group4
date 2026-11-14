import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

class CrashReportPage {
  const CrashReportPage(this.events, this.nextPageToken);
  final List<Map<String, dynamic>> events;
  final String? nextPageToken;
}

/// Reads processed Crashlytics events, never client-created Firestore mirrors.
class CrashReportsService {
  CrashReportsService({http.Client? client})
    : _client = client ?? http.Client();
  final http.Client _client;
  String? _accessToken;
  String? _uid;

  Future<void> authorize() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw StateError('Bạn cần đăng nhập lại.');
    final provider = GoogleAuthProvider()
      ..addScope('https://www.googleapis.com/auth/firebase')
      ..setCustomParameters({'login_hint': user.email ?? ''});
    final result = await user.reauthenticateWithPopup(provider);
    _accessToken = result.credential?.accessToken;
    _uid = user.uid;
    if (_accessToken == null)
      throw StateError('Chưa cấp quyền đọc Crashlytics.');
  }

  Future<CrashReportPage> load({String? pageToken}) async {
    if (_accessToken == null ||
        _uid != FirebaseAuth.instance.currentUser?.uid) {
      throw StateError('Chọn Kết nối Google để cấp quyền xem Crashlytics.');
    }
    final uri = Uri.https(
      'firebasecrashlytics.googleapis.com',
      '/v1alpha/projects/eventhub-group4/apps/1:218815401893:android:c3166be3181a746c53a24c/events',
      {
        'pageSize': '25',
        'readMask': 'eventId,eventTime,receivedTime,issueTitle,issueSubtitle,issue,version,device,platform',
        if (pageToken != null) 'pageToken': pageToken,
      },
    );
    final response = await _client
        .get(uri, headers: {'Authorization': 'Bearer $_accessToken'})
        .timeout(const Duration(seconds: 30));
    if (response.statusCode == 401) {
      _accessToken = null;
      throw StateError('Quyền Google đã hết hạn. Chọn Kết nối Google lại.');
    }
    if (response.statusCode == 403) {
      throw StateError(
        'Tài khoản Google chưa có quyền xem Crashlytics của project hoặc API chưa bật. Nhờ chủ project cấp vai trò Firebase Crashlytics Viewer.',
      );
    }
    if (response.statusCode != 200) {
      throw StateError(
        'Chưa tải được Crashlytics (HTTP ${response.statusCode}). Thử lại sau.',
      );
    }
    return parse(response.body);
  }

  static CrashReportPage parse(String body) {
    final data = jsonDecode(body) as Map<String, dynamic>;
    return CrashReportPage(
      (data['events'] as List? ?? [])
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList(),
      data['nextPageToken'] as String?,
    );
  }

  void dispose() {
    _accessToken = null;
    _uid = null;
    _client.close();
  }
}
