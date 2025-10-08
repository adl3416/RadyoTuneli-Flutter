import 'dart:io';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdMobService {
  static AdMobService? _instance;
  static AdMobService get instance => _instance ??= AdMobService._();
  
  AdMobService._();

  // Test Ad Unit IDs - Gerçek yayınlama için bu ID'leri kendi AdMob hesabınızdan alacaksınız
  static const String _testBannerId = 'ca-app-pub-3940256099942544/6300978111';
  static const String _testInterstitialId = 'ca-app-pub-3940256099942544/1033173712';
  static const String _testRewardedId = 'ca-app-pub-3940256099942544/5224354917';

  // Platform bazlı ad unit ID'leri
  static String get bannerAdUnitId {
    if (Platform.isAndroid) {
      return _testBannerId; // Android banner ad unit ID
    } else if (Platform.isIOS) {
      return _testBannerId; // iOS banner ad unit ID
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }

  static String get interstitialAdUnitId {
    if (Platform.isAndroid) {
      return _testInterstitialId; // Android interstitial ad unit ID
    } else if (Platform.isIOS) {
      return _testInterstitialId; // iOS interstitial ad unit ID
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }

  static String get rewardedAdUnitId {
    if (Platform.isAndroid) {
      return _testRewardedId; // Android rewarded ad unit ID
    } else if (Platform.isIOS) {
      return _testRewardedId; // iOS rewarded ad unit ID
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }

  // AdMob'u başlat
  Future<void> initialize() async {
    try {
      await MobileAds.instance.initialize();
      print('🎯 AdMob initialized successfully');
    } catch (e) {
      print('❌ AdMob initialization failed: $e');
    }
  }

  // Request configuration
  AdRequest get adRequest => const AdRequest(
    keywords: ['music', 'radio', 'audio', 'streaming'],
    contentUrl: 'https://www.radyotuneli.com',
    nonPersonalizedAds: false,
  );

  // Banner ad oluştur
  BannerAd createBannerAd({
    required AdSize adSize,
    required BannerAdListener listener,
  }) {
    return BannerAd(
      adUnitId: bannerAdUnitId,
      size: adSize,
      request: adRequest,
      listener: listener,
    );
  }

  // Interstitial ad yükle
  Future<InterstitialAd?> loadInterstitialAd() async {
    try {
      InterstitialAd? loadedAd;
      await InterstitialAd.load(
        adUnitId: interstitialAdUnitId,
        request: adRequest,
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (ad) {
            print('🎯 Interstitial ad loaded successfully');
            loadedAd = ad;
          },
          onAdFailedToLoad: (error) {
            print('❌ Interstitial ad failed to load: $error');
            loadedAd = null;
          },
        ),
      );
      return loadedAd;
    } catch (e) {
      print('❌ Error loading interstitial ad: $e');
      return null;
    }
  }

  // Rewarded ad yükle
  Future<RewardedAd?> loadRewardedAd() async {
    try {
      RewardedAd? loadedAd;
      await RewardedAd.load(
        adUnitId: rewardedAdUnitId,
        request: adRequest,
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          onAdLoaded: (ad) {
            print('🎯 Rewarded ad loaded successfully');
            loadedAd = ad;
          },
          onAdFailedToLoad: (error) {
            print('❌ Rewarded ad failed to load: $error');
            loadedAd = null;
          },
        ),
      );
      return loadedAd;
    } catch (e) {
      print('❌ Error loading rewarded ad: $e');
      return null;
    }
  }

  // Ad size helpers
  static AdSize get adaptiveBannerSize {
    return AdSize.banner; // 320x50
  }

  static AdSize get largeBannerSize {
    return AdSize.largeBanner; // 320x100
  }

  static AdSize get mediumRectangleSize {
    return AdSize.mediumRectangle; // 300x250
  }

  // Test cihaz ID'lerini ayarla (geliştirme sırasında)
  void setTestDeviceIds(List<String> testDeviceIds) {
    MobileAds.instance.updateRequestConfiguration(
      RequestConfiguration(testDeviceIds: testDeviceIds),
    );
  }
}