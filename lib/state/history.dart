import 'package:flutter/foundation.dart';

import '../models/meal.dart';

/// Menu yang dibuka selama aplikasi berjalan.
class History extends ChangeNotifier {
  History._();

  static final History instance = History._();

  final List<Meal> _recent = [];
  final Set<String> _seen = {};

  List<Meal> get items => List.unmodifiable(_recent);

  /// Jumlah menu berbeda yang pernah dibuka.
  int get viewedCount => _seen.length;

  void add(Meal meal) {
    _recent.removeWhere((m) => m.id == meal.id);
    _recent.insert(0, meal);
    if (_recent.length > 10) _recent.removeLast();
    _seen.add(meal.id);
    notifyListeners();
  }
}
