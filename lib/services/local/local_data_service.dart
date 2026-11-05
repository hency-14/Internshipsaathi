import '../../models/app_user.dart';
import '../../models/application.dart';
import '../../models/internship.dart';
import '../../models/recruiter.dart';
import '../../models/student.dart';
import '../../utils/constants.dart';
import '../data_service.dart';
import 'local_store.dart';

/// In-memory data service for demo mode, backed by the shared [LocalStore].
class LocalDataService implements DataService {
  LocalDataService();

  final LocalStore _store = LocalStore.instance;

  /// Builds a live stream from a snapshot function: emits the current value
  /// immediately, then again every time the store changes.
  Stream<T> _watch<T>(T Function() snapshot) async* {
    yield snapshot();
    await for (final void _ in _store.changes) {
      yield snapshot();
    }
  }

  @override
  Future<AppUser?> getAppUser(String uid) async => _store.getAppUser(uid);

  @override
  Future<void> saveAppUser(AppUser user) async => _store.saveAppUser(user);

  @override
  Future<Student?> getStudent(String id) async => _store.getStudent(id);

  @override
  Future<void> saveStudent(Student student) async =>
      _store.saveStudent(student);

  @override
  Future<Recruiter?> getRecruiter(String id) async => _store.getRecruiter(id);

  @override
  Future<void> saveRecruiter(Recruiter recruiter) async =>
      _store.saveRecruiter(recruiter);

  @override
  Future<List<Internship>> getInternships() async => _store.getInternships();

  @override
  Future<List<Internship>> getInternshipsByRecruiter(String recruiterId) async =>
      _store.getInternshipsByRecruiter(recruiterId);

  @override
  Stream<List<Internship>> watchInternshipsByRecruiter(String recruiterId) =>
      _watch(() => _store.getInternshipsByRecruiter(recruiterId));

  @override
  Future<void> postInternship(Internship internship) async =>
      _store.postInternship(internship);

  @override
  Future<void> deleteInternship(String internshipId) async =>
      _store.deleteInternship(internshipId);

  @override
  Future<List<Application>> getApplications(String studentId) async =>
      _store.getApplications(studentId);

  @override
  Stream<List<Application>> watchApplications(String studentId) =>
      _watch(() => _store.getApplications(studentId));

  @override
  Future<List<Application>> getApplicationsForInternship(
          String internshipId) async =>
      _store.getApplicationsForInternship(internshipId);

  @override
  Stream<List<Application>> watchApplicationsForInternship(
          String internshipId) =>
      _watch(() => _store.getApplicationsForInternship(internshipId));

  @override
  Future<void> apply(Application application) async =>
      _store.apply(application);

  @override
  Future<void> updateApplicationStatus(
          String applicationId, ApplicationStatus status) async =>
      _store.updateApplicationStatus(applicationId, status);

  @override
  Future<void> seedInternships(List<Internship> internships) async {
    // The local store is already seeded at construction; nothing to do.
  }

  @override
  String toString() => 'LocalDataService';
}
