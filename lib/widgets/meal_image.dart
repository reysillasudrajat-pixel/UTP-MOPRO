import 'package:flutter/material.dart';

const _palettes = [
  [Color(0xFF2F7D62), Color(0xFF1B4D3C)],
  [Color(0xFFC77D3A), Color(0xFF8F4F1F)],
  [Color(0xFF4F6D8F), Color(0xFF2E445E)],
  [Color(0xFF9A5B68), Color(0xFF633440)],
  [Color(0xFF7A8450), Color(0xFF4B5430)],
];

/// Foto menu. Selama foto dimuat (atau kalau tidak ada), tampil warna polos
/// dengan ikon. Foto muncul dengan transisi fade.
class MealImage extends StatelessWidget {
  final String? url;
  final String seed;

  const MealImage({super.key, required this.url, required this.seed});

  Widget _placeholder() {
    final colors = _palettes[seed.hashCode.abs() % _palettes.length];
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
      ),
      child: const Center(
        child: Icon(
          Icons.restaurant_menu_rounded,
          size: 40,
          color: Color(0x66FFFFFF),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final u = url;
    return Stack(
      fit: StackFit.expand,
      children: [
        _placeholder(),
        if (u != null)
          Image.network(
            u,
            fit: BoxFit.cover,
            frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
              if (wasSynchronouslyLoaded) return child;
              return AnimatedOpacity(
                opacity: frame == null ? 0 : 1,
                duration: const Duration(milliseconds: 350),
                curve: Curves.easeOut,
                child: child,
              );
            },
            errorBuilder: (_, __, ___) => const SizedBox.shrink(),
          ),
      ],
    );
  }
}
