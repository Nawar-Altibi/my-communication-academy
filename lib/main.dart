import 'package:flutter/material.dart';
import 'data/course_repository.dart';
import 'provided/fake_course_api.dart';
import 'ui/academy_app.dart';

void main() {
  runApp(AcademyApp(repository: ApiCourseRepository(FakeCourseApi())));
}
