import 'package:flutter/material.dart';

import '../data/offline_meals.dart';
import '../models/meal.dart';
import '../services/meal_api.dart';
import '../state/app_nav.dart';
import '../state/favorites.dart';
import '../state/history.dart';
import '../theme.dart';
import '../widgets/category_style.dart';
import '../widgets/fade_in_up.dart';
import '../widgets/favorite_chart.dart';
import '../widgets/heart_button.dart';
import '../widgets/meal_card.dart';
import '../widgets/meal_image.dart';
import '../widgets/pressable.dart';
import '../widgets/pulse.dart';
import 'open_meal.dart';

class DashboardScreen extends StatefulWidget {
  final MealApi api;

  const DashboardScreen({super.key, required this.api});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<String> _categories = [];
  Meal? _featured;
  bool _loading = true;
  bool _offline = false;
  bool _shuffling = false;
  int _offlineIndex = 0;
  double _turns = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Meal _offlinePick() {
    final now = DateTime.now();
    final day = now.difference(DateTime(now.year)).inDays;
    return offlineMeals[(day + _offlineIndex) % offlineMeals.length];
  }

  List<String> _offlineCategories() =>
      offlineMeals.map((m) => m.category).toSet().toList();

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final cats = await widget.api.categories();
      final meal = await widget.api.random();
      if (!mounted) return;
      setState(() {
        _categories = cats;
        _featured = meal ?? _offlinePick();
        _offline = false;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _categories = _offlineCategories();
        _featured = _offlinePick();
        _offline = true;
        _loading = false;
      });
    }
  }

  Future<void> _shuffle() async {
    if (_shuffling) return;
    setState(() {
      _shuffling = true;
      _turns += 1;
    });
    Meal? next;
    if (!_offline) {
      try {
        next = await widget.api.random();
      } catch (_) {
        next = null;
      }
    }
    if (next == null) {
      _offlineIndex++;
      next = _offlinePick();
    }
    if (!mounted) return;
    setState(() {
      _featured = next;
      _shuffling = false;
    });
  }

  void _goCategory(String category) {
    AppNav.categoryRequest.value = category;
    AppNav.tab.value = 1;
  }

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 11) return 'Selamat pagi';
    if (h < 15) return 'Selamat siang';
    if (h < 18) return 'Selamat sore';
    return 'Selamat malam';
  }

  String _question() {
    final h = DateTime.now().hour;
    if (h < 11) return 'Sarapan apa hari ini?';
    if (h < 15) return 'Makan siang apa hari ini?';
    if (h < 18) return 'Masak apa untuk sore ini?';
    return 'Makan malam apa hari ini?';
  }

  Map<String, int> _favoritesByCategory() {
    final map = <String, int>{};
    for (final m in Favorites.instance.items) {
      final key = m.category.isEmpty ? 'Lainnya' : m.category;
      map[key] = (map[key] ?? 0) + 1;
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([Favorites.instance, History.instance]),
      builder: (context, _) {
        return ListView(
          padding: EdgeInsets.zero,
          children: [
            _buildHero(context),
            const SizedBox(height: 84),
            FadeInUp(
              index: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _title(
                    'Menu pilihan hari ini',
                    trailing: IconButton(
                      onPressed: _shuffle,
                      tooltip: 'Ganti menu',
                      icon: AnimatedRotation(
                        turns: _turns,
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeOutCubic,
                        child: const Icon(
                          Icons.refresh_rounded,
                          color: AppColors.green,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _buildFeatured(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            FadeInUp(
              index: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _title('Terakhir dilihat'),
                  _buildRecent(),
                ],
              ),
            ),
            const SizedBox(height: 30),
            FadeInUp(
              index: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _title('Kategori'),
                  _buildCategories(),
                ],
              ),
            ),
            const SizedBox(height: 30),
            FadeInUp(
              index: 4,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _title('Favorit per kategori'),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    padding: const EdgeInsets.all(18),
                    decoration: _cardDecoration(),
                    child: FavoriteChart(data: _favoritesByCategory()),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 130),
          ],
        );
      },
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withAlpha(20),
          blurRadius: 16,
          offset: const Offset(0, 6),
        ),
      ],
    );
  }

  Widget _title(String text, {Widget? trailing}) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 0, trailing == null ? 20 : 8, 14),
      child: Row(
        children: [
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.2,
              ),
            ),
          ),
          if (trailing != null) trailing,
        ],
      ),
    );
  }

  Widget _buildHero(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
          child: Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.heroTop, AppColors.heroBottom],
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  top: -50,
                  right: -40,
                  child: _Circle(size: 190, alpha: 24),
                ),
                Positioned(
                  bottom: -60,
                  left: -50,
                  child: _Circle(size: 170, alpha: 16),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(20, top + 22, 20, 78),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              _greeting(),
                              style: const TextStyle(
                                color: Color(0xCCFFFFFF),
                                fontSize: 15,
                              ),
                            ),
                          ),
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withAlpha(36),
                            ),
                            child: const Icon(
                              Icons.restaurant_rounded,
                              color: Colors.white,
                              size: 22,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _question(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 30,
                          fontWeight: FontWeight.w800,
                          height: 1.15,
                          letterSpacing: -0.6,
                        ),
                      ),
                      const SizedBox(height: 20),
                      GestureDetector(
                        onTap: () => AppNav.tab.value = 1,
                        child: Container(
                          height: 50,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.search_rounded, color: AppColors.muted),
                              SizedBox(width: 10),
                              Text(
                                'Cari resep atau bahan',
                                style: TextStyle(color: AppColors.muted),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          left: 20,
          right: 20,
          bottom: -56,
          child: Row(
            children: [
              Expanded(
                child: _StatCard(
                  icon: Icons.favorite_rounded,
                  color: AppColors.heart,
                  value: Favorites.instance.count,
                  label: 'Favorit',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  icon: Icons.visibility_rounded,
                  color: AppColors.blue,
                  value: History.instance.viewedCount,
                  label: 'Dilihat',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  icon: Icons.grid_view_rounded,
                  color: AppColors.orange,
                  value: _categories.length,
                  label: 'Kategori',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFeatured() {
    if (_loading) {
      return Pulse(
        child: Container(
          height: 230,
          decoration: BoxDecoration(
            color: AppColors.skeleton,
            borderRadius: BorderRadius.circular(24),
          ),
        ),
      );
    }
    final meal = _featured;
    if (meal == null) return const SizedBox.shrink();

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      child: _FeaturedCard(
        key: ValueKey(meal.id),
        meal: meal,
        onTap: () => openMeal(
          context,
          meal: meal,
          api: widget.api,
          heroTag: 'feat-${meal.id}',
        ),
      ),
    );
  }

  Widget _buildRecent() {
    final recent = History.instance.items;

    if (recent.isEmpty) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.all(18),
        decoration: _cardDecoration(),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.tint(AppColors.blue),
              ),
              child: const Icon(
                Icons.history_rounded,
                color: AppColors.blue,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Text(
                'Menu yang kamu buka akan muncul di sini.',
                style: TextStyle(color: AppColors.muted, height: 1.4),
              ),
            ),
          ],
        ),
      );
    }

    return SizedBox(
      height: 200,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: recent.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, i) {
          final meal = recent[i];
          return SizedBox(
            width: 150,
            child: MealCard(
              meal: meal,
              heroTag: 'recent-${meal.id}',
              onTap: () => openMeal(
                context,
                meal: meal,
                api: widget.api,
                heroTag: 'recent-${meal.id}',
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCategories() {
    const delegate = SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 4,
      mainAxisSpacing: 16,
      crossAxisSpacing: 12,
      childAspectRatio: 0.72,
    );

    if (_loading) {
      return Pulse(
        child: GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          gridDelegate: delegate,
          itemCount: 8,
          itemBuilder: (context, i) => Container(
            decoration: BoxDecoration(
              color: AppColors.skeleton,
              borderRadius: BorderRadius.circular(18),
            ),
          ),
        ),
      );
    }

    final cats = _categories.take(8).toList();
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      gridDelegate: delegate,
      itemCount: cats.length,
      itemBuilder: (context, i) {
        final color = AppColors.accents[i % AppColors.accents.length];
        return Pressable(
          onTap: () => _goCategory(cats[i]),
          child: Column(
            children: [
              AspectRatio(
                aspectRatio: 1,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.tint(color),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Icon(categoryIcon(cats[i]), color: color, size: 28),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                cats[i],
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Circle extends StatelessWidget {
  final double size;
  final int alpha;

  const _Circle({required this.size, required this.alpha});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withAlpha(alpha),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final int value;
  final String label;

  const _StatCard({
    required this.icon,
    required this.color,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(30),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.tint(color),
            ),
            child: Icon(icon, size: 17, color: color),
          ),
          const SizedBox(height: 8),
          TweenAnimationBuilder<int>(
            tween: IntTween(begin: 0, end: value),
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeOutCubic,
            builder: (context, v, _) => Text(
              '$v',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                height: 1.1,
              ),
            ),
          ),
          Text(
            label,
            style: const TextStyle(fontSize: 12.5, color: AppColors.muted),
          ),
        ],
      ),
    );
  }
}

class _FeaturedCard extends StatelessWidget {
  final Meal meal;
  final VoidCallback onTap;

  const _FeaturedCard({super.key, required this.meal, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      child: Container(
        height: 230,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(34),
              blurRadius: 22,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Hero(
                tag: 'feat-${meal.id}',
                child: MealImage(url: meal.thumb, seed: meal.name),
              ),
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Color(0xD0000000)],
                    stops: [0.35, 1],
                  ),
                ),
              ),
              Positioned(
                top: 14,
                left: 14,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    color: AppColors.orange,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.local_fire_department_rounded,
                        size: 15,
                        color: Colors.white,
                      ),
                      SizedBox(width: 5),
                      Text(
                        'Pilihan hari ini',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 12,
                right: 12,
                child: HeartButton(meal: meal, size: 38),
              ),
              Positioned(
                left: 18,
                right: 18,
                bottom: 16,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            meal.name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              height: 1.15,
                            ),
                          ),
                          if (meal.subtitle.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              meal.subtitle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Color(0xCCFFFFFF),
                                fontSize: 13.5,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      width: 44,
                      height: 44,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                      child: const Icon(
                        Icons.arrow_forward_rounded,
                        color: AppColors.green,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
