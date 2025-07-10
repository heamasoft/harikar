// lib/screens/splash_screen.dart

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../main.dart'; // for LocaleProvider

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _logoAnimation;
  late final Animation<double> _textAnimation;
  bool _showLanguageOptions = false;

  @override
  void initState() {
    super.initState();

    // 1. Prepare the animations
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    );

    _logoAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
    _textAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    // 2. When the animation finishes, decide what to do
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _onAnimationComplete();
      }
    });

    // 3. Kick off the animation
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// After splash animation ends, check if language is saved.
  Future<void> _onAnimationComplete() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('selectedLanguage');

    if (saved != null) {
      // 4a. Already chosen: apply & go straight to dashboard
      final localeProv = Provider.of<LocaleProvider>(context, listen: false);
      if (saved == 'ku') {
        localeProv.setLocale(Locale('ku', 'IQ'));
      } else {
        localeProv.setLocale(Locale('ar', ''));
      }
      Navigator.pushReplacementNamed(context, '/dashboard');
    } else {
      // 4b. First run: show the buttons
      setState(() {
        _showLanguageOptions = true;
      });
    }
  }

  /// Save choice, apply locale, and navigate
  Future<void> _setLanguage(String code) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedLanguage', code);

    final localeProv = Provider.of<LocaleProvider>(context, listen: false);
    if (code == 'ku') {
      localeProv.setLocale(Locale('ku', 'IQ'));
    } else {
      localeProv.setLocale(Locale('ar', ''));
    }

    Navigator.pushReplacementNamed(context, '/dashboard');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple.shade700,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo scale
            ScaleTransition(
              scale: _logoAnimation,
              child: Image.asset(
                'assets/logo.png',
                height: 120,
                width: 120,
              ),
            ),

            SizedBox(height: 20),

            // App name & tagline fade
            FadeTransition(
              opacity: _textAnimation,
              child: Column(
                children: [
                  Text(
                    'هاریکار',
                    style: TextStyle(
                      fontFamily: 'NotoKufi',
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'ئاسانکاری و خێرای دکاری دا',
                    style: TextStyle(
                      fontFamily: 'NotoKufi',
                      fontSize: 18,
                      color: Colors.white70,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            // Only show this block once the animation is done
            if (_showLanguageOptions) ...[
              SizedBox(height: 40),
              Text(
                'زمان (Language)',
                style: TextStyle(
                  fontFamily: 'NotoKufi',
                  fontSize: 20,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () => _setLanguage('ku'),
                    child: Text('کوردی'),
                  ),
                  SizedBox(width: 20),
                  ElevatedButton(
                    onPressed: () => _setLanguage('ar'),
                    child: Text('العربية'),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
