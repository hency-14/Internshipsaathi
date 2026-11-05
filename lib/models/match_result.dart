import 'internship.dart';

/// The outcome of scoring one internship against one student.
///
/// Besides the overall [score] (0–100), it keeps a per-dimension [breakdown]
/// so the UI can *explain* the match — "Skills 85%, Location 100%, …" — which
/// is far more useful to a student than a bare number.
class MatchResult {
  final Internship internship;
  final double score; // 0–100
  final Map<MatchDimension, double> breakdown; // each 0–100
  final List<String> matchedSkills;

  const MatchResult({
    required this.internship,
    required this.score,
    required this.breakdown,
    required this.matchedSkills,
  });

  /// A short human label for the overall strength of the match.
  String get tier {
    if (score >= 80) return 'Excellent match';
    if (score >= 60) return 'Strong match';
    if (score >= 40) return 'Fair match';
    return 'Low match';
  }
}

enum MatchDimension { skills, location, interests, careerGoals }

extension MatchDimensionLabel on MatchDimension {
  String get label => switch (this) {
        MatchDimension.skills => 'Skills',
        MatchDimension.location => 'Location',
        MatchDimension.interests => 'Interests',
        MatchDimension.careerGoals => 'Career goals',
      };
}
