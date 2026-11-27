import 'package:flutter/material.dart';

import '../theme.dart';

class MealThumb extends StatelessWidget {
  final String? url;
  final String label;
  final double width;
  final double height;
  final double radius;

  const MealThumb({
    super.key,
    required this.url,
    required this.label,
    required this.width,
    required this.height,
    this.radius = 6,
  });

  Widget _placeholder() {
    return Container(
      color: AppColors.field,
      alignment: Alignment.center,
      child: Text(
        label.isEmpty ? '?' : label.substring(0, 1).toUpperCase(),
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: AppColors.muted,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final u = url;
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: SizedBox(
        width: width,
        height: height,
        child: u == null
            ? _placeholder()
            : Image.network(
                u,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _placeholder(),
              ),
      ),
    );
  }
}
