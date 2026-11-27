import 'package:flutter/material.dart';

import '../models/meal.dart';
import '../services/meal_api.dart';
import '../state/history.dart';
import '../widgets/routes.dart';
import 'detail_screen.dart';

/// Membuka halaman detail dan mencatatnya sebagai "terakhir dilihat".
/// [heroTag] harus unik per layar supaya animasi foto tidak bentrok.
void openMeal(
  BuildContext context, {
  required Meal meal,
  required MealApi api,
  required String heroTag,
}) {
  History.instance.add(meal);
  Navigator.of(context).push(
    fadeRoute(DetailScreen(meal: meal, api: api, heroTag: heroTag)),
  );
}
