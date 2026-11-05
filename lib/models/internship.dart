import '../utils/constants.dart';

/// An internship posting. Mirrors the student's matchable fields so the two
/// can be compared directly: required skills vs. the student's skills, the
/// domains it belongs to vs. the student's interests, and the career track
/// it leads toward vs. the student's goals.
class Internship {
  final String id;
  final String title;
  final String company;
  final String location;
  final WorkMode workMode;
  final int stipend; // monthly, in INR; 0 means unpaid / unspecified
  final int durationMonths;
  final String description;
  final List<String> requiredSkills;
  final List<String> domains; // maps to student interests
  final List<String> careerTracks; // maps to student career goals
  final DateTime postedAt;

  /// The uid of the recruiter who posted this. Empty for the bundled seed
  /// internships, which aren't owned by any recruiter account.
  final String recruiterId;

  const Internship({
    required this.id,
    required this.title,
    required this.company,
    required this.location,
    required this.workMode,
    required this.stipend,
    required this.durationMonths,
    required this.description,
    required this.requiredSkills,
    required this.domains,
    required this.careerTracks,
    required this.postedAt,
    this.recruiterId = '',
  });

  Map<String, dynamic> toMap() => <String, dynamic>{
        'title': title,
        'company': company,
        'location': location,
        'workMode': workMode.name,
        'stipend': stipend,
        'durationMonths': durationMonths,
        'description': description,
        'requiredSkills': requiredSkills,
        'domains': domains,
        'careerTracks': careerTracks,
        'postedAt': postedAt.toIso8601String(),
        'recruiterId': recruiterId,
      };

  factory Internship.fromMap(String id, Map<String, dynamic> map) => Internship(
        id: id,
        title: (map['title'] ?? '') as String,
        company: (map['company'] ?? '') as String,
        location: (map['location'] ?? '') as String,
        workMode: WorkModeLabel.fromString((map['workMode'] ?? 'onsite') as String),
        stipend: (map['stipend'] ?? 0) as int,
        durationMonths: (map['durationMonths'] ?? 1) as int,
        description: (map['description'] ?? '') as String,
        requiredSkills: _stringList(map['requiredSkills']),
        domains: _stringList(map['domains']),
        careerTracks: _stringList(map['careerTracks']),
        postedAt: _parseDate(map['postedAt']),
        recruiterId: (map['recruiterId'] ?? '') as String,
      );

  static List<String> _stringList(dynamic value) {
    if (value is List) {
      return value.map((dynamic e) => e.toString()).toList();
    }
    return const <String>[];
  }

  static DateTime _parseDate(dynamic value) {
    if (value is String) {
      return DateTime.tryParse(value) ?? DateTime.now();
    }
    return DateTime.now();
  }
}
