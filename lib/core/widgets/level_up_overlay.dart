import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/game_theme.dart';
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
                  GameTheme.neonCyan,
                  GameTheme.goldYellow,
                  GameTheme.neonPink,
                  GameTheme.staminaGreen,
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
                        color: GameTheme.goldYellow,
                        size: 72,
                        shadows: [
                          Shadow(color: GameTheme.goldYellow, blurRadius: 30),
                        ],
                      )
                      .animate(onPlay: (c) => c.repeat())
                      .shimmer(duration: 800.ms, color: Colors.white)
                      .then()
                      .shake(hz: 2, duration: 500.ms),

                  const SizedBox(height: 32),

                  // "LEVEL UP!" blinking neon text
                  Text(
                        'LEVEL UP!',
                        style:
                            GameTheme.neonTextStyle(
                              GameTheme.neonCyan,
                              fontSize: 36,
                            ).copyWith(
                              shadows: [
                                const Shadow(
                                  color: GameTheme.neonCyan,
                                  blurRadius: 20,
                                ),
                                const Shadow(
                                  color: GameTheme.neonCyan,
                                  blurRadius: 40,
                                ),
                              ],
                            ),
                      )
                      .animate(onPlay: (c) => c.repeat(reverse: true))
                      .fadeIn(duration: 300.ms)
                      .then()
                      .fadeOut(duration: 300.ms, delay: 400.ms),

                  const SizedBox(height: 20),

                  // Level badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      color: GameTheme.surface,
                      border: Border.all(color: GameTheme.goldYellow, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: GameTheme.goldYellow.withValues(alpha: 0.4),
                          blurRadius: 20,
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Text(
                          'LEVEL',
                          style: GameTheme.textTheme.bodySmall?.copyWith(
                            color: GameTheme.goldYellow,
                            letterSpacing: 4,
                            fontSize: 10,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.newLevel.toString(),
                          style: GameTheme.neonTextStyle(
                            GameTheme.goldYellow,
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
                        style: GameTheme.textTheme.bodySmall?.copyWith(
                          color: Colors.grey[500],
                          fontSize: 8,
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
