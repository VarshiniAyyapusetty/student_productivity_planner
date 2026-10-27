
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

    await tester.pump();
await tester.pump(const Duration(milliseconds: 100));

    expect(find.byType(DashboardScreen), findsOneWidget);
    expect(find.text('Study Planner'), findsOneWidget);
    expect(find.text("Today's Overview"), findsOneWidget);
    expect(find.text('Upcoming Tasks'), findsOneWidget);
    expect(find.text('No tasks yet'), findsOneWidget);
  });
}
