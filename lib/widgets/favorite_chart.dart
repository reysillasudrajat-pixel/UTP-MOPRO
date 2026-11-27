import 'package:flutter/material.dart';

import '../theme.dart';

/// Diagram batang horizontal. Batang tumbuh dari kosong saat tampil.
class FavoriteChart extends StatelessWidget {
  final Map<String, int> data;

  const FavoriteChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final entries = data.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final top = entries.take(5).toList();

    if (top.isEmpty) {
      return Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.tint(AppColors.heart),
            ),
            child: const Icon(
              Icons.favorite_border_rounded,
              color: AppColors.heart,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Text(
              'Simpan menu ke favorit, lalu ringkasannya muncul di sini.',
              style: TextStyle(color: AppColors.muted, height: 1.4),
            ),
          ),
        ],
      );
    }

    final max = top.first.value;
    return Column(
      children: [
        for (var i = 0; i < top.length; i++)
          Padding(
            padding: EdgeInsets.only(bottom: i == top.length - 1 ? 0 : 14),
            child: _BarRow(
              label: top[i].key,
              count: top[i].value,
              fraction: top[i].value / max,
              color: AppColors.accents[i % AppColors.accents.length],
            ),
          ),
      ],
    );
  }
}

class _BarRow extends StatelessWidget {
  final String label;
  final int count;
  final double fraction;
  final Color color;

  const _BarRow({
    required this.label,
    required this.count,
    required this.fraction,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 88,
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600),
          ),
        ),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0, end: fraction),
                duration: const Duration(milliseconds: 800),
                curve: Curves.easeOutCubic,
                builder: (context, value, _) {
                  return Stack(
                    children: [
                      Container(
                        height: 12,
                        decoration: BoxDecoration(
                          color: AppColors.tint(color),
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      Container(
                        width: constraints.maxWidth * value,
                        height: 12,
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: 20,
          child: Text(
            '$count',
            textAlign: TextAlign.right,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }
}
