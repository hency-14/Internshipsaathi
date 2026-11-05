/// App-wide catalogs used for building student profiles and internship posts.
///
/// Keeping these as fixed lists (rather than free text) is what makes the
/// matching engine reliable: both sides pick from the same vocabulary, so
/// overlaps are meaningful instead of being defeated by typos or synonyms.
library;

class AppConfig {
  AppConfig._();

  /// When `false`, the app runs entirely on an in-memory store seeded with
  /// sample data — no backend required, so it launches and demos instantly.
  ///
  /// After you run `flutterfire configure` (see README), flip this to `true`
  /// to use Firebase Auth + Cloud Firestore instead. No other code changes.
  static const bool useFirebase = true;

  static const String appName = 'InternshipSaathi';
  static const String tagline = 'Your companion for the right internship';
}

/// Catalog of skills a student can have and an internship can require.
const List<String> kSkills = <String>[
  'Python',
  'Java',
  'C++',
  'JavaScript',
  'Flutter',
  'React',
  'Node.js',
  'SQL',
  'Machine Learning',
  'Data Analysis',
  'Android',
  'UI/UX Design',
  'Figma',
  'Cloud / AWS',
  'Git',
  'Communication',
  'Digital Marketing',
  'Content Writing',
  'Excel',
  'Project Management',
  'Cybersecurity',
];

/// Broad interest areas. Students pick what excites them; internships are
/// tagged with the areas they belong to.
const List<String> kInterests = <String>[
  'Software Development',
  'Web Development',
  'Mobile Development',
  'Data Science',
  'AI / ML',
  'Design',
  'Marketing',
  'Finance',
  'Content',
  'Cybersecurity',
  'Cloud',
  'Product Management',
];

/// Longer-term career tracks a student is aiming for.
const List<String> kCareerGoals = <String>[
  'Software Engineer',
  'Data Scientist',
  'Mobile App Developer',
  'Web Developer',
  'ML Engineer',
  'Product Manager',
  'UI/UX Designer',
  'Marketing Specialist',
  'Cybersecurity Analyst',
  'Cloud Engineer',
];

/// Supported locations. "Remote" participates in matching specially —
/// a remote internship suits a student in any city.
const List<String> kLocations = <String>[
  'Remote',
  'Mumbai',
  'Delhi',
  'Bangalore',
  'Pune',
  'Hyderabad',
  'Chennai',
  'Ahmedabad',
  'Kolkata',
  'Jaipur',
];

/// How the internship is carried out.
enum WorkMode { remote, onsite, hybrid }

extension WorkModeLabel on WorkMode {
  String get label => switch (this) {
        WorkMode.remote => 'Remote',
        WorkMode.onsite => 'On-site',
        WorkMode.hybrid => 'Hybrid',
      };

  static WorkMode fromString(String value) => WorkMode.values.firstWhere(
        (WorkMode m) => m.name == value,
        orElse: () => WorkMode.onsite,
      );
}

/// Status of a student's application to an internship.
enum ApplicationStatus { applied, underReview, shortlisted, rejected, accepted }

extension ApplicationStatusLabel on ApplicationStatus {
  String get label => switch (this) {
        ApplicationStatus.applied => 'Applied',
        ApplicationStatus.underReview => 'Under Review',
        ApplicationStatus.shortlisted => 'Shortlisted',
        ApplicationStatus.rejected => 'Rejected',
        ApplicationStatus.accepted => 'Accepted',
      };

  static ApplicationStatus fromString(String value) =>
      ApplicationStatus.values.firstWhere(
        (ApplicationStatus s) => s.name == value,
        orElse: () => ApplicationStatus.applied,
      );
}
