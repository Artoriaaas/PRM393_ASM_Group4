import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase;
import 'package:google_sign_in/google_sign_in.dart';

import '../../models/auth_state.dart';
import '../../utils/app_failure.dart';
import '../contracts/auth_service.dart';

class FirebaseAuthService implements AuthService {
  FirebaseAuthService(
    this._auth, [
    FirebaseFirestore? firestore,
  ]) : _firestore = firestore ?? FirebaseFirestore.instance {
    if (_auth.currentUser != null) {
      unawaited(_syncUserToFirestore(_auth.currentUser));
    }
  }

  final firebase.FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  @override
  bool get canChangeEmail =>
      _auth.currentUser?.providerData.any((p) => p.providerId == 'password') ??
      false;

  @override
  Future<void> updateName(String name) => _run(() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw const AppFailure(
        code: 'signed-out',
        message: 'Vui lòng đăng nhập lại.',
      );
    }
    await user.updateDisplayName(name);
    try {
      final docRef = _firestore.collection('users').doc(user.uid);
      final doc = await docRef.get();
      final trimmedName =
          name.trim().length > 120 ? name.trim().substring(0, 120) : name.trim();
      if (doc.exists) {
        await docRef.update({
          'displayName': trimmedName,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      } else {
        await docRef.set({
          'role': 'user',
          'displayName': trimmedName,
          'email': user.email ?? '',
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (_) {
      /* Firestore sync error shouldn't block local auth */
    }
  });

  Future<void> _syncUserToFirestore(
    firebase.User? user, {
    String? defaultName,
  }) async {
    if (user == null) return;
    try {
      final docRef = _firestore.collection('users').doc(user.uid);
      final doc = await docRef.get();
      if (!doc.exists || doc.data() == null) {
        final rawName = (user.displayName != null &&
                user.displayName!.trim().isNotEmpty)
            ? user.displayName!.trim()
            : ((defaultName != null && defaultName.trim().isNotEmpty)
                ? defaultName.trim()
                : (user.email?.split('@').first ?? ''));
        final trimmedName =
            rawName.length > 120 ? rawName.substring(0, 120) : rawName;
        final email = (user.email ?? '').trim();
        final trimmedEmail =
            email.length > 254 ? email.substring(0, 254) : email;

        await docRef.set({
          'role': 'user',
          'displayName': trimmedName,
          'email': trimmedEmail,
          'createdAt': FieldValue.serverTimestamp(),
        });
      } else {
        final data = doc.data()!;
        final currentFirestoreName = data['displayName'] as String? ?? '';
        final currentFirestoreEmail = data['email'] as String? ?? '';
        final newName = user.displayName?.trim();
        final newEmail = user.email?.trim();

        final updates = <String, dynamic>{};
        if (currentFirestoreName.isEmpty &&
            newName != null &&
            newName.isNotEmpty) {
          updates['displayName'] =
              newName.length > 120 ? newName.substring(0, 120) : newName;
        }
        if (currentFirestoreEmail.isEmpty &&
            newEmail != null &&
            newEmail.isNotEmpty) {
          updates['email'] =
              newEmail.length > 254 ? newEmail.substring(0, 254) : newEmail;
        }
        if (updates.isNotEmpty) {
          updates['updatedAt'] = FieldValue.serverTimestamp();
          await docRef.update(updates);
        }
      }
    } catch (_) {
      /* Silently ignore sync failures on startup/network offline */
    }
  }

  final _google = GoogleSignIn.instance;
  Future<void>? _googleInitialization;

  AuthState _map(firebase.User? user) {
    if (user == null) return const AuthState.signedOut();
    if (!user.emailVerified) {
      return AuthState.unverified(uid: user.uid, email: user.email ?? '');
    }
    return AuthState.signedIn(
      uid: user.uid,
      email: user.email ?? '',
      displayName: user.displayName,
    );
  }

  @override
  AuthState get currentAuthState => _map(_auth.currentUser);
  @override
  Stream<AuthState> get authStateChanges => _auth.userChanges().map(_map);

  Future<void> _run(Future<void> Function() action) async {
    try {
      await action();
    } on firebase.FirebaseAuthException catch (e) {
      final message = switch (e.code) {
        'network-request-failed' =>
          'Không thể kết nối. Thông tin đã nhập được giữ nguyên; hãy thử lại.',
        'too-many-requests' =>
          'Bạn thao tác quá nhanh. Vui lòng chờ rồi thử lại.',
        'weak-password' =>
          'Mật khẩu chưa đáp ứng chính sách bảo mật của hệ thống.',
        'invalid-email' => 'Vui lòng nhập email đúng định dạng.',
        'operation-not-allowed' =>
          'Phương thức đăng nhập chưa được bật trên Firebase của nhóm.',
        'requires-recent-login' =>
          'Vui lòng đăng nhập lại trước khi đổi email.',
        'account-exists-with-different-credential' =>
          'Hãy đăng nhập bằng phương thức đã dùng trước đó. Tài khoản chưa được tự liên kết.',
        _ => 'Chưa thể hoàn tất. Kiểm tra thông tin, sửa nếu cần rồi thử lại.',
      };
      throw AppFailure(code: e.code, message: message, isRetryable: true);
    } on GoogleSignInException catch (e) {
      throw AppFailure(
        code: e.code.name,
        message: e.code == GoogleSignInExceptionCode.canceled
            ? 'Bạn đã hủy đăng nhập Google.'
            : 'Chưa thể đăng nhập Google. Kiểm tra kết nối và cấu hình rồi thử lại.',
        isRetryable: true,
      );
    }
  }

  @override
  Future<void> signIn(String email, String password) => _run(() async {
    final cred = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    await _syncUserToFirestore(cred.user);
  });
  @override
  Future<void> signInWithGoogle() => _run(() async {
    await (_googleInitialization ??= _google.initialize());
    final account = await _google.authenticate();
    final idToken = account.authentication.idToken;
    if (idToken == null) {
      throw const AppFailure(
        code: 'missing-token',
        message: 'Google chưa trả thông tin xác thực. Vui lòng thử lại.',
      );
    }
    final cred = await _auth.signInWithCredential(
      firebase.GoogleAuthProvider.credential(idToken: idToken),
    );
    await _syncUserToFirestore(cred.user);
  });
  @override
  Future<void> register(String name, String email, String password) =>
      _run(() async {
        final result = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
        await result.user!.updateDisplayName(name);
        await result.user!.sendEmailVerification();
        await _syncUserToFirestore(result.user, defaultName: name);
      });
  @override
  Future<void> sendVerification() => _run(() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw const AppFailure(
        code: 'signed-out',
        message: 'Vui lòng đăng nhập lại.',
      );
    }
    await user.sendEmailVerification();
  });
  @override
  Future<void> reloadUser() => _run(() async {
    await _auth.currentUser?.reload();
    await _auth.currentUser?.getIdToken(true);
    if (_auth.currentUser != null) {
      await _syncUserToFirestore(_auth.currentUser);
    }
  });
  @override
  Future<void> resetPassword(String email) =>
      _run(() => _auth.sendPasswordResetEmail(email: email));
  @override
  Future<void> changeEmail(String email, String password) => _run(() async {
    final user = _auth.currentUser;
    if (user == null || user.email == null) {
      throw const AppFailure(
        code: 'signed-out',
        message: 'Vui lòng đăng nhập lại.',
      );
    }
    await user.reauthenticateWithCredential(
      firebase.EmailAuthProvider.credential(
        email: user.email!,
        password: password,
      ),
    );
    await user.verifyBeforeUpdateEmail(email);
  });
  @override
  Future<void> signOut() => _run(() async {
    await _auth.signOut();
    try {
      await _google.signOut();
    } catch (_) {
      /* Firebase session already cleared. */
    }
  });
}
