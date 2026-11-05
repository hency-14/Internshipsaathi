import '../models/app_user.dart';
import '../models/application.dart';
import '../models/internship.dart';
import '../models/recruiter.dart';
import '../models/student.dart';
import '../utils/constants.dart';

/// Contract for all persistent data: account roles, student & recruiter
/// profiles, internship postings and applications. Implemented twice — once
/// in-memory for the demo, once against Cloud Firestore.
abstract class DataService {
  // --- accounts / roles --------------------------------------------------

  Future<AppUser?> getAppUser(String uid);

  Future<void> saveAppUser(AppUser user);

  // --- student profiles --------------------------------------------------

  Future<Student?> getStudent(String id);

  Future<void> saveStudent(Student student);

  // --- recruiter profiles ------------------------------------------------

  Future<Recruiter?> getRecruiter(String id);

  Future<void> saveRecruiter(Recruiter recruiter);

  // --- internships -------------------------------------------------------

  Future<List<Internship>> getInternships();

  /// Only the internships posted by the given recruiter.
  Future<List<Internship>> getInternshipsByRecruiter(String recruiterId);

  /// Live stream of a recruiter's postings (emits on every change).
  Stream<List<Internship>> watchInternshipsByRecruiter(String recruiterId);

  /// Creates a new internship or overwrites an existing one with the same id.
  Future<void> postInternship(Internship internship);

  Future<void> deleteInternship(String internshipId);

  // --- applications ------------------------------------------------------

  Future<List<Application>> getApplications(String studentId);

  /// Live stream of a student's applications (status updates arrive here).
  Stream<List<Application>> watchApplications(String studentId);

  /// All applications submitted to a given internship (recruiter view).
  Future<List<Application>> getApplicationsForInternship(String internshipId);

  /// Live stream of the applications to a given internship (recruiter view).
  Stream<List<Application>> watchApplicationsForInternship(String internshipId);

  Future<void> apply(Application application);

  Future<void> updateApplicationStatus(
      String applicationId, ApplicationStatus status);

  // --- seeding -----------------------------------------------------------

  /// Writes the given internships to the backing store. Used once to seed an
  /// empty Firestore; a no-op-style convenience in the local store.
  Future<void> seedInternships(List<Internship> internships);
}
