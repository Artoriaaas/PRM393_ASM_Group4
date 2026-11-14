import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:eventhub_core/eventhub_core.dart';

class ClubAssignment {
  const ClubAssignment({
    required this.email,
    required this.clubId,
    required this.clubName,
    required this.status,
    this.acceptedUid,
  });
  final String email, clubId, clubName, status;
  final String? acceptedUid;
  factory ClubAssignment.fromJson(Map<String, dynamic> d) => ClubAssignment(
    email: d['email'] as String,
    clubId: d['clubId'] as String,
    clubName: d['clubName'] as String,
    status: d['status'] as String,
    acceptedUid: d['acceptedUid'] as String?,
  );
}

abstract class IClubAssignmentService {
  Stream<List<ClubAssignment>> watchAssignments();
  Future<Result<void>> assign({required String email, required Club club});
  Future<Result<void>> revoke(ClubAssignment assignment);
}

class FirestoreClubAssignmentService implements IClubAssignmentService {
  FirestoreClubAssignmentService({
    required FirebaseFirestore firestore,
    required FirebaseAuth auth,
  }) : _db = firestore,
       _auth = auth;
  final FirebaseFirestore _db;
  final FirebaseAuth _auth;
  static String normalizeEmail(String email) => email.trim().toLowerCase();
  static bool validEmail(String email) =>
      email.length <= 254 &&
      RegExp(r'^[a-z0-9.!#$%&*+?^_`{|}~=-]+@[a-z0-9-]+(?:\.[a-z0-9-]+)+$')
          .hasMatch(email);
  @override
  Stream<List<ClubAssignment>> watchAssignments() => _db
      .collection('clubAssignments')
      .snapshots()
      .map(
        (s) =>
            s.docs.map((d) => ClubAssignment.fromJson(d.data())).toList()
              ..sort((a, b) => a.email.compareTo(b.email)),
      );
  @override
  Future<Result<void>> assign({
    required String email,
    required Club club,
  }) async {
    final normalized = normalizeEmail(email);
    if (!validEmail(normalized) ||
        !club.isActive ||
        normalized == normalizeEmail(_auth.currentUser?.email ?? '')) {
      return const Failure(
        AppFailure(
          code: 'invalid_assignment',
          message: 'Nhập email hợp lệ của người đại diện khác và chọn CLB đang hoạt động.',
        ),
      );
    }
    try {
      // Existing managers from before email assignments must be removed first.
      final managers = await _db.collection('users').get();
      if (managers.docs.any(
        (d) =>
            (d.data()['role'] == 'staff' && d.data()['clubId'] == club.id) ||
            (normalizeEmail(d.data()['email'] as String? ?? '') == normalized &&
                d.data()['role'] != 'user'),
      )) {
        return const Failure(
          AppFailure(
            code: 'manager_exists',
            message: 'CLB hoặc email đã có phân công đang hoạt động. Thu hồi quyền cũ trước.',
          ),
        );
      }
      final target = _db.collection('clubAssignments').doc(normalized);
      final slot = _db.collection('clubManagerSlots').doc(club.id);
      await _db.runTransaction((tx) async {
        final existing = await tx.get(target);
        final reserved = await tx.get(slot);
        if ((existing.exists && existing.data()?['status'] != 'revoked') ||
            reserved.exists) {
          throw StateError('Phân công đã tồn tại. Thu hồi phân công cũ trước.');
        }
        tx.set(target, {
          'email': normalized,
          'clubId': club.id,
          'clubName': club.name,
          'status': 'pending',
          'createdBy': _auth.currentUser!.uid,
          'createdAt': FieldValue.serverTimestamp(),
        });
        tx.set(slot, {'email': normalized});
      });
      return const Success(null);
    } on StateError catch (e) {
      return Result.failure(
        AppFailure(code: 'assignment_conflict', message: e.message.toString()),
      );
    } catch (_) {
      return const Failure(
        AppFailure(
          code: 'assignment_failed',
          message:
              'Chưa lưu được phân công. Kiểm tra quyền và kết nối rồi thử lại.',
          isRetryable: true,
        ),
      );
    }
  }

  @override
  Future<Result<void>> revoke(ClubAssignment assignment) async {
    try {
      final target = _db.collection('clubAssignments').doc(assignment.email);
      await _db.runTransaction((tx) async {
        final snapshot = await tx.get(target);
        final data = snapshot.data();
        if (data == null || data['status'] == 'revoked') return;
        final uid = data['acceptedUid'] as String?;
        final profile = uid == null
            ? null
            : await tx.get(_db.collection('users').doc(uid));
        tx.update(target, {
          'status': 'revoked',
          'revokedAt': FieldValue.serverTimestamp(),
          'revokedBy': _auth.currentUser!.uid,
        });
        tx.delete(
          _db.collection('clubManagerSlots').doc(data['clubId'] as String),
        );
        if (profile?.data()?['role'] == 'staff' &&
            profile?.data()?['clubId'] == data['clubId']) {
          tx.update(profile!.reference, {
            'role': 'user',
            'clubId': null,
            'clubName': null,
            'updatedAt': FieldValue.serverTimestamp(),
          });
        }
      });
      return const Success(null);
    } catch (_) {
      return const Failure(
        AppFailure(
          code: 'revoke_failed',
          message: 'Chưa thu hồi được phân công. Hãy thử lại.',
          isRetryable: true,
        ),
      );
    }
  }

  /// Called only for the Firebase-authenticated, verified email, never form input.
  Future<void> activateForCurrentUser() async {
    final user = _auth.currentUser;
    if (user == null || !user.emailVerified || user.email == null) return;
    final target = _db
        .collection('clubAssignments')
        .doc(normalizeEmail(user.email!));
    final profile = _db.collection('users').doc(user.uid);
    await _db.runTransaction((tx) async {
      final invitation = await tx.get(target);
      final data = invitation.data();
      if (data == null || data['status'] != 'pending') return;
      final current = await tx.get(profile);
      if (current.data()?['role'] != 'user') return;
      final club = await tx.get(
        _db.collection('clubs').doc(data['clubId'] as String),
      );
      if (club.data()?['status'] != 'active') return;
      tx.update(profile, {
        'role': 'staff',
        'clubId': data['clubId'],
        'clubName': data['clubName'],
        'updatedAt': FieldValue.serverTimestamp(),
      });
      tx.update(target, {
        'status': 'accepted',
        'acceptedUid': user.uid,
        'acceptedAt': FieldValue.serverTimestamp(),
      });
    });
  }
}
