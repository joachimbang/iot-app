import 'dart:async';
import 'package:flutter/material.dart';
import 'bottomNavbar.dart'; // Import du BottomNavbar
import 'package:node_red_app/utils/chart_data.dart';

class SplashScreen extends StatefulWidget {
  static const routename = '/';
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _controller.forward();

    // Naviguer vers BottomNavbar après 3 secondes
    Timer(const Duration(seconds: 5), _navigateToBottomNavbar);
  }

  void _navigateToBottomNavbar() {
    if (!mounted) return; // sécurité
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => BottomNavbar(
          initialChartData: {
            "temperature": [],
            "humidity": [],
            "luminosity": [],
            "distance": [],
          }, chartData: {},
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildLogo(BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.home, size: 100, color: Theme.of(context).primaryColor),
          const SizedBox(height: 20),
          Text(
            'Command ESP32',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
          const SizedBox(height: 10),
          const Text('Build by Joachim', style: TextStyle(fontSize: 14)),
        ],
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: _buildLogo(context),
          ),
        ),
      ),
    );
  }
}
