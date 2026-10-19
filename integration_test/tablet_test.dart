import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:my_communication_academy/data/course_repository.dart';
import 'package:my_communication_academy/data/local_store.dart';
import 'package:my_communication_academy/data/course.dart';
import 'package:my_communication_academy/provided/fake_course_api.dart';
import 'package:my_communication_academy/ui/academy_app.dart';

class OfflineRepository implements CourseRepository {
  @override
  Future<List<Course>> fetchCatalog({
    String query = '',
    String? category,
  }) async => throw const CourseFailure(FailureKind.temporary);
  @override
  Future<CourseDetail> fetchDetail(String id) async =>
      throw const CourseFailure(FailureKind.temporary);
}

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('tablet side by side in both languages', (tester) async {
    await tester.pumpWidget(
      AcademyApp(repository: ApiCourseRepository(FakeCourseApi())),
    );
    await tester.pumpAndSettle();
    await binding.convertFlutterSurfaceToImage();
    await tester.pumpAndSettle();
    expect(find.text('Your next skill starts here'), findsOneWidget);
    await tester.tap(find.text('Fundamentals of 5G NR'));
    await tester.pumpAndSettle();
    expect(find.text('Course lessons'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
    await binding.takeScreenshot('tablet-en');
    await tester.tap(find.text('العربية'));
    await tester.pumpAndSettle();
    expect(find.text('دروس الدورة'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
    await binding.takeScreenshot('tablet-ar');
    expect(tester.takeException(), isNull);
  });
  testWidgets(
    'Android preferences survive a new app instance and API failure',
    (tester) async {
      final store = PreferencesLocalStore();
      await store.savePreferences('Fundamentals', 'telecom', 'en');
      await store.saveCatalog(
        CatalogSnapshot(
          query: 'Fundamentals',
          category: 'telecom',
          courses: const [
            Course(
              id: 'c-101',
              title: 'Fundamentals of 5G NR',
              category: 'telecom',
              level: 'beginner',
              durationMinutes: 240,
              price: 49,
              rating: 4.7,
            ),
          ],
          savedAt: DateTime.now(),
        ),
      );
      await tester.pumpWidget(
        AcademyApp(
          repository: OfflineRepository(),
          store: PreferencesLocalStore(),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Fundamentals of 5G NR'), findsOneWidget);
      expect(find.text('Courses could not load'), findsNothing);
      expect(find.textContaining('Saved courses'), findsOneWidget);
      expect(
        tester.widget<TextField>(find.byType(TextField)).controller!.text,
        'Fundamentals',
      );
      await binding.takeScreenshot('tablet-saved-catalog');
      await tester.pumpWidget(const SizedBox());
      await store.savePreferences('', null, 'en');
    },
  );
}
