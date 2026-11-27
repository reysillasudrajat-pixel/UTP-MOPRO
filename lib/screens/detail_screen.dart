import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/meal.dart';
import '../services/meal_api.dart';
import '../theme.dart';
import '../widgets/fade_in_up.dart';
import '../widgets/heart_button.dart';
import '../widgets/meal_image.dart';
import '../widgets/pulse.dart';

class DetailScreen extends StatefulWidget {
  final Meal meal;
  final MealApi api;
  final String heroTag;

  const DetailScreen({
    super.key,
    required this.meal,
    required this.api,
    required this.heroTag,
  });

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late Meal _meal;
  bool _loading = false;
  bool _failed = false;
  final Set<int> _checked = {};

  @override
  void initState() {
    super.initState();
    _meal = widget.meal;
    if (!_meal.isComplete) _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _failed = false;
    });
    try {
      final full = await widget.api.lookup(widget.meal.id);
      if (!mounted) return;
      setState(() {
        if (full != null) {
          _meal = Meal(
            id: full.id,
            name: full.name,
            thumb: full.thumb ?? _meal.thumb,
            category: full.category,
            area: full.area,
            instructions: full.instructions,
            ingredients: full.ingredients,
          );
        } else {
          _failed = true;
        }
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _failed = true;
        _loading = false;
      });
    }
  }

  List<String> get _steps {
    final stepLabel = RegExp(r'^step\s*\d+$', caseSensitive: false);
    return _meal.instructions
        .split(RegExp(r'\r?\n'))
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty && !stepLabel.hasMatch(s))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        body: CustomScrollView(
          slivers: [
            _buildAppBar(),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTitle(),
                    const SizedBox(height: 24),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: _buildBody(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      pinned: true,
      expandedHeight: 340,
      backgroundColor: AppColors.bg,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      automaticallyImplyLeading: false,
      leadingWidth: 60,
      leading: Padding(
        padding: const EdgeInsets.only(left: 12),
        child: Center(
          child: _CircleButton(
            icon: Icons.arrow_back_rounded,
            onTap: () => Navigator.of(context).maybePop(),
          ),
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: Center(child: HeartButton(meal: _meal, size: 40)),
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(24),
        child: Container(
          height: 24,
          decoration: const BoxDecoration(
            color: AppColors.bg,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.parallax,
        background: Stack(
          fit: StackFit.expand,
          children: [
            Hero(
              tag: widget.heroTag,
              child: MealImage(url: _meal.thumb, seed: _meal.name),
            ),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0x8C000000), Colors.transparent],
                  stops: [0, 0.35],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTitle() {
    final text = Theme.of(context).textTheme;
    final pills = <Widget>[
      if (_meal.area.isNotEmpty)
        _InfoPill(icon: Icons.public_rounded, label: _meal.area),
      if (_meal.category.isNotEmpty)
        _InfoPill(icon: Icons.restaurant_rounded, label: _meal.category),
      if (_meal.ingredients.isNotEmpty)
        _InfoPill(
          icon: Icons.shopping_basket_outlined,
          label: '${_meal.ingredients.length} bahan',
        ),
      if (_steps.isNotEmpty)
        _InfoPill(
          icon: Icons.format_list_numbered_rounded,
          label: '${_steps.length} langkah',
        ),
    ];

    return FadeInUp(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _meal.name,
            style: text.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
              height: 1.15,
              letterSpacing: -0.3,
            ),
          ),
          if (pills.isNotEmpty) ...[
            const SizedBox(height: 14),
            Wrap(spacing: 8, runSpacing: 8, children: pills),
          ],
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Pulse(
        key: ValueKey('loading'),
        child: _SkeletonBody(),
      );
    }

    if (_failed) {
      return Padding(
        key: const ValueKey('failed'),
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          children: [
            const Text(
              'Resep tidak bisa dimuat. Periksa koneksi internet, lalu coba lagi.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.muted, height: 1.45),
            ),
            const SizedBox(height: 16),
            FilledButton(onPressed: _load, child: const Text('Coba lagi')),
          ],
        ),
      );
    }

    final steps = _steps;
    final text = Theme.of(context).textTheme;

    return Column(
      key: const ValueKey('content'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_meal.ingredients.isNotEmpty) ...[
          Text(
            'Bahan',
            style: text.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            'Ketuk bahan untuk menandai yang sudah siap.',
            style: text.bodySmall?.copyWith(color: AppColors.muted),
          ),
          const SizedBox(height: 12),
          _buildIngredients(),
          const SizedBox(height: 28),
        ],
        if (steps.isNotEmpty) ...[
          Text(
            'Cara membuat',
            style: text.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 14),
          for (var i = 0; i < steps.length; i++)
            FadeInUp(
              index: i,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 18),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 30,
                      height: 30,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.greenSoft,
                      ),
                      child: Text(
                        '${i + 1}',
                        style: const TextStyle(
                          color: AppColors.green,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          steps[i],
                          style: text.bodyLarge?.copyWith(height: 1.55),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ],
    );
  }

  Widget _buildIngredients() {
    final items = _meal.ingredients;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(18),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          for (var i = 0; i < items.length; i++) ...[
            if (i > 0) const Divider(),
            _IngredientRow(
              item: items[i],
              done: _checked.contains(i),
              onTap: () => setState(() {
                if (!_checked.remove(i)) _checked.add(i);
              }),
            ),
          ],
        ],
      ),
    );
  }
}

class _IngredientRow extends StatelessWidget {
  final Ingredient item;
  final bool done;
  final VoidCallback onTap;

  const _IngredientRow({
    required this.item,
    required this.done,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 13),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: done ? AppColors.green : Colors.transparent,
                border: Border.all(
                  color: done ? AppColors.green : AppColors.line,
                  width: 1.6,
                ),
              ),
              child: AnimatedScale(
                scale: done ? 1 : 0,
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutBack,
                child: const Icon(Icons.check_rounded, size: 14, color: Colors.white),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: TextStyle(
                  fontSize: 15.5,
                  color: done ? AppColors.muted : AppColors.ink,
                  decoration:
                      done ? TextDecoration.lineThrough : TextDecoration.none,
                  decorationColor: AppColors.muted,
                ),
                child: Text(item.name),
              ),
            ),
            if (item.measure.isNotEmpty) ...[
              const SizedBox(width: 12),
              Text(
                item.measure,
                style: const TextStyle(fontSize: 14, color: AppColors.muted),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoPill({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.line),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: AppColors.green),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CircleButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withAlpha(235),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 40,
          height: 40,
          child: Icon(icon, size: 20, color: AppColors.ink),
        ),
      ),
    );
  }
}

class _SkeletonBody extends StatelessWidget {
  const _SkeletonBody();

  Widget _bar(double widthFactor, double height) {
    return FractionallySizedBox(
      widthFactor: widthFactor,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: AppColors.skeleton,
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _bar(0.3, 22),
        const SizedBox(height: 16),
        Container(
          height: 220,
          decoration: BoxDecoration(
            color: AppColors.skeleton,
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        const SizedBox(height: 28),
        _bar(0.5, 22),
        const SizedBox(height: 16),
        _bar(1, 14),
        const SizedBox(height: 12),
        _bar(0.9, 14),
        const SizedBox(height: 12),
        _bar(0.7, 14),
      ],
    );
  }
}
