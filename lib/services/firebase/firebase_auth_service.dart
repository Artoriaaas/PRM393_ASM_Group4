import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase;
import 'package:google_sign_in/google_sign_in.dart';

import 'package:eventhub_core/eventhub_core.dart';

class FirebaseAuthService implements AuthService {
  FirebaseAuthService(this._auth, [this._firestore]);

  final firebase.FirebaseAuth _auth;
  final FirebaseFirestore? _firestore;
  AuthStateSignedIn? _cachedSignedIn;

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
    if (_firestore != null) {
      await _firestore.collection('users').doc(user.uid).update({
        'displayName': name.trim(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
  });

  final _google = GoogleSignIn.instance;
  Future<void>? _googleInitialization;

  AuthState _mapSync(firebase.User? user) {
    if (user == null) {
      _cachedSignedIn = null;
      return const AuthState.signedOut();
    }
    if (!user.emailVerified) {
      _cachedSignedIn = null;
      return AuthState.unverified(uid: user.uid, email: user.email ?? '');
    }
    if (_cachedSignedIn?.uid == user.uid) {
      return _cachedSignedIn!;
    }
    if (_firestore != null) {
      return const AuthState.restoring();
    }
    return AuthState.signedIn(
      uid: user.uid,
      email: user.email ?? '',
      displayName: user.displayName,
    );
  }

  Future<AuthState> _mapAsync(firebase.User? user) async {
    if (user == null) {
      _cachedSignedIn = null;
      return const AuthState.signedOut();
    }
    if (!user.emailVerified) {
      _cachedSignedIn = null;
      return AuthState.unverified(uid: user.uid, email: user.email ?? '');
    }
    final db = _firestore;
    if (db == null) {
      final state = AuthStateSignedIn(
        uid: user.uid,
        email: user.email ?? '',
        displayName: user.displayName,
      );
      _cachedSignedIn = state;
      return state;
    }

    try {
      final userRef = db.collection('users').doc(user.uid);
      final snap = await userRef.get();
      String role = 'user';
      String? clubId;
      String? profileName;

      if (!snap.exists || snap.data() == null) {
        await userRef.set({
          'role': 'user',
          'displayName': user.displayName ?? '',
          'email': user.email ?? '',
          'createdAt': FieldValue.serverTimestamp(),
        });
      } else {
        final data = snap.data()!;
        role = data['role'] as String? ?? 'user';
        clubId = data['clubId'] as String?;
        final storedName = data['displayName'] as String?;
        if (storedName != null && storedName.trim().isNotEmpty) {
          profileName = storedName.trim();
        }
      }

      final resolved = AuthStateSignedIn(
        uid: user.uid,
        email: user.email ?? '',
        displayName: profileName ?? user.displayName,
        role: role,
        clubId: clubId,
      );
      _cachedSignedIn = resolved;
      return resolved;
    } catch (_) {
      final fallback = AuthStateSignedIn(
        uid: user.uid,
        email: user.email ?? '',
        displayName: user.displayName,
      );
      _cachedSignedIn = fallback;
      return fallback;
    }
  }

  @override
  AuthState get currentAuthState => _mapSync(_auth.currentUser);

  @override
  Stream<AuthState> get authStateChanges =>
      _auth.userChanges().asyncMap(_mapAsync);

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
    await _auth.signInWithEmailAndPassword(email: email, password: password);
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
    await _auth.signInWithCredential(
      firebase.GoogleAuthProvider.credential(idToken: idToken),
    );
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
    _cachedSignedIn = null;
    await _auth.signOut();
    try {
      await _google.signOut();
    } catch (_) {
      /* Firebase session already cleared. */
    }
  });
}
