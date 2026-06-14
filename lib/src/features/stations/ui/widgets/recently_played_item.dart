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
    final stationName = _fixMojibake(station.name);

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
                  radioName: stationName,
                  logoUrl: station.logoUrl,
                  size: 56,
                  showBorder: false,
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              stationName,
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

  String _fixMojibake(String value) {
    const replacements = <String, String>{
      'T\u00c3\u00bcrk\u00c3\u00bc': 'T\u00fcrk\u00fc',
      'T\u00c3\u0152RK\u00c3\u0152': 'T\u00dcRK\u00dc',
      'T\u00c3\u00bcrk': 'T\u00fcrk',
      '\u00c3\u00bc': '\u00fc',
      '\u00c3\u0152': '\u00dc',
      '\u00c3\u00a7': '\u00e7',
      '\u00c3\u2021': '\u00c7',
      '\u00c4\u0178': '\u011f',
      '\u00c4\u017d': '\u011e',
      '\u00c4\u00b1': '\u0131',
      '\u00c4\u00b0': '\u0130',
      '\u00c3\u00b6': '\u00f6',
      '\u00c3\u2013': '\u00d6',
      '\u00c5\u0178': '\u015f',
      '\u00c5\u017d': '\u015e',
    };

    var result = value;
    replacements.forEach((from, to) {
      result = result.replaceAll(from, to);
    });
    return result;
  }
}
