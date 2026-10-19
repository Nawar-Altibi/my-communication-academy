import 'package:flutter/material.dart';
import 'data/course_repository.dart';
import 'data/local_store.dart';
import 'provided/fake_course_api.dart';
import 'ui/academy_app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    AcademyApp(
      repository: ApiCourseRepository(FakeCourseApi()),
      store: PreferencesLocalStore(),
    ),
  );
}
