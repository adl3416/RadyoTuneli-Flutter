import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/banner_ad_widget.dart';
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
      height: 78,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1E1E2E), // Dark blue-gray
            Color(0xFF2D2A3F), // Purple-gray
            Color(0xFF3B3C5D), // Medium blue-gray
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF1E1E2E).withOpacity(0.3),
            offset: const Offset(0, -4),
            blurRadius: 12,
            spreadRadius: 0,
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
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                // Station Logo with modern styling
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        offset: const Offset(0, 2),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: station.logoUrl != null
                        ? CachedNetworkImage(
                            imageUrl: station.logoUrl!,
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.radio,
                                color: Colors.white70,
                                size: 28,
                              ),
                            ),
                            errorWidget: (context, url, error) => Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.radio,
                                color: Colors.white70,
                                size: 28,
                              ),
                            ),
                          )
                        : Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.radio,
                              color: Colors.white70,
                              size: 28,
                            ),
                          ),
                  ),
                ),

                const SizedBox(width: 16),

                // Station Info with modern typography
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        station.name,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        playerState.isPlaying ? 'Çalıyor' : 'Duraklatıldı',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                      ),
                    ],
                  ),
                ),

                // Loading indicator or Play/Pause Button with modern styling
                if (playerState.isLoading)
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: const Center(
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      ),
                    ),
                  )
                else
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: IconButton(
                      onPressed: () async {
                        if (playerState.isPlaying) {
                          await ref.read(playerStateProvider.notifier).pause();
                        } else {
                          await ref.read(playerStateProvider.notifier).resume();
                        }
                      },
                      icon: Icon(
                        playerState.isPlaying ? Icons.pause : Icons.play_arrow,
                        color: Colors.white,
                        size: 26,
                      ),
                      padding: EdgeInsets.zero,
                    ),
                  ),

                const SizedBox(width: 8),

                // Stop Button with modern styling
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(23),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: IconButton(
                    onPressed: () async {
                      await ref.read(playerStateProvider.notifier).stop();
                    },
                    icon: const Icon(
                      Icons.stop,
                      color: Colors.white,
                      size: 22,
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

  void _showFullScreenPlayer(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.9,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1E1E2E), // Dark blue-gray
              Color(0xFF2D2A3F), // Purple-gray
              Color(0xFF3B3C5D), // Medium blue-gray
            ],
          ),
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(24),
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
          'İstasyon çalmıyor',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
        ),
      );
    }

    final station = playerState.currentStation!;

    return Padding(
      padding: const EdgeInsets.all(16), // 24'ten 16'ya azaltıldı
      child: Column(
        children: [
          // Drag Handle with modern styling
          Container(
            width: 50,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.5),
              borderRadius: BorderRadius.circular(3),
            ),
          ),

          const SizedBox(height: 32),

          // Station Logo with modern styling
          Container(
            width: 220,
            height: 220,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  offset: const Offset(0, 8),
                  blurRadius: 24,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: station.logoUrl != null
                  ? CachedNetworkImage(
                      imageUrl: station.logoUrl!,
                      width: 220,
                      height: 220,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        width: 220,
                        height: 220,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: const Icon(
                          Icons.radio,
                          color: Colors.white70,
                          size: 80,
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        width: 220,
                        height: 220,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: const Icon(
                          Icons.radio,
                          color: Colors.white70,
                          size: 80,
                        ),
                      ),
                    )
                  : Container(
                      width: 220,
                      height: 220,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: const Icon(
                        Icons.radio,
                        color: Colors.white70,
                        size: 80,
                      ),
                    ),
            ),
          ),

          const SizedBox(height: 40),

          // Station Info with modern typography
          Text(
            station.name,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: 12),

          Text(
            station.artist,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white70,
                  fontSize: 18,
                ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: 24),

          // Small Banner Ad below station info
          const SmallBannerAdWidget(),

          const SizedBox(height: 40),

          // Control Buttons with modern styling
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Previous Button - now active
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () async {
                      print('🔄 Previous button tapped in FullScreenPlayer');
                      HapticFeedback.mediumImpact();
                      try {
                        await ref.read(playerStateProvider.notifier).previousStation();
                        print('✅ Previous station method completed');
                      } catch (e) {
                        print('❌ Error calling previousStation: $e');
                      }
                    },
                    borderRadius: BorderRadius.circular(30),
                    child: const Icon(
                      Icons.skip_previous,
                      size: 32,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              // Play/Pause with enhanced styling
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(40),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      offset: const Offset(0, 4),
                      blurRadius: 16,
                    ),
                  ],
                ),
                child: playerState.isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: AppTheme.headerPurple,
                          strokeWidth: 3,
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
                          color: AppTheme.headerPurple,
                          size: 40,
                        ),
                      ),
              ),

              // Next Button - now active
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () async {
                      print('🔄 Next button tapped in FullScreenPlayer');
                      HapticFeedback.mediumImpact();
                      try {
                        await ref.read(playerStateProvider.notifier).nextStation();
                        print('✅ Next station method completed');
                      } catch (e) {
                        print('❌ Error calling nextStation: $e');
                      }
                    },
                    borderRadius: BorderRadius.circular(30),
                    child: const Icon(
                      Icons.skip_next,
                      size: 32,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 40),

          // Stop Button with modern styling
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () async {
                await ref.read(playerStateProvider.notifier).stop();
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white.withOpacity(0.2),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                  side: BorderSide(
                    color: Colors.white.withOpacity(0.3),
                    width: 1,
                  ),
                ),
              ),
              child: const Text(
                'Durdur',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          const SizedBox(height: 8), // 24'ten 8'e azaltıldı
        ],
      ),
    );
  }
}