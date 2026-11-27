import 'package:flutter/material.dart';

import '../services/meal_api.dart';
import '../state/favorites.dart';
import '../theme.dart';
import '../widgets/empty_message.dart';
import '../widgets/fade_in_up.dart';
import '../widgets/meal_card.dart';
import 'open_meal.dart';

class FavoritesScreen extends StatelessWidget {
  final MealApi api;

  const FavoritesScreen({super.key, required this.api});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: ListenableBuilder(
        listenable: Favorites.instance,
        builder: (context, _) {
          final items = Favorites.instance.items;
          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: _header(items.length)),
              if (items.isEmpty)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 100),
                    child: EmptyMessage(
                      icon: Icons.favorite_border_rounded,
                      color: AppColors.heart,
                      text:
                          'Belum ada favorit. Ketuk ikon hati pada menu untuk menyimpannya.',
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 130),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 14,
                      crossAxisSpacing: 14,
                      childAspectRatio: 0.78,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, i) {
                        final meal = items[i];
                        return FadeInUp(
                          key: ValueKey(meal.id),
                          index: i,
                          child: MealCard(
                            meal: meal,
                            heroTag: 'fav-${meal.id}',
                            onTap: () => openMeal(
                              context,
                              meal: meal,
                              api: api,
                              heroTag: 'fav-${meal.id}',
                            ),
                          ),
                        );
                      },
                      childCount: items.length,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _header(int count) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.tint(AppColors.heart),
            ),
            child: const Icon(
              Icons.favorite_rounded,
              color: AppColors.heart,
              size: 26,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Favorit',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  count == 0 ? 'Belum ada menu tersimpan' : '$count menu tersimpan',
                  style: const TextStyle(color: AppColors.muted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
