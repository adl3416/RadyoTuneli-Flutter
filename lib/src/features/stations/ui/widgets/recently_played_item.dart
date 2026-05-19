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
    final theme = Theme.of(context);
    final primary =
        theme.appBarTheme.backgroundColor ?? theme.colorScheme.primary;
    final themeBorderColor =
        theme.appBarTheme.foregroundColor ?? theme.colorScheme.primary;
    final labelColor =
        theme.textTheme.bodySmall?.color ?? theme.colorScheme.onSurface;

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 64,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: primary,
                border: Border.all(
                  color: themeBorderColor.withValues(alpha: 0.35),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: primary.withValues(alpha: 0.18),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: ClipOval(
                child: RadioLogo(
                  radioName: station.name,
                  logoUrl: station.logoUrl,
                  size: 56,
                  showBorder: false,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              station.name,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 8.5,
                height: 1,
                color: labelColor,
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
