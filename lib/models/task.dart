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
}
