import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/app_user.dart';
import '../models/recruiter.dart';
import '../models/student.dart';
import '../models/user_role.dart';
import '../services/auth_service.dart';
import '../services/data_service.dart';
import '../services/service_locator.dart';

/// Holds authentication state **and** the signed-in user's role, which drives
/// the whole app's routing (student vs. recruiter experience).
///
/// On sign-up it creates the account record (`users/{uid}`) and an initial
/// profile for the chosen role. On sign-in it loads the role from that record.
class AuthProvider extends ChangeNotifier {
  AuthProvider() {
    _sub = _auth.authState().listen(_onAuthChanged);
  }

  final AuthService _auth = ServiceLocator.instance.auth;
  final DataService _data = ServiceLocator.instance.data;
  StreamSubscription<AuthUser?>? _sub;

  AuthUser? _user;
  AppUser? _appUser;
  bool _busy = false;
  bool _signingUp = false;
  String? _error;

  AuthUser? get user => _user;
  AppUser? get appUser => _appUser;
  UserRole? get role => _appUser?.role;
  bool get isSignedIn => _user != null;

  /// True while we know who signed in but haven't resolved their role yet.
  bool get resolvingRole => isSignedIn && _appUser == null;

  bool get busy => _busy;
  String? get error => _error;

  Future<void> _onAuthChanged(AuthUser? user) async {
    _user = user;
    if (user == null) {
      _appUser = null;
      notifyListeners();
      return;
    }
    // During sign-up we set _appUser ourselves; don't race the DB read.
    if (_signingUp) {
      notifyListeners();
      return;
    }
    if (_appUser?.uid == user.uid) {
      notifyListeners();
      return;
    }
    await _resolveRole(user);
  }

  Future<void> _resolveRole(AuthUser user) async {
    notifyListeners();
    try {
      final AppUser? existing = await _data.getAppUser(user.uid);
      // Fallback keeps an older account (no role record) usable as a student.
      _appUser = existing ??
          AppUser(
            uid: user.uid,
            name: user.displayName,
            email: user.email,
            role: UserRole.student,
          );
    } finally {
      notifyListeners();
    }
  }

  Future<bool> signIn(String email, String password) async {
    return _run(() async {
      await _auth.signIn(email: email, password: password);
    });
  }

  /// Creates the account, stores its role, and seeds an empty profile for that
  /// role so the rest of the app has something to load.
  Future<bool> signUp(
    String name,
    String email,
    String password,
    UserRole role,
  ) async {
    return _run(() async {
      _signingUp = true;
      try {
        final AuthUser authUser = await _auth.signUp(
          name: name,
          email: email,
          password: password,
        );
        final AppUser appUser = AppUser(
          uid: authUser.uid,
          name: name.trim(),
          email: authUser.email,
          role: role,
        );
        await _data.saveAppUser(appUser);
        if (role == UserRole.student) {
          await _data.saveStudent(
            Student(id: authUser.uid, name: name.trim(), email: authUser.email),
          );
        } else {
          await _data.saveRecruiter(
            Recruiter(
                id: authUser.uid, name: name.trim(), email: authUser.email),
          );
        }
        _appUser = appUser; // route immediately, no extra DB read
      } finally {
        _signingUp = false;
      }
    });
  }

  /// Sends a password-reset email. Returns true on success; on failure the
  /// reason is in [error].
  Future<bool> resetPassword(String email) =>
      _run(() => _auth.sendPasswordReset(email));

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<bool> _run(Future<void> Function() action) async {
    _busy = true;
    _error = null;
    notifyListeners();
    try {
      await action();
      return true;
    } on AuthException catch (e) {
      _error = e.message;
      return false;
    } catch (e) {
      _error = 'Something went wrong. Please try again.';
      return false;
    } finally {
      _busy = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
