import '../models/internship.dart';
import '../models/match_result.dart';
import '../models/student.dart';

/// The recommendation engine of InternshipSaathi.
///
/// It scores how well an internship fits a student across four dimensions —
/// skills, location, interests and career goals — and combines them into a
/// single 0–100 score using the weights below. The function is pure (no I/O,
/// no Firebase), which keeps it fast, deterministic and easy to unit-test.
class MatchingService {
  const MatchingService();

  /// How much each dimension contributes to the final score. Must sum to 1.0.
  ///
  /// Skills dominate because they decide whether a student can actually do the
  /// work; interests and goals shape satisfaction and direction; location is a
  /// practical constraint that matters but shouldn't outweigh fit.
  static const Map<MatchDimension, double> weights = <MatchDimension, double>{
    MatchDimension.skills: 0.40,
    MatchDimension.interests: 0.25,
    MatchDimension.location: 0.20,
    MatchDimension.careerGoals: 0.15,
  };

  /// Scores a single internship for a student and returns a detailed result.
  MatchResult score(Student student, Internship internship) {
    final List<String> matchedSkills = _intersection(
      student.skills,
      internship.requiredSkills,
    );

    final double skillScore = _coverage(
      wanted: internship.requiredSkills,
      has: student.skills,
    );
    final double interestScore = _overlapRatio(
      student.interests,
      internship.domains,
    );
    final double locationScore = _locationScore(
      student.location,
      internship.location,
    );
    final double goalScore = _overlapRatio(
      student.careerGoals,
      internship.careerTracks,
    );

    final Map<MatchDimension, double> breakdown = <MatchDimension, double>{
      MatchDimension.skills: skillScore,
      MatchDimension.interests: interestScore,
      MatchDimension.location: locationScore,
      MatchDimension.careerGoals: goalScore,
    };

    double total = 0;
    breakdown.forEach((MatchDimension dim, double value) {
      total += value * (weights[dim] ?? 0);
    });

    return MatchResult(
      internship: internship,
      score: double.parse(total.toStringAsFixed(1)),
      breakdown: breakdown,
      matchedSkills: matchedSkills,
    );
  }

  /// Scores every internship for the student and returns them best-first.
  /// Internships below [minScore] are dropped so students aren't shown noise.
  List<MatchResult> rank(
    Student student,
    List<Internship> internships, {
    double minScore = 0,
  }) {
    final List<MatchResult> results = internships
        .map((Internship i) => score(student, i))
        .where((MatchResult r) => r.score >= minScore)
        .toList();
    results.sort((MatchResult a, MatchResult b) => b.score.compareTo(a.score));
    return results;
  }

  // --- scoring primitives -------------------------------------------------

  /// Fraction of the internship's required skills the student actually has,
  /// as a percentage. If a post lists no required skills we treat it as a
  /// neutral full score rather than dividing by zero.
  double _coverage({required List<String> wanted, required List<String> has}) {
    if (wanted.isEmpty) return 100;
    final Set<String> hasSet = _normalizeSet(has);
    final int covered =
        _normalizeSet(wanted).where(hasSet.contains).length;
    return covered / wanted.length * 100;
  }

  /// Jaccard-style overlap between two tag sets, as a percentage. Rewards
  /// shared tags without being dragged down by how long either list is.
  double _overlapRatio(List<String> a, List<String> b) {
    final Set<String> setA = _normalizeSet(a);
    final Set<String> setB = _normalizeSet(b);
    if (setA.isEmpty || setB.isEmpty) return 0;
    final int shared = setA.intersection(setB).length;
    final int union = setA.union(setB).length;
    return shared / union * 100;
  }

  /// Location scoring: a remote internship fits everyone; an exact city match
  /// is perfect; a student open to remote is happy anywhere; otherwise a
  /// different city is a partial (not zero) fit, since relocation is possible.
  double _locationScore(String studentLocation, String internshipLocation) {
    final String s = studentLocation.trim().toLowerCase();
    final String i = internshipLocation.trim().toLowerCase();
    if (s.isEmpty || i.isEmpty) return 0;
    if (i == 'remote' || s == 'remote') return 100;
    if (s == i) return 100;
    return 30;
  }

  List<String> _intersection(List<String> a, List<String> b) {
    final Set<String> setB = _normalizeSet(b);
    return a
        .where((String e) => setB.contains(e.trim().toLowerCase()))
        .toList();
  }

  Set<String> _normalizeSet(List<String> items) =>
      items.map((String e) => e.trim().toLowerCase()).toSet();
}
