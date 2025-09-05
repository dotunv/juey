import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SparkBadge extends StatefulWidget {
  const SparkBadge({super.key, this.size = 16, this.shimmer = false});

  final double size;
  final bool shimmer;

  @override
  State<SparkBadge> createState() => _SparkBadgeState();
}

class _SparkBadgeState extends State<SparkBadge> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));
    _pulse = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    if (widget.shimmer) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant SparkBadge oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.shimmer && !_controller.isAnimating) {
      _controller.repeat(reverse: true);
    } else if (!widget.shimmer && _controller.isAnimating) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = widget.size;
    return Semantics(
      label: 'Recommended task',
      child: AnimatedBuilder(
        animation: _pulse,
        builder: (context, child) {
          final glow = 6 + 6 * (_pulse.value);
          final opacity = 0.3 + 0.3 * (_pulse.value);
          return Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFFCB47).withOpacity(opacity),
                  blurRadius: glow,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: child,
          );
        },
        child: SvgPicture.asset(
          'assets/icons/app_icon.svg',
          width: size,
          height: size,
          semanticsLabel: 'Spark badge',
        ),
      ),
    );
  }
}
