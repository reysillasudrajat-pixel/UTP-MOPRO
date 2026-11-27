import 'package:flutter/material.dart';

import '../data/offline_meals.dart';
import '../models/meal.dart';
import '../services/meal_api.dart';
import '../state/app_nav.dart';
import '../theme.dart';
import '../widgets/category_style.dart';
import '../widgets/empty_message.dart';
import '../widgets/fade_in_up.dart';
import '../widgets/meal_card.dart';
import '../widgets/pulse.dart';
import 'open_meal.dart';

const _kAll = 'Semua';

const _errorText =
    'Tidak bisa memuat data. Periksa koneksi internet, lalu coba lagi.';

const _gridDelegate = SliverGridDelegateWithFixedCrossAxisCount(
  crossAxisCount: 2,
  mainAxisSpacing: 14,
  crossAxisSpacing: 14,
  childAspectRatio: 0.78,
);

class MenuScreen extends StatefulWidget {
  final MealApi api;

  const MenuScreen({super.key, required this.api});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  final _searchController = TextEditingController();

  List<String> _categories = [];
  String? _category;
  List<Meal> _meals = [];
  String _query = '';
  bool _loading = true;
  bool _offline = false;
  String? _error;

  MealApi get _api => widget.api;

  @override
  void initState() {
    super.initState();
    AppNav.categoryRequest.addListener(_onCategoryRequest);
    _bootstrap();
  }

  @override
  void dispose() {
    AppNav.categoryRequest.removeListener(_onCategoryRequest);
    _searchController.dispose();
    super.dispose();
  }

  void _onCategoryRequest() {
    final c = AppNav.categoryRequest.value;
    if (c == null) return;
    AppNav.categoryRequest.value = null;
    _pickCategory(c);
  }

  List<String> get _chips => _offline ? [_kAll, ..._categories] : _categories;

  Future<void> _bootstrap() async {
    _searchController.clear();
    setState(() {
      _loading = true;
      _offline = false;
      _error = null;
      _query = '';
    });
    try {
      final cats = await _api.categories();
      String? first;
      if (cats.isNotEmpty) {
        first = cats.contains('Chicken') ? 'Chicken' : cats.first;
      }
      final meals = first == null ? <Meal>[] : await _api.byCategory(first);
      if (!mounted) return;
      setState(() {
        _categories = cats;
        _category = first;
        _meals = meals;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _offline = true;
        _categories = offlineMeals.map((m) => m.category).toSet().toList();
        _category = _kAll;
        _meals = offlineMeals;
        _loading = false;
      });
    }
  }

  Future<void> _pickCategory(String category) async {
    _searchController.clear();

    if (_offline) {
      setState(() {
        _query = '';
        _category = category;
        _loading = false;
        _error = null;
        _meals = category == _kAll
            ? offlineMeals
            : offlineMeals.where((m) => m.category == category).toList();
      });
      return;
    }

    setState(() {
      _query = '';
      _category = category;
      _loading = true;
      _error = null;
    });
    try {
      final meals = await _api.byCategory(category);
      if (!mounted) return;
      setState(() {
        _meals = meals;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _meals = [];
        _loading = false;
        _error = _errorText;
      });
    }
  }

