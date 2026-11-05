import 'dart:async';

import '../../data/seed_data.dart';
import '../../models/app_user.dart';
import '../../models/application.dart';
import '../../models/internship.dart';
import '../../models/recruiter.dart';
import '../../models/student.dart';
import '../../models/user_role.dart';
import '../../utils/constants.dart';

/// A single in-memory database shared by the local auth and data services.
///
/// It lives for the lifetime of the app process (data resets on restart),
/// which is exactly what you want for a demo or a classroom presentation:
/// no setup, predictable state, and ready-made demo accounts.
class LocalStore {
  LocalStore._() {
    _seed();
  }
  static final LocalStore instance = LocalStore._();

  final Map<String, String> _passwords = <String, String>{}; // email -> pw
  final Map<String, String> _uidByEmail = <String, String>{}; // email -> uid
  final Map<String, AppUser> _users = <String, AppUser>{}; // uid -> AppUser
  final Map<String, Student> _students = <String, Student>{};
  final Map<String, Recruiter> _recruiters = <String, Recruiter>{};
  final List<Internship> _internships = <Internship>[];
  final List<Application> _applications = <Application>[];

  int _counter = 0;
  String _newId(String prefix) => '$prefix${++_counter}';

  /// Broadcasts whenever any data changes, so the local data service can power
  /// live streams just like Firestore does.
  final StreamController<void> _changes = StreamController<void>.broadcast();
  Stream<void> get changes => _changes.stream;
  void _notify() {
    if (!_changes.isClosed) _changes.add(null);
  }

  void _seed() {
    _internships.addAll(SeedData.internships());

    // Demo student with a complete profile.
    const String studentUid = 'demo-student';
    const String studentEmail = 'demo@saathi.app';
    _passwords[studentEmail] = '123456';
    _uidByEmail[studentEmail] = studentUid;
    _users[studentUid] = const AppUser(
      uid: studentUid,
      name: 'Aarav Sharma',
      email: studentEmail,
      role: UserRole.student,
    );
    _students[studentUid] = const Student(
      id: studentUid,
      name: 'Aarav Sharma',
      email: studentEmail,
      education: 'B.Tech Computer Science, Semester 7',
      bio: 'Aspiring mobile developer who loves building clean, useful apps.',
      location: 'Pune',
      skills: <String>['Flutter', 'Git', 'SQL', 'Java', 'Android'],
      interests: <String>['Mobile Development', 'Software Development'],
      careerGoals: <String>['Mobile App Developer', 'Software Engineer'],
    );

    // Demo recruiter with a company profile.
    const String recruiterUid = 'demo-recruiter';
    const String recruiterEmail = 'recruiter@saathi.app';
    _passwords[recruiterEmail] = '123456';
    _uidByEmail[recruiterEmail] = recruiterUid;
    _users[recruiterUid] = const AppUser(
      uid: recruiterUid,
      name: 'Priya Menon',
      email: recruiterEmail,
      role: UserRole.recruiter,
    );
    _recruiters[recruiterUid] = const Recruiter(
      id: recruiterUid,
      name: 'Priya Menon',
      email: recruiterEmail,
      companyName: 'Nova Apps',
      about: 'We build delightful mobile products.',
      website: 'novaapps.example.com',
      location: 'Pune',
    );
  }

  // --- auth-facing helpers ----------------------------------------------

  bool emailExists(String email) => _uidByEmail.containsKey(email);

  /// Stores credentials only and returns the new uid. The role and profile
  /// are written separately via [saveAppUser] / [saveStudent] / [saveRecruiter].
  String registerCredentials(String email, String password) {
    final String uid = _newId('u');
    _passwords[email] = password;
    _uidByEmail[email] = uid;
    return uid;
  }

  String? authenticate(String email, String password) {
    if (_passwords[email] == password) return _uidByEmail[email];
    return null;
  }

  // --- accounts / profiles ----------------------------------------------

  AppUser? getAppUser(String uid) => _users[uid];
  void saveAppUser(AppUser user) {
    _users[user.uid] = user;
    _notify();
  }

  Student? getStudent(String id) => _students[id];
  void saveStudent(Student student) {
    _students[student.id] = student;
    _notify();
  }

  Recruiter? getRecruiter(String id) => _recruiters[id];
  void saveRecruiter(Recruiter recruiter) {
    _recruiters[recruiter.id] = recruiter;
    _notify();
  }

  // --- internships -------------------------------------------------------

  List<Internship> getInternships() =>
      List<Internship>.unmodifiable(_internships);

  List<Internship> getInternshipsByRecruiter(String recruiterId) => _internships
      .where((Internship i) => i.recruiterId == recruiterId)
      .toList();

  void postInternship(Internship internship) {
    final int idx =
        _internships.indexWhere((Internship i) => i.id == internship.id);
    if (idx >= 0) {
      _internships[idx] = internship;
    } else {
      _internships.add(internship);
    }
    _notify();
  }

  void deleteInternship(String internshipId) {
    _internships.removeWhere((Internship i) => i.id == internshipId);
    _applications.removeWhere((Application a) => a.internshipId == internshipId);
    _notify();
  }

  String newInternshipId() => _newId('intern');

  // --- applications ------------------------------------------------------

  List<Application> getApplications(String studentId) => _applications
      .where((Application a) => a.studentId == studentId)
      .toList();

  List<Application> getApplicationsForInternship(String internshipId) =>
      _applications
          .where((Application a) => a.internshipId == internshipId)
          .toList();

  void apply(Application application) {
    final bool already = _applications.any((Application a) =>
        a.studentId == application.studentId &&
        a.internshipId == application.internshipId);
    if (!already) {
      _applications.add(application);
      _notify();
    }
  }

  void updateApplicationStatus(String applicationId, ApplicationStatus status) {
    final int idx =
        _applications.indexWhere((Application a) => a.id == applicationId);
    if (idx >= 0) {
      _applications[idx] = _applications[idx].copyWith(status: status);
      _notify();
    }
  }
}
