import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:eventhub_core/eventhub_core.dart';

import 'web_contracts.dart';

class FirebaseWebAuthService implements IWebAuthService {
  FirebaseWebAuthService({FirebaseAuth? auth, FirebaseFirestore? firestore})
    : _auth = auth ?? FirebaseAuth.instance,
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
      final result = await fetchProfile(user.uid);
      return result.when(
        success: (profile) {
          _cachedUser = profile;
          return profile;
        },
        failure: (failure) {
          _cachedUser = null;
          throw failure;
        },
      );
    });
  }

  @override
  Future<Result<WebUserProfile>> fetchProfile(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (!doc.exists || doc.data() == null) {
        final authUser = _auth.currentUser;
        final initialProfile = {
          'role': 'user',
          'displayName': authUser?.displayName ?? '',
          'email': authUser?.email ?? '',
          'createdAt': FieldValue.serverTimestamp(),
        };
        await _firestore.collection('users').doc(uid).set(initialProfile);
        return Result.success(
          WebUserProfile(
            uid: uid,
            email: authUser?.email ?? '',
            displayName: authUser?.displayName ?? '',
            role: 'user',
          ),
        );
      }
      return Result.success(WebUserProfile.fromJson(uid, doc.data()!));
    } on FirebaseException catch (e) {
      return Result.failure(
        AppFailure(
          code: e.code,
          message:
              'Không thể đọc hồ sơ tài khoản (${e.code}). Kiểm tra quyền Firestore trên users/{uid}.',
          isRetryable: true,
        ),
      );
    } catch (e) {
      return Result.failure(
        AppFailure(
          code: 'profile_load_failed',
          message: 'Không thể tải thông tin hồ sơ tài khoản: $e',
          isRetryable: true,
        ),
      );
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
            isRetryable: true,
          ),
        );
      }
      final profileResult = await fetchProfile(user.uid);
      profileResult.when(
        success: (p) => _cachedUser = p,
        failure: (_) => _cachedUser = null,
      );
      return profileResult;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'popup-closed-by-user' ||
          e.code == 'cancelled-popup-request' ||
          e.code == 'cancelled') {
        return Result.failure(
          const AppFailure(
            code: 'popup_cancelled',
            message: 'Bạn đã đóng cửa sổ đăng nhập Google.',
            isRetryable: true,
          ),
        );
      }
      if (e.code == 'network-request-failed') {
        return Result.failure(
          const AppFailure(
            code: 'network_error',
            message: 'Mất kết nối mạng khi xác thực Google. Vui lòng thử lại.',
            isRetryable: true,
          ),
        );
      }
      return Result.failure(
        AppFailure(
          code: e.code,
          message: e.message ?? 'Đăng nhập Google thất bại.',
          isRetryable: true,
        ),
      );
    } catch (e) {
      return Result.failure(
        AppFailure(
          code: 'unknown_auth_error',
          message: 'Lỗi không xác định khi đăng nhập: $e',
          isRetryable: true,
        ),
      );
    }
  }

  @override
  Future<void> signOut() async {
    _cachedUser = null;
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
    if (!doc.exists || doc.data() == null) return null;
    return Club.fromJson(clubId, doc.data()!);
  }

  Event _mapEventDoc(
    DocumentSnapshot<Map<String, dynamic>> doc, {
    String fallbackClubId = '',
  }) {
    final d = doc.data() ?? const <String, dynamic>{};
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
      coverUrl: d['coverUrl'] as String? ?? '',
      topic: d['topic'] as String? ?? '',
      audience: d['audience'] as String? ?? '',
      preparation: d['preparation'] as String? ?? '',
      activities:
          (d['activities'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      mode: d['registrationMode'] as String? ?? 'required',
      status: d['status'] as String? ?? 'draft',
      capacity: (d['capacity'] as num?)?.toInt() ?? 0,
      activeCount: (d['activeCount'] as num?)?.toInt() ?? 0,
      clubId: d['clubId'] as String? ?? fallbackClubId,
      visibility: d['visibility'] as String? ?? 'public',
      updatedAt: (d['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  @override
  Stream<List<Event>> streamClubEvents(String clubId) {
    return _firestore
        .collection('events')
        .where('clubId', isEqualTo: clubId)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((doc) => _mapEventDoc(doc, fallbackClubId: clubId))
              .toList(),
        );
  }

  @override
  Stream<Event?> streamEvent(String eventId) {
    return _firestore.collection('events').doc(eventId).snapshots().map((doc) {
      if (!doc.exists || doc.data() == null) return null;
      return _mapEventDoc(doc);
    });
  }

  @override
  Future<Result<String>> createEvent(Event event) async {
    try {
      final docRef = _firestore
          .collection('events')
          .doc(event.id.isEmpty ? null : event.id);
      await docRef.set({
        'title': event.title.trim(),
        'clubId': event.clubId,
        'clubName': event.clubName,
        'location': event.location.trim(),
        'startsAt': Timestamp.fromDate(event.startsAt),
        'endsAt': Timestamp.fromDate(event.endsAt),
        'deadline': event.mode == 'free' || event.deadline == null
            ? null
            : Timestamp.fromDate(event.deadline!),
        'description': event.description.trim(),
        'topic': event.topic.trim(),
        'audience': event.audience.trim(),
        'preparation': event.preparation.trim(),
        'activities': event.activities,
        'coverKey': event.coverKey,
        'registrationMode': event.mode,
        'visibility': event.visibility,
        'status': event.status,
        'capacity': event.mode == 'free' ? 0 : event.capacity,
        'activeCount': 0,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return Result.success(docRef.id);
    } catch (e) {
      return Result.failure(
        AppFailure(
          code: 'create_event_error',
          message: 'Không thể tạo sự kiện: $e',
          isRetryable: true,
        ),
      );
    }
  }

  @override
  Future<Result<void>> updateEvent(Event event) async {
    try {
      final docRef = _firestore.collection('events').doc(event.id);
      await _firestore.runTransaction((tx) async {
        final snap = await tx.get(docRef);
        if (!snap.exists) {
          throw const AppFailure(
            code: 'event_not_found',
            message: 'Không tìm thấy sự kiện cần cập nhật.',
          );
        }
        final currentActive =
            (snap.data()?['activeCount'] as num?)?.toInt() ?? 0;
        if (event.mode == 'required' && event.capacity < currentActive) {
          throw AppFailure(
            code: 'capacity_below_active',
            message:
                'Sức chứa (${event.capacity}) không được nhỏ hơn số lượt đã duyệt hiện tại ($currentActive).',
          );
        }
        tx.update(docRef, {
          'title': event.title.trim(),
          'location': event.location.trim(),
          'startsAt': Timestamp.fromDate(event.startsAt),
          'endsAt': Timestamp.fromDate(event.endsAt),
          'deadline': event.mode == 'free' || event.deadline == null
              ? null
              : Timestamp.fromDate(event.deadline!),
          'description': event.description.trim(),
          'topic': event.topic.trim(),
          'audience': event.audience.trim(),
          'preparation': event.preparation.trim(),
          'activities': event.activities,
          'coverKey': event.coverKey,
          'registrationMode': event.mode,
          'visibility': event.visibility,
          'status': event.status,
          'capacity': event.mode == 'free' ? 0 : event.capacity,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      });
      return const Success(null);
    } on AppFailure catch (f) {
      return Result.failure(f);
    } catch (e) {
      return Result.failure(
        AppFailure(
          code: 'update_event_error',
          message: 'Không thể cập nhật sự kiện: $e',
          isRetryable: true,
        ),
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
      return const Success(null);
    } catch (e) {
      return Result.failure(
        AppFailure(
          code: 'archive_event_error',
          message: 'Không thể lưu trữ sự kiện: $e',
          isRetryable: true,
        ),
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
      return const Success(null);
    } catch (e) {
      return Result.failure(
        AppFailure(
          code: 'cancel_event_error',
          message: 'Không thể hủy sự kiện: $e',
          isRetryable: true,
        ),
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
      return const Success(null);
    } catch (e) {
      return Result.failure(
        AppFailure(
          code: 'toggle_session_error',
          message: 'Không thể thay đổi trạng thái phiên điểm danh: $e',
          isRetryable: true,
        ),
      );
    }
  }

  @override
  Future<Result<QrTokenBundle>> generateAndRotateQrToken({
    required String eventId,
    required String clubId,
    required String staffUid,
    String? previousQrHash,
  }) async {
    try {
      final rand = Random.secure();
      final bytes = List<int>.generate(32, (_) => rand.nextInt(256));
      final encoded = base64UrlEncode(bytes).replaceAll('=', '');
      final rawToken = 'EVT_${eventId}_$encoded';
      final qrHash = sha256.convert(utf8.encode(rawToken)).toString();

      final batch = _firestore.batch();
      final disabledHashes = <String>{};

      if (previousQrHash != null && previousQrHash.isNotEmpty) {
        disabledHashes.add(previousQrHash);
        batch.update(
          _firestore.collection('qrCredentials').doc(previousQrHash),
          {'enabled': false},
        );
      }

      // Also disable any other active credentials for this event & club
      final activeSnap = await _firestore
          .collection('qrCredentials')
          .where('clubId', isEqualTo: clubId)
          .where('eventId', isEqualTo: eventId)
          .where('enabled', isEqualTo: true)
          .get();

      for (final doc in activeSnap.docs) {
        if (disabledHashes.add(doc.id)) {
          batch.update(doc.reference, {'enabled': false});
        }
      }

      batch.set(_firestore.collection('qrCredentials').doc(qrHash), {
        'eventId': eventId,
        'clubId': clubId,
        'enabled': true,
        'createdBy': staffUid,
        'createdAt': FieldValue.serverTimestamp(),
      });

      await batch.commit();

      return Result.success(QrTokenBundle(rawToken: rawToken, qrHash: qrHash));
    } catch (e) {
      return Result.failure(
        AppFailure(
          code: 'generate_qr_error',
          message: 'Không thể sinh hoặc làm mới mã QR: $e',
          isRetryable: true,
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
    final d = doc.data() ?? const <String, dynamic>{};
    final pData = d['participant'] as Map<String, dynamic>? ?? const {};
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
          throw const AppFailure(
            code: 'event_not_found',
            message: 'Không tìm thấy sự kiện.',
          );
        }
        if (!regSnap.exists) {
          throw const AppFailure(
            code: 'registration_not_found',
            message: 'Không tìm thấy đơn đăng ký.',
          );
        }

        final currentStatus = regSnap.data()?['status'] as String? ?? '';
        if (currentStatus != 'pending') {
          throw const AppFailure(
            code: 'not_pending',
            message: 'Đơn đăng ký không ở trạng thái chờ duyệt.',
          );
        }

        final capacity = (evSnap.data()?['capacity'] as num?)?.toInt() ?? 0;
        final activeCount =
            (evSnap.data()?['activeCount'] as num?)?.toInt() ?? 0;

        if (activeCount >= capacity) {
          throw const AppFailure(
            code: 'event_full',
            message: 'Sự kiện đã hết chỗ, không thể duyệt thêm.',
          );
        }

        tx.update(regRef, {
          'status': 'approved',
          'reason': note,
          'reviewedBy': staffUid,
          'reviewedAt': FieldValue.serverTimestamp(),
        });

        tx.update(eventRef, {
          'activeCount': currentActivePlusOne(activeCount),
          'updatedAt': FieldValue.serverTimestamp(),
        });

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

      return const Success(null);
    } on AppFailure catch (f) {
      return Result.failure(f);
    } catch (e) {
      return Result.failure(
        AppFailure(
          code: 'approve_transaction_error',
          message: 'Không thể phê duyệt đơn: $e',
          isRetryable: true,
        ),
      );
    }
  }

  int currentActivePlusOne(int activeCount) => activeCount + 1;

  @override
  Future<Result<void>> rejectRegistration({
    required String registrationId,
    required String eventId,
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

      await _firestore.runTransaction((tx) async {
        final regSnap = await tx.get(regRef);
        if (!regSnap.exists) {
          throw const AppFailure(
            code: 'registration_not_found',
            message: 'Không tìm thấy đơn đăng ký.',
          );
        }
        final currentStatus = regSnap.data()?['status'] as String? ?? '';
        if (currentStatus != 'pending') {
          throw const AppFailure(
            code: 'not_pending',
            message: 'Chỉ có thể từ chối đơn đang ở trạng thái chờ duyệt.',
          );
        }
        final resolvedEventId =
            regSnap.data()?['eventId'] as String? ?? eventId;

        tx.update(regRef, {
          'status': 'rejected',
          'reason': trimmedReason,
          'reviewedBy': staffUid,
          'reviewedAt': FieldValue.serverTimestamp(),
        });

        tx.set(notifRef, {
          'title': 'Đơn đăng ký không được duyệt',
          'body': trimmedReason,
          'type': 'registration_rejected',
          'eventId': resolvedEventId,
          'registrationId': registrationId,
          'createdAt': FieldValue.serverTimestamp(),
          'readAt': null,
        });
      });
      return const Success(null);
    } on AppFailure catch (f) {
      return Result.failure(f);
    } catch (e) {
      return Result.failure(
        AppFailure(
          code: 'reject_error',
          message: 'Không thể từ chối đơn: $e',
          isRetryable: true,
        ),
      );
    }
  }

  @override
  Future<int> countPublishedEvents(String clubId) async {
    final snap = await _firestore
        .collection('events')
        .where('clubId', isEqualTo: clubId)
        .where('status', isEqualTo: 'published')
        .count()
        .get();
    return snap.count ?? 0;
  }

  @override
  Future<int> countPendingRegistrations(String clubId) async {
    final snap = await _firestore
        .collection('registrations')
        .where('clubId', isEqualTo: clubId)
        .where('status', isEqualTo: 'pending')
        .count()
        .get();
    return snap.count ?? 0;
  }

  @override
  Future<int> countApprovedRegistrations(String clubId) async {
    final snap = await _firestore
        .collection('registrations')
        .where('clubId', isEqualTo: clubId)
        .where('status', isEqualTo: 'approved')
        .count()
        .get();
    return snap.count ?? 0;
  }

  @override
  Future<int> countCheckedInRegistrations(String clubId) async {
    final snap = await _firestore
        .collection('registrations')
        .where('clubId', isEqualTo: clubId)
        .where('checkInAt', isNull: false)
        .count()
        .get();
    return snap.count ?? 0;
  }

  @override
  Stream<List<Announcement>> streamClubAnnouncements(String clubId) {
    return _firestore
        .collection('announcements')
        .where('clubId', isEqualTo: clubId)
        .snapshots()
        .map((snap) {
          final list = snap.docs.map((doc) {
            final raw = doc.data();
            final ts = raw['createdAt'];
            return Announcement.fromJson(doc.id, {
              ...raw,
              if (ts is Timestamp) 'createdAt': ts.toDate(),
            });
          }).toList();
          list.sort((a, b) {
            final bTime = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
            final aTime = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
            return bTime.compareTo(aTime);
          });
          return list;
        });
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
          isRetryable: true,
        ),
      );
    }
  }
}

// Top-level helper để tái sử dụng giữa FirestoreClubService và FirestoreAdminService
Event mapEventDoc(
  DocumentSnapshot<Map<String, dynamic>> doc, {
  String fallbackClubId = '',
}) {
  final d = doc.data() ?? const <String, dynamic>{};
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
    coverUrl: d['coverUrl'] as String? ?? '',
    topic: d['topic'] as String? ?? '',
    audience: d['audience'] as String? ?? '',
    preparation: d['preparation'] as String? ?? '',
    activities:
        (d['activities'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        const [],
    mode: d['registrationMode'] as String? ?? 'required',
    status: d['status'] as String? ?? 'draft',
    capacity: (d['capacity'] as num?)?.toInt() ?? 0,
    activeCount: (d['activeCount'] as num?)?.toInt() ?? 0,
    clubId: d['clubId'] as String? ?? fallbackClubId,
    visibility: d['visibility'] as String? ?? 'public',
    updatedAt: (d['updatedAt'] as Timestamp?)?.toDate(),
  );
}

class FirestoreAdminService implements IAdminService {
  FirestoreAdminService({
    required FirebaseFirestore firestore,
    required FirebaseAuth auth,
  }) : _firestore = firestore,
       _auth = auth;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  // ── Quản lý người dùng ──────────────────────────────────────────────────────

  @override
  Stream<List<WebUserProfile>> streamAllUsers() {
    return _firestore
        .collection('users')
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((doc) => WebUserProfile.fromJson(doc.id, doc.data()))
              .toList(),
        );
  }

  @override
  Future<Result<void>> updateUserRole({
    required String targetUid,
    required String newRole,
    String? clubId,
    String? clubName,
  }) async {
    final currentUid = _auth.currentUser?.uid;
    if (currentUid != null && currentUid == targetUid) {
      return Result.failure(
        const AppFailure(
          code: 'self_role_change',
          message: 'Không thể thay đổi vai trò của chính mình.',
        ),
      );
    }
    try {
      final Map<String, dynamic> data = {
        'role': newRole,
        'updatedAt': FieldValue.serverTimestamp(),
      };
      if (newRole == 'staff') {
        data['clubId'] = clubId;
        data['clubName'] = clubName;
      } else {
        data['clubId'] = null;
        data['clubName'] = null;
      }
      await _firestore.collection('users').doc(targetUid).update(data);
      return const Success(null);
    } on FirebaseException catch (e) {
      return Result.failure(
        AppFailure(
          code: e.code,
          message: 'Không thể cập nhật vai trò người dùng (${e.code}).',
          isRetryable: true,
        ),
      );
    } catch (e) {
      return Result.failure(
        AppFailure(
          code: 'update_role_error',
          message: 'Lỗi khi cập nhật vai trò: $e',
          isRetryable: true,
        ),
      );
    }
  }

  // ── Quản lý CLB ─────────────────────────────────────────────────────────────

  @override
  Stream<List<Club>> streamAllClubs() {
    return _firestore
        .collection('clubs')
        .orderBy('name')
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((doc) => Club.fromJson(doc.id, doc.data()))
              .toList(),
        );
  }

  @override
  Future<Result<String>> createClub({
    required String name,
    String shortName = '',
    String description = '',
  }) async {
    try {
      final ref = _firestore.collection('clubs').doc();
      await ref.set({
        'name': name.trim(),
        'shortName': shortName.trim(),
        'description': description.trim(),
        'status': 'active',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return Result.success(ref.id);
    } on FirebaseException catch (e) {
      return Result.failure(
        AppFailure(
          code: e.code,
          message: 'Không thể tạo CLB (${e.code}).',
          isRetryable: true,
        ),
      );
    } catch (e) {
      return Result.failure(
        AppFailure(
          code: 'create_club_error',
          message: 'Lỗi khi tạo CLB: $e',
          isRetryable: true,
        ),
      );
    }
  }

  @override
  Future<Result<void>> updateClub(Club club) async {
    try {
      await _firestore.collection('clubs').doc(club.id).update({
        'name': club.name,
        'shortName': club.shortName,
        'description': club.description,
        'status': club.status,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return const Success(null);
    } on FirebaseException catch (e) {
      return Result.failure(
        AppFailure(
          code: e.code,
          message: 'Không thể cập nhật CLB (${e.code}).',
          isRetryable: true,
        ),
      );
    } catch (e) {
      return Result.failure(
        AppFailure(
          code: 'update_club_error',
          message: 'Lỗi khi cập nhật CLB: $e',
          isRetryable: true,
        ),
      );
    }
  }

  @override
  Future<Result<void>> archiveClub(String clubId) async {
    try {
      await _firestore.collection('clubs').doc(clubId).update({
        'status': 'archived',
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return const Success(null);
    } on FirebaseException catch (e) {
      return Result.failure(
        AppFailure(
          code: e.code,
          message: 'Không thể lưu trữ CLB (${e.code}).',
          isRetryable: true,
        ),
      );
    } catch (e) {
      return Result.failure(
        AppFailure(
          code: 'archive_club_error',
          message: 'Lỗi khi lưu trữ CLB: $e',
          isRetryable: true,
        ),
      );
    }
  }

  // ── Giám sát sự kiện toàn trường ────────────────────────────────────────────

  @override
  Stream<List<Event>> streamAllEvents() {
    return _firestore
        .collection('events')
        .snapshots()
        .map((snap) => snap.docs.map((doc) => mapEventDoc(doc)).toList());
  }

  @override
  Future<Result<void>> adminApproveEvent(String eventId) async {
    try {
      await _firestore.collection('events').doc(eventId).update({
        'status': 'published',
        'reviewedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return const Success(null);
    } on FirebaseException catch (e) {
      return Result.failure(
        AppFailure(
          code: e.code,
          message: 'Không thể phê duyệt sự kiện (${e.code}).',
          isRetryable: true,
        ),
      );
    } catch (e) {
      return Result.failure(
        AppFailure(
          code: 'admin_approve_event_error',
          message: 'Lỗi khi phê duyệt sự kiện: $e',
          isRetryable: true,
        ),
      );
    }
  }

  @override
  Future<Result<void>> adminRejectEvent(
    String eventId, {
    required String reason,
  }) async {
    try {
      await _firestore.collection('events').doc(eventId).update({
        'status': 'rejected',
        'rejectionReason': reason,
        'reviewedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return const Success(null);
    } on FirebaseException catch (e) {
      return Result.failure(
        AppFailure(
          code: e.code,
          message: 'Không thể từ chối sự kiện (${e.code}).',
          isRetryable: true,
        ),
      );
    } catch (e) {
      return Result.failure(
        AppFailure(
          code: 'admin_reject_event_error',
          message: 'Lỗi khi từ chối sự kiện: $e',
          isRetryable: true,
        ),
      );
    }
  }

  @override
  Future<int> countSystemPendingEvents() async {
    try {
      final snap = await _firestore
          .collection('events')
          .where('status', isEqualTo: 'pending_approval')
          .count()
          .get();
      return snap.count ?? 0;
    } catch (_) {
      return 0;
    }
  }

  @override
  Future<Result<void>> adminCancelEvent(String eventId) async {
    try {
      await _firestore.collection('events').doc(eventId).update({
        'status': 'cancelled',
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return const Success(null);
    } on FirebaseException catch (e) {
      return Result.failure(
        AppFailure(
          code: e.code,
          message: 'Không thể hủy sự kiện (${e.code}).',
          isRetryable: true,
        ),
      );
    } catch (e) {
      return Result.failure(
        AppFailure(
          code: 'admin_cancel_event_error',
          message: 'Lỗi khi hủy sự kiện: $e',
          isRetryable: true,
        ),
      );
    }
  }

  @override
  Future<Result<void>> adminArchiveEvent(String eventId) async {
    try {
      await _firestore.collection('events').doc(eventId).update({
        'status': 'archived',
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return const Success(null);
    } on FirebaseException catch (e) {
      return Result.failure(
        AppFailure(
          code: e.code,
          message: 'Không thể lưu trữ sự kiện (${e.code}).',
          isRetryable: true,
        ),
      );
    } catch (e) {
      return Result.failure(
        AppFailure(
          code: 'admin_archive_event_error',
          message: 'Lỗi khi lưu trữ sự kiện: $e',
          isRetryable: true,
        ),
      );
    }
  }

  // ── Giám sát đơn đăng ký toàn trường ───────────────────────────────────────

  @override
  Stream<List<Registration>> streamAllPendingRegistrations() {
    return _firestore
        .collection('registrations')
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .map(
          (snap) => snap.docs.map((doc) => _mapRegistrationDoc(doc)).toList(),
        );
  }

  Registration _mapRegistrationDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? const <String, dynamic>{};
    final pData = d['participant'] as Map<String, dynamic>? ?? const {};
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

  // ── Dashboard toàn trường ───────────────────────────────────────────────────

  @override
  Future<int> countSystemPublishedEvents() async {
    final snap = await _firestore
        .collection('events')
        .where('status', isEqualTo: 'published')
        .count()
        .get();
    return snap.count ?? 0;
  }

  @override
  Future<int> countSystemPendingRegistrations() async {
    final snap = await _firestore
        .collection('registrations')
        .where('status', isEqualTo: 'pending')
        .count()
        .get();
    return snap.count ?? 0;
  }

  @override
  Future<int> countSystemApprovedRegistrations() async {
    final snap = await _firestore
        .collection('registrations')
        .where('status', isEqualTo: 'approved')
        .count()
        .get();
    return snap.count ?? 0;
  }

  @override
  Future<int> countUsersByRole(String role) async {
    final snap = await _firestore
        .collection('users')
        .where('role', isEqualTo: role)
        .count()
        .get();
    return snap.count ?? 0;
  }

  @override
  Future<int> countActiveClubs() async {
    final snap = await _firestore
        .collection('clubs')
        .where('status', isEqualTo: 'active')
        .count()
        .get();
    return snap.count ?? 0;
  }

  @override
  Future<List<Map<String, Object>>> getClubEventStats() async {
    // Query tất cả events
    final eventsSnap = await _firestore.collection('events').get();

    // Group by clubId
    final Map<String, Map<String, Object>> statsMap = {};
    for (final doc in eventsSnap.docs) {
      final d = doc.data();
      final clubId = d['clubId'] as String? ?? '';
      final clubName = d['clubName'] as String? ?? clubId;
      final status = d['status'] as String? ?? '';

      statsMap.putIfAbsent(
        clubId,
        () => {
          'clubId': clubId,
          'clubName': clubName,
          'published': 0,
          'approved': 0,
          'checkedIn': 0,
        },
      );

      if (status == 'published') {
        statsMap[clubId]!['published'] =
            ((statsMap[clubId]!['published'] as int?) ?? 0) + 1;
      }
    }

    // Query approved + checkedIn registrations per club
    final approvedSnap = await _firestore
        .collection('registrations')
        .where('status', isEqualTo: 'approved')
        .get();
    for (final doc in approvedSnap.docs) {
      final d = doc.data();
      final clubId = d['clubId'] as String? ?? '';
      if (statsMap.containsKey(clubId)) {
        statsMap[clubId]!['approved'] =
            ((statsMap[clubId]!['approved'] as int?) ?? 0) + 1;
        if (d['checkInAt'] != null) {
          statsMap[clubId]!['checkedIn'] =
              ((statsMap[clubId]!['checkedIn'] as int?) ?? 0) + 1;
        }
      }
    }

    return statsMap.values.toList();
  }

  // ── Thông báo toàn trường ───────────────────────────────────────────────────

  @override
  Stream<List<Announcement>> streamAllAnnouncements() {
    return _firestore.collection('announcements').snapshots().map((snap) {
      final list = snap.docs.map((doc) {
        final raw = doc.data();
        final ts = raw['createdAt'];
        return Announcement.fromJson(doc.id, {
          ...raw,
          if (ts is Timestamp) 'createdAt': ts.toDate(),
        });
      }).toList();
      list.sort((a, b) {
        final bTime = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        final aTime = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        return bTime.compareTo(aTime);
      });
      return list;
    });
  }
}

class FirebaseWebAnalyticsService implements IWebAnalyticsService {
  FirebaseWebAnalyticsService({FirebaseAnalytics? analytics})
    : _analytics = analytics ?? FirebaseAnalytics.instance;

  final FirebaseAnalytics _analytics;

  @override
  Future<void> setUserId(String? uid) async {
    try {
      await _analytics.setUserId(id: uid);
    } catch (_) {}
  }

  @override
  Future<void> logEvent(String name, [Map<String, Object>? parameters]) async {
    try {
      await _analytics.logEvent(name: name, parameters: parameters);
    } catch (_) {}
  }
}

class FirebaseWebRemoteConfigService implements IWebRemoteConfigService {
  FirebaseWebRemoteConfigService({FirebaseRemoteConfig? remoteConfig})
    : _remoteConfig = remoteConfig ?? FirebaseRemoteConfig.instance;

  final FirebaseRemoteConfig _remoteConfig;

  @override
  Future<void> initialize() async {
    try {
      await _remoteConfig.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: const Duration(seconds: 15),
          minimumFetchInterval: const Duration(minutes: 5),
        ),
      );
      await _remoteConfig.setDefaults(const {
        'show_recommendations': true,
        'recommendation_limit': 10,
        'web_dashboard_recent_limit': 4,
        'web_dashboard_chart_limit': 5,
      });
      await _remoteConfig.fetchAndActivate();
    } catch (_) {
      // Safe fallback to local defaults when offline.
    }
  }

  @override
  bool getBool(String key, {bool defaultValue = false}) {
    try {
      return _remoteConfig.getBool(key);
    } catch (_) {
      return defaultValue;
    }
  }

  @override
  int getInt(String key, {int defaultValue = 0}) {
    try {
      return _remoteConfig.getInt(key);
    } catch (_) {
      return defaultValue;
    }
  }

  @override
  String getString(String key, {String defaultValue = ''}) {
    try {
      return _remoteConfig.getString(key);
    } catch (_) {
      return defaultValue;
    }
  }
}
