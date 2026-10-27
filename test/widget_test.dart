import 'package:flutter_test/flutter_test.dart';
import 'package:student_productivity_planner/main.dart';
import 'package:student_productivity_planner/screens/dashboard_screen.dart';

void main() {
  testWidgets('Dashboard displays its main sections', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const StudentProductivityPlanner());

    expect(find.byType(DashboardScreen), findsOneWidget);
    expect(find.text('Study Planner'), findsOneWidget);
    expect(find.text("Today's Overview"), findsOneWidget);
    expect(find.text('Upcoming Tasks'), findsOneWidget);
    expect(find.text('No tasks yet'), findsOneWidget);
  });
}
