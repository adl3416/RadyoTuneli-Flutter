import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../core/services/admob_service.dart';

class InterstitialAdManager {
  static InterstitialAdManager? _instance;
  static InterstitialAdManager get instance => _instance ??= InterstitialAdManager._();
  
  InterstitialAdManager._();

  InterstitialAd? _interstitialAd;
  bool _isAdLoaded = false;
  bool _isAdShowing = false;

  // Ad gösterim sayaçları
  int _screenTransitionCount = 0;
  static const int _adShowFrequency = 3; // Her 3 ekran geçişinde reklam göster

  // Reklamı yükle
  Future<void> loadInterstitialAd() async {
    if (_isAdLoaded || _isAdShowing) return;

    try {
      _interstitialAd = await AdMobService.instance.loadInterstitialAd();
      
      if (_interstitialAd != null) {
        _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
          onAdDismissedFullScreenContent: (ad) {
            print('🎯 Interstitial ad dismissed');
            _disposeAd();
            // Yeni reklam yükle
            loadInterstitialAd();
          },
          onAdFailedToShowFullScreenContent: (ad, error) {
            print('❌ Interstitial ad failed to show: $error');
            _disposeAd();
            // Yeni reklam yükle
            loadInterstitialAd();
          },
          onAdShowedFullScreenContent: (ad) {
            print('🎯 Interstitial ad showed');
            _isAdShowing = true;
          },
          onAdImpression: (ad) {
            print('🎯 Interstitial ad impression recorded');
          },
          onAdClicked: (ad) {
            print('🎯 Interstitial ad clicked');
          },
        );

        _isAdLoaded = true;
        print('🎯 Interstitial ad loaded and ready to show');
      }
    } catch (e) {
      print('❌ Error loading interstitial ad: $e');
      _isAdLoaded = false;
    }
  }

  // Reklamı göster
  Future<bool> showInterstitialAd() async {
    if (!_isAdLoaded || _interstitialAd == null || _isAdShowing) {
      print('⚠️ Interstitial ad not ready to show');
      return false;
    }

    try {
      await _interstitialAd!.show();
      return true;
    } catch (e) {
      print('❌ Error showing interstitial ad: $e');
      _disposeAd();
      return false;
    }
  }

  // Ekran geçişlerinde reklam göster
  Future<void> onScreenTransition() async {
    _screenTransitionCount++;
    
    if (_screenTransitionCount >= _adShowFrequency) {
      _screenTransitionCount = 0;
      await showInterstitialAd();
    }
  }

  // Reklamı temizle
  void _disposeAd() {
    _interstitialAd?.dispose();
    _interstitialAd = null;
    _isAdLoaded = false;
    _isAdShowing = false;
  }

  // Bellek temizliği
  void dispose() {
    _disposeAd();
  }

  // Reklam durumu getters
  bool get isAdLoaded => _isAdLoaded;
  bool get isAdShowing => _isAdShowing;
}

// Interstitial reklam göstermek için yardımcı widget
class InterstitialAdWrapper extends StatefulWidget {
  final Widget child;
  final bool showAdOnInit;

  const InterstitialAdWrapper({
    super.key,
    required this.child,
    this.showAdOnInit = false,
  });

  @override
  State<InterstitialAdWrapper> createState() => _InterstitialAdWrapperState();
}

class _InterstitialAdWrapperState extends State<InterstitialAdWrapper> {
  @override
  void initState() {
    super.initState();
    
    // Reklamı önceden yükle
    InterstitialAdManager.instance.loadInterstitialAd();
    
    // Eğer istendiyse başlangıçta reklam göster
    if (widget.showAdOnInit) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        InterstitialAdManager.instance.showInterstitialAd();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

// Özel interstitial reklam butonları
class ShowInterstitialAdButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;

  const ShowInterstitialAdButton({
    super.key,
    this.text = 'Reklam İzle',
    this.onPressed,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () async {
        final shown = await InterstitialAdManager.instance.showInterstitialAd();
        if (shown) {
          onPressed?.call();
        } else {
          // Reklam gösterilemedi, alternatif aksiyon
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Reklam şu anda kullanılamıyor'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      },
      icon: Icon(icon ?? Icons.play_arrow),
      label: Text(text),
      style: ElevatedButton.styleFrom(
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}

// Navigation helper için mixin
mixin InterstitialAdMixin<T extends StatefulWidget> on State<T> {
  @override
  void initState() {
    super.initState();
    // Ekran geçişi kaydet
    WidgetsBinding.instance.addPostFrameCallback((_) {
      InterstitialAdManager.instance.onScreenTransition();
    });
  }
}