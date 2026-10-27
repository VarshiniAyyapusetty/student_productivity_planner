import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../main.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';
import '../providers/study_session_provider.dart';
import '../services/study_tip_service.dart';
import '../providers/profile_provider.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _heroAnimation;
  late final Animation<double> _tasksStatAnimation;
  late final Animation<double> _studyStatAnimation;
  late final Animation<double> _completedStatAnimation;
  late final Animation<double> _sessionsStatAnimation;
  late final Animation<double> _tasksSectionAnimation;
  late final Animation<double> _sessionsSectionAnimation;
  late Future<String> _studyTipFuture;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _heroAnimation = _makeEntranceAnimation(0.0, 0.42);
    _tasksStatAnimation = _makeEntranceAnimation(0.18, 0.58);
    _studyStatAnimation = _makeEntranceAnimation(0.27, 0.67);
    _completedStatAnimation = _makeEntranceAnimation(0.36, 0.76);
    _sessionsStatAnimation = _makeEntranceAnimation(0.45, 0.85);
    _tasksSectionAnimation = _makeEntranceAnimation(0.48, 0.88);
    _sessionsSectionAnimation = _makeEntranceAnimation(0.60, 1.0);

    _studyTipFuture = StudyTipService().fetchStudyTip();

    _controller.forward();
  }

  Animation<double> _makeEntranceAnimation(double start, double end) {
    return CurvedAnimation(
      parent: _controller,
      curve: Interval(start, end, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _enter(Animation<double> animation, Widget child) {
    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.12),
          end: Offset.zero,
        ).animate(animation),
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final taskProvider = context.watch<TaskProvider>();
    final studyProvider = context.watch<StudySessionProvider>();

    final tasks = taskProvider.tasks;
    final pendingTasks = tasks.where((task) => !task.isCompleted).toList();
    final todaySessions = studyProvider.todaySessions;
    final completedTasks = taskProvider.completedTasks;
    final totalTasks = taskProvider.totalTasks;
    final todayMinutes = studyProvider.todayMinutes;

    pendingTasks.sort((a, b) {
      if (a.dueDate == null && b.dueDate == null) return 0;
      if (a.dueDate == null) return 1;
      if (b.dueDate == null) return -1;
      return a.dueDate!.compareTo(b.dueDate!);
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Study Planner',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              return IconButton(
                tooltip: themeProvider.isDarkMode
                    ? 'Switch to light mode'
                    : 'Switch to dark mode',
                icon: Icon(
                  themeProvider.isDarkMode
                      ? Icons.light_mode_outlined
                      : Icons.dark_mode_outlined,
                ),
                onPressed: () {
                  themeProvider.toggleTheme(!themeProvider.isDarkMode);
                },
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(18, 12, 18, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _enter(
              _heroAnimation,
              _buildWelcomeHeader(context, pendingTasks.length),
            ),
            const SizedBox(height: 20),
            _enter(
              _heroAnimation,
              _buildProgressCard(
                context,
                completedTasks,
                totalTasks,
                taskProvider.completionProgress,
              ),
            ),
            const SizedBox(height: 18),

            // REST API: Daily Inspiration card.
            _enter(_tasksSectionAnimation, _buildStudyTipCard(context)),

            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _enter(
                    _tasksStatAnimation,
                    _buildStatCard(
                      context,
                      title: 'All tasks',
                      value: totalTasks.toString(),
                      subtitle: '${pendingTasks.length} remaining',
                      icon: Icons.checklist_rounded,
                      accent: const Color(0xFF4D8DFF),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _enter(
                    _studyStatAnimation,
                    _buildStatCard(
                      context,
                      title: 'Study time',
                      value: '${todayMinutes ~/ 60}h ${todayMinutes % 60}m',
                      subtitle: 'Today',
                      icon: Icons.timer_rounded,
                      accent: const Color(0xFFFFA34D),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _enter(
                    _completedStatAnimation,
                    _buildStatCard(
                      context,
                      title: 'Completed',
                      value: completedTasks.toString(),
                      subtitle: 'Tasks finished',
                      icon: Icons.task_alt_rounded,
                      accent: const Color(0xFF39B982),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _enter(
                    _sessionsStatAnimation,
                    _buildStatCard(
                      context,
                      title: 'Sessions',
                      value: todaySessions.length.toString(),
                      subtitle: 'Logged today',
                      icon: Icons.menu_book_rounded,
                      accent: const Color(0xFF9A78E8),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),
            _enter(
              _tasksSectionAnimation,
              _buildSectionHeader(
                context,
                title: 'Up next',
                subtitle: 'A short list to keep you moving',
                icon: Icons.upcoming_rounded,
              ),
            ),
            const SizedBox(height: 12),
            _enter(
              _tasksSectionAnimation,
              _buildUpcomingTasks(context, tasks, pendingTasks),
            ),
            const SizedBox(height: 28),
            _enter(
              _sessionsSectionAnimation,
              _buildSectionHeader(
                context,
                title: "Today's study log",
                subtitle: 'Your focused work so far',
                icon: Icons.history_rounded,
              ),
            ),
            const SizedBox(height: 12),
            _enter(
              _sessionsSectionAnimation,
              _buildStudySessions(context, studyProvider),
            ),
          ],
        ),
      ),
    );
  }

  void _refreshStudyTip() {
    setState(() {
      _studyTipFuture = StudyTipService().fetchStudyTip();
    });
  }

  Widget _buildStudyTipCard(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondaryContainer.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.55),
        ),
      ),
      child: FutureBuilder<String>(
        future: _studyTipFuture,
        builder: (context, snapshot) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.lightbulb_rounded,
                    color: theme.colorScheme.secondary,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'DAILY INSPIRATION',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.secondary,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Get another tip',
                    onPressed:
                        snapshot.connectionState == ConnectionState.waiting
                        ? null
                        : _refreshStudyTip,
                    icon: const Icon(Icons.refresh_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (snapshot.connectionState == ConnectionState.waiting)
                const Row(
                  children: [
                    SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    SizedBox(width: 12),
                    Expanded(child: Text('Fetching a fresh tip...')),
                  ],
                )
              else if (snapshot.hasError || !snapshot.hasData)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Could not load a tip right now.'),
                    const SizedBox(height: 6),
                    TextButton.icon(
                      onPressed: _refreshStudyTip,
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('Try again'),
                    ),
                  ],
                )
              else
                Text(
                  snapshot.data!,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    height: 1.4,
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  

Widget _buildWelcomeHeader(BuildContext context, int pendingCount) {
  final theme = Theme.of(context);
  final colors = theme.colorScheme;
  final profile = context.watch<ProfileProvider>().profile;

  final name = profile.name.trim();
  final firstName = name.isEmpty ? 'Student' : name.split(' ').first;
  final greeting = pendingCount == 0
      ? 'You are all caught up!'
      : 'You have $pendingCount task${pendingCount == 1 ? '' : 's'} to tackle.';

  final now = DateTime.now();
  const months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];
  const weekdays = [
    'Monday', 'Tuesday', 'Wednesday', 'Thursday',
    'Friday', 'Saturday', 'Sunday',
  ];
  final dateLabel = '${weekdays[now.weekday - 1]}, '
      '${months[now.month - 1]} ${now.day}';

  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: colors.primaryContainer.withValues(alpha: 0.55),
      borderRadius: BorderRadius.circular(24),
      border: Border.all(
        color: colors.primary.withValues(alpha: 0.14),
      ),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dateLabel.toUpperCase(),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: colors.primary,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.1,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Hello, $firstName 👋',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.8,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: colors.primary,
                borderRadius: BorderRadius.circular(18),
              ),
              alignment: Alignment.center,
              child: Text(
                name.isEmpty ? '?' : name[0].toUpperCase(),
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: colors.onPrimary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Text(
          greeting,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: colors.onSurfaceVariant,
            height: 1.4,
          ),
        ),
      ],
    ),
  );
}



  Widget _buildProgressCard(
    BuildContext context,
    int completed,
    int total,
    double progress,
  ) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [colors.primary, colors.tertiary],
        ),
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: colors.primary.withValues(alpha: 0.22),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  "TODAY'S FOCUS",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.4,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  total == 0 ? 'Ready' : '${(progress * 100).round()}% done',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            total == 0
                ? 'Start small. Build momentum.'
                : '$completed of $total tasks done',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 23,
              height: 1.2,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            total == 0
                ? 'Add a task to give your study day a clear starting point.'
                : total == completed
                ? 'Great work — you completed every task on your list.'
                : 'Keep your focus on the next small step.',
            style: const TextStyle(color: Colors.white70, height: 1.4),
          ),
          const SizedBox(height: 20),
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: progress),
            duration: const Duration(milliseconds: 1200),
            curve: Curves.easeOutCubic,
            builder: (context, animatedProgress, child) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: LinearProgressIndicator(
                  value: animatedProgress,
                  minHeight: 10,
                  backgroundColor: Colors.white.withValues(alpha: 0.25),
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  
Widget _buildStatCard(
  BuildContext context, {
  required String title,
  required String value,
  required String subtitle,
  required IconData icon,
  required Color accent,
}) {
  final theme = Theme.of(context);
  final colors = theme.colorScheme;

  return Container(
    constraints: const BoxConstraints(minHeight: 158),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: colors.surface,
      borderRadius: BorderRadius.circular(22),
      border: Border.all(
        color: accent.withValues(alpha: 0.25),
      ),
      boxShadow: [
        BoxShadow(
          color: accent.withValues(alpha: 0.07),
          blurRadius: 16,
          offset: const Offset(0, 6),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.13),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(
                icon,
                color: accent,
                size: 25,
              ),
            ),
            Icon(
              Icons.north_east_rounded,
              color: accent.withValues(alpha: 0.7),
              size: 19,
            ),
          ],
        ),
        const SizedBox(height: 18),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w900,
            letterSpacing: -0.8,
            color: colors.onSurface,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w800,
            color: colors.onSurface,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          subtitle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.bodySmall?.copyWith(
            color: colors.onSurfaceVariant,
          ),
        ),
      ],
    ),
  );
}


  Widget _buildSectionHeader(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: theme.colorScheme.onPrimaryContainer),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildUpcomingTasks(
    BuildContext context,
    List<Task> tasks,
    List<Task> pendingTasks,
  ) {
    final theme = Theme.of(context);

    if (tasks.isEmpty) {
      return _buildEmptyCard(
        context,
        icon: Icons.event_available_rounded,
        title: 'Nothing on the list yet',
        message: 'Add your first task and it will show up here.',
      );
    }

    if (pendingTasks.isEmpty) {
      return _buildEmptyCard(
        context,
        icon: Icons.celebration_rounded,
        title: 'All tasks completed',
        message: 'Nice work. You have cleared your current list.',
      );
    }

    return Column(
      children: pendingTasks.take(3).toList().asMap().entries.map((entry) {
        final index = entry.key;
        final task = entry.value;
        final priorityColor = switch (task.priority.name) {
          'high' => theme.colorScheme.error,
          'medium' => const Color(0xFFE59A26),
          _ => const Color(0xFF39A879),
        };

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
            ),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 5,
            ),
            leading: Container(
              width: 42,
              height: 42,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: priorityColor.withValues(alpha: 0.13),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Text(
                '${index + 1}'.padLeft(2, '0'),
                style: TextStyle(
                  color: priorityColor,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            title: Text(
              task.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 5),
              child: Text(
                task.dueDate == null
                    ? '${_priorityLabel(task.priority)} priority'
                    : '${_priorityLabel(task.priority)} priority • Due ${_formatDate(task.dueDate!)}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            trailing: Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildStudySessions(
    BuildContext context,
    StudySessionProvider studyProvider,
  ) {
    final sessions = studyProvider.todaySessions;

    if (studyProvider.isLoading) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (sessions.isEmpty) {
      return _buildEmptyCard(
        context,
        icon: Icons.menu_book_rounded,
        title: 'No study sessions yet',
        message: 'Your sessions for today will appear here.',
      );
    }

    return Column(
      children: sessions.take(3).map((session) {
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(18),
          ),
          child: ListTile(
            leading: const CircleAvatar(child: Icon(Icons.menu_book_rounded)),
            title: Text(
              session.subject,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            subtitle: Text(
              session.goal.isEmpty
                  ? '${session.durationMinutes} minutes'
                  : '${session.durationMinutes} minutes • ${session.goal}',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: const Icon(Icons.check_circle_outline_rounded),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildEmptyCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String message,
  }) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, size: 34, color: theme.colorScheme.primary),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static String _priorityLabel(TaskPriority priority) {
    switch (priority.name) {
      case 'low':
        return 'Low';
      case 'high':
        return 'High';
      default:
        return 'Medium';
    }
  }

  static String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
