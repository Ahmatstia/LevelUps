import 'package:flutter/material.dart';
import '../../core/theme/game_theme.dart';
import '../../main.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  double _progress = 0.0;
  String _currentMessage = 'Memulai sistem...';
  final List<String> _messages = [
    'Menghubungkan ke Neural Link...',
    'Memuat aset piksel...',
    'Sinkronisasi data hero...',
    'Menyiapkan dunia...',
    'Mengalokasikan Mana...',
    'Membangun Quest...',
    'Sistem SIAP!',
  ];
  int _messageIndex = 0;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(duration: const Duration(seconds: 4), vsync: this)
          ..addListener(() {
            setState(() {
              _progress = _controller.value;
              // Update messages based on progress
              int index = (_controller.value * (_messages.length - 1)).floor();
              if (index != _messageIndex) {
                _messageIndex = index;
                _currentMessage = _messages[_messageIndex];
              }
            });
          });

    _controller.forward().then((_) {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GameTheme.background,
      body: Stack(
        children: [
          // Background Grid Effect
          Positioned.fill(child: CustomPaint(painter: GridPainter())),

          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo or Title
                ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [GameTheme.neonCyan, GameTheme.neonPink],
                  ).createShader(bounds),
                  child: const Text(
                    'LEVEL UP',
                    style: TextStyle(
                      fontFamily: 'PressStart2P',
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 4,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'RPG PRODUCTIVITY',
                  style: TextStyle(
                    fontFamily: 'PressStart2P',
                    fontSize: 12,
                    color: GameTheme.neonCyan,
                    letterSpacing: 2,
                  ),
                ),

                const SizedBox(height: 60),

                // Animated Progress Bar Container
                Container(
                  width: 250,
                  height: 20,
                  decoration: BoxDecoration(
                    border: Border.all(color: GameTheme.neonCyan, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: GameTheme.neonCyan.withValues(alpha: 0.3),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      // Progress Fill
                      Container(
                        width: 250 * _progress,
                        color: GameTheme.neonCyan,
                      ),
                      // Glitchy Scanline Overlay on bar
                      Positioned.fill(
                        child: Opacity(
                          opacity: 0.1,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.black.withValues(alpha: 0.1),
                                  Colors.transparent,
                                  Colors.black.withValues(alpha: 0.1),
                                ],
                                stops: const [0, 0.5, 1],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Loading Text
                SizedBox(
                  height: 20,
                  child: Text(
                    _currentMessage.toUpperCase(),
                    style: const TextStyle(
                      fontFamily: 'PressStart2P',
                      fontSize: 8,
                      color: Colors.white70,
                    ),
                  ),
                ),

                const SizedBox(height: 5),

                // Percentage
                Text(
                  '${(_progress * 100).toInt()}%',
                  style: const TextStyle(
                    fontFamily: 'PressStart2P',
                    fontSize: 10,
                    color: GameTheme.neonCyan,
                  ),
                ),
              ],
            ),
          ),

          // CRT Overlay Effect
          IgnorePointer(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.05),
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.05),
                  ],
                  stops: const [0, 0.5, 1],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = GameTheme.neonCyan.withValues(alpha: 0.05)
      ..strokeWidth = 1;

    const double step = 30;

    for (double i = 0; i < size.width; i += step) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }

    for (double i = 0; i < size.height; i += step) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
