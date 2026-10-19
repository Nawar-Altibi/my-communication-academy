import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_communication_academy/data/local_store.dart';
import 'package:my_communication_academy/state/catalog_controller.dart';
import 'package:my_communication_academy/ui/academy_app.dart';
import 'package:my_communication_academy/data/course.dart';
import 'core_test.dart' show ControlledRepository, sample, flush;

class StringDisk {
  String? value;
  bool fail = false;
  PreferencesLocalStore open() => PreferencesLocalStore.withAccess(
    read: () async {
      if (fail) throw Exception('disk unavailable');
      return value;
    },
    write: (next) async {
      if (fail) throw Exception('disk unavailable');
      value = next;
    },
  );
}

CatalogSnapshot snapshot({
  String query = '',
  String? category,
  List<Course> courses = const [sample],
}) => CatalogSnapshot(
  query: query,
  category: category,
  courses: courses,
  savedAt: DateTime.utc(2026, 10, 19),
);

void main() {
  test(
    'serialized writes preserve newest preferences and snapshot after reopening',
    () async {
      final disk = StringDisk();
      final store = disk.open();
      await Future.wait([
        store.savePreferences('net', 'telecom', 'ar'),
        store.saveCatalog(snapshot(query: 'net', category: 'telecom')),
        store.savePreferences('deep', 'ai', 'en'),
      ]);
      final restored = await disk.open().read();
      expect(restored.query, 'deep');
      expect(restored.category, 'ai');
      expect(restored.language, 'en');
      expect(restored.snapshot!.query, 'net');
      expect(restored.snapshot!.courses.single.id, 'a');
    },
  );
  test('corrupt or incompatible documents fall back safely', () async {
    final disk = StringDisk()..value = 'invalid JSON';
    expect((await disk.open().read()).query, '');
    disk.value = jsonEncode({'version': 9, 'query': 'old'});
    expect((await disk.open().read()).snapshot, isNull);
    disk.value = jsonEncode({
      'version': 1,
      'category': 'quantum',
      'language': 'xx',
      'snapshot': {'courses': 'bad'},
    });
    final state = await disk.open().read();
    expect(state.category, isNull);
    expect(state.language, 'en');
    expect(state.snapshot, isNull);
  });
  test('failed storage never prevents catalog use', () async {
    final disk = StringDisk()..fail = true;
    final repo = ControlledRepository();
    final c = CatalogController(repo, store: disk.open());
    final load = c.initialize();
    await flush();
    repo.requests.single.result.complete([sample]);
    await load;
    await flush();
    expect(c.state, LoadState.loaded);
    expect(c.courses.single.id, 'a');
    c.dispose();
  });
  test(
    'matching cache survives startup failure and successful refresh replaces it',
    () async {
      final disk = StringDisk();
      final store = disk.open();
      await store.savePreferences('net', 'telecom', 'ar');
      await store.saveCatalog(snapshot(query: 'net', category: 'telecom'));
      final repo = ControlledRepository();
      final c = CatalogController(repo, store: disk.open());
      final initial = c.initialize();
      await flush();
      expect(c.showingSaved, isTrue);
      expect(c.courses.single.id, 'a');
      expect(repo.requests.single.query, 'net');
      expect(repo.requests.single.category, 'telecom');
      repo.requests.single.result.completeError(Exception('offline'));
      await initial;
      expect(c.state, LoadState.loaded);
      expect(c.showingSaved, isTrue);
      expect(c.refreshFailures, 1);
      final refresh = c.load(refresh: true);
      repo.requests.last.result.complete([]);
      await refresh;
      await flush();
      expect(c.showingSaved, isFalse);
      expect((await store.read()).snapshot!.courses, isEmpty);
      c.dispose();
    },
  );
  test(
    'mismatched cache and failed new search never show unrelated data',
    () async {
      final disk = StringDisk();
      final store = disk.open();
      await store.saveCatalog(snapshot());
      await store.savePreferences('fail', 'ai', 'en');
      final repo = ControlledRepository();
      final c = CatalogController(repo, store: store);
      final initial = c.initialize();
      await flush();
      expect(c.courses, isEmpty);
      expect(c.showingSaved, isFalse);
      repo.requests.single.result.completeError(Exception('offline'));
      await initial;
      expect(c.state, LoadState.error);
      c.setQuery('', immediate: true);
      repo.requests.last.result.completeError(Exception('again'));
      await flush();
      expect(c.state, LoadState.error);
      expect(c.courses, isEmpty);
      c.dispose();
    },
  );
  test('stale results cannot replace persisted catalog', () async {
    final disk = StringDisk();
    final store = disk.open();
    final repo = ControlledRepository();
    final c = CatalogController(repo, store: store);
    final old = c.load();
    c.setQuery('new', immediate: true);
    repo.requests.last.result.complete([]);
    await flush();
    repo.requests.first.result.complete([sample]);
    await old;
    await flush();
    final saved = await store.read();
    expect(saved.snapshot!.query, 'new');
    expect(saved.snapshot!.courses, isEmpty);
    c.dispose();
  });
  test('search preferences are saved independently of API failure', () async {
    final disk = StringDisk();
    final store = disk.open();
    final repo = ControlledRepository();
    final c = CatalogController(repo, store: store);
    c.setQuery('fail', immediate: true);
    c.setCategory('ai');
    c.setLanguage('ar');
    for (final r in repo.requests) {
      r.result.completeError(Exception('failed'));
    }
    await flush();
    await flush();
    final saved = await store.read();
    expect(saved.query, 'fail');
    expect(saved.category, 'ai');
    expect(saved.language, 'ar');
    c.dispose();
  });
  testWidgets('Arabic tablet stays RTL and overflow-free at text scale 1.5', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1100, 900);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 1.5;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
      tester.platformDispatcher.clearTextScaleFactorTestValue();
    });
    final disk = StringDisk();
    await disk.open().savePreferences('', null, 'ar');
    final repo = ControlledRepository();
    await tester.pumpWidget(AcademyApp(repository: repo, store: disk.open()));
    await tester.pump();
    repo.requests.single.result.complete([sample]);
    await tester.pumpAndSettle();
    expect(find.text('مهارتك التالية بانتظارك'), findsOneWidget);
    expect(
      Directionality.of(tester.element(find.text('مهارتك التالية بانتظارك'))),
      TextDirection.rtl,
    );
    await tester.tap(find.text(sample.title));
    await tester.pump();
    expect(repo.details.length, 1);
    repo.details.single.complete(
      const CourseDetail(
        id: 'a',
        title: 'Network basics',
        enrolled: false,
        lessons: [Lesson(id: '1', position: 1, isPreview: false)],
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('دروس الدورة'), findsOneWidget);
    expect(tester.takeException(), isNull);
    tester.view.physicalSize = const Size(390, 844);
    await tester.pumpAndSettle();
    expect(repo.details.length, 1);
    await tester.scrollUntilVisible(find.text('دروس الدورة'), 180, scrollable: find.descendant(of: find.byType(DetailBody), matching: find.byType(Scrollable)));
    expect(find.text('دروس الدورة'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  testWidgets(
    'broken images use stable placeholder and expose no redundant semantics',
    (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 300,
              height: 150,
              child: CourseImage(url: 'https://example.invalid/lte.png'),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.school_outlined), findsOneWidget);
      expect(tester.takeException(), isNull);
      expect(tester.getSize(find.byType(CourseImage)), const Size(300, 150));
    },
  );
}
