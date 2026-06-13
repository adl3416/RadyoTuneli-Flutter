import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../stations/data/stations_provider.dart';
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Color? appBarBg;
    Color? appBarFg;

    if (isDark) {
      appBarBg = Colors.black;
      appBarFg = Colors.white;
    } else if (colorSchemeStr == 'karadeniz') {
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
      drawer: _buildDrawer(context, ref),
      body: Container(
        color: appBarBg ?? Theme.of(context).appBarTheme.backgroundColor,
        child: SafeArea(
          bottom: false,
          top: false,
          child: Builder(
            builder: (builderContext) {
              return Column(
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
                            IconButton(
                              style: IconButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                foregroundColor: appBarFg ?? Colors.white,
                              ),
                              icon: Icon(Icons.menu, color: appBarFg ?? Colors.white),
                              onPressed: () {
                                Scaffold.of(builderContext).openDrawer();
                              },
                            ),
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
                                  
                                  // Zebra effect for neutral themes
                                  Color? zebraColor;
                                  if (isDark) {
                                    zebraColor = index % 2 == 0
                                        ? const Color(0xFF171717)
                                        : const Color(0xFF202020);
                                  } else if (colorSchemeStr == 'varsayilan' || colorSchemeStr == 'purple') {
                                    zebraColor = index % 2 == 0
                                        ? const Color(0xFFF1F3F5)
                                        : const Color(0xFFE5E7EB);
                                  } else if (colorSchemeStr == 'beyaz') {
                                    zebraColor = index % 2 == 0
                                        ? AppTheme.beyazBackgroundFull
                                        : AppTheme.beyazCardGrey;
                                  } else if (colorSchemeStr == 'sade') {
                                    zebraColor = index % 2 == 0 ? Colors.white : const Color(0xFFE8E8E8);
                                  }

                                  return Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                    child: RadioStationCard(
                                      title: station.name,
                                      subtitle: station.genre ?? 'Müzik',
                                      imageUrl: station.logoUrl,
                                      isPlaying: isPlaying,
                                      isFavorite: true,
                                      onTap: () {
                                        final playerState = ref.read(playerStateProvider);
                                        // Sadece aynı istasyon yükleniyorsa engelle
                                        final isSameStationLoading = playerState.currentStation?.id == station.id && playerState.isLoading;
                                        if (isSameStationLoading) return;
                                        if (isPlaying) {
                                          ref.read(playerStateProvider.notifier).pause();
                                        } else {
                                          ref.read(playerStateProvider.notifier).playStation(station);
                                        }
                                      },
                                      onFavoriteToggle: () => ref.read(favoritesProvider.notifier).toggleFavorite(station.id),
                                      backgroundColor: zebraColor ?? (colorSchemeStr == 'kanarya' ? AppTheme.kanaryaSecondary : (colorSchemeStr == 'aslan' ? AppTheme.aslanRed : (colorSchemeStr == 'karadeniz' ? AppTheme.karadenizBordo : (colorSchemeStr == 'kartal' ? AppTheme.kartalBlack : (colorSchemeStr == 'timsah' ? AppTheme.timsahGreen : null))))),
                                      titleColor: colorSchemeStr == 'kanarya' ? AppTheme.kanaryaPrimary : (colorSchemeStr == 'aslan' ? AppTheme.aslanOfficialYellow : (colorSchemeStr == 'karadeniz' ? AppTheme.karadenizMavi : (colorSchemeStr == 'kartal' ? AppTheme.kartalWhite : (colorSchemeStr == 'timsah' ? AppTheme.timsahWhite : null)))),
                                      playButtonBackgroundColor: colorSchemeStr == 'aslan' ? AppTheme.aslanOfficialYellow : (colorSchemeStr == 'karadeniz' ? AppTheme.karadenizMavi : (colorSchemeStr == 'kartal' ? AppTheme.kartalWhite : (colorSchemeStr == 'timsah' ? AppTheme.timsahWhite : null))),
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
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final textColor =
        Theme.of(context).textTheme.bodyLarge?.color ?? colorScheme.onSurface;
    final drawerBg = Theme.of(context).appBarTheme.backgroundColor ??
        Theme.of(context).colorScheme.primary;
    final drawerFg = Theme.of(context).appBarTheme.foregroundColor ??
        Theme.of(context).colorScheme.onPrimary;
    final drawerIconColor = colorScheme.onSurface.withValues(alpha: 0.88);

    return Drawer(
      backgroundColor: colorScheme.surface,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          Container(
            width: double.infinity,
            height: 150,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [drawerBg, Color.lerp(drawerBg, Colors.black, 0.16)!],
              ),
              boxShadow: [
                BoxShadow(
                  color: drawerBg.withValues(alpha: 0.18),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            padding: const EdgeInsets.only(top: 50, left: 20, bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    'assets/images/icon.png',
                    width: 32,
                    height: 32,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Radyo Tüneli',
                  style: TextStyle(
                    color: drawerFg,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          ListTile(
            leading: Icon(Icons.home, color: drawerIconColor),
            title: Text(
              'Ana Sayfa',
              style: TextStyle(color: textColor, fontWeight: FontWeight.w500),
            ),
            onTap: () {
              Navigator.pop(context);
              ref.read(selectedTabProvider.notifier).state = 0;
            },
          ),
          Divider(
            height: 1,
            indent: 16,
            endIndent: 16,
            color: drawerFg.withValues(alpha: 0.12),
          ),
          ListTile(
            leading: const Icon(Icons.favorite, color: Color(0xFFFB7185)),
            title: Text(
              'Favoriler',
              style: TextStyle(color: textColor, fontWeight: FontWeight.w500),
            ),
            onTap: () {
              Navigator.pop(context);
              ref.read(selectedTabProvider.notifier).state = 1;
            },
          ),
          Divider(
            height: 1,
            indent: 16,
            endIndent: 16,
            color: drawerFg.withValues(alpha: 0.12),
          ),
          ListTile(
            leading: Icon(Icons.settings, color: drawerIconColor),
            title: Text(
              'Ayarlar',
              style: TextStyle(color: textColor, fontWeight: FontWeight.w500),
            ),
            onTap: () {
              Navigator.pop(context);
              ref.read(selectedTabProvider.notifier).state = 2;
            },
          ),
          Divider(
            height: 1,
            indent: 16,
            endIndent: 16,
            color: drawerFg.withValues(alpha: 0.12),
          ),
          ExpansionTile(
            leading: Icon(Icons.category_outlined, color: drawerIconColor),
            iconColor: drawerIconColor,
            collapsedIconColor: drawerIconColor,
            title: Text(
              'Kategoriler',
              style: TextStyle(color: textColor, fontWeight: FontWeight.w500),
            ),
            children: [
              _buildDrawerCategoryTile(context, ref, 'muzik', 'Müzik', Icons.music_note, textColor),
              _buildDrawerCategoryTile(context, ref, 'turku', 'Türkü', Icons.queue_music, textColor),
              _buildDrawerCategoryTile(context, ref, 'haber', 'Haber', Icons.article, textColor),
              _buildDrawerCategoryTile(context, ref, 'spor', 'Spor', Icons.sports_soccer, textColor),
              _buildDrawerCategoryTile(context, ref, 'dini', 'Dini', Icons.mosque, textColor),
              _buildDrawerCategoryTile(context, ref, 'arabesk', 'Arabesk', Icons.mic, textColor),
              _buildDrawerCategoryTile(context, ref, 'yerel', 'Yerel', Icons.location_on, textColor),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerCategoryTile(
    BuildContext context,
    WidgetRef ref,
    String id,
    String title,
    IconData icon,
    Color textColor,
  ) {
    final isSelected = ref.watch(selectedCategoryProvider) == id;

    return ListTile(
      contentPadding: const EdgeInsets.only(left: 32, right: 16),
      leading: Icon(
        icon,
        size: 20,
        color: isSelected ? AppTheme.gradientBlue : textColor,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: textColor,
          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
        ),
      ),
      onTap: () {
        ref.read(selectedCategoryProvider.notifier).state = id;
        ref.read(selectedTabProvider.notifier).state = 0;
        Navigator.pop(context);
      },
    );
  }
}

