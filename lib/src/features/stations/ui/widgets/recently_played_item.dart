import 'package:flutter/material.dart';
import '../../domain/station_model.dart';
import 'radio_logo.dart';

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
    final primary = Theme.of(context).appBarTheme.backgroundColor ?? Theme.of(context).primaryColor;
    final bezelColor = isDark
        ? Color.lerp(primary, Colors.black, 0.55)!
        : primary;
    const screenBg = Color(0xFFF5F5F5);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 66,
        margin: const EdgeInsets.only(right: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // TV gövdesi
            Container(
              width: 56,
              height: 46,
              decoration: BoxDecoration(
                color: bezelColor,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: primary.withValues(alpha: 0.30),
                    blurRadius: 6,
                    spreadRadius: 0,
                  ),
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.25),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(2),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Container(color: screenBg),
                      RadioLogo(
                        radioName: station.name,
                        logoUrl: station.logoUrl,
                        size: 40,
                        showBorder: false,
                      ),
                      // Cam yansıması
                      Positioned(
                        top: 0, left: 0, right: 0,
                        height: 16,
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


