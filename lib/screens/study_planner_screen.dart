import 'package:flutter/material.dart';

class StudyPlannerScreen extends StatefulWidget {
  const StudyPlannerScreen({super.key});

  @override
  State<StudyPlannerScreen> createState() => _StudyPlannerScreenState();
}

class _StudyPlannerScreenState extends State<StudyPlannerScreen> {
  final List<_StudySession> _sessions = [];

  final List<String> _subjects = [
    'Data Structures',
    'Database Management',
    'Operating Systems',
    'Computer Networks',
    'Java Programming',
    'Mathematics',
    'Other',
  ];

  DateTime _selectedDate = DateUtils.dateOnly(DateTime.now());

  List<_StudySession> get _selectedSessions {
    return _sessions.where((session) {
      return DateUtils.isSameDay(session.date, _selectedDate);
    }).toList()..sort((a, b) => a.date.compareTo(b.date));
  }

  int get _totalMinutes => _selectedSessions.fold(
    0,
    (total, session) => total + session.durationMinutes,
  );

  Future<void> _addSession() async {
    final session = await showDialog<_StudySession>(
      context: context,
      builder: (_) =>
          _StudySessionDialog(subjects: _subjects, initialDate: _selectedDate),
    );

    if (!mounted || session == null) return;

    setState(() {
      _sessions.add(session);
      _selectedDate = session.date;
    });
  }

  void _changeWeek(int offset) {
    setState(() {
      _selectedDate = _selectedDate.add(Duration(days: offset * 7));
    });
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${date.day} ${months[date.month - 1]}';
  }

  @override
  Widget build(BuildContext context) {
    final weekStart = _selectedDate.subtract(
      Duration(days: _selectedDate.weekday - 1),
    );
    final sessions = _selectedSessions;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Study Planner',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            tooltip: 'Add study session',
            onPressed: _addSession,
            icon: const Icon(Icons.add_circle_outline),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addSession,
        icon: const Icon(Icons.add),
        label: const Text('Plan session'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 25,
                    child: Icon(Icons.menu_book_outlined, size: 28),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Your study time',
                          style: TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${_totalMinutes ~/ 60}h ${_totalMinutes % 60}m',
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        Text('${sessions.length} sessions on selected day'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              IconButton(
                onPressed: () => _changeWeek(-1),
                icon: const Icon(Icons.chevron_left),
              ),
              Expanded(
                child: Text(
                  '${_formatDate(weekStart)} – '
                  '${_formatDate(weekStart.add(const Duration(days: 6)))}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              IconButton(
                onPressed: () => _changeWeek(1),
                icon: const Icon(Icons.chevron_right),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: List.generate(7, (index) {
              final day = weekStart.add(Duration(days: index));
              final isSelected = DateUtils.isSameDay(day, _selectedDate);
              final isToday = DateUtils.isSameDay(day, DateTime.now());

              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: () {
                      setState(() {
                        _selectedDate = day;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Theme.of(context).colorScheme.primary
                            : null,
                        borderRadius: BorderRadius.circular(14),
                        border: isToday && !isSelected
                            ? Border.all(
                                color: Theme.of(context).colorScheme.primary,
                              )
                            : null,
                      ),
                      child: Column(
                        children: [
                          Text(
                            ['M', 'T', 'W', 'T', 'F', 'S', 'S'][index],
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${day.day}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isSelected ? Colors.white : null,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 28),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Study sessions',
                style: Theme.of(context).textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              Text(
                '${sessions.length} planned',
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (sessions.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 32,
                  horizontal: 20,
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.event_note_outlined,
                      size: 48,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'No sessions planned',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Add a study session to organise your day.',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
          else
            ...sessions.map((session) {
              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  leading: CircleAvatar(
                    child: Text(
                      session.subject.isEmpty
                          ? '?'
                          : session.subject[0].toUpperCase(),
                    ),
                  ),
                  title: Text(
                    session.subject,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (session.goal.isNotEmpty) Text(session.goal),
                      const SizedBox(height: 4),
                      Text(
                        '${session.durationMinutes} minutes • '
                        '${_formatDate(session.date)}',
                      ),
                    ],
                  ),
                  isThreeLine: session.goal.isNotEmpty,
                  trailing: IconButton(
                    tooltip: 'Delete session',
                    onPressed: () {
                      setState(() {
                        _sessions.removeWhere((item) => item.id == session.id);
                      });
                    },
                    icon: const Icon(Icons.delete_outline),
                  ),
                ),
              );
            }),
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}

class _StudySessionDialog extends StatefulWidget {
  const _StudySessionDialog({
    required this.subjects,
    required this.initialDate,
  });

  final List<String> subjects;
  final DateTime initialDate;

  @override
  State<_StudySessionDialog> createState() => _StudySessionDialogState();
}

class _StudySessionDialogState extends State<_StudySessionDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _durationController;
  late final TextEditingController _goalController;

  late String _selectedSubject;
  late DateTime _sessionDate;

  @override
  void initState() {
    super.initState();
    _durationController = TextEditingController(text: '60');
    _goalController = TextEditingController();
    _selectedSubject = widget.subjects.first;
    _sessionDate = widget.initialDate;
  }

  @override
  void dispose() {
    _durationController.dispose();
    _goalController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _sessionDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (picked != null && mounted) {
      setState(() {
        _sessionDate = DateUtils.dateOnly(picked);
      });
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final session = _StudySession(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      subject: _selectedSubject,
      durationMinutes: int.parse(_durationController.text),
      goal: _goalController.text.trim(),
      date: _sessionDate,
    );

    Navigator.of(context).pop(session);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Plan a study session'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                initialValue: _selectedSubject,
                decoration: const InputDecoration(
                  labelText: 'Subject',
                  border: OutlineInputBorder(),
                ),
                items: widget.subjects.map((subject) {
                  return DropdownMenuItem<String>(
                    value: subject,
                    child: Text(subject),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedSubject = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _durationController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Duration (minutes)',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  final minutes = int.tryParse(value ?? '');

                  if (minutes == null || minutes <= 0) {
                    return 'Enter a duration greater than zero';
                  }

                  if (minutes > 1440) {
                    return 'Duration cannot exceed 1440 minutes';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _goalController,
                decoration: const InputDecoration(
                  labelText: 'Study goal (optional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 14),
              OutlinedButton.icon(
                onPressed: _pickDate,
                icon: const Icon(Icons.calendar_today),
                label: Text(
                  '${_sessionDate.day}/${_sessionDate.month}/'
                  '${_sessionDate.year}',
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(onPressed: _submit, child: const Text('Add session')),
      ],
    );
  }
}

class _StudySession {
  const _StudySession({
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
}
