import 'dart:async';

import '../auth_service.dart';
import 'local_store.dart';

/// In-memory authentication for demo mode. Backed by [LocalStore], it supports
/// sign-up, sign-in and sign-out against accounts that live only for the
/// current app session (plus the pre-seeded `demo@saathi.app` account).
class LocalAuthService implements AuthService {
  LocalAuthService();

  final LocalStore _store = LocalStore.instance;
  final StreamController<AuthUser?> _controller =
      StreamController<AuthUser?>.broadcast();
  AuthUser? _current;

  @override
  AuthUser? get currentUser => _current;

  @override
  Stream<AuthUser?> authState() async* {
    yield _current;
    yield* _controller.stream;
  }

  @override
  Future<AuthUser> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    final String normalized = email.trim().toLowerCase();
    if (_store.emailExists(normalized)) {
      throw const AuthException('An account with this email already exists.');
    }
    final String uid = _store.registerCredentials(normalized, password);
    return _emit(AuthUser(uid: uid, email: normalized, displayName: name.trim()));
  }

  @override
  Future<AuthUser> signIn({
    required String email,
    required String password,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    final String normalized = email.trim().toLowerCase();
    final String? uid = _store.authenticate(normalized, password);
    if (uid == null) {
      throw const AuthException('Incorrect email or password.');
    }
    final String name = _store.getAppUser(uid)?.name ?? '';
    return _emit(AuthUser(uid: uid, email: normalized, displayName: name));
  }

  @override
  Future<void> sendPasswordReset(String email) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    final String normalized = email.trim().toLowerCase();
    if (!_store.emailExists(normalized)) {
      throw const AuthException('No account found with this email.');
    }
    // Demo mode has no mailbox; succeeding here is enough to exercise the UI.
  }

  @override
  Future<void> signOut() async {
    _current = null;
    _controller.add(null);
  }

  AuthUser _emit(AuthUser user) {
    _current = user;
    _controller.add(user);
    return user;
  }
}
