import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_communication_academy/data/course.dart';
import 'package:my_communication_academy/data/course_repository.dart';
import 'package:my_communication_academy/provided/fake_course_api.dart';
import 'package:my_communication_academy/state/catalog_controller.dart';
import 'package:my_communication_academy/state/detail_controller.dart';
import 'package:my_communication_academy/ui/academy_app.dart';
import 'package:my_communication_academy/l10n/app_localizations.dart';

class ControlledRepository implements CourseRepository {
  final requests =
      <({String query, String? category, Completer<List<Course>> result})>[];
  final details = <Completer<CourseDetail>>[];
  @override
  Future<List<Course>> fetchCatalog({String query = '', String? category}) {
    final result = Completer<List<Course>>();
    requests.add((query: query, category: category, result: result));
    return result.future;
  }

  @override
  Future<CourseDetail> fetchDetail(String id) {
    final result = Completer<CourseDetail>();
    details.add(result);
    return result.future;
  }
}

const sample = Course(id: 'a', title: 'Network basics');
Future<void> flush() => Future<void>.delayed(Duration.zero);

void main() {
  test('provided malformed catalog yields eight unique safe courses', () async {
    final repo = ApiCourseRepository(
      FakeCourseApi(failEvery: 0, latencyScale: 0),
    );
    final list = await repo.fetchCatalog();
    expect(list.length, 8);
    expect(list.map((e) => e.id).toSet().length, 8);
    expect(list.any((e) => e.id == 'c-104' || e.id == '109'), isFalse);
    expect(list.firstWhere((e) => e.id == 'c-103').price, 39);
    expect(list.firstWhere((e) => e.id == 'c-105').price, 0);
    expect(list.firstWhere((e) => e.id == 'c-105').level, isNull);
    expect(list.firstWhere((e) => e.id == 'c-107').durationMinutes, isNull);
    expect(list.firstWhere((e) => e.id == 'c-107').rating, isNull);
    expect(list.firstWhere((e) => e.id == 'c-108').rating, isNull);
    expect(list.firstWhere((e) => e.id == 'c-110').category, isNull);
  });
  test('bad envelope is an error, not an empty list', () {
    expect(() => parseCatalog('{"data":{}}'), throwsFormatException);
  });
  test('partial lesson total and enrollment stay honest', () async {
    final repo = ApiCourseRepository(
      FakeCourseApi(failEvery: 0, latencyScale: 0),
    );
    final detail = await repo.fetchDetail('c-101');
    expect(detail.knownSeconds, 2580);
    expect(detail.unknownDurations, 1);
    expect(detail.lessons.last.title, isNull);
    expect(detail.lessons.last.position, 4);
    expect(detail.lessons.where(detail.canOpen).length, 1);
    final enrolled = await repo.fetchDetail('c-102');
    expect(enrolled.lessons.every(enrolled.canOpen), isTrue);
    final sql = await repo.fetchDetail('c-107');
    expect(sql.lessons.first.durationSeconds, 600);
    expect((await repo.fetchDetail('c-111')).lessons, isEmpty);
  });
  test(
    'Python requires explicit retry and string yes is not preview',
    () async {
      final repo = ApiCourseRepository(FakeCourseApi(latencyScale: 0));
      await expectLater(
        repo.fetchDetail('c-103'),
        throwsA(isA<CourseFailure>()),
      );
      final detail = await repo.fetchDetail('c-103');
      expect(detail.lessons.first.isPreview, isFalse);
      expect(detail.canOpen(detail.lessons.first), isFalse);
    },
  );
  test(
    'search rejects stale success and failure before debounce dispatch',
    () async {
      final repo = ControlledRepository();
      final c = CatalogController(
        repo,
        debounce: const Duration(milliseconds: 20),
      );
      final first = c.load();
      c.setQuery('net');
      repo.requests.first.result.complete([sample]);
      await first;
      expect(c.state, LoadState.loading);
      expect(c.courses, isEmpty);
      await Future<void>.delayed(const Duration(milliseconds: 30));
      c.setQuery('network', immediate: true);
      repo.requests[2].result.complete([sample]);
      await flush();
      repo.requests[1].result.completeError(
        const CourseFailure(FailureKind.temporary),
      );
      await flush();
      expect(c.state, LoadState.loaded);
      expect(c.query, 'network');
      expect(c.courses, [sample]);
      c.dispose();
    },
  );
  test(
    'debounce combines keystrokes and filter dispatches latest query',
    () async {
      final repo = ControlledRepository();
      final c = CatalogController(
        repo,
        debounce: const Duration(milliseconds: 10),
      );
      c.setQuery('n');
      c.setQuery('ne');
      c.setQuery('net');
      expect(repo.requests, isEmpty);
      await Future<void>.delayed(const Duration(milliseconds: 20));
      expect(repo.requests.length, 1);
      expect(repo.requests.single.query, 'net');
      c.setCategory('ai');
      expect(repo.requests.last.category, 'ai');
      expect(repo.requests.last.query, 'net');
      for (final r in repo.requests) {
        r.result.complete([]);
      }
      await flush();
      c.dispose();
    },
  );
  test('refresh retains data but failed new query clears it', () async {
    final repo = ControlledRepository();
    final c = CatalogController(repo);
    final initial = c.load();
    repo.requests.last.result.complete([sample]);
    await initial;
    final refresh = c.load(refresh: true);
    repo.requests.last.result.completeError(Exception('offline'));
    await refresh;
    expect(c.courses, [sample]);
    expect(c.state, LoadState.loaded);
    expect(c.refreshFailures, 1);
    c.setQuery('fail', immediate: true);
    repo.requests.last.result.completeError(Exception('failed'));
    await flush();
    expect(c.state, LoadState.error);
    expect(c.courses, isEmpty);
    c.dispose();
  });
  test('disposed controllers ignore late completion', () async {
    final repo = ControlledRepository();
    final c = CatalogController(repo);
    var notifications = 0;
    c.addListener(() => notifications++);
    final loading = c.load();
    c.dispose();
    final before = notifications;
    repo.requests.single.result.complete([sample]);
    await loading;
    expect(notifications, before);
    final detail = DetailController(repo, 'a');
    final request = detail.load();
    detail.dispose();
    repo.details.single.completeError(Exception('late'));
    await request;
  });
  testWidgets('catalog error has retry and recovers to clearable empty state', (
    tester,
  ) async {
    final repo = ControlledRepository();
    await tester.pumpWidget(AcademyApp(repository: repo));
    repo.requests.single.result.completeError(Exception('failed'));
    await tester.pumpAndSettle();
    expect(find.text('Courses could not load'), findsOneWidget);
    await tester.tap(find.text('Try again'));
    await tester.pump();
    repo.requests.last.result.complete([]);
    await tester.pumpAndSettle();
    expect(find.text('No courses found'), findsOneWidget);
    expect(find.text('Clear filters'), findsOneWidget);
  });
  testWidgets('404 differs from a temporary failure', (tester) async {
    final repo = ControlledRepository();
    final c = DetailController(repo, 'missing');
    unawaited(c.load());
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: L10n.localizationsDelegates,
        supportedLocales: L10n.supportedLocales,
        home: Scaffold(body: DetailBody(controller: c)),
      ),
    );
    repo.details.single.completeError(
      const CourseFailure(FailureKind.unavailable),
    );
    await tester.pumpAndSettle();
    expect(find.text('Course no longer available'), findsOneWidget);
    expect(find.text('Try again'), findsNothing);
    await tester.pumpWidget(const SizedBox());
    c.dispose();
  });
}
