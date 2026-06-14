import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'radio_logo.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/providers/color_scheme_provider.dart';

class RadioStationCard extends ConsumerWidget {
  final String title;
  final String subtitle;
  final String? imageUrl;
  final VoidCallback? onTap;
  final VoidCallback? onFavoriteToggle;
  final bool isPlaying;
  final bool isFavorite;
  final Color? backgroundColor;
  final Color? titleColor;
  final Color? subtitleColor;
  final Color? playButtonBackgroundColor;
  final Color? playIconColor;

  const RadioStationCard({
    Key? key,
    required this.title,
    required this.subtitle,
    this.imageUrl,
    this.onTap,
    this.onFavoriteToggle,
    this.isPlaying = false,
    this.isFavorite = false,
    this.backgroundColor,
    this.titleColor,
    this.subtitleColor,
    this.playButtonBackgroundColor,
    this.playIconColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final themeName = ref.watch(colorSchemeProvider);
    final isWhiteTheme = themeName == 'beyaz';

    // Beyaz veya Sade tema için özel stil
    final isNeutralTheme =
        themeName == 'varsayilan' ||
        themeName == 'purple' ||
        themeName == 'beyaz' ||
        themeName == 'sade';
    
    final effectiveBgColor =
        backgroundColor ??
        (isNeutralTheme
            ? (themeName == 'varsayilan' || themeName == 'purple'
                ? const Color(0xFFF1F3F5)
                : Colors.white)
            : null);
    
    final primary = effectiveBgColor ?? colorScheme.primary;
    final cardStart = effectiveBgColor == null
        ? (isPlaying ? const Color(0xFF9A63FF) : const Color(0xFF7E57E7))
        : HSLColor.fromColor(primary).withLightness(0.44).toColor();
    final cardMid = effectiveBgColor == null
        ? (isPlaying ? const Color(0xFF7744EA) : const Color(0xFF5B38D2))
        : HSLColor.fromColor(primary).withLightness(0.37).toColor();
    final cardEnd = effectiveBgColor == null
        ? (isPlaying ? const Color(0xFF4520BE) : const Color(0xFF311C82))
        : HSLColor.fromColor(primary).withLightness(0.27).toColor();

    final resolvedTitleColor =
        titleColor ?? (isNeutralTheme ? colorScheme.onSurface : Colors.white);
    final resolvedSubtitleColor = subtitleColor ??
        (isNeutralTheme
            ? colorScheme.onSurface.withValues(alpha: 0.64)
            : const Color(0xFFE2D9FF).withValues(alpha: 0.92));

    final isLightCard = effectiveBgColor != null &&
        ThemeData.estimateBrightnessForColor(effectiveBgColor) ==
            Brightness.light;
    final resolvedCardBorder = isLightCard
        ? (isWhiteTheme
            ? const Color(0xFFF1F4F8)
            : const Color(0xFFDCE3EC))
        : Colors.white.withValues(alpha: isPlaying ? 0.24 : 0.16);
    final resolvedFavoriteBg = isLightCard
        ? const Color(0xFFFFFFFF)
        : Colors.white.withValues(alpha: 0.10);
    final resolvedFavoriteBorder = isLightCard
        ? const Color(0xFFDCE3EC)
        : Colors.white.withValues(alpha: 0.16);
    final resolvedPlayBg = playButtonBackgroundColor ?? AppTheme.orange400;
    final resolvedPlayIcon = playIconColor ?? Colors.white;
    final resolvedFavoriteIcon = isLightCard
        ? const Color(0xFF667085)
        : Colors.white.withValues(alpha: 0.86);

    final themeGradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [cardStart, cardMid, cardEnd],
    );

    return Container(
      width: double.infinity,
      height: 64,
      margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 10),
      decoration: BoxDecoration(
        color: effectiveBgColor,
        gradient: effectiveBgColor == null ? themeGradient : null,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: (effectiveBgColor == null ? cardMid : primary).withValues(
              alpha: isLightCard
                  ? (isWhiteTheme ? (isPlaying ? 0.05 : 0.03) : (isPlaying ? 0.10 : 0.06))
                  : (isPlaying ? 0.48 : 0.34),
            ),
            blurRadius: isLightCard ? 16 : (isPlaying ? 24 : 18),
            offset: Offset(0, isLightCard ? 8 : 12),
          ),
        ],
        border: Border.all(
          color: resolvedCardBorder,
          width: isPlaying ? 1.2 : 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(6),
            child: Row(
              children: [
                RadioLogo(
                  radioName: title,
                  logoUrl: imageUrl,
                  size: 44,
                  showBorder: true,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: resolvedTitleColor,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: resolvedSubtitleColor,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: resolvedFavoriteBg,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: resolvedFavoriteBorder,
                        ),
                      ),
                      child: IconButton(
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          foregroundColor: isFavorite
                              ? AppTheme.gradientPink
                              : resolvedFavoriteIcon,
                        ),
                        onPressed: () {
                          if (onFavoriteToggle != null) {
                            HapticFeedback.lightImpact();
                            onFavoriteToggle!();
                          }
                        },
                        icon: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_outline,
                          color: isFavorite
                              ? AppTheme.gradientPink
                              : resolvedFavoriteIcon,
                          size: 18,
                        ),
                        padding: EdgeInsets.zero,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: resolvedPlayBg,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: resolvedPlayBg.withValues(alpha: 0.36),
                            blurRadius: 14,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: IconButton(
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          foregroundColor: resolvedPlayIcon,
                        ),
                        onPressed: onTap,
                        icon: Icon(
                          isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                          color: resolvedPlayIcon,
                          size: 22,
                        ),
                        padding: EdgeInsets.zero,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
