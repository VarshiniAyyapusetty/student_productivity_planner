class StudySession {
  const StudySession({
    required this.id,
    required this.subject,
    required this.durationMinutes,
    required this.goal,
    required this.date,
  });

  final String id;
  final String subject;
  final int durationMinutes;
  final String goal;
  final DateTime date;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'subject': subject,
      'durationMinutes': durationMinutes,
      'goal': goal,
      'date': date.toIso8601String(),
    };
  }

  factory StudySession.fromJson(Map<String, dynamic> json) {
    return StudySession(
      id: json['id'] as String,
      subject: json['subject'] as String,
      durationMinutes: json['durationMinutes'] as int,
      goal: json['goal'] as String? ?? '',
      date: DateTime.parse(json['date'] as String),
    );
  }
}
