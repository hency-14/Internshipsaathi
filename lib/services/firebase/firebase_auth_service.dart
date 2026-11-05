import 'package:firebase_auth/firebase_auth.dart';

import '../auth_service.dart';

/// Authentication backed by Firebase Auth (email/password).
///
/// Only instantiated when [AppConfig.useFirebase] is true, so the demo build
/// never touches Firebase. It maps Firebase's [User] to our neutral
/// [AuthUser] and translates error codes into readable messages.
class FirebaseAuthService implements AuthService {
  FirebaseAuthService();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  AuthUser? _map(User? user) {
    if (user == null) return null;
    return AuthUser(
      uid: user.uid,
      email: user.email ?? '',
      displayName: user.displayName ?? '',
    );
  }

  @override
  AuthUser? get currentUser => _map(_auth.currentUser);

  @override
  Stream<AuthUser?> authState() =>
      _auth.authStateChanges().map(_map);

  @override
  Future<AuthUser> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final UserCredential cred = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      await cred.user?.updateDisplayName(name.trim());
      await cred.user?.reload();
      final AuthUser? mapped = _map(_auth.currentUser);
      if (mapped == null) throw const AuthException('Sign up failed.');
      return mapped;
    } on FirebaseAuthException catch (e) {
      throw AuthException(_message(e));
    }
  }

  @override
  Future<AuthUser> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final UserCredential cred = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final AuthUser? mapped = _map(cred.user);
      if (mapped == null) throw const AuthException('Sign in failed.');
      return mapped;
    } on FirebaseAuthException catch (e) {
      throw AuthException(_message(e));
    }
  }

  @override
  Future<void> sendPasswordReset(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw AuthException(_message(e));
    }
  }

  @override
  Future<void> signOut() => _auth.signOut();

  String _message(FirebaseAuthException e) => switch (e.code) {
        'email-already-in-use' =>
          'An account with this email already exists.',
        'invalid-email' => 'That email address looks invalid.',
        'weak-password' => 'Password should be at least 6 characters.',
        'user-not-found' ||
        'wrong-password' ||
        'invalid-credential' =>
          'Incorrect email or password.',
        'network-request-failed' =>
          'Network error. Check your connection and try again.',
        _ => e.message ?? 'Authentication failed.',
      };
}
