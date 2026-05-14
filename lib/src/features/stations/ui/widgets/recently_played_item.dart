import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/constants/app_constants.dart';
import '../../domain/station_model.dart';

class RecentlyPlayedStationItem extends StatelessWidget {
  final Station station;
  final VoidCallback? onTap;

  const RecentlyPlayedStationItem({
    super.key,
    required this.station,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bezelColor = isDark ? const Color(0xFF2A2A2A) : const Color(0xFF1C1C1E);
    final screenBg = isDark ? const Color(0xFF0D0D0D) : const Color(0xFF111111);
    final glowColor = Theme.of(context).primaryColor;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 80,
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // TV gövdesi
            Container(
              width: 68,
              height: 56,
              decoration: BoxDecoration(
                color: bezelColor,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: glowColor.withValues(alpha: 0.35),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.5),
                    blurRadius: 4,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(3),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(5),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Ekran arka planı
                      Container(color: screenBg),
                      // Logo
                      CachedNetworkImage(
                        imageUrl: station.logoUrl,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: screenBg,
                          child: const Icon(Icons.radio, size: 24, color: Colors.white30),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: screenBg,
                          child: const Icon(Icons.radio, size: 24, color: Colors.white30),
                        ),
                      ),
                      // Ekran parlaması (cam yansıması)
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        height: 18,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.white.withValues(alpha: 0.18),
                                Colors.white.withValues(alpha: 0.0),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // TV ayakları
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 12,
                  height: 4,
                  decoration: BoxDecoration(
                    color: bezelColor,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(3),
                      bottomRight: Radius.circular(3),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Container(
                  width: 12,
                  height: 4,
                  decoration: BoxDecoration(
                    color: bezelColor,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(3),
                      bottomRight: Radius.circular(3),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 3),
            // İstasyon adı
            Text(
              station.name,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w500,
                    fontSize: 10,
                  ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

