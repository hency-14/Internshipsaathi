import '../utils/constants.dart';

/// A record that a student applied to an internship.
class Application {
  final String id;
  final String studentId;
  final String internshipId;
  final ApplicationStatus status;
  final DateTime appliedAt;

  const Application({
    required this.id,
    required this.studentId,
    required this.internshipId,
    required this.status,
    required this.appliedAt,
  });

  Application copyWith({ApplicationStatus? status}) => Application(
        id: id,
        studentId: studentId,
        internshipId: internshipId,
        status: status ?? this.status,
        appliedAt: appliedAt,
      );

  Map<String, dynamic> toMap() => <String, dynamic>{
        'studentId': studentId,
        'internshipId': internshipId,
        'status': status.name,
        'appliedAt': appliedAt.toIso8601String(),
      };

  factory Application.fromMap(String id, Map<String, dynamic> map) =>
      Application(
        id: id,
        studentId: (map['studentId'] ?? '') as String,
        internshipId: (map['internshipId'] ?? '') as String,
        status: ApplicationStatusLabel.fromString(
            (map['status'] ?? 'applied') as String),
        appliedAt:
            DateTime.tryParse((map['appliedAt'] ?? '') as String) ??
                DateTime.now(),
      );
}
