import 'package:flutter/material.dart';

/// Muncul pelan dari bawah. Item berurutan diberi jeda kecil.
/// Hanya 8 item pertama yang dianimasikan, sisanya langsung tampil
/// supaya scroll tidak terasa berkedip.
class FadeInUp extends StatefulWidget {
  final Widget child;
  final int index;

  const FadeInUp({super.key, required this.child, this.index = 0});

  @override
  State<FadeInUp> createState() => _FadeInUpState();
}

class _FadeInUpState extends State<FadeInUp>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _curve;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 480),
    );
    _curve = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);

    if (widget.index >= 8) {
      _controller.value = 1;
    } else {
      Future.delayed(Duration(milliseconds: widget.index * 70), () {
        if (mounted) _controller.forward();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _curve,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.06),
          end: Offset.zero,
        ).animate(_curve),
        child: widget.child,
      ),
    );
  }
}
