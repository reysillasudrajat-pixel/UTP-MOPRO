import 'package:flutter/foundation.dart';

import '../models/meal.dart';

/// Daftar favorit, disimpan di memori selama aplikasi berjalan.
class Favorites extends ChangeNotifier {
  Favorites._();

  static final Favorites instance = Favorites._();

  final Map<String, Meal> _items = {};

  /// Yang terakhir ditambahkan tampil paling depan.
  List<Meal> get items => _items.values.toList().reversed.toList();

  int get count => _items.length;

  bool contains(String id) => _items.containsKey(id);

  void toggle(Meal meal) {
    if (_items.remove(meal.id) == null) {
      _items[meal.id] = meal;
    }
    notifyListeners();
  }
}
