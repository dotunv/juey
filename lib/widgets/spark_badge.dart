import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SparkBadge extends StatelessWidget {
  const SparkBadge({super.key, this.size = 16});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Color(0x66FFCB47),
            blurRadius: 8,
            spreadRadius: 0,
          ),
        ],
      ),
      child: SvgPicture.asset(
        'assets/icons/app_icon.svg',
        width: size,
        height: size,
      ),
    );
  }
}
