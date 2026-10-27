import 'package:flutter/material.dart';

import '../models/task.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  final List<Task> _tasks = [];
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  TaskPriority _selectedPriority = TaskPriority.medium;
  DateTime? _selectedDate;

  int get _completedCount => _tasks.where((task) => task.isCompleted).length;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _showAddTaskDialog() async {
    _titleController.clear();
    _descriptionController.clear();
    _selectedPriority = TaskPriority.medium;
    _selectedDate = null;

    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Add New Task'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: _titleController,
                      autofocus: true,
                      decoration: const InputDecoration(
                        labelText: 'Task title',
                        hintText: 'e.g. Complete DSA assignment',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _descriptionController,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: 'Description (optional)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<TaskPriority>(
                      initialValue: _selectedPriority,
                      decoration: const InputDecoration(
                        labelText: 'Priority',
                        border: OutlineInputBorder(),
                      ),
                      items: TaskPriority.values.map((priority) {
                        return DropdownMenuItem(
                          value: priority,
                          child: Text(_priorityLabel(priority)),
                        );
                      }).toList(),
                      onChanged: (priority) {
                        if (priority != null) {
                          setDialogState(() {
                            _selectedPriority = priority;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(
                            const Duration(days: 3650),
                          ),
                        );

                        if (date != null) {
                          setDialogState(() {
                            _selectedDate = date;
                          });
                        }
                      },
                      icon: const Icon(Icons.calendar_month),
                      label: Text(
                        _selectedDate == null
                            ? 'Choose due date'
                            : 'Due: ${_formatDate(_selectedDate!)}',
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext, false),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () {
                    if (_titleController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please enter a task title.'),
                        ),
                      );
                      return;
                    }

                    Navigator.pop(dialogContext, true);
                  },
                  child: const Text('Add Task'),
                ),
              ],
            );
          },
        );
      },
    );

    if (result == true && mounted) {
      setState(() {
        _tasks.add(
          Task(
            id: DateTime.now().microsecondsSinceEpoch.toString(),
            title: _titleController.text.trim(),
            description: _descriptionController.text.trim(),
            dueDate: _selectedDate,
            priority: _selectedPriority,
          ),
        );
      });
    }
  }

  void _toggleTask(Task task, bool? value) {
    setState(() {
      task.isCompleted = value ?? false;
    });
  }

  void _deleteTask(Task task) {
    setState(() {
      _tasks.removeWhere((item) => item.id == task.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final completed = _completedCount;
    final total = _tasks.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Tasks & Assignments',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddTaskDialog,
        icon: const Icon(Icons.add),
        label: const Text('Add Task'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$completed of $total tasks completed',
                      style: Theme.of(context).textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    LinearProgressIndicator(
                      value: total == 0 ? 0 : completed / total,
                      minHeight: 8,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _tasks.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.task_alt, size: 64, color: Colors.grey),
                          SizedBox(height: 12),
                          Text(
                            'No tasks yet',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 6),
                          Text('Tap Add Task to plan your day.'),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: _tasks.length,
                      itemBuilder: (context, index) {
                        final task = _tasks[index];

                        return Card(
                          margin: const EdgeInsets.only(bottom: 10),
                          child: ListTile(
                            leading: Checkbox(
                              value: task.isCompleted,
                              onChanged: (value) => _toggleTask(task, value),
                            ),
                            title: Text(
                              task.title,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                decoration: task.isCompleted
                                    ? TextDecoration.lineThrough
                                    : null,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (task.description.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Text(task.description),
                                  ),
                                const SizedBox(height: 4),
                                Text(
                                  '${_priorityLabel(task.priority)} priority'
                                  '${task.dueDate == null ? '' : ' • Due ${_formatDate(task.dueDate!)}'}',
                                ),
                              ],
                            ),
                            isThreeLine: task.description.isNotEmpty,
                            trailing: IconButton(
                              tooltip: 'Delete task',
                              icon: const Icon(Icons.delete_outline),
                              onPressed: () => _deleteTask(task),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  static String _priorityLabel(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.low:
        return 'Low';
      case TaskPriority.medium:
        return 'Medium';
      case TaskPriority.high:
        return 'High';
    }
  }

  static String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
