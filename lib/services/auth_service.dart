/// A backend-agnostic view of the signed-in user. Both the local demo auth
/// and Firebase auth produce this same shape, so the rest of the app never
/// needs to know which backend is active.
class AuthUser {
  final String uid;
  final String email;
  final String displayName;

  const AuthUser({
    required this.uid,
    required this.email,
    required this.displayName,
  });
}

/// Thrown by auth implementations with a user-friendly [message].
class AuthException implements Exception {
  final String message;
  const AuthException(this.message);
  @override
  String toString() => message;
}

/// Contract for authentication. Swapping local ↔ Firebase is just a matter of
/// which implementation the [ServiceLocator] hands out.
abstract class AuthService {
  /// Emits the current user (or null when signed out) and every change after.
  Stream<AuthUser?> authState();

  AuthUser? get currentUser;

  Future<AuthUser> signUp({
    required String name,
    required String email,
    required String password,
  });

  Future<AuthUser> signIn({
    required String email,
    required String password,
  });

  /// Sends a password-reset email (or simulates it in demo mode).
  Future<void> sendPasswordReset(String email);

  Future<void> signOut();
}
