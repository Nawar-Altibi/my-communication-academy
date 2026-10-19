import 'dart:convert';

String? nonBlank(Object? value) =>
    value is String && value.trim().isNotEmpty ? value.trim() : null;

double? number(Object? value) {
  final result = value is num
      ? value.toDouble()
      : value is String
      ? double.tryParse(value)
      : null;
  return result != null && result.isFinite && result >= 0 ? result : null;
}

int? duration(Object? value) {
  final n = number(value);
  return n != null && n == n.truncateToDouble() ? n.toInt() : null;
}

const categories = ['telecom', 'programming', 'ai', 'data'];
const levels = ['beginner', 'intermediate', 'advanced'];

class Course {
  const Course({
    required this.id,
    required this.title,
    this.category,
    this.level,
    this.durationMinutes,
    this.price,
    this.rating,
    this.thumbnailUrl,
  });

  final String id;
  final String title;
  final String? category;
  final String? level;
  final int? durationMinutes;
  final double? price;
  final double? rating;
  final String? thumbnailUrl;

  static Course? parse(Object? raw) {
    if (raw is! Map) return null;
    final id = nonBlank(raw['id']);
    final title = nonBlank(raw['title']);
    if (id == null || title == null) return null;
    final rating = number(raw['rating']);
    return Course(
      id: id,
      title: title,
      category: categories.contains(raw['category'])
          ? raw['category'] as String
          : null,
      level: levels.contains(raw['level']) ? raw['level'] as String : null,
      durationMinutes: duration(raw['durationMinutes']),
      price: number(raw['price']),
      rating: rating != null && rating <= 5 ? rating : null,
      thumbnailUrl: nonBlank(raw['thumbnailUrl']),
    );
  }

  Map<String, Object?> toJson() => {
    'id': id,
    'title': title,
    'category': category,
    'level': level,
    'durationMinutes': durationMinutes,
    'price': price,
    'rating': rating,
    'thumbnailUrl': thumbnailUrl,
  };
}

List<Course> parseCatalog(String body) {
  final envelope = jsonDecode(body);
  if (envelope is! Map || envelope['data'] is! List) {
    throw const FormatException('Expected a course list');
  }
  final unique = <String, Course>{};
  for (final row in envelope['data'] as List) {
    final course = Course.parse(row);
    if (course != null) unique.putIfAbsent(course.id, () => course);
  }
  return List.unmodifiable(unique.values);
}

class Lesson {
  const Lesson({
    required this.id,
    required this.position,
    this.title,
    this.durationSeconds,
    required this.isPreview,
  });
  final String id;
  final int position;
  final String? title;
  final int? durationSeconds;
  final bool isPreview;
}

class CourseDetail {
  const CourseDetail({
    required this.id,
    required this.title,
    this.instructor,
    this.description,
    required this.enrolled,
    required this.lessons,
  });
  final String id;
  final String title;
  final String? instructor;
  final String? description;
  final bool enrolled;
  final List<Lesson> lessons;

  int get knownSeconds =>
      lessons.fold(0, (n, l) => n + (l.durationSeconds ?? 0));
  int get unknownDurations =>
      lessons.where((l) => l.durationSeconds == null).length;
  bool canOpen(Lesson lesson) => enrolled || lesson.isPreview;

  static CourseDetail parse(String body) {
    final envelope = jsonDecode(body);
    if (envelope is! Map || envelope['data'] is! Map) {
      throw const FormatException('Expected course details');
    }
    final raw = envelope['data'] as Map;
    final id = nonBlank(raw['id']);
    final title = nonBlank(raw['title']);
    if (id == null || title == null) {
      throw const FormatException('Invalid course');
    }
    final lessons = <Lesson>[];
    final seen = <String>{};
    final rows = raw['lessons'];
    if (rows is List) {
      for (var i = 0; i < rows.length; i++) {
        final row = rows[i];
        if (row is! Map) continue;
        final lessonId = nonBlank(row['id']);
        if (lessonId == null || !seen.add(lessonId)) continue;
        lessons.add(
          Lesson(
            id: lessonId,
            position: i + 1,
            title: nonBlank(row['title']),
            durationSeconds: duration(row['durationSeconds']),
            isPreview: row['isPreview'] == true,
          ),
        );
      }
    }
    final instructor = raw['instructor'];
    return CourseDetail(
      id: id,
      title: title,
      description: nonBlank(raw['description']),
      instructor: instructor is Map ? nonBlank(instructor['name']) : null,
      enrolled: raw['enrolled'] == true,
      lessons: List.unmodifiable(lessons),
    );
  }
}
