import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../app/app_root.dart';
import '../../onboarding/ui/onboarding_screen.dart';
import 'splash_screen.dart';

class SplashNavigation extends StatefulWidget {
  const SplashNavigation({super.key});

  @override
  State<SplashNavigation> createState() => _SplashNavigationState();
}

class _SplashNavigationState extends State<SplashNavigation> {
  bool _isLoading = true;
  Widget? _nextScreen;

  @override
  void initState() {
    super.initState();
    _checkFirstTime();
  }

  Future<void> _checkFirstTime() async {
    final prefs = await SharedPreferences.getInstance();
    final bool onboardingCompleted = prefs.getBool('onboarding_completed') ?? false;

    if (mounted) {
      setState(() {
        _nextScreen = onboardingCompleted 
            ? const AppRoot() 
            : const OnboardingScreen();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SplashScreen();
    }
    
    // Splash tamamlandıktan sonra ana uygulamaya geç
    return _nextScreen!;
  }
}