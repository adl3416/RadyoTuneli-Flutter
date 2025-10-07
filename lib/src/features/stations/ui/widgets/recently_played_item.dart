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
        width: 70, // 80'den 70'e küçültüldü
        margin: const EdgeInsets.only(right: 12), // 16'dan 12'ye küçültüldü
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 50, // 60'dan 50'ye küçültüldü
              height: 50, // 60'dan 50'ye küçültüldü
              decoration: BoxDecoration(
                color: AppConstants.surfaceVariant,
                borderRadius: BorderRadius.circular(25), // 30'dan 25'e küçültüldü
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 6, // 8'den 6'ya küçültüldü
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(25), // 30'dan 25'e küçültüldü
                child: CachedNetworkImage(
                  imageUrl: station.logoUrl,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: AppConstants.surfaceVariant,
                    child: Icon(
                      Icons.radio,
                      size: 20, // 24'den 20'ye küçültüldü
                      color: AppConstants.textSecondary,
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: AppConstants.surfaceVariant,
                    child: Icon(
                      Icons.radio,
                      size: 20, // 24'den 20'ye küçültüldü
                      color: AppConstants.textSecondary,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 4), // 6'dan 4'e küçültüldü
            Expanded(
              child: Text(
                station.name,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w500,
                      fontSize: 10, // 12'den 10'a küçültüldü
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
