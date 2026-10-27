import 'package:flutter/foundation.dart';

import '../models/task.dart';

class TaskProvider extends ChangeNotifier {
  final List<Task> _tasks = [];

  List<Task> get tasks => List.unmodifiable(_tasks);

  int get totalTasks => _tasks.length;

  int get completedTasks => _tasks.where((task) => task.isCompleted).length;

  int get pendingTasks => totalTasks - completedTasks;

  double get completionProgress =>
      totalTasks == 0 ? 0 : completedTasks / totalTasks;

  void addTask(Task task) {
    _tasks.add(task);
    notifyListeners();
  }

  void toggleTask(String id, bool isCompleted) {
    final index = _tasks.indexWhere((task) => task.id == id);

    if (index == -1) return;

    _tasks[index].isCompleted = isCompleted;
    notifyListeners();
  }

  void deleteTask(String id) {
    _tasks.removeWhere((task) => task.id == id);
    notifyListeners();
  }
}
