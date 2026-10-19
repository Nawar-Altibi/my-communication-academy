// lib/provided/fake_course_api.dart
// PROVIDED FILE. Do not modify. Wrap it or build on top of it.

import 'dart:convert';
import 'dart:math' as math;

/// Thrown for non-2xx responses, as an HTTP client wrapper would.
class ApiException implements Exception {
  ApiException(this.statusCode, this.message);

  final int statusCode;
  final String message;

  @override
  String toString() => 'ApiException($statusCode): $message';
}

/// Simulates the My Communication Academy course API.
/// Methods return raw JSON strings, exactly as received over HTTP.
class FakeCourseApi {
  FakeCourseApi({this.failEvery = 5, this.latencyScale = 1.0});

  /// Every [failEvery]-th call to [fetchCourses] fails with HTTP 500.
  /// Set to 0 to disable.
  final int failEvery;

  /// Multiplies every simulated delay. Use 0 in tests.
  final double latencyScale;

  int _catalogCalls = 0;
  final Map<String, int> _detailCalls = {};

  /// GET /courses?query=&category=
  Future<String> fetchCourses({String query = '', String? category}) async {
    _catalogCalls++;
    final callNumber = _catalogCalls;
    final q = query.trim().toLowerCase();

    // Shorter queries are slower, so responses can arrive out of order.
    await _delay(math.max(150, 1200 - q.length * 200));

    if (failEvery > 0 && callNumber % failEvery == 0) {
      throw ApiException(500, 'Internal server error');
    }
    if (q.contains('fail')) {
      throw ApiException(503, 'Search service unavailable');
    }

    final items = _catalog.where((e) {
      if (e is! Map) return true; // Corrupt rows slip through every filter.
      final title = e['title'];
      final matchesQuery =
          q.isEmpty || (title is String && title.toLowerCase().contains(q));
      final matchesCategory = category == null || e['category'] == category;
      return matchesQuery && matchesCategory;
    }).toList();

    return jsonEncode({
      'data': items,
      'meta': {'count': items.length, 'schemaVersion': 2},
    });
  }

  /// GET /courses/{id}
  Future<String> fetchCourseDetail(String id) async {
    final attempt = (_detailCalls[id] ?? 0) + 1;
    _detailCalls[id] = attempt;

    await _delay(700);

    if (id == 'c-103' && attempt == 1) {
      throw ApiException(503, 'Service temporarily unavailable');
    }
    final detail = _details[id];
    if (detail == null) {
      throw ApiException(404, 'Course $id not found');
    }
    return jsonEncode({'data': detail});
  }

  Future<void> _delay(int ms) => Future<void>.delayed(
        Duration(milliseconds: (ms * latencyScale).round()),
      );
}

const List<Object?> _catalog = [
  {
    'id': 'c-101', 'title': 'Fundamentals of 5G NR', 'category': 'telecom',
    'level': 'beginner', 'durationMinutes': 240, 'price': 49.0,
    'rating': 4.7, 'thumbnailUrl': 'https://picsum.photos/seed/c101/400/225',
  },
  {
    'id': 'c-102', 'title': 'LTE Radio Network Planning', 'category': 'telecom',
    'level': 'intermediate', 'durationMinutes': 360, 'price': 79.0,
    'rating': 4.5, 'thumbnailUrl': 'https://example.invalid/lte.png',
  },
  {
    'id': 'c-103', 'title': 'Python for Network Engineers',
    'category': 'programming', 'level': 'beginner', 'durationMinutes': 300,
    'price': '39.00', 'rating': 4.8,
    'thumbnailUrl': 'https://picsum.photos/seed/c103/400/225',
  },
  {
    'id': 'c-104', 'category': 'telecom', 'level': 'advanced',
    'durationMinutes': 180, 'price': 59.0, 'rating': 4.2, 'thumbnailUrl': null,
  },
  {
    'id': 'c-105', 'title': 'Introduction to Machine Learning',
    'category': 'ai', 'level': 'expert', 'durationMinutes': 420, 'price': 0,
    'rating': 4.6, 'thumbnailUrl': 'https://picsum.photos/seed/c105/400/225',
  },
  {
    'id': 'c-101', 'title': 'Fundamentals of 5G NR', 'category': 'telecom',
    'level': 'beginner', 'durationMinutes': 240, 'price': 49.0,
    'rating': 4.7, 'thumbnailUrl': 'https://picsum.photos/seed/c101/400/225',
  },
  'corrupted-row',
  {
    'id': 'c-107', 'title': 'Data Analysis with SQL', 'category': 'data',
    'level': 'beginner', 'durationMinutes': -1, 'price': 29.0,
    'rating': null, 'thumbnailUrl': null,
  },
  {
    'id': 'c-108', 'title': 'Optical Fiber Transmission Systems',
    'category': 'telecom', 'level': 'advanced', 'durationMinutes': 510,
    'price': 99.0, 'rating': 9.2,
    'thumbnailUrl': 'https://picsum.photos/seed/c108/400/225',
  },
  {
    'id': 109, 'title': 'Microwave Link Engineering', 'category': 'telecom',
    'level': 'intermediate', 'durationMinutes': 200, 'price': 69.0,
    'rating': 4.3, 'thumbnailUrl': null,
  },
  {
    'id': 'c-110', 'title': 'Prompt Engineering for Engineers',
    'category': 'quantum', 'level': 'beginner', 'durationMinutes': 90,
    'price': 19.0, 'rating': 4.1, 'thumbnailUrl': null,
  },
  {
    'id': 'c-111', 'title': 'Deep Learning for Signal Processing',
    'category': 'ai', 'level': 'advanced', 'durationMinutes': 480,
    'price': 119.0, 'rating': 4.9,
  },
];

