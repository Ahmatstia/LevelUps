import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:confetti/confetti.dart';
import '../../core/theme/game_theme.dart';
import '../../core/providers/user_provider.dart';

class DailyRewardDialog extends ConsumerStatefulWidget {
  final int xpAmount;
  final int streakDay;

  const DailyRewardDialog({
    super.key,
    required this.xpAmount,
    required this.streakDay,
  });

  static Future<void> show(BuildContext context, WidgetRef ref) async {
    final user = ref.read(userProvider);
    if (user == null) return;

    final lastLogin = user.lastTaskDate;
    final now = DateTime.now();
    final todayNorm = DateTime(now.year, now.month, now.day);
    final lastNorm = DateTime(lastLogin.year, lastLogin.month, lastLogin.day);

    // Jika sudah login hari ini, jangan tampilkan
    if (lastNorm == todayNorm) return;

    // Hitung XP reward berdasarkan streak
    final streak = user.streak;
    int xp;
    if (streak >= 7) {
      xp = 50;
    } else if (streak >= 3) {
      xp = 30;
    } else if (streak >= 2) {
      xp = 20;
    } else {
      xp = 15;
    }

    // Claim reward
    await ref.read(userProvider.notifier).addXp(xp);

    if (context.mounted) {
      await showDialog(
        context: context,
        barrierDismissible: false,
        barrierColor: Colors.black87,
        builder: (_) => DailyRewardDialog(xpAmount: xp, streakDay: streak + 1),
      );
    }
  }

  @override
  ConsumerState<DailyRewardDialog> createState() => _DailyRewardDialogState();
}

class _DailyRewardDialogState extends ConsumerState<DailyRewardDialog> {
  late ConfettiController _confetti;

  @override
  void initState() {
    super.initState();
    _confetti = ConfettiController(duration: const Duration(seconds: 3));
    Future.delayed(const Duration(milliseconds: 300), () {
      _confetti.play();
    });
  }

  @override
  void dispose() {
    _confetti.dispose();
    super.dispose();
  }

  String get _tierLabel {
    if (widget.streakDay >= 7) return '🔥 STREAK BONUS!';
    if (widget.streakDay >= 3) return '⚡ COMBO REWARD!';
    return '🎁 DAILY REWARD!';
  }

  Color get _tierColor {
    if (widget.streakDay >= 7) return GameTheme.goldYellow;
    if (widget.streakDay >= 3) return GameTheme.neonPink;
    return GameTheme.neonCyan;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        // Confetti
        ConfettiWidget(
          confettiController: _confetti,
          blastDirectionality: BlastDirectionality.explosive,
          numberOfParticles: 30,
          gravity: 0.3,
          colors: [
            GameTheme.neonCyan,
            GameTheme.neonPink,
            GameTheme.goldYellow,
            GameTheme.staminaGreen,
          ],
        ),
        Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: GameTheme.surface,
              border: Border.all(color: _tierColor, width: 2),
              boxShadow: [
                BoxShadow(
                  color: _tierColor.withValues(alpha: 0.3),
                  blurRadius: 20,
                  spreadRadius: 4,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Text(
                  _tierLabel,
                  style: GameTheme.neonTextStyle(_tierColor, fontSize: 14),
                  textAlign: TextAlign.center,
                ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.3),
                const SizedBox(height: 24),

                // XP Icon
                Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _tierColor.withValues(alpha: 0.1),
                        border: Border.all(color: _tierColor, width: 3),
                        boxShadow: [
                          BoxShadow(
                            color: _tierColor.withValues(alpha: 0.4),
                            blurRadius: 20,
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.bolt,
                        color: _tierColor,
                        size: 44,
                        shadows: [Shadow(color: _tierColor, blurRadius: 12)],
                      ),
                    )
                    .animate(delay: 200.ms)
                    .scale(
                      begin: const Offset(0, 0),
                      duration: 500.ms,
                      curve: Curves.elasticOut,
                    ),
                const SizedBox(height: 20),

                // XP Amount
                Text(
                      '+${widget.xpAmount} XP',
                      style: GameTheme.neonTextStyle(_tierColor, fontSize: 36),
                    )
                    .animate(delay: 400.ms)
                    .fadeIn()
                    .scale(begin: const Offset(0.5, 0.5), duration: 400.ms),
                const SizedBox(height: 8),

                Text(
                  'Login Day ${widget.streakDay}',
                  style: GameTheme.textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[400],
                    letterSpacing: 1,
                  ),
                ).animate(delay: 500.ms).fadeIn(),
                const SizedBox(height: 6),

                if (widget.streakDay >= 7)
                  Text(
                    'Streak bonus activated! Keep it up!',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 11,
                      color: GameTheme.goldYellow,
                    ),
                    textAlign: TextAlign.center,
                  ).animate(delay: 600.ms).fadeIn(),

                const SizedBox(height: 28),

                // Claim Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _tierColor,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero,
                      ),
                      elevation: 0,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(
                      'CLAIM REWARD!',
                      style: GameTheme.textTheme.bodyMedium?.copyWith(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                ).animate(delay: 700.ms).slideY(begin: 0.3).fadeIn(),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
