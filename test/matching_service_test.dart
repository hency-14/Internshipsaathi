import 'package:flutter_test/flutter_test.dart';
import 'package:internship_saathi/models/internship.dart';
import 'package:internship_saathi/models/match_result.dart';
import 'package:internship_saathi/models/student.dart';
import 'package:internship_saathi/services/matching_service.dart';
import 'package:internship_saathi/utils/constants.dart';

/// Unit tests for the core recommendation logic. Because [MatchingService] is
/// pure, these run fast and need no Flutter bindings, Firebase or UI.
void main() {
  const MatchingService engine = MatchingService();

  Internship internship({
    String id = 'i',
    String location = 'Pune',
    List<String> skills = const <String>['Flutter', 'Git'],
    List<String> domains = const <String>['Mobile Development'],
    List<String> tracks = const <String>['Mobile App Developer'],
  }) {
    return Internship(
      id: id,
      title: 'Role',
      company: 'Co',
      location: location,
      workMode: WorkMode.hybrid,
      stipend: 10000,
      durationMonths: 3,
      description: '',
      requiredSkills: skills,
      domains: domains,
      careerTracks: tracks,
      postedAt: DateTime(2026, 1, 1),
    );
  }

  const Student student = Student(
    id: 's',
    name: 'Test',
    email: 't@e.com',
    location: 'Pune',
    skills: <String>['Flutter', 'Git', 'SQL'],
    interests: <String>['Mobile Development', 'Software Development'],
    careerGoals: <String>['Mobile App Developer'],
  );

  test('a perfectly aligned internship scores very high', () {
    final MatchResult r = engine.score(student, internship());
    expect(r.score, greaterThanOrEqualTo(80));
    expect(r.breakdown[MatchDimension.skills], 100); // has both required
    expect(r.breakdown[MatchDimension.location], 100); // same city
  });

  test('skills score reflects the fraction of required skills held', () {
    // Requires 4 skills, student has 2 of them -> 50%.
    final MatchResult r = engine.score(
      student,
      internship(skills: <String>['Flutter', 'Git', 'Python', 'React']),
    );
    expect(r.breakdown[MatchDimension.skills], 50);
    expect(r.matchedSkills.length, 2);
  });

  test('a remote internship gives full location score to any student', () {
    final MatchResult r = engine.score(
      student,
      internship(location: 'Remote'),
    );
    expect(r.breakdown[MatchDimension.location], 100);
  });

  test('a different city is a partial, not zero, location match', () {
    final MatchResult r = engine.score(
      student,
      internship(location: 'Delhi'),
    );
    expect(r.breakdown[MatchDimension.location], 30);
  });

  test('matching is case- and whitespace-insensitive', () {
    final MatchResult r = engine.score(
      student,
      internship(skills: <String>[' flutter ', 'GIT']),
    );
    expect(r.breakdown[MatchDimension.skills], 100);
  });

  test('rank orders internships best-first and drops those below minScore', () {
    final Internship strong = internship(id: 'strong');
    final Internship weak = internship(
      id: 'weak',
      location: 'Delhi',
      skills: <String>['Python', 'Machine Learning'],
      domains: <String>['Data Science'],
      tracks: <String>['Data Scientist'],
    );

    final List<MatchResult> ranked =
        engine.rank(student, <Internship>[weak, strong]);
    expect(ranked.first.internship.id, 'strong');
    expect(ranked.first.score, greaterThan(ranked.last.score));

    final List<MatchResult> filtered =
        engine.rank(student, <Internship>[weak, strong], minScore: 70);
    expect(filtered.every((MatchResult r) => r.score >= 70), isTrue);
  });

  test('weights sum to 1.0 so the max possible score is 100', () {
    final double total =
        MatchingService.weights.values.fold(0, (double a, double b) => a + b);
    expect(total, closeTo(1.0, 1e-9));
  });
}
