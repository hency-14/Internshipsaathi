/// Which kind of account a user has. Chosen at sign-up and used to route the
/// whole app to either the student experience or the recruiter experience.
enum UserRole { student, recruiter }

extension UserRoleLabel on UserRole {
  String get label => switch (this) {
        UserRole.student => 'Student',
        UserRole.recruiter => 'Recruiter',
      };

  static UserRole fromString(String value) => UserRole.values.firstWhere(
        (UserRole r) => r.name == value,
        orElse: () => UserRole.student,
      );
}
