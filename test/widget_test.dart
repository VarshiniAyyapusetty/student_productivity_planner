import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:student_productivity_planner/main.dart';
import 'package:student_productivity_planner/screens/dashboard_screen.dart';

void main() {
  testWidgets('Dashboard displays its main sections', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => ThemeProvider(),
        child: const StudentProductivityPlanner(),
      ),
    );

    // Allow the dashboard entrance animations to progress.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.byType(DashboardScreen), findsOneWidget);
    expect(find.text('Study Planner'), findsOneWidget);
    expect(find.text('YOUR DAY, AT A GLANCE'), findsOneWidget);
    expect(find.text("TODAY'S FOCUS"), findsOneWidget);
    expect(find.text('DAILY INSPIRATION'), findsOneWidget);
    expect(find.byTooltip('Get another tip'), findsOneWidget);
    expect(find.text('Up next'), findsOneWidget);
    expect(find.text("Today's study log"), findsOneWidget);
    expect(find.text('Nothing on the list yet'), findsOneWidget);
  });
}
