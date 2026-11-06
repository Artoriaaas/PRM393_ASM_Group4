import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:eventhub_core/eventhub_core.dart';
import 'web_contracts.dart';

class FirebaseWebAuthService implements IWebAuthService {
  FirebaseWebAuthService({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  WebUserProfile? _cachedUser;

  @override
  WebUserProfile? get currentUser => _cachedUser;

  @override
  Stream<WebUserProfile?> authStateChanges() {
    return _auth.authStateChanges().asyncMap((user) async {
      if (user == null) {
        _cachedUser = null;
        return null;
      }
      final profile = await fetchProfile(user.uid);
      _cachedUser = profile;
      return profile;
    });
  }

  @override
  Future<WebUserProfile?> fetchProfile(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (!doc.exists) {
        final currentUser = _auth.currentUser;
        final initialProfile = {
          'role': 'user',
          'displayName': currentUser?.displayName ?? '',
          'email': currentUser?.email ?? '',
          'createdAt': FieldValue.serverTimestamp(),
        };
        await _firestore.collection('users').doc(uid).set(initialProfile);
        return WebUserProfile(
          uid: uid,
          email: currentUser?.email ?? '',
          displayName: currentUser?.displayName ?? '',
          role: 'user',
        );
      }
      return WebUserProfile.fromJson(uid, doc.data()!);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<Result<WebUserProfile>> signInWithGoogle() async {
    try {
      final provider = GoogleAuthProvider();
      provider.addScope('email');
      provider.addScope('profile');
      final cred = await _auth.signInWithPopup(provider);
      final user = cred.user;
      if (user == null) {
        return Result.failure(
          const AppFailure(
            code: 'auth_null_user',
            message: 'Đăng nhập Google không thành công.',
          ),
        );
      }
      final profile = await fetchProfile(user.uid);
      if (profile == null) {
        return Result.failure(
          const AppFailure(
            code: 'profile_load_failed',
            message: 'Không thể tải thông tin hồ sơ tài khoản.',
          ),
        );
      }
      return Result.success(profile);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'popup-closed-by-user' || e.code == 'cancelled') {
        return Result.failure(
          const AppFailure(
            code: 'popup_cancelled',
            message: 'Bạn đã đóng cửa sổ đăng nhập Google.',
          ),
        );
      }
      return Result.failure(
        AppFailure(
          code: e.code,
          message: e.message ?? 'Đăng nhập Google thất bại.',
        ),
      );
    } catch (e) {
      return Result.failure(
        AppFailure(
          code: 'unknown_auth_error',
          message: 'Lỗi không xác định khi đăng nhập: $e',
        ),
      );
    }
  }

  @override
  Future<void> signOut() async {
    await _auth.signOut();
  }
}

class FirestoreClubService implements IClubService {
  FirestoreClubService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  @override
  Future<Club?> getClub(String clubId) async {
    final doc = await _firestore.collection('clubs').doc(clubId).get();
    if (!doc.exists) return null;
    return Club.fromJson(clubId, doc.data()!);
  }

  @override
  Stream<List<Event>> streamClubEvents(String clubId) {
    return _firestore
        .collection('events')
        .where('clubId', isEqualTo: clubId)
        .snapshots()
        .map((snap) => snap.docs.map((doc) {
              final d = doc.data();
              return Event(
                id: doc.id,
                title: d['title'] as String? ?? '',
                clubName: d['clubName'] as String? ?? '',
                location: d['location'] as String? ?? '',
                startsAt: (d['startsAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
                endsAt: (d['endsAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
                deadline: (d['deadline'] as Timestamp?)?.toDate(),
                description: d['description'] as String? ?? '',
                coverKey: d['coverKey'] as String? ?? '',
                topic: d['topic'] as String? ?? '',
                audience: d['audience'] as String? ?? '',
                preparation: d['preparation'] as String? ?? '',
                activities: (d['activities'] as List<dynamic>?)
                        ?.map((e) => e.toString())
                        .toList() ??
                    const [],
                mode: d['registrationMode'] as String? ?? 'required',
                status: d['status'] as String? ?? 'draft',
                capacity: (d['capacity'] as num?)?.toInt() ?? 0,
                activeCount: (d['activeCount'] as num?)?.toInt() ?? 0,
                clubId: d['clubId'] as String? ?? clubId,
                visibility: d['visibility'] as String? ?? 'public',
                updatedAt: (d['updatedAt'] as Timestamp?)?.toDate(),
              );
            }).toList());
  }

  @override
  Future<Result<String>> createEvent(Event event) async {
    try {
      final docRef = _firestore.collection('events').doc(
            event.id.isEmpty ? null : event.id,
          );
      await docRef.set({
        'title': event.title.trim(),
        'clubId': event.clubId,
        'clubName': event.clubName,
        'location': event.location.trim(),
        'startsAt': Timestamp.fromDate(event.startsAt),
        'endsAt': Timestamp.fromDate(event.endsAt),
        if (event.deadline != null)
          'deadline': Timestamp.fromDate(event.deadline!),
        'description': event.description.trim(),
        'topic': event.topic.trim(),
        'audience': event.audience.trim(),
        'preparation': event.preparation.trim(),
        'activities': event.activities,
        'coverKey': event.coverKey,
        'registrationMode': event.mode,
        'visibility': event.visibility,
        'status': event.status,
        'capacity': event.capacity,
        'activeCount': event.activeCount,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return Result.success(docRef.id);
    } catch (e) {
      return Result.failure(
        AppFailure(code: 'create_event_error', message: 'Không thể tạo sự kiện: $e'),
      );
    }
  }

  @override
  Future<Result<void>> updateEvent(Event event) async {
    try {
      await _firestore.collection('events').doc(event.id).update({
        'title': event.title.trim(),
        'location': event.location.trim(),
        'startsAt': Timestamp.fromDate(event.startsAt),
        'endsAt': Timestamp.fromDate(event.endsAt),
        if (event.deadline != null)
          'deadline': Timestamp.fromDate(event.deadline!),
        'description': event.description.trim(),
        'topic': event.topic.trim(),
        'audience': event.audience.trim(),
        'preparation': event.preparation.trim(),
        'activities': event.activities,
        'coverKey': event.coverKey,
        'registrationMode': event.mode,
        'visibility': event.visibility,
        'status': event.status,
        'capacity': event.capacity,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return Result.success(null);
    } catch (e) {
      return Result.failure(
        AppFailure(code: 'update_event_error', message: 'Không thể cập nhật sự kiện: $e'),
      );
    }
  }

  @override
  Future<Result<void>> archiveEvent(String eventId) async {
    try {
      await _firestore.collection('events').doc(eventId).update({
        'status': 'archived',
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return Result.success(null);
    } catch (e) {
      return Result.failure(
        AppFailure(code: 'archive_event_error', message: 'Không thể lưu trữ sự kiện: $e'),
      );
    }
  }

  @override
  Future<Result<void>> cancelEvent(String eventId) async {
    try {
      await _firestore.collection('events').doc(eventId).update({
        'status': 'cancelled',
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return Result.success(null);
    } catch (e) {
      return Result.failure(
        AppFailure(code: 'cancel_event_error', message: 'Không thể hủy sự kiện: $e'),
      );
    }
  }

  @override
  Stream<CheckinSession?> streamCheckinSession(String eventId) {
    return _firestore
        .collection('checkinSessions')
        .doc(eventId)
        .snapshots()
        .map((doc) {
      if (!doc.exists || doc.data() == null) return null;
      return CheckinSession.fromJson(eventId, doc.data()!);
    });
  }

  @override
  Future<Result<void>> toggleCheckinSession({
    required String eventId,
    required String clubId,
    required bool open,
    required String staffUid,
  }) async {
    try {
      await _firestore.collection('checkinSessions').doc(eventId).set({
        'eventId': eventId,
        'clubId': clubId,
        'open': open,
        'updatedBy': staffUid,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      return Result.success(null);
    } catch (e) {
      return Result.failure(
        AppFailure(
          code: 'toggle_session_error',
          message: 'Không thể thay đổi trạng thái phiên điểm danh: $e',
        ),
      );
    }
  }

  @override
  Future<Result<String>> generateAndRotateQrToken({
    required String eventId,
    required String clubId,
    required String staffUid,
  }) async {
    try {
      final rand = Random.secure();
      final bytes = List<int>.generate(32, (_) => rand.nextInt(256));
      final rawToken = 'EVT_${eventId}_${base64UrlEncode(bytes)}';
      final qrHash = sha256.convert(utf8.encode(rawToken)).toString();

      await _firestore.collection('qrCredentials').doc(qrHash).set({
        'eventId': eventId,
        'clubId': clubId,
        'enabled': true,
        'createdBy': staffUid,
        'createdAt': FieldValue.serverTimestamp(),
      });

      return Result.success(rawToken);
    } catch (e) {
      return Result.failure(
        AppFailure(
          code: 'generate_qr_error',
          message: 'Không thể sinh mã QR: $e',
        ),
      );
    }
  }

  @override
  Stream<List<Registration>> streamEventRegistrations(String eventId) {
    return _firestore
        .collection('registrations')
        .where('eventId', isEqualTo: eventId)
        .snapshots()
        .map((snap) => snap.docs.map(_mapRegistrationDoc).toList());
  }

  @override
  Stream<List<Registration>> streamClubPendingRegistrations(String clubId) {
    return _firestore
        .collection('registrations')
        .where('clubId', isEqualTo: clubId)
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .map((snap) => snap.docs.map(_mapRegistrationDoc).toList());
  }

  @override
  Stream<List<Registration>> streamAllClubRegistrations(String clubId) {
    return _firestore
        .collection('registrations')
        .where('clubId', isEqualTo: clubId)
        .snapshots()
        .map((snap) => snap.docs.map(_mapRegistrationDoc).toList());
  }

  Registration _mapRegistrationDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? {};
    final pData = d['participant'] as Map<String, dynamic>? ?? {};
    return Registration(
      id: doc.id,
      eventId: d['eventId'] as String? ?? '',
      status: d['status'] as String? ?? 'pending',
      generation: (d['generation'] as num?)?.toInt() ?? 1,
      participant: Participant(
        name: pData['name'] as String? ?? '',
        email: pData['email'] as String? ?? '',
        group: pData['group'] as String? ?? 'student',
        cohort: pData['cohort'] as String? ?? '',
        organization: pData['organization'] as String? ?? '',
        phone: pData['phone'] as String? ?? '',
      ),
      uid: d['uid'] as String? ?? '',
      clubId: d['clubId'] as String? ?? '',
      checkInAt: (d['checkInAt'] as Timestamp?)?.toDate(),
      createdAt: (d['createdAt'] as Timestamp?)?.toDate(),
      reason: d['reason'] as String?,
      reviewedBy: d['reviewedBy'] as String?,
      reviewedAt: (d['reviewedAt'] as Timestamp?)?.toDate(),
      qrHash: d['qrHash'] as String?,
      lastOperationId: d['lastOperationId'] as String? ?? '',
    );
  }

  @override
  Future<Result<void>> approveRegistration({
    required String registrationId,
    required String eventId,
    required String studentUid,
    required String staffUid,
    String? note,
  }) async {
    try {
      final eventRef = _firestore.collection('events').doc(eventId);
      final regRef = _firestore.collection('registrations').doc(registrationId);
      final notifRef = _firestore
          .collection('users')
          .doc(studentUid)
          .collection('notifications')
          .doc();

      await _firestore.runTransaction((tx) async {
        final evSnap = await tx.get(eventRef);
        final regSnap = await tx.get(regRef);

        if (!evSnap.exists) {
          throw Exception('Không tìm thấy sự kiện.');
        }
        if (!regSnap.exists) {
          throw Exception('Không tìm thấy đơn đăng ký.');
        }

        final currentStatus = regSnap.data()?['status'] as String? ?? '';
        if (currentStatus != 'pending') {
          throw Exception('Đơn đăng ký không ở trạng thái chờ duyệt.');
        }

        final capacity = (evSnap.data()?['capacity'] as num?)?.toInt() ?? 0;
        final activeCount = (evSnap.data()?['activeCount'] as num?)?.toInt() ?? 0;

        if (activeCount >= capacity) {
          throw Exception('Sự kiện đã hết chỗ, không thể duyệt thêm.');
        }

        // 1. Update registration
        tx.update(regRef, {
          'status': 'approved',
          'reason': note,
          'reviewedBy': staffUid,
          'reviewedAt': FieldValue.serverTimestamp(),
        });

        // 2. Increment activeCount
        tx.update(eventRef, {
          'activeCount': FieldValue.increment(1),
          'updatedAt': FieldValue.serverTimestamp(),
        });

        // 3. Create inbox notification
        tx.set(notifRef, {
          'title': 'Đơn đăng ký đã được duyệt!',
          'body': 'Đơn tham gia sự kiện của bạn đã được Trưởng CLB phê duyệt.',
          'type': 'registration_approved',
          'eventId': eventId,
          'registrationId': registrationId,
          'createdAt': FieldValue.serverTimestamp(),
          'readAt': null,
        });
      });

      return Result.success(null);
    } catch (e) {
      return Result.failure(
        AppFailure(
          code: 'approve_transaction_error',
          message: e.toString().replaceFirst('Exception: ', ''),
        ),
      );
    }
  }

  @override
  Future<Result<void>> rejectRegistration({
    required String registrationId,
    required String studentUid,
    required String staffUid,
    required String reason,
  }) async {
    final trimmedReason = reason.trim();
    if (trimmedReason.length < 3 || trimmedReason.length > 300) {
      return Result.failure(
        const AppFailure(
          code: 'invalid_reason_length',
          message: 'Lý do từ chối bắt buộc từ 3 đến 300 ký tự.',
        ),
      );
    }

    try {
      final regRef = _firestore.collection('registrations').doc(registrationId);
      final notifRef = _firestore
          .collection('users')
          .doc(studentUid)
          .collection('notifications')
          .doc();

      final batch = _firestore.batch();

      batch.update(regRef, {
        'status': 'rejected',
        'reason': trimmedReason,
        'reviewedBy': staffUid,
        'reviewedAt': FieldValue.serverTimestamp(),
      });

      batch.set(notifRef, {
        'title': 'Đơn đăng ký không được duyệt',
        'body': trimmedReason,
        'type': 'registration_rejected',
        'eventId': regRef.id.contains('_') ? regRef.id.split('_').last : '',
        'registrationId': registrationId,
        'createdAt': FieldValue.serverTimestamp(),
        'readAt': null,
      });

      await batch.commit();
      return Result.success(null);
    } catch (e) {
      return Result.failure(
        AppFailure(
          code: 'reject_error',
          message: 'Không thể từ chối đơn: $e',
        ),
      );
    }
  }

  @override
  Future<int> countPublishedEvents(String clubId) async {
    try {
      final snap = await _firestore
          .collection('events')
          .where('clubId', isEqualTo: clubId)
          .where('status', isEqualTo: 'published')
          .count()
          .get();
      return snap.count ?? 0;
    } catch (_) {
      return 0;
    }
  }

  @override
  Future<int> countPendingRegistrations(String clubId) async {
    try {
      final snap = await _firestore
          .collection('registrations')
          .where('clubId', isEqualTo: clubId)
          .where('status', isEqualTo: 'pending')
          .count()
          .get();
      return snap.count ?? 0;
    } catch (_) {
      return 0;
    }
  }

  @override
  Future<int> countApprovedRegistrations(String clubId) async {
    try {
      final snap = await _firestore
          .collection('registrations')
          .where('clubId', isEqualTo: clubId)
          .where('status', isEqualTo: 'approved')
          .count()
          .get();
      return snap.count ?? 0;
    } catch (_) {
      return 0;
    }
  }

  @override
  Future<int> countCheckedInRegistrations(String clubId) async {
    try {
      final snap = await _firestore
          .collection('registrations')
          .where('clubId', isEqualTo: clubId)
          .where('checkInAt', isNull: false)
          .count()
          .get();
      return snap.count ?? 0;
    } catch (_) {
      return 0;
    }
  }

  @override
  Stream<List<Announcement>> streamClubAnnouncements(String clubId) {
    return _firestore
        .collection('announcements')
        .where('clubId', isEqualTo: clubId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((doc) {
              return Announcement.fromJson(doc.id, doc.data());
            }).toList());
  }

  @override
  Future<Result<String>> publishAnnouncement(Announcement announcement) async {
    try {
      final ref = _firestore.collection('announcements').doc();
      await ref.set({
        'title': announcement.title.trim(),
        'body': announcement.body.trim(),
        'scope': announcement.scope,
        'clubId': announcement.clubId,
        'clubName': announcement.clubName,
        if (announcement.eventId != null && announcement.eventId!.isNotEmpty)
          'eventId': announcement.eventId,
        'authorUid': announcement.authorUid,
        'authorRole': announcement.authorRole,
        'createdAt': FieldValue.serverTimestamp(),
      });
      return Result.success(ref.id);
    } catch (e) {
      return Result.failure(
        AppFailure(
          code: 'publish_announcement_error',
          message: 'Không thể gửi thông báo: $e',
        ),
      );
    }
  }
}

class FirebaseWebAnalyticsService implements IWebAnalyticsService {
  FirebaseWebAnalyticsService({FirebaseAnalytics? analytics})
      : _analytics = analytics ?? FirebaseAnalytics.instance;

  final FirebaseAnalytics _analytics;

  @override
  Future<void> logEvent(String name, [Map<String, Object>? parameters]) async {
    try {
      await _analytics.logEvent(name: name, parameters: parameters);
    } catch (_) {}
  }
}
