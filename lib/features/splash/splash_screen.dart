import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
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
  String _currentMessage = 'Initializing...';
  final List<String> _messages = [
    'Loading preferences...',
    'Syncing data...',
    'Preparing tasks...',
    'Ready!',
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
      backgroundColor: AppTheme.background,
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo or Title
                Icon(
                  Icons.auto_awesome,
                  size: 64,
                  color: AppTheme.primary,
                ),
                const SizedBox(height: 24),
                Text(
                  'LEVEL UP',
                  style: AppTheme.textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryDark,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'PRODUCTIVITY',
                  style: AppTheme.textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                    letterSpacing: 4,
                  ),
                ),

                const SizedBox(height: 60),

                // Animated Progress Bar Container
                Container(
                  width: 250,
                  height: 8,
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Stack(
                    children: [
                      // Progress Fill
                      Container(
                        width: 250 * _progress,
                        decoration: BoxDecoration(
                          color: AppTheme.primary,
                          borderRadius: BorderRadius.circular(4),
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
                    _currentMessage,
                    style: AppTheme.textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


