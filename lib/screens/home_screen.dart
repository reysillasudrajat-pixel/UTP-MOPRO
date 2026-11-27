import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/offline_meals.dart';
import '../models/meal.dart';
import '../services/meal_api.dart';
import '../state/favorites.dart';
import '../theme.dart';
import '../widgets/fade_in_up.dart';
import '../widgets/meal_card.dart';
import '../widgets/pulse.dart';
import '../widgets/routes.dart';
import 'detail_screen.dart';

const _kFav = 'Favorit';
const _kAll = 'Semua';

const _errorText =
    'Tidak bisa memuat data. Periksa koneksi internet, lalu coba lagi.';

const _gridDelegate = SliverGridDelegateWithFixedCrossAxisCount(
  crossAxisCount: 2,
  mainAxisSpacing: 14,
  crossAxisSpacing: 14,
  childAspectRatio: 0.78,
);

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _api = MealApi();
  final _searchController = TextEditingController();

  List<String> _categories = [];
  String? _category;
  List<Meal> _meals = [];
  String _query = '';
  bool _loading = true;
  bool _offline = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    Favorites.instance.addListener(_onFavoritesChanged);
    _bootstrap();
  }

  @override
  void dispose() {
    Favorites.instance.removeListener(_onFavoritesChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onFavoritesChanged() {
    if (!mounted) return;
    if (_category == _kFav && _query.isEmpty) {
      setState(() => _meals = Favorites.instance.items);
    }
  }

  List<String> get _chips =>
      _offline ? [_kAll, _kFav] : [_kFav, ..._categories];

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
        _categories = [];
        _category = _kAll;
        _meals = offlineMeals;
        _loading = false;
      });
    }
  }

  Future<void> _pickCategory(String category) async {
    _searchController.clear();

    if (category == _kFav || category == _kAll) {
      setState(() {
        _query = '';
        _category = category;
        _loading = false;
        _error = null;
        _meals = category == _kFav ? Favorites.instance.items : offlineMeals;
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
      await _pickCategory(_category ?? (_offline ? _kAll : _kFav));
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

  void _open(Meal meal) {
    Navigator.of(context).push(fadeRoute(DetailScreen(meal: meal, api: _api)));
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        body: SafeArea(
          bottom: false,
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: _buildHeader()),
              SliverPersistentHeader(
                pinned: true,
                delegate: _ChipsDelegate(_buildChips()),
              ),
              _buildContent(),
              const SliverToBoxAdapter(child: SizedBox(height: 32)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
      child: FadeInUp(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Mau makan apa hari ini?',
              style: text.headlineMedium?.copyWith(
                fontWeight: FontWeight.w800,
                height: 1.15,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Cari resep dan simpan menu favoritmu.',
              style: text.bodyMedium?.copyWith(color: AppColors.muted),
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
                    color: AppColors.green,
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
          icon: c == _kFav ? Icons.favorite_rounded : null,
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
        child: _Message(
          icon: Icons.cloud_off_rounded,
          text: _error!,
          action: 'Coba lagi',
          onAction: _bootstrap,
        ),
      );
    }

    if (_meals.isEmpty) {
      final inFav = _category == _kFav && _query.isEmpty;
      return SliverFillRemaining(
        hasScrollBody: false,
        child: _Message(
          icon: inFav ? Icons.favorite_border_rounded : Icons.search_off_rounded,
          text: inFav
              ? 'Belum ada favorit. Ketuk ikon hati pada menu untuk menyimpannya.'
              : _query.isEmpty
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
              child: MealCard(meal: meal, onTap: () => _open(meal)),
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
  final IconData? icon;
  final bool selected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? AppColors.green : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? AppColors.green : AppColors.line,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 15,
                color: selected ? Colors.white : AppColors.heart,
              ),
              const SizedBox(width: 6),
            ],
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

class _Message extends StatelessWidget {
  final IconData icon;
  final String text;
  final String? action;
  final VoidCallback? onAction;

  const _Message({
    required this.icon,
    required this.text,
    this.action,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return FadeInUp(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 36),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.greenSoft,
                ),
                child: Icon(icon, color: AppColors.green, size: 30),
              ),
              const SizedBox(height: 16),
              Text(
                text,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.muted, height: 1.45),
              ),
              if (action != null) ...[
                const SizedBox(height: 16),
                FilledButton(onPressed: onAction, child: Text(action!)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
