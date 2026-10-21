import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/course.dart';

class CourseRepository {
  static Future<String> langCode() async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getString('locale') ?? 'ru_RU').split('_').first;
  }

  /// Courses available in the current language, in order. A course that has
  /// no version for the language is simply not listed (content is Russian
  /// first; en/es follow).
  Future<List<Course>> loadAll() async {
    final lang = await langCode();
    final result = <Course>[];
    try {
      final index = jsonDecode(await rootBundle.loadString('assets/courses/index.json'))
          as Map<String, dynamic>;
      for (final id in (index['courses'] as List)) {
        try {
          final raw = jsonDecode(await rootBundle.loadString('assets/courses/$id.json'))
              as Map<String, dynamic>;
          final course = Course.fromJson(raw, lang);
          if (course.languages.contains(lang)) result.add(course);
        } catch (_) {}
      }
    } catch (_) {}
    result.sort((a, b) => a.order.compareTo(b.order));
    return result;
  }

  Future<Course?> load(String id) async {
    final all = await loadAll();
    for (final c in all) {
      if (c.id == id) return c;
    }
    return null;
  }
}
