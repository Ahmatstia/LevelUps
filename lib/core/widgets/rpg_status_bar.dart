import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/game_theme.dart';

/// A reusable RPG-style progress bar widget with neon glow,
/// thick border, and optional segment dividers — just like a classic JRPG HP bar.
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
    this.height = 18,
    this.segments = 10,
    this.label,
    this.animate = true,
  });

  @override
  Widget build(BuildContext context) {
    final glow = glowColor ?? barColor;
    final clampedValue = value.clamp(0.0, 1.0);

    Widget bar = LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          height: height,
          decoration: BoxDecoration(
            color: Colors.black,
            border: Border.all(
              color: barColor.withValues(alpha: 0.8),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: glow.withValues(alpha: 0.3),
                blurRadius: 8,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Stack(
            children: [
              // Filled portion
              FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: clampedValue,
                child: Container(
                  decoration: BoxDecoration(
                    color: barColor,
                    boxShadow: [
                      BoxShadow(
                        color: glow.withValues(alpha: 0.6),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                ),
              ),

              // Segment lines overlay
              if (segments > 1)
                Row(
                  children: List.generate(segments - 1, (i) {
                    return Expanded(
                      child: Container(
                        margin: const EdgeInsets.only(right: 0),
                        decoration: BoxDecoration(
                          border: Border(
                            right: BorderSide(
                              color: Colors.black.withValues(alpha: 0.5),
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
            ],
          ),
        );
      },
    );

    if (animate) {
      bar = bar
          .animate(onPlay: (controller) => controller.repeat())
          .shimmer(
            duration: 2500.ms,
            color: Colors.white.withValues(alpha: 0.15),
          );
    }

    if (label == null) return bar;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label!,
          style: GameTheme.textTheme.bodySmall?.copyWith(
            color: barColor,
            fontSize: 8,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 4),
        bar,
      ],
    );
  }
}
