import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../stations/ui/widgets/radio_station_card.dart';
import '../../../core/widgets/banner_ad_widget.dart';
import '../data/favorites_provider.dart';
import '../../player/data/player_provider.dart';
import '../../stations/ui/widgets/station_list_tile.dart';
import '../../../shared/providers/color_scheme_provider.dart';
import '../../../core/theme/app_theme.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favorites = ref.watch(favoritesProvider);
    final sortedFavoriteStationsAsync = ref.watch(sortedFavoriteStationsProvider);

    final colorScheme = Theme.of(context).colorScheme;
    final activeScheme = ref.watch(colorSchemeProvider);
    final isKanarya = activeScheme == 'kanarya';

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                color: isKanarya ? AppTheme.kanaryaSecondary : colorScheme.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  // Favorite Icon
                  Container(
                    width: 45,
                    height: 45,
                    decoration: BoxDecoration(
                      color: isKanarya ? AppTheme.kanaryaPrimary.withOpacity(0.12) : colorScheme.onPrimary.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: const Icon(
                      Icons.favorite,
                      // For Kanarya use yellow icon; otherwise white
                      color: null,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Title
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Favori Radyolarım',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: isKanarya ? AppTheme.kanaryaPrimary : colorScheme.onPrimary,
                            ),
                        ),
                        Text(
                          '${favorites.length} istasyon',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: isKanarya ? AppTheme.kanaryaPrimary.withOpacity(0.9) : colorScheme.onPrimary.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // A-Z Sort Button
                  Consumer(
                    builder: (context, ref, child) {
                      final sortAtoZ = ref.watch(favoritesSortAtoZProvider);
                      return IconButton(
                        onPressed: () {
                          HapticFeedback.mediumImpact();
                          ref.read(favoritesSortAtoZProvider.notifier).state = !sortAtoZ;
                        },
                        icon: Icon(
                          sortAtoZ ? Icons.sort_by_alpha : Icons.sort,
                          color: isKanarya ? AppTheme.kanaryaPrimary : (sortAtoZ ? colorScheme.onPrimary : colorScheme.onPrimary.withOpacity(0.7)),
                          size: 22,
                        ),
                        tooltip: sortAtoZ ? 'Normal Sıralama' : 'A-Z Sıralama',
                      );
                    },
                  ),
                  // Clear All Button - Delete All iconuna değiştirdik
                  if (favorites.isNotEmpty)
                      IconButton(
                      onPressed: () => _showClearAllDialog(context, ref, activeScheme),
                      icon: Icon(
                        Icons.delete_sweep,
                        color: isKanarya ? AppTheme.kanaryaPrimary : Colors.white,
                        size: 22,
                      ),
                      tooltip: 'Tümünü Temizle',
                    ),
                ],
              ),
            ),
            
            // Banner Ad
            const SmallBannerAdWidget(),
            
            const SizedBox(height: 16),
            
            // Favorites List
            Expanded(
              child: sortedFavoriteStationsAsync.when(
                data: (favoriteStations) {
                  if (favoriteStations.isEmpty) {
                    return _buildEmptyState(context);
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: favoriteStations.length,
                    itemBuilder: (context, index) {
                      final station = favoriteStations[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: RadioStationCard(
                          title: station.name,
                          subtitle: station.genre ?? 'Radio',
                          imageUrl: station.logoUrl,
                          // If the active scheme is 'kanarya', force navy background + yellow text
                          backgroundColor: activeScheme == 'kanarya' ? AppTheme.kanaryaSecondary : null,
                          titleColor: activeScheme == 'kanarya' ? AppTheme.kanaryaPrimary : null,
                          subtitleColor: activeScheme == 'kanarya' ? AppTheme.kanaryaPrimary.withOpacity(0.9) : null,
                          isPlaying: ref.watch(playerStateProvider).currentStation?.id == station.id &&
                                    ref.watch(playerStateProvider).isPlaying,
                          isFavorite: true, // Favori sayfasında hepsi favori
                          onTap: () {
                            HapticFeedback.mediumImpact();
                            final playerState = ref.read(playerStateProvider);
                            final isCurrentStation = playerState.currentStation?.id == station.id;
                            final isPlaying = isCurrentStation && playerState.isPlaying;
                            final isLoading = isCurrentStation && playerState.isLoading;
                            
                            if (isLoading) return;
                            
                            if (isCurrentStation && isPlaying) {
                              ref.read(playerStateProvider.notifier).pause();
                            } else {
                              ref.read(playerStateProvider.notifier).playStation(station);
                            }
                          },
                          onFavoriteToggle: () {
                            ref.read(favoritesProvider.notifier).toggleFavorite(station.id);
                          },
                        ),
                      );
                    },
                  );
                },
                loading: () => Center(
                  child: CircularProgressIndicator(
                    color: isKanarya ? AppTheme.kanaryaPrimary : colorScheme.primary,
                  ),
                ),
                error: (error, stack) => _buildErrorState(context, error.toString(), activeScheme),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Vintage Radio Logo
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.asset(
                  'assets/images/radio_logo.png',
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Henüz Favori Yok',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onBackground,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Radyo istasyonlarının yanındaki kalp simgesine\ntıklayarak favorilerinize ekleyebilirsiniz',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: colorScheme.onBackground.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              // Ana sayfaya geç
              HapticFeedback.lightImpact();
            },
            icon: const Icon(Icons.explore),
            label: const Text('Radyoları Keşfet'),
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String error, String activeScheme) {
    final colorScheme = Theme.of(context).colorScheme;
    final isKanarya = activeScheme == 'kanarya';

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: isKanarya ? AppTheme.kanaryaPrimary : colorScheme.onBackground,
          ),
          const SizedBox(height: 16),
          Text(
            'Bir Hata Oluştu',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: isKanarya ? AppTheme.kanaryaPrimary : colorScheme.onBackground,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: isKanarya ? AppTheme.kanaryaPrimary.withOpacity(0.9) : colorScheme.onBackground.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }

  void _showClearAllDialog(BuildContext context, WidgetRef ref, String activeScheme) {
    final colorScheme = Theme.of(context).colorScheme;
    final isKanarya = activeScheme == 'kanarya';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isKanarya ? AppTheme.kanaryaSecondary : colorScheme.surface,
        title: Row(
          children: [
            Icon(
              Icons.warning_amber,
              color: isKanarya ? AppTheme.kanaryaPrimary : colorScheme.error,
              size: 24,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Tüm Favorileri Temizle',
                style: TextStyle(
                  color: isKanarya ? AppTheme.kanaryaPrimary : colorScheme.onSurface,
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          'Tüm favori radyo istasyonlarınızı silmek istediğinizden emin misiniz?\n\nBu işlem geri alınamaz.',
          style: TextStyle(
            color: isKanarya ? AppTheme.kanaryaPrimary.withOpacity(0.9) : colorScheme.onSurface.withOpacity(0.9),
            fontSize: 14,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'İptal',
              style: TextStyle(color: isKanarya ? AppTheme.kanaryaPrimary.withOpacity(0.8) : colorScheme.onSurface.withOpacity(0.8)),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              HapticFeedback.mediumImpact();
              ref.read(favoritesProvider.notifier).clearAllFavorites();
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isKanarya ? AppTheme.kanaryaPrimary : colorScheme.error,
              foregroundColor: isKanarya ? AppTheme.kanaryaSecondary : colorScheme.onError,
            ),
            child: const Text('Temizle'),
          ),
        ],
      ),
    );
  }
}
