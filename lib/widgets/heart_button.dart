import 'package:flutter/material.dart';

import '../models/meal.dart';
import '../state/favorites.dart';
import '../theme.dart';

class HeartButton extends StatelessWidget {
  final Meal meal;
  final double size;

  const HeartButton({super.key, required this.meal, this.size = 36});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Favorites.instance,
      builder: (context, _) {
        final fav = Favorites.instance.contains(meal.id);
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => Favorites.instance.toggle(meal),
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withAlpha(235),
            ),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 260),
              switchInCurve: Curves.elasticOut,
              transitionBuilder: (child, animation) =>
                  ScaleTransition(scale: animation, child: child),
              child: Icon(
                fav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                key: ValueKey(fav),
                size: size * 0.55,
                color: fav ? AppColors.heart : AppColors.ink,
              ),
            ),
          ),
        );
      },
    );
  }
}