const Map<String, Map<String, Object?>> _details = {
  'c-101': {
    'id': 'c-101', 'title': 'Fundamentals of 5G NR',
    'description': 'Air interface, NR numerology, beam management and the '
        '5G core, explained for working engineers.',
    'instructor': {'name': 'Dr. Lina Haddad'}, 'enrolled': false,
    'lessons': [
      {'id': 'l-1', 'title': 'Why 5G?', 'durationSeconds': 420, 'isPreview': true},
      {'id': 'l-2', 'title': 'NR numerology', 'durationSeconds': 1260, 'isPreview': false},
      {'id': 'l-3', 'title': 'Beam management', 'durationSeconds': null, 'isPreview': false},
      {'id': 'l-4', 'title': null, 'durationSeconds': 900, 'isPreview': false},
    ],
  },
  'c-102': {
    'id': 'c-102', 'title': 'LTE Radio Network Planning',
    'description': 'Coverage and capacity planning for LTE networks.',
    'instructor': null, 'enrolled': true,
    'lessons': [
      {'id': 'l-1', 'title': 'Link budgets', 'durationSeconds': 1500, 'isPreview': true},
      {'id': 'l-2', 'title': 'Propagation models', 'durationSeconds': 1800, 'isPreview': false},
      {'id': 'l-3', 'title': 'Capacity dimensioning', 'durationSeconds': 2100, 'isPreview': false},
    ],
  },
  'c-103': {
    'id': 'c-103', 'title': 'Python for Network Engineers',
    'description': 'Automate network tasks with Python, from parsing '
        'configs to calling device APIs.',
    'instructor': {'name': 'Omar Saleh'}, 'enrolled': false,
    'lessons': [
      {'id': 'l-1', 'title': 'Python refresher', 'durationSeconds': 900, 'isPreview': 'yes'},
      {'id': 'l-2', 'title': 'Parsing configs', 'durationSeconds': 1200, 'isPreview': false},
      {'id': 'l-3', 'title': 'Talking to devices', 'durationSeconds': 1500, 'isPreview': false},
    ],
  },
  'c-105': {
    'id': 'c-105', 'title': 'Introduction to Machine Learning',
    'description': 'Core ideas of supervised and unsupervised learning.',
    'instructor': {'name': 'Sara Nasser'}, 'enrolled': false,
    'lessons': [],
  },
  'c-107': {
    'id': 'c-107', 'title': 'Data Analysis with SQL', 'description': '',
    'instructor': {'name': 'Karim Aziz'}, 'enrolled': false,
    'lessons': [
      {'id': 'l-1', 'title': 'SELECT basics', 'durationSeconds': '600', 'isPreview': true},
      {'id': 'l-2', 'title': 'Joins and aggregation', 'durationSeconds': 1800, 'isPreview': false},
    ],
  },
  'c-111': {
    'id': 'c-111', 'title': 'Deep Learning for Signal Processing',
    'description': 'Neural networks applied to radio signals.',
    'instructor': {'name': 'Dr. Lina Haddad'}, 'enrolled': false,
  },
};
