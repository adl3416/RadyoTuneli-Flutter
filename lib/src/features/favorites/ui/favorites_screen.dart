import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../../stations/data/stations_provider.dart';
import '../../stations/ui/widgets/station_list_tile.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoriteStationsAsync = ref.watch(favoriteStationsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Favoriler'),
        actions: [
          favoriteStationsAsync.when(
            data: (favoriteStations) => favoriteStations.isNotEmpty
                ? TextButton(
                    onPressed: () {
                      _showClearFavoritesDialog(context, ref);
                    },
                    child: Text(
                      'Temizle',
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ],
      ),
      body: favoriteStationsAsync.when(
        data: (favoriteStations) {
          if (favoriteStations.isEmpty) {
            return _buildEmptyState(context);
          }

          return Column(
            children: [
              // Favorites count info
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                child: Text(
                  '${favoriteStations.length} favori istasyon',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppConstants.textSecondary,
                      ),
                ),
              ),

              // Favorites list
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: favoriteStations.length,
                  itemBuilder: (context, index) {
                    final station = favoriteStations[index];
                    return StationListTile(
                      station: station,
                      onPlayPressed: () {
                        // TODO: Implement play functionality
                        print('Playing favorite: ${station.name}');
                      },
                      onTap: () {
                        // TODO: Navigate to player screen
                        print('Favorite station tapped: ${station.name}');
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: AppConstants.textSecondary,
              ),
              const SizedBox(height: 16),
              Text(
                'Favoriler yüklenemedi',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppConstants.textSecondary,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Lütfen tekrar deneyin',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppConstants.textSecondary,
                    ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.refresh(favoriteStationsProvider),
                child: const Text('Tekrar Dene'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite_outline,
            size: 80,
            color: AppConstants.textSecondary.withOpacity(0.5),
          ),
          const SizedBox(height: 24),
          Text(
            'Henüz favori radyo istasyonunuz yok',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppConstants.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'Beğendiğiniz istasyonları favorilere eklemek için kalp ikonuna dokunun',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppConstants.textSecondary,
                  ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () {
              // TODO: Navigate to home screen or stations list
            },
            icon: const Icon(Icons.explore),
            label: const Text('İstasyonları Keşfet'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showClearFavoritesDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Favorileri Temizle'),
          content: const Text(
            'Tüm favori istasyonları kaldırmak istediğinizden emin misiniz?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('İptal'),
            ),
            TextButton(
              onPressed: () {
                // TODO: Implement clear all favorites
                Navigator.of(context).pop();
              },
              child: Text(
                'Temizle',
                style: TextStyle(color: AppConstants.vibrantRed),
              ),
            ),
          ],
        );
      },
    );
  }
}
