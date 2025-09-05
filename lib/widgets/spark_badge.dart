import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../app/theme/color_schemes.dart';

class SparkBadge extends StatefulWidget {
  final double size;
  final bool pulse;
  final String semanticsLabel;

  const SparkBadge({super.key, this.size = 18, this.pulse = false, this.semanticsLabel = 'Recommended task'});

  @override
  State<SparkBadge> createState() => _SparkBadgeState();
}

class _SparkBadgeState extends State<SparkBadge> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400))
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final glow = BoxShadow(color: AppColors.accent.withOpacity(0.6), blurRadius: 10, spreadRadius: 1);

    final star = CustomPaint(
      size: Size.square(widget.size),
      painter: _SparkPainter(color: AppColors.accent),
    );

    final child = Container(
      width: widget.size,
      height: widget.size,
      alignment: Alignment.center,
      child: star,
    );

    return Semantics(
      label: widget.semanticsLabel,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final t = widget.pulse ? (0.85 + 0.15 * math.sin(_controller.value * 2 * math.pi)) : 1.0;
          return AnimatedScale(
            duration: const Duration(milliseconds: 160),
            scale: t,
            curve: Curves.easeOut,
            child: DecoratedBox(
              decoration: BoxDecoration(boxShadow: [glow]),
              child: child,
            ),
          );
        },
      ),
    );
  }
}

class _SparkPainter extends CustomPainter {
  final Color color;
  const _SparkPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color..style = PaintingStyle.fill;
    final w = size.width;
    final h = size.height;
    final path = Path();
    // 8-point spark similar to app icon
    path.moveTo(w * 0.5, 0);
    path.lineTo(w * 0.62, h * 0.28);
    path.lineTo(w, h * 0.5);
    path.lineTo(w * 0.62, h * 0.72);
    path.lineTo(w * 0.5, h);
    path.lineTo(w * 0.38, h * 0.72);
    path.lineTo(0, h * 0.5);
    path.lineTo(w * 0.38, h * 0.28);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _SparkPainter oldDelegate) => oldDelegate.color != color;
}
