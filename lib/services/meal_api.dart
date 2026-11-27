import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/meal.dart';

/// Klien untuk TheMealDB (kunci uji gratis: 1).
/// Untuk app yang dirilis publik, TheMealDB menyarankan kunci produksi.
class MealApi {
  static const _base = 'https://www.themealdb.com/api/json/v1/1';

  final http.Client _client;

  MealApi({http.Client? client}) : _client = client ?? http.Client();

  Future<Map<String, dynamic>> _get(
    String path,
    Map<String, String> query,
  ) async {
    var uri = Uri.parse('$_base/$path');
    if (query.isNotEmpty) {
      uri = uri.replace(queryParameters: query);
    }
    final res = await _client.get(uri).timeout(const Duration(seconds: 10));
    if (res.statusCode != 200) {
      throw Exception('Server membalas ${res.statusCode}');
    }
    final body = jsonDecode(res.body);
    if (body is! Map<String, dynamic>) {
      throw const FormatException('Format respons tidak dikenali');
    }
    return body;
  }

  List<Meal> _meals(Map<String, dynamic> body, {String category = ''}) {
    final raw = body['meals'];
    if (raw is! List) return [];
    return raw.whereType<Map<String, dynamic>>().map((j) {
      final m = Meal.fromJson(j);
      if (m.category.isNotEmpty || category.isEmpty) return m;
      return Meal(
        id: m.id,
        name: m.name,
        thumb: m.thumb,
        category: category,
      );
    }).toList();
  }

  Future<List<String>> categories() async {
    final body = await _get('categories.php', {});
    final raw = body['categories'];
    if (raw is! List) return [];
    return raw
        .whereType<Map<String, dynamic>>()
        .map((j) => (j['strCategory'] as String?) ?? '')
        .where((c) => c.isNotEmpty)
        .toList();
  }

  Future<List<Meal>> byCategory(String category) async {
    final body = await _get('filter.php', {'c': category});
    return _meals(body, category: category);
  }

  Future<List<Meal>> search(String query) async {
    final body = await _get('search.php', {'s': query});
    return _meals(body);
  }

  Future<Meal?> random() async {
    final body = await _get('random.php', {});
    final list = _meals(body);
    return list.isEmpty ? null : list.first;
  }

  Future<Meal?> lookup(String id) async {
    final body = await _get('lookup.php', {'i': id});
    final list = _meals(body);
    return list.isEmpty ? null : list.first;
  }
}
