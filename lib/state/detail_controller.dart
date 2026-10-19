import 'package:flutter/foundation.dart';
import '../data/course.dart';
import '../data/course_repository.dart';
import 'catalog_controller.dart';

class DetailController extends ChangeNotifier {
  DetailController(this.repository, this.id);
  final CourseRepository repository;
  final String id;
  LoadState state = LoadState.loading;
  CourseDetail? detail;
  FailureKind? failure;
  bool _disposed = false;
  int _generation = 0;

  Future<void> load() async {
    final token = ++_generation;
    state = LoadState.loading;
    failure = null;
    notifyListeners();
    try {
      final result = await repository.fetchDetail(id);
      if (_disposed || token != _generation) return;
      detail = result;
      state = LoadState.loaded;
    } catch (e) {
      if (_disposed || token != _generation) return;
      failure = e is CourseFailure ? e.kind : FailureKind.temporary;
      state = LoadState.error;
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _generation++;
    super.dispose();
  }
}
