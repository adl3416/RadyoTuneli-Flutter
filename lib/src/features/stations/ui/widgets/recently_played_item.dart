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

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 78,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: primary,
                border: Border.all(
                  color: const Color(0xFFE7EAFE),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 10,
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
            const SizedBox(height: 6),
            Text(
              station.name,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 10,
                height: 1.2,
                color: const Color(0xFF27314D),
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
