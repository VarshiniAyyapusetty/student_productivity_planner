import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/task.dart';

class TaskProvider extends ChangeNotifier {
  static const String _storageKey = 'student_productivity_tasks';

  final List<Task> _tasks = [];
  bool _isLoading = true;

  List<Task> get tasks => List.unmodifiable(_tasks);
  bool get isLoading => _isLoading;

  int get totalTasks => _tasks.length;
  int get completedTasks => _tasks.where((task) => task.isCompleted).length;
  int get pendingTasks => totalTasks - completedTasks;

  double get completionProgress =>
      totalTasks == 0 ? 0 : completedTasks / totalTasks;

  Future<void> loadTasks() async {
    try {
      final preferences = await SharedPreferences.getInstance();
      final savedTasks = preferences.getString(_storageKey);

      if (savedTasks != null) {
        final decoded = jsonDecode(savedTasks) as List<dynamic>;
        _tasks
          ..clear()
          ..addAll(
            decoded.map(
              (item) => Task.fromJson(Map<String, dynamic>.from(item as Map)),
            ),
          );
      }
    } catch (error) {
      debugPrint('Could not load saved tasks: $error');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _saveTasks() async {
    try {
      final preferences = await SharedPreferences.getInstance();
      final encoded = jsonEncode(_tasks.map((task) => task.toJson()).toList());
      await preferences.setString(_storageKey, encoded);
    } catch (error) {
      debugPrint('Could not save tasks: $error');
    }
  }

  void addTask(Task task) {
    _tasks.add(task);
    notifyListeners();
    _saveTasks();
  }
  
  void updateTask(Task updatedTask) {
    final index = _tasks.indexWhere((task) => task.id == updatedTask.id);
    if (index == -1) return;

    _tasks[index] = updatedTask;
    notifyListeners();
    _saveTasks();
  }

  void toggleTask(String id, bool isCompleted) {
    final index = _tasks.indexWhere((task) => task.id == id);
    if (index == -1) return;

    _tasks[index].isCompleted = isCompleted;
    notifyListeners();
    _saveTasks();
  }

  void deleteTask(String id) {
    _tasks.removeWhere((task) => task.id == id);
    notifyListeners();
    _saveTasks();
  }
}
