
class UserProfile {
  final String name;
  final String email;
  final String course;
  final String college;
  final int yearOfStudy;

  const UserProfile({
    this.name = '',
    this.email = '',
    this.course = '',
    this.college = '',
    this.yearOfStudy = 1,
  });

  UserProfile copyWith({
    String? name,
    String? email,
    String? course,
    String? college,
    int? yearOfStudy,
  }) {
    return UserProfile(
      name: name ?? this.name,
      email: email ?? this.email,
      course: course ?? this.course,
      college: college ?? this.college,
      yearOfStudy: yearOfStudy ?? this.yearOfStudy,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'course': course,
      'college': college,
      'yearOfStudy': yearOfStudy,
    };
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      course: json['course'] as String? ?? '',
      college: json['college'] as String? ?? '',
      yearOfStudy: json['yearOfStudy'] as int? ?? 1,
    );
  }
}
