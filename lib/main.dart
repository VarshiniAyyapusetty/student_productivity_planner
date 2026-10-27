import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/task_provider.dart';
import 'providers/study_session_provider.dart';
import 'screens/main_navigation_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/tasks_screen.dart';
import 'screens/study_planner_screen.dart';
import 'screens/insights_screen.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const StudentProductivityPlanner(),
    ),
  );
}

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;

  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  void toggleTheme(bool isDark) {
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }
}

class StudentProductivityPlanner extends StatelessWidget {
  const StudentProductivityPlanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => TaskProvider()..loadTasks()),
            ChangeNotifierProvider(
              create: (_) => StudySessionProvider()..loadSessions(),
            ),
          ],
          child: MaterialApp(
            title: 'Student Productivity Planner',
            debugShowCheckedModeBanner: false,
            themeMode: themeProvider.themeMode,
            theme: ThemeData(
              useMaterial3: true,
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.indigo,
                brightness: Brightness.light,
              ),
              scaffoldBackgroundColor: const Color(0xFFF7F8FC),
              cardTheme: CardThemeData(
                elevation: 0,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
            darkTheme: ThemeData(
              useMaterial3: true,
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.indigo,
                brightness: Brightness.dark,
              ),
              cardTheme: CardThemeData(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
            initialRoute: '/',
            routes: {
              '/': (context) => const MainNavigationScreen(),
              '/dashboard': (context) => const DashboardScreen(),
              '/tasks': (context) => const TasksScreen(),
              '/study': (context) => const StudyPlannerScreen(),
              '/insights': (context) => const InsightsScreen(),
            },
          ),
        );
      },
    );
  }
}
