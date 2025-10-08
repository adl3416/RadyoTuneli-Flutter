import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../app/main_screen.dart';
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
    // Theme provider'ın yüklenmesi için kısa bir süre bekle
    await Future.delayed(const Duration(milliseconds: 500));
    
    final prefs = await SharedPreferences.getInstance();
    final bool onboardingCompleted = prefs.getBool('onboarding_completed') ?? false;

    if (mounted) {
      setState(() {
        _nextScreen = onboardingCompleted 
            ? const MainScreen() 
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