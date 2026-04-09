import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/theme/app_theme.dart';
import '../data/player_provider.dart';
import '../../stations/ui/widgets/radio_logo.dart';

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
        // Removed top boxShadow to avoid thin divider artifact on some devices / Android Auto
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
                // Station Logo with colorful initials
                RadioLogo(
                  radioName: station.name,
                  logoUrl: station.logoUrl,
                  size: 50,
                  showBorder: true,
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

    return SingleChildScrollView(
      child: Padding(
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
              width: 200, // 220'den 200'e küçültüldü
              height: 200,
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
              child: RadioLogo(
                radioName: station.name,
                logoUrl: station.logoUrl,
                size: 200,
                showBorder: true,
              ),
            ),
  
            const SizedBox(height: 30), // 40'tan 30'a azaltıldı
  
            // Station Info with modern typography
            Text(
              station.name,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 22, // 24'ten 22'ye küçültüldü
                  ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
  
            const SizedBox(height: 8), // 12'den 8'e azaltıldı
  
            Text(
              station.artist,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white70,
                    fontSize: 16, // 18'den 16'ya küçültüldü
                  ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
  
            const SizedBox(height: 30), // 40'tan 30'a azaltıldı
  
            // Control Buttons with modern styling
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Previous Button - now active
                Container(
                  width: 54, // 60'tan 54'e küçültüldü
                  height: 54,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(27),
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
                      borderRadius: BorderRadius.circular(27),
                      child: const Icon(
                        Icons.skip_previous,
                        size: 28, // 32'den 28'e küçültüldü
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
  
                // Play/Pause with enhanced styling
                Container(
                  width: 70, // 80'den 70'e küçültüldü
                  height: 70,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(35),
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
                            size: 36, // 40'tan 36'ya küçültüldü
                          ),
                        ),
                ),
  
                // Next Button - now active
                Container(
                  width: 54, // 60'tan 54'e küçültüldü
                  height: 54,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(27),
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
                      borderRadius: BorderRadius.circular(27),
                      child: const Icon(
                        Icons.skip_next,
                        size: 28, // 32'den 28'e küçültüldü
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
  
            const SizedBox(height: 30), // 40'tan 30'a azaltıldı
  
            // Stop Button with modern styling
            SizedBox(
              width: double.infinity,
              height: 50, // 56'dan 50'ye küçültüldü
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
                    borderRadius: BorderRadius.circular(25),
                    side: BorderSide(
                      color: Colors.white.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                ),
                child: const Text(
                  'Durdur',
                  style: TextStyle(
                    fontSize: 16, // 18'den 16'ya küçültüldü
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
  
            const SizedBox(height: 16), // 8'den 16'ya artırıldı (alt boşluk için)
          ],
        ),
      ),
    );
  }
}