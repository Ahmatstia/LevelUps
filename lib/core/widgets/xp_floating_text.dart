import 'package:flutter/material.dart';
import '../theme/game_theme.dart';

/// Shows a floating "+XP" text at the given [position] that
/// floats upward and fades out — classic JRPG damage number style.
///
/// Usage:
/// ```dart
/// XpFloatingText.show(context, position: renderBox.localToGlobal(Offset.zero), xp: 25);
/// ```
class XpFloatingText extends StatelessWidget {
  final int xp;
  final VoidCallback onComplete;

  const XpFloatingText({super.key, required this.xp, required this.onComplete});

  static OverlayEntry? _activeEntry;

  /// Inserts a floating +XP text at the screen position of [renderBox].
  /// Automatically removes itself after the animation completes.
  static void show(
    BuildContext context, {
    required RenderBox renderBox,
    required int xp,
  }) {
    // Dismiss any previous floating text
    _activeEntry?.remove();
    _activeEntry = null;

    final position = renderBox.localToGlobal(
      Offset(renderBox.size.width / 2 - 30, renderBox.size.height / 2),
    );

    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (ctx) => Positioned(
        left: position.dx,
        top: position.dy,
        child: IgnorePointer(
          child: XpFloatingText(
            xp: xp,
            onComplete: () {
              entry.remove();
              if (_activeEntry == entry) _activeEntry = null;
            },
          ),
        ),
      ),
    );

    _activeEntry = entry;
    Overlay.of(context).insert(entry);
  }

  @override
  Widget build(BuildContext context) {
    return _FloatingXpAnimated(xp: xp, onComplete: onComplete);
  }
}

class _FloatingXpAnimated extends StatefulWidget {
  final int xp;
  final VoidCallback onComplete;

  const _FloatingXpAnimated({required this.xp, required this.onComplete});

  @override
  State<_FloatingXpAnimated> createState() => _FloatingXpAnimatedState();
}

class _FloatingXpAnimatedState extends State<_FloatingXpAnimated>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _slideY;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _slideY = Tween<double>(
      begin: 0,
      end: -80,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));

    _opacity = Tween<double>(begin: 1, end: 0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.5, 1.0, curve: Curves.easeIn),
      ),
    );

    _ctrl.forward().whenComplete(widget.onComplete);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => Transform.translate(
        offset: Offset(0, _slideY.value),
        child: Opacity(
          opacity: _opacity.value,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: GameTheme.goldYellow.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: GameTheme.goldYellow, width: 1),
              boxShadow: [
                BoxShadow(
                  color: GameTheme.goldYellow.withValues(alpha: 0.5),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Text(
              '+${widget.xp} XP',
              style: GameTheme.neonTextStyle(GameTheme.goldYellow, fontSize: 12)
                  .copyWith(
                    shadows: [
                      Shadow(color: GameTheme.goldYellow, blurRadius: 12),
                    ],
                  ),
            ),
          ),
        ),
      ),
    );
  }
}
