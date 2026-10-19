// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class L10nEn extends L10n {
  L10nEn([String locale = 'en']) : super(locale);

  @override
  String get academy => 'My Communication Academy';

  @override
  String get headline => 'Build your next skill.';

  @override
  String get intro => 'Practical learning for curious engineers.';

  @override
  String get search => 'Search courses';

  @override
  String get clearSearch => 'Clear search';

  @override
  String get all => 'All';

  @override
  String get telecom => 'Telecom';

  @override
  String get programming => 'Programming';

  @override
  String get ai => 'AI';

  @override
  String get data => 'Data';

  @override
  String get other => 'Other';

  @override
  String get beginner => 'Beginner';

  @override
  String get intermediate => 'Intermediate';

  @override
  String get advanced => 'Advanced';

  @override
  String get unspecified => 'Unspecified';

  @override
  String get free => 'Free';

  @override
  String get priceUnavailable => 'Price unavailable';

  @override
  String get ratingUnavailable => 'Rating unavailable';

  @override
  String get durationUnavailable => 'Duration unavailable';

  @override
  String get catalogError => 'Courses could not load';

  @override
  String get tryLater => 'Please try again in a moment.';

  @override
  String get retry => 'Try again';

  @override
  String get emptyTitle => 'No courses found';

  @override
  String get emptyMessage => 'Try another search or category.';

  @override
  String get clearFilters => 'Clear filters';

  @override
  String get refreshError =>
      'Could not refresh. Your previous courses are still here.';

  @override
  String get details => 'Course details';

  @override
  String get missingTitle => 'Course no longer available';

  @override
  String get missingMessage =>
      'This course may have been removed from the academy.';

  @override
  String get detailError => 'Could not load this course';

  @override
  String get temporaryMessage =>
      'There is a temporary problem. Please try again.';

  @override
  String get instructorUnavailable => 'Instructor unavailable';

  @override
  String get descriptionUnavailable => 'No description available.';

  @override
  String get lessons => 'Course lessons';

  @override
  String get emptyLessons => 'No lessons available yet';

  @override
  String get checkBack => 'Please check back later.';

  @override
  String get preview => 'Preview';

  @override
  String get available => 'Available';

  @override
  String get locked => 'Locked';

  @override
  String get lockedMessage => 'Enroll in this course to access this lesson.';

  @override
  String get chooseTitle => 'Your next skill starts here';

  @override
  String get chooseMessage => 'Select a course to explore its lessons.';

  @override
  String get language => 'العربية';

  @override
  String get back => 'Back to courses';

  @override
  String get loading => 'Loading courses';

  @override
  String courseCount(int count) {
    return '$count courses';
  }

  @override
  String minuteCount(int count) {
    return '$count min';
  }

  @override
  String secondCount(int minutes, int seconds) {
    return '$minutes min $seconds sec';
  }

  @override
  String lessonNumber(int number) {
    return 'Lesson $number';
  }

  @override
  String playing(String title) {
    return 'Playing: $title';
  }

  @override
  String totalDuration(String duration) {
    return '$duration total';
  }

  @override
  String partialDuration(String duration, int count) {
    return '$duration known · $count lesson duration(s) unavailable';
  }

  @override
  String savedCatalog(String time) {
    return 'Saved courses · $time';
  }

  @override
  String openCourse(String title) {
    return 'Open course: $title';
  }
}
