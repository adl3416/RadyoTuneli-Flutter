import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../stations/ui/widgets/radio_station_card.dart';
import '../data/favorites_provider.dart';
import '../../player/data/player_provider.dart';
import '../../../shared/providers/color_scheme_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../app/main_screen.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoritesAsync = ref.watch(sortedFavoriteStationsProvider);
    final colorSchemeStr = ref.watch(colorSchemeProvider);

    Color? appBarBg;
    Color? appBarFg;

    if (colorSchemeStr == 'karadeniz') {
      appBarBg = AppTheme.karadenizBordo;
      appBarFg = AppTheme.karadenizMavi;
    } else if (colorSchemeStr == 'kartal') {
      appBarBg = AppTheme.kartalBlack;
      appBarFg = AppTheme.kartalWhite;
    } else if (colorSchemeStr == 'timsah') {
      appBarBg = AppTheme.timsahGreen;
      appBarFg = AppTheme.timsahWhite;
    } else {
      appBarBg = Theme.of(context).appBarTheme.backgroundColor;
      appBarFg = Theme.of(context).appBarTheme.foregroundColor;
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Container(
        color: appBarBg ?? Theme.of(context).appBarTheme.backgroundColor,
        child: SafeArea(
          bottom: false,
          top: false,
          child: Column(
            children: [
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: appBarBg ?? Theme.of(context).appBarTheme.backgroundColor,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(12),
                    bottomRight: Radius.circular(12),
                  ),
                ),
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Favoriler',
                            style: TextStyle(
                              color: appBarFg ?? Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  child: favoritesAsync.when(
                    data: (favorites) => favorites.isEmpty
                        ? const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.favorite_border, size: 64, color: Colors.grey),
                                SizedBox(height: 16),
                                Text('Henüz favori istasyonun yok'),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            itemCount: favorites.length,
                            itemBuilder: (context, index) {
                              final station = favorites[index];
                              final isPlaying = ref.watch(playerStateProvider).currentStation?.id == station.id && ref.watch(playerStateProvider).isPlaying;
                              
                              return Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                child: RadioStationCard(
                                  title: station.name,
                                  subtitle: station.genre ?? 'Turkish Radio',
                                  imageUrl: station.logoUrl,
                                  isPlaying: isPlaying,
                                  isFavorite: true,
                                  onTap: () {
                                    final playerState = ref.read(playerStateProvider);
                                    if (playerState.isLoading) return;
                                    if (isPlaying) {
                                      ref.read(playerStateProvider.notifier).pause();
                                    } else {
                                      ref.read(playerStateProvider.notifier).playStation(station);
                                    }
                                  },
                                  onFavoriteToggle: () => ref.read(favoritesProvider.notifier).toggleFavorite(station.id),
                                  backgroundColor: colorSchemeStr == 'kanarya' ? AppTheme.kanaryaSecondary : (colorSchemeStr == 'aslan' ? AppTheme.aslanRed : (colorSchemeStr == 'karadeniz' ? AppTheme.karadenizBordo : (colorSchemeStr == 'kartal' ? AppTheme.kartalBlack : (colorSchemeStr == 'timsah' ? AppTheme.timsahGreen : null)))),
                                  titleColor: colorSchemeStr == 'kanarya' ? AppTheme.kanaryaPrimary : (colorSchemeStr == 'aslan' ? AppTheme.aslanYellow : (colorSchemeStr == 'karadeniz' ? AppTheme.karadenizMavi : (colorSchemeStr == 'kartal' ? AppTheme.kartalWhite : (colorSchemeStr == 'timsah' ? AppTheme.timsahWhite : null)))),
                                  subtitleColor: colorSchemeStr == 'kanarya' ? AppTheme.kanaryaPrimary.withOpacity(0.9) : (colorSchemeStr == 'aslan' ? AppTheme.aslanYellow.withOpacity(0.9) : (colorSchemeStr == 'karadeniz' ? AppTheme.karadenizMavi.withOpacity(0.9) : (colorSchemeStr == 'kartal' ? AppTheme.kartalWhite.withOpacity(0.9) : (colorSchemeStr == 'timsah' ? AppTheme.timsahGreen.withOpacity(0.95) : null)))),
                                  playButtonBackgroundColor: colorSchemeStr == 'aslan' ? AppTheme.aslanYellow : (colorSchemeStr == 'karadeniz' ? AppTheme.karadenizMavi : (colorSchemeStr == 'kartal' ? AppTheme.kartalWhite : (colorSchemeStr == 'timsah' ? AppTheme.timsahWhite : null))),
                                  playIconColor: colorSchemeStr == 'aslan' ? Colors.black : (colorSchemeStr == 'karadeniz' ? AppTheme.karadenizBordo : (colorSchemeStr == 'kartal' ? AppTheme.kartalBlack : (colorSchemeStr == 'timsah' ? AppTheme.timsahGreen : null))),
                                ),
                              );
                            },
                          ),
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (err, stack) => Center(child: Text('Hata: $err')),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
