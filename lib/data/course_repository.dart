import '../provided/fake_course_api.dart';
import 'course.dart';

enum FailureKind { unavailable, temporary, invalidData }

class CourseFailure implements Exception {
  const CourseFailure(this.kind);
  final FailureKind kind;
}

abstract interface class CourseRepository {
  Future<List<Course>> fetchCatalog({String query = '', String? category});
  Future<CourseDetail> fetchDetail(String id);
}

class ApiCourseRepository implements CourseRepository {
  ApiCourseRepository(this.api);
  final FakeCourseApi api;

  Future<T> _read<T>(
    Future<String> Function() request,
    T Function(String) parse,
  ) async {
    try {
      return parse(await request());
    } on ApiException catch (e) {
      throw CourseFailure(
        e.statusCode == 404 ? FailureKind.unavailable : FailureKind.temporary,
      );
    } on FormatException {
      throw const CourseFailure(FailureKind.invalidData);
    }
  }

  @override
  Future<List<Course>> fetchCatalog({String query = '', String? category}) =>
      _read(
        () => api.fetchCourses(query: query, category: category),
        parseCatalog,
      );

  @override
  Future<CourseDetail> fetchDetail(String id) =>
      _read(() => api.fetchCourseDetail(id), CourseDetail.parse);
}
