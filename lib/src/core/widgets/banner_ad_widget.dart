import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../core/services/admob_service.dart';

class BannerAdWidget extends StatefulWidget {
  final AdSize adSize;
  final EdgeInsets padding;
  final bool showCloseButton;

  const BannerAdWidget({
    super.key,
    this.adSize = AdSize.banner,
    this.padding = const EdgeInsets.all(8.0),
    this.showCloseButton = false,
  });

  @override
  State<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> {
  BannerAd? _bannerAd;
  bool _isAdLoaded = false;
  bool _isAdClosed = false;

  @override
  void initState() {
    super.initState();
    _loadBannerAd();
  }

  void _loadBannerAd() {
    _bannerAd = AdMobService.instance.createBannerAd(
      adSize: widget.adSize,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          print('🎯 Banner ad loaded successfully');
          if (mounted) {
            setState(() {
              _isAdLoaded = true;
            });
          }
        },
        onAdFailedToLoad: (ad, error) {
          print('❌ Banner ad failed to load: $error');
          ad.dispose();
          if (mounted) {
            setState(() {
              _isAdLoaded = false;
            });
          }
        },
        onAdOpened: (ad) {
          print('🎯 Banner ad opened');
        },
        onAdClosed: (ad) {
          print('🎯 Banner ad closed');
        },
        onAdImpression: (ad) {
          print('🎯 Banner ad impression recorded');
        },
        onAdClicked: (ad) {
          print('🎯 Banner ad clicked');
        },
      ),
    );

    _bannerAd?.load();
  }

  void _closeBannerAd() {
    setState(() {
      _isAdClosed = true;
    });
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Eğer reklam kapatıldıysa hiçbir şey gösterme
    if (_isAdClosed) {
      return const SizedBox.shrink();
    }

    // Eğer reklam yüklenmediyse loading indicator göster
    if (!_isAdLoaded || _bannerAd == null) {
      return Container(
        padding: widget.padding,
        child: Container(
          width: widget.adSize.width.toDouble(),
          height: widget.adSize.height.toDouble(),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface.withOpacity(0.3),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Theme.of(context).dividerColor.withOpacity(0.5),
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Theme.of(context).primaryColor.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Reklam yükleniyor...',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Reklam yüklendiyse göster
    return Container(
      padding: widget.padding,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).shadowColor.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Stack(
            children: [
              // Banner reklam
              SizedBox(
                width: widget.adSize.width.toDouble(),
                height: widget.adSize.height.toDouble(),
                child: AdWidget(ad: _bannerAd!),
              ),
              
              // Kapatma butonu (eğer etkinleştirilmişse)
              if (widget.showCloseButton)
                Positioned(
                  top: 4,
                  right: 4,
                  child: GestureDetector(
                    onTap: _closeBannerAd,
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// Farklı boyutlarda banner reklamlar için özel widget'lar
class SmallBannerAdWidget extends StatelessWidget {
  final EdgeInsets padding;
  final bool showCloseButton;

  const SmallBannerAdWidget({
    super.key,
    this.padding = const EdgeInsets.all(8.0),
    this.showCloseButton = false,
  });

  @override
  Widget build(BuildContext context) {
    return BannerAdWidget(
      adSize: AdSize.banner, // 320x50
      padding: padding,
      showCloseButton: showCloseButton,
    );
  }
}

class LargeBannerAdWidget extends StatelessWidget {
  final EdgeInsets padding;
  final bool showCloseButton;

  const LargeBannerAdWidget({
    super.key,
    this.padding = const EdgeInsets.all(8.0),
    this.showCloseButton = false,
  });

  @override
  Widget build(BuildContext context) {
    return BannerAdWidget(
      adSize: AdSize.largeBanner, // 320x100
      padding: padding,
      showCloseButton: showCloseButton,
    );
  }
}

class MediumRectangleBannerAdWidget extends StatelessWidget {
  final EdgeInsets padding;
  final bool showCloseButton;

  const MediumRectangleBannerAdWidget({
    super.key,
    this.padding = const EdgeInsets.all(8.0),
    this.showCloseButton = false,
  });

  @override
  Widget build(BuildContext context) {
    return BannerAdWidget(
      adSize: AdSize.mediumRectangle, // 300x250
      padding: padding,
      showCloseButton: showCloseButton,
    );
  }
}