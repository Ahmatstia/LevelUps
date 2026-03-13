import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_theme.dart';
import '../services/sfx_service.dart';

/// Full-screen overlay shown when the player levels up.
/// Shows confetti blast, neon "LEVEL UP!" text, and plays fanfare SFX.
/// Dismisses automatically after 4 seconds or on tap.
class LevelUpOverlay extends StatefulWidget {
  final int newLevel;
  final VoidCallback onDismiss;

  const LevelUpOverlay({
    super.key,
    required this.newLevel,
    required this.onDismiss,
  });

  /// Inserts the LevelUpOverlay into the Overlay above everything.
  static OverlayEntry show(BuildContext context, {required int newLevel}) {
    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) =>
          LevelUpOverlay(newLevel: newLevel, onDismiss: () => entry.remove()),
    );
    Overlay.of(context).insert(entry);
    return entry;
  }

  @override
  State<LevelUpOverlay> createState() => _LevelUpOverlayState();
}

class _LevelUpOverlayState extends State<LevelUpOverlay> {
  late final ConfettiController _confetti;

  @override
  void initState() {
    super.initState();
    _confetti = ConfettiController(duration: const Duration(seconds: 3));
    _confetti.play();
    SfxService.instance.playLevelUp();

    // Auto-dismiss after 4.5 seconds
    Future.delayed(const Duration(milliseconds: 4500), () {
      if (mounted) widget.onDismiss();
    });
  }

  @override
  void dispose() {
    _confetti.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onDismiss,
      child: Material(
        color: Colors.transparent,
        child: Stack(
          children: [
            // Dark backdrop
            Container(color: Colors.black.withValues(alpha: 0.85)),

            // Confetti from top-center
            Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: _confetti,
                blastDirectionality: BlastDirectionality.explosive,
                emissionFrequency: 0.06,
                numberOfParticles: 20,
                gravity: 0.1,
                colors: const [
                  AppTheme.primary,
                  AppTheme.goldYellow,
                  AppTheme.accent,
                  AppTheme.staminaGreen,
                  Colors.white,
                ],
              ),
            ),

            // Center content
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Star burst icon
                  const Icon(
                        Icons.auto_awesome,
                        color: AppTheme.goldYellow,
                        size: 72,
                      )
                      .animate(onPlay: (c) => c.repeat())
                      .shimmer(duration: 800.ms, color: Colors.white)
                      .then()
                      .shake(hz: 2, duration: 500.ms),

                  const SizedBox(height: 32),

                  Text(
                        'LEVEL UP!',
                        style: AppTheme.textTheme.displayLarge?.copyWith(
                          color: AppTheme.primary,
                          fontSize: 36,
                          fontWeight: FontWeight.w900,
                        ),
                      )
                      .animate(onPlay: (c) => c.repeat(reverse: true))
                      .fadeIn(duration: 300.ms)
                      .then()
                      .fadeOut(duration: 300.ms, delay: 400.ms),

                  const SizedBox(height: 20),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 20,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primary.withOpacity(0.15),
                          blurRadius: 20,
                          spreadRadius: 4,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Text(
                          'LEVEL',
                          style: AppTheme.textTheme.bodyMedium?.copyWith(
                            color: AppTheme.primary,
                            letterSpacing: 4,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.newLevel.toString(),
                          style: AppTheme.textTheme.displayLarge?.copyWith(
                            color: AppTheme.primary,
                            fontSize: 56,
                          ),
                        ),
                      ],
                    ),
                  ).animate().scale(
                    delay: 200.ms,
                    duration: 600.ms,
                    curve: Curves.elasticOut,
                  ),

                  const SizedBox(height: 32),

                  Text(
                        'TAP TO CONTINUE',
                        style: AppTheme.textTheme.bodyMedium?.copyWith(
                          color: Colors.white70,
                          letterSpacing: 2,
                        ),
                      )
                      .animate(onPlay: (c) => c.repeat(reverse: true))
                      .fadeIn(duration: 800.ms),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
