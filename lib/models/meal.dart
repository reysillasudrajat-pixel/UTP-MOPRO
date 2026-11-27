class Ingredient {
  final String name;
  final String measure;

  const Ingredient(this.name, this.measure);
}

class Meal {
  final String id;
  final String name;
  final String? thumb;
  final String category;
  final String area;
  final String instructions;
  final List<Ingredient> ingredients;

  const Meal({
    required this.id,
    required this.name,
    this.thumb,
    this.category = '',
    this.area = '',
    this.instructions = '',
    this.ingredients = const [],
  });

  /// Hasil filter dari API hanya berisi id, nama, dan foto.
  /// Detail lengkap diambil terpisah lewat lookup.
  bool get isComplete => instructions.isNotEmpty;

  String get subtitle =>
      [area, category].where((e) => e.isNotEmpty).join(', ');

  factory Meal.fromJson(Map<String, dynamic> j) {
    String s(String key) {
      final v = j[key];
      return v is String ? v.trim() : '';
    }

    final items = <Ingredient>[];
    for (var i = 1; i <= 20; i++) {
      final name = s('strIngredient$i');
      if (name.isEmpty) continue;
      items.add(Ingredient(name, s('strMeasure$i')));
    }

    final thumb = s('strMealThumb');
    return Meal(
      id: s('idMeal'),
      name: s('strMeal'),
      thumb: thumb.isEmpty ? null : thumb,
      category: s('strCategory'),
      area: s('strArea'),
      instructions: s('strInstructions'),
      ingredients: items,
    );
  }
}
