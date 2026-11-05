/// A recruiter's company profile. Stored at `recruiters/{uid}`. The company
/// name is stamped onto every internship they post.
class Recruiter {
  final String id; // same as the auth uid
  final String name; // contact person
  final String email;
  final String companyName;
  final String about;
  final String website;
  final String location;

  const Recruiter({
    required this.id,
    required this.name,
    required this.email,
    this.companyName = '',
    this.about = '',
    this.website = '',
    this.location = '',
  });

  /// True once the recruiter has given enough to start posting internships.
  bool get isProfileComplete => companyName.isNotEmpty && location.isNotEmpty;

  Recruiter copyWith({
    String? name,
    String? companyName,
    String? about,
    String? website,
    String? location,
  }) {
    return Recruiter(
      id: id,
      name: name ?? this.name,
      email: email,
      companyName: companyName ?? this.companyName,
      about: about ?? this.about,
      website: website ?? this.website,
      location: location ?? this.location,
    );
  }

  Map<String, dynamic> toMap() => <String, dynamic>{
        'name': name,
        'email': email,
        'companyName': companyName,
        'about': about,
        'website': website,
        'location': location,
      };

  factory Recruiter.fromMap(String id, Map<String, dynamic> map) => Recruiter(
        id: id,
        name: (map['name'] ?? '') as String,
        email: (map['email'] ?? '') as String,
        companyName: (map['companyName'] ?? '') as String,
        about: (map['about'] ?? '') as String,
        website: (map['website'] ?? '') as String,
        location: (map['location'] ?? '') as String,
      );
}
