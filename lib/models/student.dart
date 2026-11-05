/// A student's profile. These four signals — skills, location, interests and
/// career goals — are exactly what the matching engine scores against.
class Student {
  final String id;
  final String name;
  final String email;
  final String education;
  final String bio;
  final String location;
  final List<String> skills;
  final List<String> interests;
  final List<String> careerGoals;

  const Student({
    required this.id,
    required this.name,
    required this.email,
    this.education = '',
    this.bio = '',
    this.location = '',
    this.skills = const <String>[],
    this.interests = const <String>[],
    this.careerGoals = const <String>[],
  });

  /// True once the student has filled in enough to be matched meaningfully.
  bool get isProfileComplete =>
      location.isNotEmpty &&
      skills.isNotEmpty &&
      interests.isNotEmpty &&
      careerGoals.isNotEmpty;

  Student copyWith({
    String? name,
    String? education,
    String? bio,
    String? location,
    List<String>? skills,
    List<String>? interests,
    List<String>? careerGoals,
  }) {
    return Student(
      id: id,
      name: name ?? this.name,
      email: email,
      education: education ?? this.education,
      bio: bio ?? this.bio,
      location: location ?? this.location,
      skills: skills ?? this.skills,
      interests: interests ?? this.interests,
      careerGoals: careerGoals ?? this.careerGoals,
    );
  }

  Map<String, dynamic> toMap() => <String, dynamic>{
        'name': name,
        'email': email,
        'education': education,
        'bio': bio,
        'location': location,
        'skills': skills,
        'interests': interests,
        'careerGoals': careerGoals,
      };

  factory Student.fromMap(String id, Map<String, dynamic> map) => Student(
        id: id,
        name: (map['name'] ?? '') as String,
        email: (map['email'] ?? '') as String,
        education: (map['education'] ?? '') as String,
        bio: (map['bio'] ?? '') as String,
        location: (map['location'] ?? '') as String,
        skills: _stringList(map['skills']),
        interests: _stringList(map['interests']),
        careerGoals: _stringList(map['careerGoals']),
      );

  static List<String> _stringList(dynamic value) {
    if (value is List) {
      return value.map((dynamic e) => e.toString()).toList();
    }
    return const <String>[];
  }
}
