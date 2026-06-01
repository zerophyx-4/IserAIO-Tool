import 'package:flutter/material.dart';

class StatBar extends StatelessWidget {
  final double value;
  final double max;
  final Color color;

  const StatBar({super.key, required this.value, required this.max, required this.color});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return Container(
        height: 4,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(99),
        ),
        child: Align(
          alignment: Alignment.centerLeft,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 700),
            curve: Curves.easeOutCubic,
            width: constraints.maxWidth * (value / max).clamp(0.0, 1.0),
            decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(99)),
          ),
        ),
      );
    });
  }
}