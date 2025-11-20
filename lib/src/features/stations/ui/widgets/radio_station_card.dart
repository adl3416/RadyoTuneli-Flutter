import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'radio_logo.dart';
import '../../../../core/theme/app_theme.dart';

class RadioStationCard extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Container(
      // keep full available width but add a small horizontal inset so cards
      // appear slightly narrower than the screen edge
      width: double.infinity,
      height: 68,
      margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 10),
      decoration: BoxDecoration(
        // If a concrete backgroundColor is provided (e.g. for Favorites Kanarya), use it.
        // Otherwise fall back to the app's radio card gradient.
        color: backgroundColor,
        gradient: backgroundColor == null ? AppTheme.radioCardGradient : null,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 4, offset: const Offset(0, 2)),
        ],
        // thin separator line at bottom to visually separate adjacent cards
        border: Border(
          bottom: BorderSide(color: AppTheme.gray200.withOpacity(0.9), width: 0.5),
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
                // Station Image/Icon - Modern logo with initials
                RadioLogo(
                  radioName: title,
                  logoUrl: imageUrl,
                  size: 40,
                  showBorder: true,
                ),
                const SizedBox(width: 10),
                // Title & Subtitle
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
                          fontWeight: FontWeight.bold,
                          color: titleColor ?? AppTheme.white,
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: subtitleColor ?? AppTheme.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),
                // Buttons Row
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Favorite Button
                    IconButton(
                      onPressed: () {
                        if (onFavoriteToggle != null) {
                          HapticFeedback.lightImpact();
                          onFavoriteToggle!();
                        }
                      },
                      icon: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_outline,
                        color: isFavorite ? Colors.red : AppTheme.white,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 4),
                    // Play/Pause Button
                    IconButton(
                      style: IconButton.styleFrom(
                        backgroundColor: playButtonBackgroundColor ?? Theme.of(context).colorScheme.primary,
                      ),
                      onPressed: onTap,
                      icon: Icon(
                        isPlaying ? Icons.pause : Icons.play_arrow,
                        color: playIconColor ?? Theme.of(context).colorScheme.onPrimary,
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