  Future<void> _runSearch(String text) async {
    final q = text.trim();

    if (q.isEmpty) {
      final c = _category;
      if (c != null) {
        await _pickCategory(c);
      } else {
        await _bootstrap();
      }
      return;
    }

    if (_offline) {
      final lower = q.toLowerCase();
      setState(() {
        _query = q;
        _meals = offlineMeals
            .where((m) => m.name.toLowerCase().contains(lower))
            .toList();
      });
      return;
    }

    setState(() {
      _query = q;
      _loading = true;
      _error = null;
    });
    try {
      final meals = await _api.search(q);
      if (!mounted) return;
      setState(() {
        _meals = meals;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _meals = [];
        _loading = false;
        _error = _errorText;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _buildHeader()),
          SliverPersistentHeader(
            pinned: true,
            delegate: _ChipsDelegate(_buildChips()),
          ),
          _buildContent(),
          const SliverToBoxAdapter(child: SizedBox(height: 130)),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
      child: FadeInUp(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.tint(AppColors.orange),
                  ),
                  child: const Icon(
                    Icons.restaurant_menu_rounded,
                    color: AppColors.orange,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Jelajahi menu',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.4,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Cari nama menu atau pilih kategori.',
                        style: TextStyle(color: AppColors.muted),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            TextField(
              controller: _searchController,
              textInputAction: TextInputAction.search,
              onChanged: (_) => setState(() {}),
              onSubmitted: _runSearch,
              decoration: InputDecoration(
                hintText: 'Cari menu, misalnya ayam atau sambal',
                hintStyle: const TextStyle(color: AppColors.muted),
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  color: AppColors.muted,
                ),
                suffixIcon: _searchController.text.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(
                          Icons.close_rounded,
                          color: AppColors.muted,
                        ),
                        onPressed: () {
                          _searchController.clear();
                          _runSearch('');
                        },
                      ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 16),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AppColors.line),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(
                    color: AppColors.orange,
                    width: 1.5,
                  ),
                ),
              ),
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOut,
              alignment: Alignment.topCenter,
              child: _offline
                  ? _buildOfflineNotice()
                  : const SizedBox(width: double.infinity),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOfflineNotice() {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.fromLTRB(14, 6, 6, 6),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3E6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.wifi_off_rounded, size: 18, color: Color(0xFF9A5B1F)),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'Tidak terhubung ke server. Menampilkan menu bawaan.',
              style: TextStyle(fontSize: 13, color: Color(0xFF6B3F12)),
            ),
          ),
          TextButton(onPressed: _bootstrap, child: const Text('Coba lagi')),
        ],
      ),
    );
  }

  Widget _buildChips() {
    final chips = _chips;
    return ListView.separated(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      itemCount: chips.length,
      separatorBuilder: (_, __) => const SizedBox(width: 8),
      itemBuilder: (context, i) {
        final c = chips[i];
        return _CategoryChip(
          label: c,
          icon: categoryIcon(c),
          color: AppColors.accents[i % AppColors.accents.length],
          selected: _query.isEmpty && c == _category,
          onTap: () => _pickCategory(c),
        );
      },
    );
  }

  Widget _buildContent() {
    if (_loading) {
      return SliverPadding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
        sliver: SliverGrid(
          gridDelegate: _gridDelegate,
          delegate: SliverChildBuilderDelegate(
            (context, i) => const Pulse(child: _SkeletonCard()),
            childCount: 6,
          ),
        ),
      );
    }

    if (_error != null) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: EmptyMessage(
          icon: Icons.cloud_off_rounded,
          text: _error!,
          action: 'Coba lagi',
          onAction: _bootstrap,
        ),
      );
    }

    if (_meals.isEmpty) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: EmptyMessage(
          icon: Icons.search_off_rounded,
          color: AppColors.orange,
          text: _query.isEmpty
              ? 'Belum ada menu di kategori ini.'
              : 'Tidak ada menu untuk "$_query". Coba kata kunci lain.',
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      sliver: SliverGrid(
        gridDelegate: _gridDelegate,
        delegate: SliverChildBuilderDelegate(
          (context, i) {
            final meal = _meals[i];
            return FadeInUp(
              key: ValueKey(meal.id),
              index: i,
              child: MealCard(
                meal: meal,
                heroTag: 'menu-${meal.id}',
                onTap: () => openMeal(
                  context,
                  meal: meal,
                  api: _api,
                  heroTag: 'menu-${meal.id}',
                ),
              ),
            );
          },
          childCount: _meals.length,
        ),
      ),
    );
  }
}

class _ChipsDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  _ChipsDelegate(this.child);

  @override
  double get minExtent => 56;

  @override
  double get maxExtent => 56;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(color: AppColors.bg, child: child);
  }

  @override
  bool shouldRebuild(covariant _ChipsDelegate oldDelegate) => true;
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    required this.icon,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? color : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? color : AppColors.line),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: selected ? Colors.white : color),
            const SizedBox(width: 6),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 220),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: selected ? Colors.white : AppColors.ink,
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }
}

class _SkeletonCard extends StatelessWidget {
  const _SkeletonCard();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.skeleton,
        borderRadius: BorderRadius.circular(18),
      ),
    );
  }
}
