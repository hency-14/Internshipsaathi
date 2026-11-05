import 'package:flutter_test/flutter_test.dart';
import 'package:internship_saathi/models/application.dart';
import 'package:internship_saathi/models/internship.dart';
import 'package:internship_saathi/models/student.dart';
import 'package:internship_saathi/services/data_service.dart';
import 'package:internship_saathi/services/local/local_data_service.dart';
import 'package:internship_saathi/utils/constants.dart';

/// Integration-style tests over the in-memory backend. They exercise the same
/// DataService contract the Firebase implementation honours: posting, applying,
/// recruiter queries, status updates, and the live streams.
void main() {
  final DataService data = LocalDataService();

  Internship posting(String id, String recruiterId) => Internship(
        id: id,
        title: 'Test Role',
        company: 'TestCo',
        location: 'Remote',
        workMode: WorkMode.remote,
        stipend: 10000,
        durationMonths: 3,
        description: 'desc',
        requiredSkills: const <String>['Flutter'],
        domains: const <String>['Mobile Development'],
        careerTracks: const <String>['Mobile App Developer'],
        postedAt: DateTime(2026, 2, 1),
        recruiterId: recruiterId,
      );

  test('a posted internship is retrievable by its recruiter', () async {
    await data.postInternship(posting('t-intern-1', 't-rec-1'));
    final List<Internship> mine =
        await data.getInternshipsByRecruiter('t-rec-1');
    expect(mine.any((Internship i) => i.id == 't-intern-1'), isTrue);
    // Another recruiter doesn't see it.
    final List<Internship> other =
        await data.getInternshipsByRecruiter('t-rec-2');
    expect(other.any((Internship i) => i.id == 't-intern-1'), isFalse);
  });

  test('applying is recorded once and is idempotent per student', () async {
    final Application app = Application(
      id: 'app-ta-1',
      studentId: 't-student-1',
      internshipId: 't-intern-1',
      status: ApplicationStatus.applied,
      appliedAt: _fixedDate,
    );
    await data.apply(app);
    await data.apply(app); // duplicate ignored
    final List<Application> apps = await data.getApplications('t-student-1');
    expect(apps.where((Application a) => a.internshipId == 't-intern-1').length,
        1);
  });

  test('a recruiter can read and update an application status', () async {
    final List<Application> forPost =
        await data.getApplicationsForInternship('t-intern-1');
    expect(forPost, isNotEmpty);
    await data.updateApplicationStatus('app-ta-1', ApplicationStatus.shortlisted);
    final List<Application> after =
        await data.getApplicationsForInternship('t-intern-1');
    expect(after.firstWhere((Application a) => a.id == 'app-ta-1').status,
        ApplicationStatus.shortlisted);
  });

  test('deleting a posting removes its applications too', () async {
    await data.deleteInternship('t-intern-1');
    final List<Internship> mine =
        await data.getInternshipsByRecruiter('t-rec-1');
    expect(mine.any((Internship i) => i.id == 't-intern-1'), isFalse);
    final List<Application> apps =
        await data.getApplicationsForInternship('t-intern-1');
    expect(apps, isEmpty);
  });

  test('watchApplications emits again after a new application', () async {
    await data.postInternship(posting('t-intern-2', 't-rec-1'));
    final Stream<List<Application>> stream =
        data.watchApplications('t-student-2');
    final Future<List<List<Application>>> firstTwo = stream.take(2).toList();

    // Give the initial emission a tick, then apply.
    await Future<void>.delayed(const Duration(milliseconds: 10));
    await data.apply(Application(
      id: 'app-ta-2',
      studentId: 't-student-2',
      internshipId: 't-intern-2',
      status: ApplicationStatus.applied,
      appliedAt: _fixedDate,
    ));

    final List<List<Application>> emissions = await firstTwo;
    expect(emissions.first, isEmpty); // nothing applied yet
    expect(emissions.last.length, 1); // after applying
  });

  test('Internship round-trips through its map, preserving recruiterId', () {
    final Internship original = posting('rt-1', 'rec-rt');
    final Internship restored =
        Internship.fromMap(original.id, original.toMap());
    expect(restored.recruiterId, 'rec-rt');
    expect(restored.requiredSkills, original.requiredSkills);
    expect(restored.workMode, WorkMode.remote);
  });

  test('Student round-trips through its map', () {
    const Student original = Student(
      id: 's1',
      name: 'Test',
      email: 't@e.com',
      location: 'Pune',
      skills: <String>['Flutter'],
      interests: <String>['Mobile Development'],
      careerGoals: <String>['Mobile App Developer'],
    );
    final Student restored = Student.fromMap(original.id, original.toMap());
    expect(restored.name, 'Test');
    expect(restored.skills, <String>['Flutter']);
    expect(restored.isProfileComplete, isTrue);
  });
}

final DateTime _fixedDate = DateTime(2026, 2, 2);
