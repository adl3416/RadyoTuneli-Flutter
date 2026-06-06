import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../app/app_root.dart';
import '../../../core/theme/app_theme.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IntroductionScreen(
        globalBackgroundColor: AppTheme.headerPurple,
        pages: _buildPages(),
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
            color: Colors.white.withOpacity(0.16),
            borderRadius: BorderRadius.circular(25),
            border: Border.all(color: Colors.white.withOpacity(0.16)),
          ),
          padding: const EdgeInsets.all(10),
          child: const Icon(
            Icons.arrow_forward,
            color: Colors.white,
            size: 24,
          ),
        ),
        done: FittedBox(
          fit: BoxFit.scaleDown,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
            ),
            child: const Text(
              'Başla',
              softWrap: false,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: AppTheme.headerPurple,
                fontSize: 16,
              ),
            ),
          ),
        ),
        curve: Curves.fastLinearToSlowEaseIn,
        controlsMargin: const EdgeInsets.all(16),
        controlsPadding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
        dotsDecorator: const DotsDecorator(
          size: Size(10, 10),
          color: Colors.white38,
          activeSize: Size(22, 10),
          activeColor: Colors.white,
          activeShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(25)),
          ),
        ),
        dotsContainerDecorator: ShapeDecoration(
          color: AppTheme.cardPurpleDark.withOpacity(0.35),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
        ),
      ),
    );
  }

  List<PageViewModel> _buildPages() {
    return [
      PageViewModel(
        title: "Radyo Tüneli'ne Hoş Geldiniz!",
        body: "Türkiye'nin sevilen radyo istasyonlarını tek yerde keşfedin.",
        image: _buildHeroImage(),
        decoration: _getPageDecoration(),
      ),
      PageViewModel(
        title: 'Farklı Kategoriler',
        body: 'Müzik, türkü, haber ve daha fazlasına hızlıca ulaşın.',
        image: _buildPageImage(
          icon: Icons.grid_view_rounded,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.cardPurple.withOpacity(0.9),
              AppTheme.cardPurpleDark.withOpacity(0.75),
            ],
          ),
        ),
        decoration: _getPageDecoration(),
      ),
      PageViewModel(
        title: 'Arabada da Dinleyin',
        body: 'Araç kullanımına uygun pratik deneyimle yayınları sürdürebilin.',
        image: _buildPageImage(
          icon: Icons.directions_car_filled_rounded,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.orange400.withOpacity(0.95),
              AppTheme.yellowOrange.withOpacity(0.82),
            ],
          ),
        ),
        decoration: _getPageDecoration(),
      ),
    ];
  }

  Widget _buildPageImage({
    required IconData icon,
    required Gradient gradient,
  }) {
    return Container(
      width: 196,
      height: 196,
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(98),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.22),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Icon(
        icon,
        size: 82,
        color: Colors.white,
      ),
    );
  }

  Widget _buildHeroImage() {
    return Container(
      width: 224,
      height: 224,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.18),
            Colors.white.withOpacity(0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(36),
        border: Border.all(color: Colors.white.withOpacity(0.16)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.18),
            blurRadius: 32,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: Image.asset(
            'assets/images/app_icon_full.png',
            width: 168,
            height: 168,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }

  PageDecoration _getPageDecoration() {
    return const PageDecoration(
      titleTextStyle: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: Colors.white,
      ),
      bodyTextStyle: TextStyle(
        fontSize: 16,
        color: Colors.white70,
        height: 1.4,
      ),
      imagePadding: EdgeInsets.only(top: 40),
      pageColor: AppTheme.headerPurple,
      contentMargin: EdgeInsets.symmetric(horizontal: 16),
      titlePadding: EdgeInsets.only(top: 32, bottom: 16),
      bodyPadding: EdgeInsets.symmetric(horizontal: 16),
    );
  }

  void _onIntroEnd(BuildContext context) async {
    HapticFeedback.lightImpact();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_completed', true);

    if (context.mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const AppRoot(),
        ),
      );
    }
  }
}
