import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/app_user.dart';
import '../../models/application.dart';
import '../../models/internship.dart';
import '../../models/recruiter.dart';
import '../../models/student.dart';
import '../../utils/constants.dart';
import '../data_service.dart';

/// Data service backed by Cloud Firestore.
///
/// Collection layout:
///   users/{uid}               -> account record with role
///   students/{uid}            -> student profile
///   recruiters/{uid}          -> recruiter / company profile
///   internships/{id}          -> internship posting (has recruiterId)
///   applications/{autoId}     -> one per (student, internship)
class FirestoreDataService implements DataService {
  FirestoreDataService();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _users =>
      _db.collection('users');
  CollectionReference<Map<String, dynamic>> get _students =>
      _db.collection('students');
  CollectionReference<Map<String, dynamic>> get _recruiters =>
      _db.collection('recruiters');
  CollectionReference<Map<String, dynamic>> get _internships =>
      _db.collection('internships');
  CollectionReference<Map<String, dynamic>> get _applications =>
      _db.collection('applications');

  // --- accounts / roles --------------------------------------------------

  @override
  Future<AppUser?> getAppUser(String uid) async {
    final DocumentSnapshot<Map<String, dynamic>> doc =
        await _users.doc(uid).get();
    final Map<String, dynamic>? data = doc.data();
    if (data == null) return null;
    return AppUser.fromMap(doc.id, data);
  }

  @override
  Future<void> saveAppUser(AppUser user) =>
      _users.doc(user.uid).set(user.toMap());

  // --- student profiles --------------------------------------------------

  @override
  Future<Student?> getStudent(String id) async {
    final DocumentSnapshot<Map<String, dynamic>> doc =
        await _students.doc(id).get();
    final Map<String, dynamic>? data = doc.data();
    if (data == null) return null;
    return Student.fromMap(doc.id, data);
  }

  @override
  Future<void> saveStudent(Student student) =>
      _students.doc(student.id).set(student.toMap());

  // --- recruiter profiles ------------------------------------------------

  @override
  Future<Recruiter?> getRecruiter(String id) async {
    final DocumentSnapshot<Map<String, dynamic>> doc =
        await _recruiters.doc(id).get();
    final Map<String, dynamic>? data = doc.data();
    if (data == null) return null;
    return Recruiter.fromMap(doc.id, data);
  }

  @override
  Future<void> saveRecruiter(Recruiter recruiter) =>
      _recruiters.doc(recruiter.id).set(recruiter.toMap());

  // --- internships -------------------------------------------------------

  @override
  Future<List<Internship>> getInternships() async {
    final QuerySnapshot<Map<String, dynamic>> snap =
        await _internships.orderBy('postedAt', descending: true).get();
    return snap.docs
        .map((QueryDocumentSnapshot<Map<String, dynamic>> d) =>
            Internship.fromMap(d.id, d.data()))
        .toList();
  }

  @override
  Future<List<Internship>> getInternshipsByRecruiter(
      String recruiterId) async {
    // Filtered by recruiter, then sorted client-side so no composite index
    // is required.
    final QuerySnapshot<Map<String, dynamic>> snap = await _internships
        .where('recruiterId', isEqualTo: recruiterId)
        .get();
    final List<Internship> list = snap.docs
        .map((QueryDocumentSnapshot<Map<String, dynamic>> d) =>
            Internship.fromMap(d.id, d.data()))
        .toList();
    list.sort((Internship a, Internship b) => b.postedAt.compareTo(a.postedAt));
    return list;
  }

  @override
  Stream<List<Internship>> watchInternshipsByRecruiter(String recruiterId) {
    return _internships
        .where('recruiterId', isEqualTo: recruiterId)
        .snapshots()
        .map((QuerySnapshot<Map<String, dynamic>> snap) {
      final List<Internship> list = snap.docs
          .map((QueryDocumentSnapshot<Map<String, dynamic>> d) =>
              Internship.fromMap(d.id, d.data()))
          .toList();
      list.sort(
          (Internship a, Internship b) => b.postedAt.compareTo(a.postedAt));
      return list;
    });
  }

  @override
  Future<void> postInternship(Internship internship) =>
      _internships.doc(internship.id).set(internship.toMap());

  @override
  Future<void> deleteInternship(String internshipId) async {
    // Remove the posting and any applications that reference it.
    final QuerySnapshot<Map<String, dynamic>> apps = await _applications
        .where('internshipId', isEqualTo: internshipId)
        .get();
    final WriteBatch batch = _db.batch();
    for (final QueryDocumentSnapshot<Map<String, dynamic>> d in apps.docs) {
      batch.delete(d.reference);
    }
    batch.delete(_internships.doc(internshipId));
    await batch.commit();
  }

  // --- applications ------------------------------------------------------

  @override
  Future<List<Application>> getApplications(String studentId) async {
    final QuerySnapshot<Map<String, dynamic>> snap = await _applications
        .where('studentId', isEqualTo: studentId)
        .get();
    return snap.docs
        .map((QueryDocumentSnapshot<Map<String, dynamic>> d) =>
            Application.fromMap(d.id, d.data()))
        .toList();
  }

  @override
  Stream<List<Application>> watchApplications(String studentId) {
    return _applications
        .where('studentId', isEqualTo: studentId)
        .snapshots()
        .map(_toApplications);
  }

  @override
  Future<List<Application>> getApplicationsForInternship(
      String internshipId) async {
    final QuerySnapshot<Map<String, dynamic>> snap = await _applications
        .where('internshipId', isEqualTo: internshipId)
        .get();
    return _toApplications(snap);
  }

  @override
  Stream<List<Application>> watchApplicationsForInternship(
      String internshipId) {
    return _applications
        .where('internshipId', isEqualTo: internshipId)
        .snapshots()
        .map(_toApplications);
  }

  List<Application> _toApplications(QuerySnapshot<Map<String, dynamic>> snap) =>
      snap.docs
          .map((QueryDocumentSnapshot<Map<String, dynamic>> d) =>
              Application.fromMap(d.id, d.data()))
          .toList();

  @override
  Future<void> apply(Application application) async {
    final QuerySnapshot<Map<String, dynamic>> existing = await _applications
        .where('studentId', isEqualTo: application.studentId)
        .where('internshipId', isEqualTo: application.internshipId)
        .limit(1)
        .get();
    if (existing.docs.isNotEmpty) return; // already applied
    await _applications.add(application.toMap());
  }

  @override
  Future<void> updateApplicationStatus(
          String applicationId, ApplicationStatus status) =>
      _applications.doc(applicationId).update(<String, dynamic>{
        'status': status.name,
      });

  // --- seeding -----------------------------------------------------------

  @override
  Future<void> seedInternships(List<Internship> internships) async {
    final WriteBatch batch = _db.batch();
    for (final Internship i in internships) {
      batch.set(_internships.doc(i.id), i.toMap());
    }
    await batch.commit();
  }
}
