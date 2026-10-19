import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'course.dart';

class CatalogSnapshot {
  const CatalogSnapshot({
    required this.query,
    required this.category,
    required this.courses,
    required this.savedAt,
  });
  final String query;
  final String? category;
  final List<Course> courses;
  final DateTime savedAt;
  bool matches(String query, String? category) =>
      this.query.trim() == query.trim() && this.category == category;
  Map<String, Object?> toJson() => {
    'query': query,
    'category': category,
    'savedAt': savedAt.toUtc().toIso8601String(),
    'courses': courses.map((c) => c.toJson()).toList(),
  };
  static CatalogSnapshot? parse(Object? raw) {
    if (raw is! Map || raw['query'] is! String || raw['courses'] is! List) {
      return null;
    }
    final savedAt = DateTime.tryParse(
      raw['savedAt'] is String ? raw['savedAt'] as String : '',
    );
    final category = raw['category'];
    if (savedAt == null ||
        (category != null && !categories.contains(category))) {
      return null;
    }
    final parsed = parseCatalog(jsonEncode({'data': raw['courses']}));
    return CatalogSnapshot(
      query: raw['query'] as String,
      category: category as String?,
      courses: parsed,
      savedAt: savedAt,
    );
  }
}

class SavedState {
  const SavedState({
    this.query = '',
    this.category,
    this.language = 'en',
    this.snapshot,
  });
  final String query;
  final String? category;
  final String language;
  final CatalogSnapshot? snapshot;
}

abstract interface class LocalStore {
  Future<SavedState> read();
  Future<void> savePreferences(String query, String? category, String language);
  Future<void> saveCatalog(CatalogSnapshot snapshot);
}

/// One writer serializes read-modify-write operations on the app-owned document.
class PreferencesLocalStore implements LocalStore {
  PreferencesLocalStore()
    : this.withAccess(
        read: () => SharedPreferencesAsync().getString(key),
        write: (value) => SharedPreferencesAsync().setString(key, value),
      );
  PreferencesLocalStore.withAccess({
    required Future<String?> Function() read,
    required Future<void> Function(String) write,
  }) : _read = read,
       _writeValue = write;
  final Future<String?> Function() _read;
  final Future<void> Function(String) _writeValue;
  static const key = 'academy.state.v1';
  Future<void> _writes = Future.value();

  @override
  Future<SavedState> read() async {
    try {
      final encoded = await _read();
      if (encoded == null) return const SavedState();
      final raw = jsonDecode(encoded);
      if (raw is! Map || raw['version'] != 1) return const SavedState();
      return SavedState(
        query: raw['query'] is String ? raw['query'] as String : '',
        category: categories.contains(raw['category'])
            ? raw['category'] as String
            : null,
        language: raw['language'] == 'ar' ? 'ar' : 'en',
        snapshot: CatalogSnapshot.parse(raw['snapshot']),
      );
    } catch (_) {
      return const SavedState();
    }
  }

  Future<void> _write(SavedState Function(SavedState) update) {
    _writes = _writes
        .then((_) async {
          final next = update(await read());
          await _writeValue(
            jsonEncode({
              'version': 1,
              'query': next.query,
              'category': next.category,
              'language': next.language,
              'snapshot': next.snapshot?.toJson(),
            }),
          );
        })
        .catchError((Object _) {
          /* Persistence is best effort, never a UI failure. */
        });
    return _writes;
  }

  @override
  Future<void> savePreferences(
    String query,
    String? category,
    String language,
  ) => _write(
    (old) => SavedState(
      query: query,
      category: category,
      language: language,
      snapshot: old.snapshot,
    ),
  );
  @override
  Future<void> saveCatalog(CatalogSnapshot snapshot) => _write(
    (old) => SavedState(
      query: old.query,
      category: old.category,
      language: old.language,
      snapshot: snapshot,
    ),
  );
}
