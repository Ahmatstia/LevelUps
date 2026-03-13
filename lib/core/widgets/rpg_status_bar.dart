import 'package:flutter/material.dart';

/// A reusable clean progress bar widget.
class RpgStatusBar extends StatelessWidget {
  final double value; // 0.0 to 1.0
  final Color barColor;
  final Color? glowColor;
  final double height;
  final int segments;
  final String? label;
  final bool animate;

  const RpgStatusBar({
    super.key,
    required this.value,
    required this.barColor,
    this.glowColor,
    this.height = 12, // slightly thinner default
    this.segments = 10,
    this.label,
    this.animate = true,
  });

  @override
  Widget build(BuildContext context) {
    final clampedValue = value.clamp(0.0, 1.0);

    Widget bar = Container(
      height: height,
      decoration: BoxDecoration(
        color: barColor.withOpacity(0.15),
        borderRadius: BorderRadius.circular(height / 2),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(height / 2),
        child: FractionallySizedBox(
          alignment: Alignment.centerLeft,
          widthFactor: clampedValue,
          child: Container(color: barColor),
        ),
      ),
    );

    if (label == null) return bar;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label!,
          style: TextStyle(
            color: barColor,
            fontSize: 10,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 4),
        bar,
      ],
    );
  }
}
