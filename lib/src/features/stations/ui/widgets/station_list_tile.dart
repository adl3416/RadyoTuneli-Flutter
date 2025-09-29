import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/snackbar_helper.dart';
import '../../domain/station_model.dart';
import '../../data/stations_provider.dart';
import '../../../player/data/player_provider.dart';
import '../../../player/domain/player_state_model.dart';

class StationListTile extends ConsumerWidget {
  final Station station;
  final VoidCallback? onPlayPressed;
  final VoidCallback? onTap;

  const StationListTile({
    super.key,
    required this.station,
    this.onPlayPressed,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playerState = ref.watch(playerStateProvider);
    final isCurrentStation = playerState.currentStation?.id == station.id;
    final isPlaying = isCurrentStation && playerState.isPlaying;
    final isLoading = isCurrentStation && playerState.isLoading;

    // Listen to errors and show snackbar
    ref.listen<PlayerStateModel>(playerStateProvider, (previous, next) {
      if (next.error != null && (previous?.error != next.error)) {
        AppSnackBar.showError(context, next.error!);
        // Clear error after showing
        Future.microtask(
            () => ref.read(playerStateProvider.notifier).clearError());
      }
    });

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Station Logo
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppConstants.surfaceVariant,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
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

                const SizedBox(width: 12),

                // Station Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        station.name,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        station.bitrate,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppConstants.textSecondary,
                            ),
                      ),
                      if (station.genre != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          station.genre!,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppConstants.textSecondary,
                                    fontSize: 11,
                                  ),
                        ),
                      ],
                    ],
                  ),
                ),

                // Favorite Button
                IconButton(
                  onPressed: () {
                    ref
                        .read(favoriteNotifierProvider.notifier)
                        .toggleFavorite(station.id);
                  },
                  icon: Icon(
                    station.isFavorite
                        ? Icons.favorite
                        : Icons.favorite_outline,
                    color: station.isFavorite
                        ? AppConstants.vibrantRed
                        : AppConstants.textSecondary,
                  ),
                ),

                // Play Button
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isCurrentStation
                        ? (isPlaying
                            ? AppConstants.vibrantRed
                            : Theme.of(context).primaryColor)
                        : Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: IconButton(
                    onPressed: () async {
                      if (isCurrentStation && isPlaying) {
                        await ref.read(playerStateProvider.notifier).pause();
                      } else if (isCurrentStation && !isPlaying) {
                        await ref.read(playerStateProvider.notifier).resume();
                      } else {
                        await ref
                            .read(playerStateProvider.notifier)
                            .playStation(station);
                      }
                    },
                    icon: isLoading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Icon(
                            isCurrentStation && isPlaying
                                ? Icons.pause
                                : Icons.play_arrow,
                            color: Colors.white,
                            size: 20,
                          ),
                    padding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
