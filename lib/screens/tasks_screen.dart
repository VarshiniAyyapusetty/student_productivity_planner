import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/task.dart';
import '../providers/task_provider.dart';

enum _TaskFilter { all, pending, completed, high, medium, low }

enum _TaskSort { dueDate, priority, title }

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  TaskPriority _selectedPriority = TaskPriority.medium;
  DateTime? _selectedDate;

  _TaskFilter _selectedFilter = _TaskFilter.all;
  _TaskSort _selectedSort = _TaskSort.dueDate;

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
                        return DropdownMenuItem<TaskPriority>(
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
                        final now = DateTime.now();

                        final date = await showDatePicker(
                          context: context,
                          initialDate: _selectedDate ?? now,
                          firstDate: DateTime(now.year, now.month, now.day),
                          lastDate: now.add(const Duration(days: 3650)),
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

    if (result != true || !mounted) return;

    final task = Task(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      dueDate: _selectedDate,
      priority: _selectedPriority,
    );

    context.read<TaskProvider>().addTask(task);
  }

  void _toggleTask(Task task, bool? value) {
    context.read<TaskProvider>().toggleTask(task.id, value ?? false);
  }

  void _deleteTask(Task task) {
    context.read<TaskProvider>().deleteTask(task.id);
  }

  List<Task> _getVisibleTasks(List<Task> allTasks) {
    final filteredTasks = allTasks.where((task) {
      switch (_selectedFilter) {
        case _TaskFilter.all:
          return true;
        case _TaskFilter.pending:
          return !task.isCompleted;
        case _TaskFilter.completed:
          return task.isCompleted;
        case _TaskFilter.high:
          return task.priority == TaskPriority.high;
        case _TaskFilter.medium:
          return task.priority == TaskPriority.medium;
        case _TaskFilter.low:
          return task.priority == TaskPriority.low;
      }
    }).toList();

    switch (_selectedSort) {
      case _TaskSort.dueDate:
        filteredTasks.sort((a, b) {
          if (a.dueDate == null && b.dueDate == null) {
            return a.title.toLowerCase().compareTo(b.title.toLowerCase());
          }
          if (a.dueDate == null) return 1;
          if (b.dueDate == null) return -1;

          return a.dueDate!.compareTo(b.dueDate!);
        });

      case _TaskSort.priority:
        const priorityOrder = {
          TaskPriority.high: 0,
          TaskPriority.medium: 1,
          TaskPriority.low: 2,
        };

        filteredTasks.sort((a, b) {
          return priorityOrder[a.priority]!.compareTo(
            priorityOrder[b.priority]!,
          );
        });

      case _TaskSort.title:
        filteredTasks.sort((a, b) {
          return a.title.toLowerCase().compareTo(b.title.toLowerCase());
        });
    }

    return filteredTasks;
  }

  @override
  Widget build(BuildContext context) {
    final taskProvider = context.watch<TaskProvider>();
    final allTasks = taskProvider.tasks;
    final tasks = _getVisibleTasks(allTasks);
    final completed = taskProvider.completedTasks;
    final total = taskProvider.totalTasks;

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
                      value: taskProvider.completionProgress,
                      minHeight: 8,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Filter and sorting controls.
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<_TaskFilter>(
                    initialValue: _selectedFilter,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'Filter',
                      prefixIcon: Icon(Icons.filter_list),
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 12,
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: _TaskFilter.all,
                        child: Text('All tasks'),
                      ),
                      DropdownMenuItem(
                        value: _TaskFilter.pending,
                        child: Text('Pending'),
                      ),
                      DropdownMenuItem(
                        value: _TaskFilter.completed,
                        child: Text('Completed'),
                      ),
                      DropdownMenuItem(
                        value: _TaskFilter.high,
                        child: Text('High priority'),
                      ),
                      DropdownMenuItem(
                        value: _TaskFilter.medium,
                        child: Text('Medium priority'),
                      ),
                      DropdownMenuItem(
                        value: _TaskFilter.low,
                        child: Text('Low priority'),
                      ),
                    ],
                    onChanged: (filter) {
                      if (filter != null) {
                        setState(() {
                          _selectedFilter = filter;
                        });
                      }
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<_TaskSort>(
                    initialValue: _selectedSort,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'Sort by',
                      prefixIcon: Icon(Icons.sort),
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 12,
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: _TaskSort.dueDate,
                        child: Text('Due date'),
                      ),
                      DropdownMenuItem(
                        value: _TaskSort.priority,
                        child: Text('Priority'),
                      ),
                      DropdownMenuItem(
                        value: _TaskSort.title,
                        child: Text('Title A–Z'),
                      ),
                    ],
                    onChanged: (sort) {
                      if (sort != null) {
                        setState(() {
                          _selectedSort = sort;
                        });
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            Text(
              '${tasks.length} ${tasks.length == 1 ? 'task' : 'tasks'} shown',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 8),

            Expanded(
              child: allTasks.isEmpty
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
                  : tasks.isEmpty
                  ? const Center(child: Text('No tasks match this filter.'))
                  : ListView.builder(
                      itemCount: tasks.length,
                      itemBuilder: (context, index) {
                        final task = tasks[index];

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
