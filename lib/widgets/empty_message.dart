import 'package:flutter/material.dart';

import '../theme.dart';
import 'fade_in_up.dart';

class EmptyMessage extends StatelessWidget {
  final IconData icon;
  final String text;
  final String? action;
  final VoidCallback? onAction;
  final Color color;

  const EmptyMessage({
    super.key,
    required this.icon,
    required this.text,
    this.action,
    this.onAction,
    this.color = AppColors.green,
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
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.tint(color),
                ),
                child: Icon(icon, color: color, size: 32),
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
