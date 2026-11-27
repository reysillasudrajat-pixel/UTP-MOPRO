import 'package:flutter/material.dart';

IconData categoryIcon(String name) {
  switch (name.toLowerCase()) {
    case 'beef':
    case 'bakar':
      return Icons.kebab_dining;
    case 'chicken':
    case 'pork':
      return Icons.lunch_dining;
    case 'lamb':
    case 'goat':
    case 'daging':
      return Icons.dinner_dining;
    case 'dessert':
      return Icons.cake;
    case 'pasta':
    case 'mie':
      return Icons.ramen_dining;
    case 'seafood':
      return Icons.set_meal;
    case 'side':
      return Icons.tapas;
    case 'starter':
    case 'sup':
      return Icons.soup_kitchen;
    case 'vegan':
    case 'vegetarian':
    case 'sayur':
      return Icons.eco;
    case 'breakfast':
      return Icons.free_breakfast;
    case 'nasi':
      return Icons.rice_bowl;
    default:
      return Icons.restaurant;
  }
}
