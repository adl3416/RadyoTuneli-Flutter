import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/vintage_radio_logo.dart';
import '../../../app/app_root.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IntroductionScreen(
        globalBackgroundColor: AppTheme.headerPurple,
        pages: _buildPages(context),
        onDone: () => _onIntroEnd(context),
        onSkip: () => _onIntroEnd(context),
        showSkipButton: true,
        skip: const Text(
          'Geç',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.white,
            fontSize: 16,
          ),
        ),
        next: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(25),
          ),
          child: const Icon(
            Icons.arrow_forward,
            color: Colors.white,
            size: 24,
          ),
        ),
        done: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(25),
          ),
          child: const Text(
            'Başla',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: AppTheme.headerPurple,
              fontSize: 16,
            ),
          ),
        ),
        curve: Curves.fastLinearToSlowEaseIn,
        controlsMargin: const EdgeInsets.all(16),
        controlsPadding: const EdgeInsets.fromLTRB(8.0, 4.0, 8.0, 4.0),
        dotsDecorator: const DotsDecorator(
          size: Size(10.0, 10.0),
          color: Colors.white38,
          activeSize: Size(22.0, 10.0),
          activeColor: Colors.white,
          activeShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(25.0)),
          ),
        ),
        dotsContainerDecorator: ShapeDecoration(
          color: Colors.black.withOpacity(0.2),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(8.0)),
          ),
        ),
      ),
    );
  }

  List<PageViewModel> _buildPages(BuildContext context) {
    return [
      // Sayfa 1: Hoş Geldiniz
      PageViewModel(
        title: "Radyo Tüneli'ne Hoş Geldiniz!",
        body: "Türkiye'nin en iyi radyo istasyonlarını keşfedin",
        image: _buildVintageRadioImage(),
        decoration: _getPageDecoration(),
      ),

      // Sayfa 2: Kategoriler
      PageViewModel(
        title: "7 Farklı Kategori",
        body: "Haber, müzik, spor ve daha fazlası...",
        image: _buildPageImage(
          icon: Icons.category,
          color: Colors.white,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.cardPurple.withOpacity(0.8),
              AppTheme.cardPurpleDark.withOpacity(0.6),
            ],
          ),
        ),
        decoration: _getPageDecoration(),
      ),

      // Sayfa 3: Android Auto
      PageViewModel(
        title: "Arabada da Dinleyin",
        body: "Android Auto ve CarPlay desteği",
        image: _buildPageImage(
          icon: Icons.directions_car,
          color: Colors.white,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.orange400.withOpacity(0.8),
              AppTheme.yellowOrange.withOpacity(0.6),
            ],
          ),
        ),
        decoration: _getPageDecoration(),
      ),
    ];
  }

  Widget _buildPageImage({
    required IconData icon,
    required Color color,
    required Gradient gradient,
  }) {
    return Container(
      width: 200,
      height: 200,
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Icon(
        icon,
        size: 80,
        color: color,
      ),
    );
  }

  PageDecoration _getPageDecoration() {
    return PageDecoration(
      titleTextStyle: const TextStyle(
        fontSize: 24.0,
        fontWeight: FontWeight.w700,
        color: Colors.white,
      ),
      bodyTextStyle: const TextStyle(
        fontSize: 16.0,
        color: Colors.white70,
        height: 1.4,
      ),
      imagePadding: const EdgeInsets.only(top: 60),
      pageColor: AppTheme.headerPurple,
      contentMargin: const EdgeInsets.symmetric(horizontal: 16),
      titlePadding: const EdgeInsets.only(top: 40, bottom: 16),
      bodyPadding: const EdgeInsets.symmetric(horizontal: 16),
    );
  }

  void _onIntroEnd(BuildContext context) async {
    HapticFeedback.lightImpact();
    
    // Onboarding'in tamamlandığını kaydet
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_completed', true);

    // Ana uygulamaya geç
    if (context.mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const AppRoot(),
        ),
      );
    }
  }

  Widget _buildVintageRadioImage() {
    return Container(
      width: 200,
      height: 200,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.1),
            Colors.white.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: const Center(
        child: VintageRadioLogo(
          size: 120,
          primaryColor: Colors.white,
          accentColor: Color(0xFFE5E7EB),
        ),
      ),
    );
  }
}