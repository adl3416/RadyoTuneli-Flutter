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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 80,
        margin: const EdgeInsets.only(right: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: AppConstants.surfaceVariant,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: CachedNetworkImage(
                  imageUrl: station.logoUrl,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: AppConstants.surfaceVariant,
                    child: Icon(
                      Icons.radio,
                      size: 24,
                      color: AppConstants.textSecondary,
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: AppConstants.surfaceVariant,
                    child: Icon(
                      Icons.radio,
                      size: 24,
                      color: AppConstants.textSecondary,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Expanded(
              child: Text(
                station.name,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                    ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
