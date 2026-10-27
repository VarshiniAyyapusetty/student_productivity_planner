import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/task_provider.dart';
import '../providers/study_session_provider.dart';

class InsightsScreen extends StatelessWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final taskProvider = context.watch<TaskProvider>();
    final studyProvider = context.watch<StudySessionProvider>();
    final theme = Theme.of(context);

    final totalTasks = taskProvider.totalTasks;
    final completedTasks = taskProvider.completedTasks;
    final pendingTasks = taskProvider.pendingTasks;
    final progress = taskProvider.completionProgress;
    final sessions = studyProvider.sessions;
    final totalStudyMinutes = studyProvider.totalMinutes;

    final subjectMinutes = <String, int>{};
    for (final session in sessions) {
      subjectMinutes.update(
        session.subject,
        (minutes) => minutes + session.durationMinutes,
        ifAbsent: () => session.durationMinutes,
      );
    }

    final sortedSubjects = subjectMinutes.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final mostStudiedSubject = sortedSubjects.isEmpty
        ? null
        : sortedSubjects.first;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Productivity Insights',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: studyProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Text(
                  'Your Progress 📊',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Understand your study habits and track your progress.',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 24),

                // Task completion overview
                _sectionTitle(context, 'Task Overview'),
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Completion rate',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            Text(
                              '${(progress * 100).round()}%',
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: progress,
                            minHeight: 10,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: _metric(
                                context,
                                'Total',
                                totalTasks.toString(),
                                Icons.task_alt,
                                Colors.blue,
                              ),
                            ),
                            Expanded(
                              child: _metric(
                                context,
                                'Completed',
                                completedTasks.toString(),
                                Icons.check_circle_outline,
                                Colors.green,
                              ),
                            ),
                            Expanded(
                              child: _metric(
                                context,
                                'Pending',
                                pendingTasks.toString(),
                                Icons.pending_actions,
                                Colors.orange,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                // Study time overview
                _sectionTitle(context, 'Study Time'),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _summaryCard(
                        context,
                        title: 'Total planned',
                        value: _formatDuration(totalStudyMinutes),
                        subtitle: 'Across all sessions',
                        icon: Icons.schedule,
                        color: Colors.deepPurple,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _summaryCard(
                        context,
                        title: 'Sessions',
                        value: sessions.length.toString(),
                        subtitle: 'Planned sessions',
                        icon: Icons.menu_book_outlined,
                        color: Colors.teal,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 28),

                // Subject-wise study time
                _sectionTitle(context, 'Subject Breakdown'),
                const SizedBox(height: 12),

                if (sortedSubjects.isEmpty)
                  const Card(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Text(
                        'No study data yet. Add study sessions to see '
                        'your subject-wise breakdown.',
                      ),
                    ),
                  )
                else
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: sortedSubjects.map((entry) {
                          final share = totalStudyMinutes == 0
                              ? 0.0
                              : entry.value / totalStudyMinutes;

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 18),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        entry.key,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    Text(_formatDuration(entry.value)),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: LinearProgressIndicator(
                                    value: share,
                                    minHeight: 8,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),

                const SizedBox(height: 28),

                // Productivity summary
                _sectionTitle(context, 'Your Highlights'),
                const SizedBox(height: 12),

                _highlightCard(
                  context,
                  icon: Icons.emoji_events_outlined,
                  color: Colors.amber.shade800,
                  title: totalTasks == 0
                      ? 'Start your productivity journey'
                      : progress == 1
                      ? 'All tasks completed!'
                      : 'Keep making progress',
                  description: totalTasks == 0
                      ? 'Add your first task to start tracking your progress.'
                      : progress == 1
                      ? 'You have completed every task currently on your list.'
                      : '$pendingTasks task(s) remain. Complete them one at a time.',
                ),

                const SizedBox(height: 12),

                _highlightCard(
                  context,
                  icon: Icons.auto_graph,
                  color: Colors.indigo,
                  title: mostStudiedSubject == null
                      ? 'Plan your first study session'
                      : 'Top planned subject: ${mostStudiedSubject.key}',
                  description: mostStudiedSubject == null
                      ? 'Create study sessions to discover which subjects get the most time.'
                      : '${_formatDuration(mostStudiedSubject.value)} planned for this subject across your saved sessions.',
                ),

                const SizedBox(height: 24),
                Text(
                  'Study durations reflect planned session lengths, '
                  'not actual tracked study time.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
    );
  }

  Widget _sectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge
          ?.copyWith(fontWeight: FontWeight.bold),
    );
  }

  Widget _metric(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        Text(title, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }

  Widget _summaryCard(
    BuildContext context, {
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 14),
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }

  Widget _highlightCard(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required String title,
    required String description,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: color.withValues(alpha: 0.12),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Text(description),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(int minutes) {
    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;

    if (hours == 0) return '${remainingMinutes}m';
    if (remainingMinutes == 0) return '${hours}h';
    return '${hours}h ${remainingMinutes}m';
  }
}
