import 'user_role.dart';

/// The account-level record that ties a signed-in user to their [role].
/// Stored at `users/{uid}` and read right after sign-in to decide which
/// experience (student or recruiter) to show.
class AppUser {
  final String uid;
  final String name;
  final String email;
  final UserRole role;

  const AppUser({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
  });

  Map<String, dynamic> toMap() => <String, dynamic>{
        'name': name,
        'email': email,
        'role': role.name,
      };

  factory AppUser.fromMap(String uid, Map<String, dynamic> map) => AppUser(
        uid: uid,
        name: (map['name'] ?? '') as String,
        email: (map['email'] ?? '') as String,
        role: UserRoleLabel.fromString((map['role'] ?? 'student') as String),
      );
}
