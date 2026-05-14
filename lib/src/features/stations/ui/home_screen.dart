import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/stations_provider.dart';
import 'widgets/recently_played_item.dart';
import '../../player/data/player_provider.dart';
import '../../player/ui/automotive_player_screen.dart';
import '../../../core/theme/app_theme.dart';
import 'widgets/radio_station_card.dart';
import '../../../shared/providers/color_scheme_provider.dart';
import '../../favorites/data/favorites_provider.dart';
import '../../../app/main_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  late TextEditingController _searchController;
  late FocusNode _searchFocusNode;
  bool _isSearchActive = false;
  Color? _appBarBg;
  Color? _appBarFg;
  String? _colorSchemeStr;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searchFocusNode = FocusNode();
    _searchFocusNode.addListener(() {
      if (!_searchFocusNode.hasFocus && _searchController.text.isEmpty) {
        setState(() => _isSearchActive = false);
      }
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _colorSchemeStr = ref.watch(colorSchemeProvider);
    if (_colorSchemeStr == 'karadeniz') {
      _appBarBg = AppTheme.karadenizBordo;
      _appBarFg = AppTheme.karadenizMavi;
    } else if (_colorSchemeStr == 'kartal') {
      _appBarBg = AppTheme.kartalBlack;
      _appBarFg = AppTheme.kartalWhite;
    } else if (_colorSchemeStr == 'timsah') {
      _appBarBg = AppTheme.timsahGreen;
      _appBarFg = AppTheme.timsahWhite;
    } else {
      _appBarBg = Theme.of(context).appBarTheme.backgroundColor;
      _appBarFg = Theme.of(context).appBarTheme.foregroundColor;
    }
    
    final filteredStationsAsync = ref.watch(filteredStationsProvider);
    final recentlyPlayedAsync = ref.watch(actualRecentlyPlayedStationsProvider);
    final searchQuery = ref.watch(searchQueryProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      drawer: _buildDrawer(),
      body: Container(
        color: _appBarBg ?? Theme.of(context).appBarTheme.backgroundColor,
        child: SafeArea(
          bottom: false,
          top: false,
          child: Column(
            children: [
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: _appBarBg ?? Theme.of(context).appBarTheme.backgroundColor,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(12),
                    bottomRight: Radius.circular(12),
                  ),
                ),
                child: SafeArea(
                  bottom: false,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
                        child: _isSearchActive ? _buildSearchHeader() : _buildNormalHeader(),
                      ),
                      if (!_isSearchActive) _buildCategoryChips(),
                    ],
                  ),
                ),
              ),
              // Son Dinlenenler — sabit bölüm, radyo listesiyle birlikte kaymaz
              if (searchQuery.isEmpty)
                Builder(builder: (context) {
                  final primary = Theme.of(context).primaryColor;
                  final isDark = Theme.of(context).brightness == Brightness.dark;
                  final bezelColor = isDark
                      ? Color.lerp(primary, Colors.black, 0.55)!
                      : Color.lerp(primary, Colors.white, 0.15)!;
                  final cardBg = isDark
                      ? Color.lerp(primary, Colors.black, 0.82)!
                      : Color.lerp(primary, Colors.white, 0.88)!;
                  final onBezel = bezelColor.computeLuminance() > 0.4
                      ? Colors.black87
                      : Colors.white;

                  return Container(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
                    child: Container(
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: bezelColor, width: 3),
                        boxShadow: [
                          BoxShadow(
                            color: primary.withValues(alpha: 0.30),
                            blurRadius: 10,
                            spreadRadius: 1,
                          ),
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.18),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Başlık çubuğu — tema rengiyle
                          Container(
                            decoration: BoxDecoration(
                              color: bezelColor,
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(11)),
                            ),
                            padding: const EdgeInsets.only(left: 12, right: 4, top: 5, bottom: 5),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.tv, size: 14, color: onBezel.withValues(alpha: 0.8)),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Son Dinlenenler',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                        color: onBezel,
                                      ),
                                    ),
                                  ],
                                ),
                                recentlyPlayedAsync.maybeWhen(
                                  data: (list) => list.isNotEmpty
                                      ? TextButton(
                                          style: TextButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                                            minimumSize: Size.zero,
                                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                            foregroundColor: onBezel.withValues(alpha: 0.75),
                                          ),
                                          onPressed: () {
                                            HapticFeedback.lightImpact();
                                            ref.read(recentlyPlayedNotifierProvider.notifier).clearRecent();
                                          },
                                          child: const Text('Temizle', style: TextStyle(fontSize: 12)),
                                        )
                                      : const SizedBox.shrink(),
                                  orElse: () => const SizedBox.shrink(),
                                ),
                              ],
                            ),
                          ),
                          // Ekran alanı
                          SizedBox(
                            height: 108,
                            child: recentlyPlayedAsync.when(
                              data: (recentlyPlayedStations) => recentlyPlayedStations.isEmpty
                                  ? Center(
                                      child: Text(
                                        'Henüz radyo dinlemediniz',
                                        style: TextStyle(
                                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.45),
                                          fontSize: 13,
                                        ),
                                      ),
                                    )
                                  : ListView.builder(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      scrollDirection: Axis.horizontal,
                                      itemCount: recentlyPlayedStations.length,
                                      itemBuilder: (context, index) {
                                        final station = recentlyPlayedStations[index];
                                        return RecentlyPlayedStationItem(
                                          station: station,
                                          onTap: () => ref.read(playerStateProvider.notifier).playStation(station),
                                        );
                                      },
                                    ),
                              loading: () => const SizedBox.shrink(),
                              error: (_, __) => const SizedBox.shrink(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              // Radyo listesi — sadece bu kısım kaydırılır
              Expanded(
                child: Container(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  child: filteredStationsAsync.when(
                    data: (filteredStations) {
                      if (filteredStations.isEmpty) {
                        return _buildEmptyState(context, searchQuery);
                      }
                      return ListView.builder(
                        padding: EdgeInsets.zero,
                        itemCount: filteredStations.length,
                        itemBuilder: (context, index) {
                          final station = filteredStations[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                            child: RadioStationCard(
                              title: station.name,
                              subtitle: station.genre ?? 'Turkish Radio',
                              imageUrl: station.logoUrl,
                              isPlaying: ref.watch(playerStateProvider).currentStation?.id == station.id && ref.watch(playerStateProvider).isPlaying,
                              isFavorite: ref.watch(favoritesProvider).contains(station.id),
                              onTap: () {
                                final playerState = ref.read(playerStateProvider);
                                // Sadece aynı istasyon zaten yükleniyorsa engelle;
                                // farklı istasyona geçişe her zaman izin ver
                                final isSameStationLoading = playerState.currentStation?.id == station.id && playerState.isLoading;
                                if (isSameStationLoading) return;
                                if (playerState.currentStation?.id == station.id && playerState.isPlaying) {
                                  ref.read(playerStateProvider.notifier).pause();
                                } else {
                                  ref.read(playerStateProvider.notifier).playStation(station);
                                  if (_isSearchActive) {
                                    setState(() => _isSearchActive = false);
                                    _searchController.clear();
                                    ref.read(searchQueryProvider.notifier).state = '';
                                    _searchFocusNode.unfocus();
                                  }
                                }
                              },
                              onFavoriteToggle: () => ref.read(favoritesProvider.notifier).toggleFavorite(station.id),
                              backgroundColor: _colorSchemeStr == 'kanarya' ? AppTheme.kanaryaSecondary : (_colorSchemeStr == 'aslan' ? AppTheme.aslanRed : (_colorSchemeStr == 'karadeniz' ? AppTheme.karadenizBordo : (_colorSchemeStr == 'kartal' ? AppTheme.kartalBlack : (_colorSchemeStr == 'timsah' ? AppTheme.timsahGreen : null)))),
                              titleColor: _colorSchemeStr == 'kanarya' ? AppTheme.kanaryaPrimary : (_colorSchemeStr == 'aslan' ? AppTheme.aslanYellow : (_colorSchemeStr == 'karadeniz' ? AppTheme.karadenizMavi : (_colorSchemeStr == 'kartal' ? AppTheme.kartalWhite : (_colorSchemeStr == 'timsah' ? AppTheme.timsahWhite : null)))),
                              subtitleColor: _colorSchemeStr == 'kanarya' ? AppTheme.kanaryaPrimary.withOpacity(0.9) : (_colorSchemeStr == 'aslan' ? AppTheme.aslanYellow.withOpacity(0.9) : (_colorSchemeStr == 'karadeniz' ? AppTheme.karadenizMavi.withOpacity(0.9) : (_colorSchemeStr == 'kartal' ? AppTheme.kartalWhite.withOpacity(0.9) : (_colorSchemeStr == 'timsah' ? AppTheme.timsahGreen.withOpacity(0.95) : null)))),
                              playButtonBackgroundColor: _colorSchemeStr == 'aslan' ? AppTheme.aslanYellow : (_colorSchemeStr == 'karadeniz' ? AppTheme.karadenizMavi : (_colorSchemeStr == 'kartal' ? AppTheme.kartalWhite : (_colorSchemeStr == 'timsah' ? AppTheme.timsahWhite : null))),
                              playIconColor: _colorSchemeStr == 'aslan' ? Colors.black : (_colorSchemeStr == 'karadeniz' ? AppTheme.karadenizBordo : (_colorSchemeStr == 'kartal' ? AppTheme.kartalBlack : (_colorSchemeStr == 'timsah' ? AppTheme.timsahGreen : null))),
                            ),
                          );
                        },
                      );
                    },
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

  Widget _buildEmptyState(BuildContext context, String searchQuery) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text('İstasyon bulunamadı'),
        ],
      ),
    );
  }

  Widget _buildDrawer() {
    final headerBg = _appBarBg ?? Theme.of(context).primaryColor;
    final headerFg = _appBarFg ?? Colors.white;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final drawerBg = Theme.of(context).scaffoldBackgroundColor;
    final itemColor = Theme.of(context).colorScheme.onSurface;

    return Drawer(
      backgroundColor: drawerBg,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            height: 150,
            decoration: BoxDecoration(
              color: headerBg,
              boxShadow: [
                BoxShadow(
                  color: headerBg.withValues(alpha: 0.4),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            padding: const EdgeInsets.only(top: 50, left: 20, bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(Icons.radio, color: headerFg.withValues(alpha: 0.8), size: 28),
                const SizedBox(height: 6),
                Text(
                  'Radyo Tüneli',
                  style: TextStyle(
                    color: headerFg,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          ListTile(
            leading: Icon(Icons.home, color: headerBg),
            title: Text('Ana Sayfa', style: TextStyle(color: itemColor, fontWeight: FontWeight.w500)),
            onTap: () => Navigator.pop(context),
          ),
          Divider(height: 1, indent: 16, endIndent: 16, color: itemColor.withValues(alpha: 0.1)),
          ListTile(
            leading: Icon(Icons.favorite, color: Colors.redAccent),
            title: Text('Favoriler', style: TextStyle(color: itemColor, fontWeight: FontWeight.w500)),
            onTap: () {
              Navigator.pop(context);
              ref.read(selectedTabProvider.notifier).state = 1;
            },
          ),
          Divider(height: 1, indent: 16, endIndent: 16, color: itemColor.withValues(alpha: 0.1)),
          ListTile(
            leading: Icon(Icons.settings, color: headerBg),
            title: Text('Ayarlar', style: TextStyle(color: itemColor, fontWeight: FontWeight.w500)),
            onTap: () {
              Navigator.pop(context);
              ref.read(selectedTabProvider.notifier).state = 2;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNormalHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          Builder(builder: (context) => IconButton(
            onPressed: () => Scaffold.of(context).openDrawer(),
            icon: Icon(Icons.menu, color: _appBarFg ?? Colors.white),
          )),
          Expanded(child: Text('Radyo Tüneli', style: TextStyle(color: _appBarFg ?? Colors.white, fontSize: 20, fontWeight: FontWeight.bold))),
          IconButton(
            onPressed: () {
              setState(() => _isSearchActive = true);
              _searchFocusNode.requestFocus();
            },
            icon: Icon(Icons.search, color: _appBarFg ?? Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChips() {
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final fg = _appBarFg ?? Colors.white;
    final bg = _appBarBg ?? Theme.of(context).primaryColor;

    final List<(String?, String, IconData)> categories = [
      (null, 'Tümü', Icons.radio),
      ('muzik', 'Müzik', Icons.music_note),
      ('turku', 'Türkü', Icons.queue_music),
      ('haber', 'Haber', Icons.article),
      ('spor', 'Spor', Icons.sports_soccer),
      ('dini', 'Dini', Icons.mosque),
      ('arabesk', 'Arabesk', Icons.mic),
      ('yerel', 'Yerel', Icons.location_on),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(8, 2, 8, 10),
      child: Row(
        children: categories.map((cat) {
          final isSelected = selectedCategory == cat.$1;
          return Padding(
            padding: const EdgeInsets.only(right: 6),
            child: GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                ref.read(selectedCategoryProvider.notifier).state = cat.$1;
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isSelected ? fg : fg.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? fg : fg.withValues(alpha: 0.45),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(cat.$3, size: 13, color: isSelected ? bg : fg),
                    const SizedBox(width: 4),
                    Text(
                      cat.$2,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? bg : fg,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSearchHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              setState(() => _isSearchActive = false);
              _searchController.clear();
              ref.read(searchQueryProvider.notifier).state = '';
              _searchFocusNode.unfocus();
            },
            icon: Icon(Icons.arrow_back, color: _appBarFg ?? Colors.white),
          ),
          Expanded(
            child: TextField(
              controller: _searchController,
              focusNode: _searchFocusNode,
              onChanged: (val) => ref.read(searchQueryProvider.notifier).state = val,
              decoration: InputDecoration(
                hintText: 'Ara...',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
