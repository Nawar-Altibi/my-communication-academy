import 'dart:async';
import 'package:flutter/foundation.dart';
import '../data/course.dart';
import '../data/course_repository.dart';
import '../data/local_store.dart';

enum LoadState { loading, loaded, error }

class CatalogController extends ChangeNotifier {
  CatalogController(
    this.repository, {
    this.debounce = const Duration(milliseconds: 300),
    this.store,
  });
  final CourseRepository repository;
  final Duration debounce;
  final LocalStore? store;
  String language = 'en';
  DateTime? savedAt;
  bool get showingSaved => savedAt != null;
  String query = '';
  String? category;
  List<Course> courses = const [];
  LoadState state = LoadState.loading;
  bool refreshing = false;
  int refreshFailures = 0;
  int _generation = 0;
  bool _disposed = false;
  Timer? _timer;

  Future<void> initialize() async {
    final initialGeneration = _generation;
    SavedState saved;
    try {
      saved = await store?.read() ?? const SavedState();
    } catch (_) {
      saved = const SavedState();
    }
    if (_disposed || initialGeneration != _generation) return;
    query = saved.query;
    category = saved.category;
    language = saved.language;
    final snapshot = saved.snapshot;
    if (snapshot != null && snapshot.matches(query, category)) {
      courses = snapshot.courses;
      savedAt = snapshot.savedAt;
      state = LoadState.loaded;
    }
    await load(refresh: showingSaved);
  }

  Future<void> _persistPreferences() async {
    try {
      await store?.savePreferences(query, category, language);
    } catch (_) {
      /* Non-critical. */
    }
  }

  void setLanguage(String value) {
    language = value;
    unawaited(_persistPreferences());
    notifyListeners();
  }

  void setQuery(String value, {bool immediate = false}) {
    if (value == query) return;
    query = value;
    _criteriaChanged(immediate);
  }

  void setCategory(String? value) {
    if (value == category) return;
    category = value;
    _criteriaChanged(true);
  }

  void clear() {
    query = '';
    category = null;
    _criteriaChanged(true);
  }

  void _criteriaChanged(bool immediate) {
    _timer?.cancel();
    _generation++;
    courses = const [];
    savedAt = null;
    state = LoadState.loading;
    refreshing = false;
    notifyListeners();
    if (immediate) {
      unawaited(_persistPreferences());
      unawaited(load());
    } else {
      _timer = Timer(debounce, () {
        unawaited(_persistPreferences());
        unawaited(load());
      });
    }
  }

  Future<void> load({bool refresh = false}) async {
    _timer?.cancel();
    unawaited(_persistPreferences());
    final token = ++_generation;
    final requestQuery = query;
    final requestCategory = category;
    final keep = refresh && state == LoadState.loaded;
    refreshing = keep;
    if (!keep) state = LoadState.loading;
    notifyListeners();
    try {
      final result = await repository.fetchCatalog(
        query: query,
        category: category,
      );
      if (_disposed || token != _generation) return;
      courses = result;
      savedAt = null;
      state = LoadState.loaded;
      unawaited(
        _persistCatalog(
          CatalogSnapshot(
            query: requestQuery,
            category: requestCategory,
            courses: result,
            savedAt: DateTime.now(),
          ),
        ),
      );
    } catch (_) {
      if (_disposed || token != _generation) return;
      if (keep) {
        refreshFailures++;
      } else {
        courses = const [];
        state = LoadState.error;
      }
    }
    refreshing = false;
    notifyListeners();
  }

  Future<void> _persistCatalog(CatalogSnapshot snapshot) async {
    try {
      await store?.saveCatalog(snapshot);
    } catch (_) {
      /* Non-critical. */
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _generation++;
    _timer?.cancel();
    super.dispose();
  }
}
