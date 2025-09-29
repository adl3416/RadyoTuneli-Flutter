import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/constants/app_constants.dart';
import '../data/player_provider.dart';

class MiniPlayer extends ConsumerWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playerState = ref.watch(playerStateProvider);

    if (playerState.currentStation == null) {
      return const SizedBox.shrink();
    }

    final station = playerState.currentStation!;

    return Container(
      height: 64,
      decoration: BoxDecoration(
        color: AppConstants.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            offset: const Offset(0, -2),
            blurRadius: 8,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // Navigate to full screen player
            _showFullScreenPlayer(context);
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                // Station Logo
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: station.logoUrl != null
                      ? CachedNetworkImage(
                          imageUrl: station.logoUrl!,
                          width: 48,
                          height: 48,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            width: 48,
                            height: 48,
                            color: AppConstants.surfaceVariant,
                            child: const Icon(
                              Icons.radio,
                              color: AppConstants.textSecondary,
                              size: 24,
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            width: 48,
                            height: 48,
                            color: AppConstants.surfaceVariant,
                            child: const Icon(
                              Icons.radio,
                              color: AppConstants.textSecondary,
                              size: 24,
                            ),
                          ),
                        )
                      : Container(
                          width: 48,
                          height: 48,
                          color: AppConstants.surfaceVariant,
                          child: const Icon(
                            Icons.radio,
                            color: AppConstants.textSecondary,
                            size: 24,
                          ),
                        ),
                ),

                const SizedBox(width: 12),

                // Station Info
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        station.name,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              color: AppConstants.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        playerState.isPlaying ? 'Playing' : 'Paused',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppConstants.textSecondary,
                            ),
                      ),
                    ],
                  ),
                ),

                // Loading indicator or Play/Pause Button
                if (playerState.isLoading)
                  const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: AppConstants.primaryAccent,
                      strokeWidth: 2,
                    ),
                  )
                else
                  IconButton(
                    onPressed: () async {
                      if (playerState.isPlaying) {
                        await ref.read(playerStateProvider.notifier).pause();
                      } else {
                        await ref.read(playerStateProvider.notifier).resume();
                      }
                    },
                    icon: Icon(
                      playerState.isPlaying ? Icons.pause : Icons.play_arrow,
                      color: AppConstants.textPrimary,
                      size: 24,
                    ),
                  ),

                // Stop Button
                IconButton(
                  onPressed: () async {
                    await ref.read(playerStateProvider.notifier).stop();
                  },
                  icon: const Icon(
                    Icons.stop,
                    color: AppConstants.textPrimary,
                    size: 24,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showFullScreenPlayer(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.9,
        decoration: const BoxDecoration(
          color: AppConstants.primaryBackground,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(20),
          ),
        ),
        child: const FullScreenPlayer(),
      ),
    );
  }
}

class FullScreenPlayer extends ConsumerWidget {
  const FullScreenPlayer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playerState = ref.watch(playerStateProvider);

    if (playerState.currentStation == null) {
      return const Center(
        child: Text(
          'No station playing',
          style: TextStyle(color: AppConstants.textPrimary),
        ),
      );
    }

    final station = playerState.currentStation!;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Drag Handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppConstants.textSecondary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          const SizedBox(height: 24),

          // Station Logo (Large)
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: station.logoUrl != null
                ? CachedNetworkImage(
                    imageUrl: station.logoUrl!,
                    width: 200,
                    height: 200,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      width: 200,
                      height: 200,
                      color: AppConstants.surfaceVariant,
                      child: const Icon(
                        Icons.radio,
                        color: AppConstants.textSecondary,
                        size: 80,
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      width: 200,
                      height: 200,
                      color: AppConstants.surfaceVariant,
                      child: const Icon(
                        Icons.radio,
                        color: AppConstants.textSecondary,
                        size: 80,
                      ),
                    ),
                  )
                : Container(
                    width: 200,
                    height: 200,
                    color: AppConstants.surfaceVariant,
                    child: const Icon(
                      Icons.radio,
                      color: AppConstants.textSecondary,
                      size: 80,
                    ),
                  ),
          ),

          const SizedBox(height: 32),

          // Station Info
          Text(
            station.name,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppConstants.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 8),

          Text(
            station.artist,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppConstants.textSecondary,
                ),
            textAlign: TextAlign.center,
          ),

          const Spacer(),

          // Control Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Previous (disabled for radio)
              IconButton(
                onPressed: null,
                icon: const Icon(
                  Icons.skip_previous,
                  size: 36,
                  color: AppConstants.textSecondary,
                ),
              ),

              // Play/Pause
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: AppConstants.primaryAccent,
                  borderRadius: BorderRadius.circular(36),
                ),
                child: playerState.isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: Colors.white,
                        ),
                      )
                    : IconButton(
                        onPressed: () async {
                          if (playerState.isPlaying) {
                            await ref
                                .read(playerStateProvider.notifier)
                                .pause();
                          } else {
                            await ref
                                .read(playerStateProvider.notifier)
                                .resume();
                          }
                        },
                        icon: Icon(
                          playerState.isPlaying
                              ? Icons.pause
                              : Icons.play_arrow,
                          color: Colors.white,
                          size: 36,
                        ),
                      ),
              ),

              // Next (disabled for radio)
              IconButton(
                onPressed: null,
                icon: const Icon(
                  Icons.skip_next,
                  size: 36,
                  color: AppConstants.textSecondary,
                ),
              ),
            ],
          ),

          const SizedBox(height: 32),

          // Stop Button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () async {
                await ref.read(playerStateProvider.notifier).stop();
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConstants.vibrantRed,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              child: const Text(
                'Stop',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
