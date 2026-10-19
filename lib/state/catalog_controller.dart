import 'dart:async';
import 'package:flutter/foundation.dart';
import '../data/course.dart';
import '../data/course_repository.dart';

enum LoadState { loading, loaded, error }

class CatalogController extends ChangeNotifier {
  CatalogController(
    this.repository, {
    this.debounce = const Duration(milliseconds: 300),
  });
  final CourseRepository repository;
  final Duration debounce;
  String query = '';
  String? category;
  List<Course> courses = const [];
  LoadState state = LoadState.loading;
  bool refreshing = false;
  int refreshFailures = 0;
  int _generation = 0;
  bool _disposed = false;
  Timer? _timer;

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
    state = LoadState.loading;
    refreshing = false;
    notifyListeners();
    if (immediate) {
      unawaited(load());
    } else {
      _timer = Timer(debounce, load);
    }
  }

  Future<void> load({bool refresh = false}) async {
    _timer?.cancel();
    final token = ++_generation;
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
      state = LoadState.loaded;
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

  @override
  void dispose() {
    _disposed = true;
    _generation++;
    _timer?.cancel();
    super.dispose();
  }
}
