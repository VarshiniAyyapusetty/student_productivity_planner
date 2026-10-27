enum TaskPriority { low, medium, high }

class Task {
  Task({
    required this.id,
    required this.title,
    this.description = '',
    this.dueDate,
    this.priority = TaskPriority.medium,
    this.isCompleted = false,
  });

  final String id;
  final String title;
  final String description;
  final DateTime? dueDate;
  final TaskPriority priority;
  bool isCompleted;

  void toggleCompleted() {
    isCompleted = !isCompleted;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'dueDate': dueDate?.toIso8601String(),
      'priority': priority.name,
      'isCompleted': isCompleted,
    };
  }

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      dueDate: json['dueDate'] == null
          ? null
          : DateTime.parse(json['dueDate'] as String),
      priority: TaskPriority.values.firstWhere(
        (priority) => priority.name == json['priority'],
        orElse: () => TaskPriority.medium,
      ),
      isCompleted: json['isCompleted'] as bool? ?? false,
    );
  }
}
