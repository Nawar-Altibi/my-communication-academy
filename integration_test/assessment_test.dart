import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:my_communication_academy/data/course_repository.dart';
import 'package:my_communication_academy/provided/fake_course_api.dart';
import 'package:my_communication_academy/ui/academy_app.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('default API acceptance flow on Android', (tester) async {
    await tester.pumpWidget(
      AcademyApp(repository: ApiCourseRepository(FakeCourseApi())),
    );
    await tester.pumpAndSettle();
    await binding.convertFlutterSurfaceToImage();
    await tester.pumpAndSettle();
    expect(find.text('8 courses'), findsOneWidget);
    await binding.takeScreenshot('catalog-en');

    Future<void> search(String value) async {
      await tester.ensureVisible(find.byType(TextField));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(TextField));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), value);
      await tester.pump(const Duration(milliseconds: 350));
      // Wait for the fake API even if its loading sliver is offscreen.
      await tester.pump(const Duration(milliseconds: 1300));
      await tester.pumpAndSettle();
    }

    Future<void> back() async {
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
    }

    Future<void> open(String title) async {
      await tester.ensureVisible(find.text(title).first);
      await tester.pumpAndSettle();
      await tester.tap(find.text(title).first);
      await tester.pumpAndSettle();
    }

    await search('net');
    expect(find.text('2 courses'), findsOneWidget);
    await search('zzz');
    expect(find.text('No courses found'), findsOneWidget);
    await search('fail');
    expect(find.text('Courses could not load'), findsOneWidget);
    await binding.takeScreenshot('catalog-error-en');
    await search('Python');
    // The fifth catalog call is deliberately unsuccessful.
    expect(find.text('Courses could not load'), findsOneWidget);
    await tester.tap(find.text('Try again'));
    await tester.pumpAndSettle();
    await open('Python for Network Engineers');
    expect(find.text('Could not load this course'), findsOneWidget);
    await tester.tap(find.text('Try again'));
    await tester.pumpAndSettle();
    expect(find.text('Course lessons'), findsOneWidget);
    await back();

    await search('Fundamentals');
    await open('Fundamentals of 5G NR');
    expect(
      find.text('43 min known · 1 lesson duration(s) unavailable'),
      findsOneWidget,
    );
    await tester.ensureVisible(find.text('Why 5G?'));
    await tester.tap(find.text('Why 5G?'));
    await tester.pumpAndSettle();
    expect(find.text('Playing: Why 5G?'), findsOneWidget);
    await tester.ensureVisible(find.text('NR numerology'));
    await tester.tap(find.text('NR numerology'));
    await tester.pumpAndSettle();
    expect(
      find.text('Enroll in this course to access this lesson.'),
      findsOneWidget,
    );
    await binding.takeScreenshot('detail-en');
    await back();
    await search('Optical');
    await open('Optical Fiber Transmission Systems');
    expect(find.text('Course no longer available'), findsOneWidget);
    await back();
    await search('Introduction');
    await open('Introduction to Machine Learning');
    expect(find.text('No lessons available yet'), findsOneWidget);
    await back();
    await search('LTE');
    if (find.text('Try again').evaluate().isNotEmpty) {
      await tester.tap(find.text('Try again'));
      await tester.pumpAndSettle();
    }
    await open('LTE Radio Network Planning');
    await tester.ensureVisible(find.text('Propagation models'));
    await tester.tap(find.text('Propagation models'));
    await tester.pumpAndSettle();
    expect(find.text('Playing: Propagation models'), findsOneWidget);
    await back();

    await search('');
    await tester.tap(find.text('عربي'));
    await tester.pumpAndSettle();
    await binding.takeScreenshot('catalog-ar');
    await search('Fundamentals');
    if (find.text('إعادة المحاولة').evaluate().isNotEmpty) {
      await tester.tap(find.text('إعادة المحاولة'));
      await tester.pumpAndSettle();
    }
    await open('Fundamentals of 5G NR');
    expect(find.text('دروس الدورة'), findsOneWidget);
    await binding.takeScreenshot('detail-ar');
    expect(tester.takeException(), isNull);
  });
}
