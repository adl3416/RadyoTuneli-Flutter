import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/banner_ad_widget.dart';
import '../../stations/domain/station_model.dart';
import '../data/player_provider.dart';
import '../data/audio_service_handler.dart';
import '../../favorites/data/favorites_provider.dart';

class AutomotivePlayerScreen extends ConsumerWidget {
  const AutomotivePlayerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playerState = ref.watch(playerStateProvider);
    
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Adaptive paddings and sizes based on available space
            final horizontalPad = constraints.maxWidth > 600 ? 24.0 : 16.0;
            final spacingLarge = constraints.maxHeight < 400 ? 12.0 : 20.0;
            final logoSize = (constraints.maxWidth * 0.25).clamp(64.0, 140.0);

            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: horizontalPad, vertical: spacingLarge),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight - MediaQuery.of(context).padding.vertical),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header
                    Row(
                      children: [
                        Icon(
                          Icons.radio,
                          color: AppTheme.orange400,
                          size: 28,
                        ),
                        const SizedBox(width: 12),
                        Flexible(
                          child: Text(
                            'Radyo Tüneli',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'ARABA MODU',
                          style: TextStyle(
                            color: AppTheme.orange400,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: spacingLarge),

                    // Current Station Display (responsive)
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(spacingLarge),
                      decoration: BoxDecoration(
                        color: Colors.grey[900],
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppTheme.orange400.withOpacity(0.3),
                          width: 2,
                        ),
                      ),
                      child: Column(
                        children: [
                          // Station Logo (responsive size)
                          Container(
                            width: logoSize,
                            height: logoSize,
                            decoration: BoxDecoration(
                              color: AppTheme.orange400.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Icon(
                              Icons.radio,
                              color: AppTheme.orange400,
                              size: (logoSize * 0.5).clamp(28.0, 80.0),
                            ),
                          ),

                          SizedBox(height: spacingLarge),

                          // Station Name
                          Text(
                            playerState.currentStation?.name ?? 'Radyo Seçiniz',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),

                          const SizedBox(height: 8),

                          // Station Description
                          Text(
                            playerState.currentStation?.artist ?? 'Radyo çalmıyor',
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.center,
                          ),

                          SizedBox(height: spacingLarge),

                          // Status Indicator
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: playerState.isPlaying ? AppTheme.orange400.withOpacity(0.2) : Colors.grey[800],
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  playerState.isPlaying ? Icons.play_arrow : playerState.isLoading ? Icons.sync : Icons.pause,
                                  color: playerState.isPlaying ? AppTheme.orange400 : Colors.grey[400],
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  playerState.isPlaying ? 'ÇALIYOR' : playerState.isLoading ? 'YÜKLENİYOR' : 'DURAKLATILDI',
                                  style: TextStyle(
                                    color: playerState.isPlaying ? AppTheme.orange400 : Colors.grey[400],
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: spacingLarge),

                    // Test Reklam Alanı - keep smaller on compact screens
                    Container(
                      width: double.infinity,
                      height: constraints.maxHeight < 420 ? 56 : 80,
                      margin: EdgeInsets.symmetric(horizontal: constraints.maxWidth < 360 ? 8 : 20),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: Text(
                          'REKLAM BURASI - TEST',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: spacingLarge),

                    // Large Control Buttons - make them wrap if space is tight
                    Wrap(
                      alignment: WrapAlignment.spaceEvenly,
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        _buildLargeButton(
                          icon: Icons.skip_previous,
                          label: 'ÖNCEKİ',
                          onPressed: () async {
                            HapticFeedback.mediumImpact();
                            await ref.read(playerStateProvider.notifier).previousStation();
                          },
                        ),
                        _buildLargeButton(
                          icon: playerState.isPlaying ? Icons.pause : playerState.isLoading ? Icons.sync : Icons.play_arrow,
                          label: playerState.isPlaying ? 'DURAKLAT' : 'ÇALIŞ',
                          isPrimary: true,
                          onPressed: () {
                            HapticFeedback.heavyImpact();
                            if (playerState.isPlaying) {
                              ref.read(playerStateProvider.notifier).pause();
                            } else {
                              if (playerState.currentStation != null) {
                                ref.read(playerStateProvider.notifier).resume();
                              }
                            }
                          },
                        ),
                        _buildLargeButton(
                          icon: Icons.skip_next,
                          label: 'SONRAKİ',
                          onPressed: () async {
                            HapticFeedback.mediumImpact();
                            await ref.read(playerStateProvider.notifier).nextStation();
                          },
                        ),
                      ],
                    ),

                    SizedBox(height: spacingLarge),

                    // Bottom Actions
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildSmallButton(
                          icon: Icons.list,
                          label: 'İSTASYONLAR',
                          onPressed: () {
                            HapticFeedback.lightImpact();
                            Navigator.pop(context);
                          },
                        ),
                        _buildSmallButton(
                          icon: Icons.favorite,
                          label: 'FAVORİLER',
                          onPressed: () {
                            HapticFeedback.lightImpact();
                            _showFavoritesModal(context, ref);
                          },
                        ),
                        _buildSmallButton(
                          icon: Icons.volume_up,
                          label: 'SES',
                          onPressed: () {
                            HapticFeedback.lightImpact();
                            _showVolumeModal(context, ref);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildLargeButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    bool isPrimary = false,
  }) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: isPrimary ? AppTheme.orange400 : Colors.grey[800],
            borderRadius: BorderRadius.circular(16),
            boxShadow: isPrimary ? [
              BoxShadow(
                color: AppTheme.orange400.withOpacity(0.3),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ] : null,
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onPressed,
              borderRadius: BorderRadius.circular(16),
              child: Icon(
                icon,
                color: isPrimary ? Colors.black : Colors.white,
                size: 36,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          label,
          style: TextStyle(
            color: isPrimary ? AppTheme.orange400 : Colors.grey[400],
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildSmallButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: Colors.grey[800],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onPressed,
              borderRadius: BorderRadius.circular(12),
              child: Icon(
                icon,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[400],
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  void _showVolumeModal(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Consumer(
        builder: (context, ref, child) {
          return Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.volume_up,
                      color: AppTheme.orange400,
                      size: 32,
                    ),
                    const SizedBox(width: 16),
                    Text(
                      'SES SEVİYESİ',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '80%',
                      style: TextStyle(
                        color: AppTheme.orange400,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Icon(
                      Icons.volume_mute,
                      color: Colors.grey[400],
                      size: 24,
                    ),
                    Expanded(
                      child: SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          trackShape: const RoundedRectSliderTrackShape(),
                          trackHeight: 6,
                          thumbColor: AppTheme.orange400,
                          activeTrackColor: AppTheme.orange400,
                          inactiveTrackColor: Colors.grey[700],
                          thumbShape: const RoundSliderThumbShape(
                            enabledThumbRadius: 12,
                          ),
                        ),
                        child: Slider(
                          value: 0.8,
                          onChanged: (value) {
                            HapticFeedback.selectionClick();
                            // Apply volume to audio service
                            final audioHandler = ref.read(playerStateProvider.notifier).audioHandler;
                            if (audioHandler != null) {
                              // Use the base AudioHandler's customAction for volume
                              audioHandler.customAction('setVolume', {'volume': value});
                            }
                          },
                          min: 0.0,
                          max: 1.0,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.volume_up,
                      color: Colors.grey[400],
                      size: 24,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildVolumePreset('DÜŞÜK', 0.3, ref),
                    _buildVolumePreset('ORTA', 0.6, ref),
                    _buildVolumePreset('YÜKSEK', 0.9, ref),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildVolumePreset(String label, double value, WidgetRef ref) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        final audioHandler = ref.read(playerStateProvider.notifier).audioHandler;
        if (audioHandler != null) {
          // Use the base AudioHandler's customAction for volume
          audioHandler.customAction('setVolume', {'volume': value});
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.grey[800],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  void _showFavoritesModal(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Consumer(
        builder: (context, ref, child) {
          final favoritesAsync = ref.watch(sortedFavoriteStationsProvider);
          return Container(
            height: MediaQuery.of(context).size.height * 0.7,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.favorite,
                      color: AppTheme.orange400,
                      size: 32,
                    ),
                    const SizedBox(width: 16),
                    Text(
                      'FAVORİ İSTASYONLAR',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: favoritesAsync.when(
                    data: (favorites) {
                      if (favorites.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.favorite_border,
                                color: Colors.grey[400],
                                size: 64,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Henüz favori istasyon yok',
                                style: TextStyle(
                                  color: Colors.grey[400],
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                      return ListView.builder(
                        itemCount: favorites.length,
                        itemBuilder: (context, index) {
                          final station = favorites[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.grey[800],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: CircleAvatar(
                                backgroundColor: AppTheme.orange400.withOpacity(0.2),
                                child: Icon(
                                  Icons.radio,
                                  color: AppTheme.orange400,
                                ),
                              ),
                              title: Text(
                                station.name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              subtitle: Text(
                                station.description ?? station.genre ?? '',
                                style: TextStyle(
                                  color: Colors.grey[400],
                                  fontSize: 12,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              trailing: Icon(
                                Icons.play_arrow,
                                color: AppTheme.orange400,
                                size: 28,
                              ),
                              onTap: () {
                                HapticFeedback.mediumImpact();
                                ref.read(playerStateProvider.notifier).playStation(station);
                                Navigator.pop(context);
                              },
                            ),
                          );
                        },
                      );
                    },
                    loading: () => const Center(
                      child: CircularProgressIndicator(),
                    ),
                    error: (error, stack) => Center(
                      child: Text(
                        'Favoriler yüklenemedi',
                        style: TextStyle(
                          color: Colors.grey[400],
                        ),
                      ),
                    ),
                  ),
                ),
                
                // Banner Reklam
                const Padding(
                  padding: EdgeInsets.only(top: 16),
                  child: SmallBannerAdWidget(
                    padding: EdgeInsets.all(0),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}