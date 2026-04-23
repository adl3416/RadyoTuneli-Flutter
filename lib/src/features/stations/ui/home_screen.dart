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
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
                    child: _isSearchActive ? _buildSearchHeader() : _buildNormalHeader(),
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  child: filteredStationsAsync.when(
                    data: (filteredStations) {
                      return CustomScrollView(
                        slivers: [
                          if (searchQuery.isEmpty) ...[
                            SliverToBoxAdapter(
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text('Son Dinlenenler', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                    TextButton(
                                      onPressed: () {
                                        HapticFeedback.lightImpact();
                                        ref.read(recentlyPlayedNotifierProvider.notifier).clearRecent();
                                      },
                                      child: const Text('Temizle'),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SliverToBoxAdapter(
                              child: SizedBox(
                                height: 82,
                                child: recentlyPlayedAsync.when(
                                  data: (recentlyPlayedStations) => ListView.builder(
                                    padding: const EdgeInsets.symmetric(horizontal: 16),
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
                                  loading: () => const Center(child: CircularProgressIndicator()),
                                  error: (err, stack) => Center(child: Text('Hata: $err')),
                                ),
                              ),
                            ),
                            const SliverToBoxAdapter(child: SizedBox(height: 24)),
                          ],
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                searchQuery.isNotEmpty ? 'Arama Sonuçları (${filteredStations.length})' : 'Tüm İstasyonlar (${filteredStations.length})',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                            ),
                          ),
                          const SliverToBoxAdapter(child: SizedBox(height: 16)),
                          if (filteredStations.isEmpty)
                            SliverToBoxAdapter(child: _buildEmptyState(context, searchQuery))
                          else
                            SliverList(
                              delegate: SliverChildBuilderDelegate(
                                (context, index) {
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
                                        if (playerState.isLoading) return;
                                        if (playerState.currentStation?.id == station.id && playerState.isPlaying) {
                                          ref.read(playerStateProvider.notifier).pause();
                                        } else {
                                          ref.read(playerStateProvider.notifier).playStation(station);
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
                                childCount: filteredStations.length,
                              ),
                            ),
                        ],
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
    return Drawer(
      child: Column(
        children: [
            Container(
              width: double.infinity,
              height: 150,
              color: AppTheme.headerPurple,
              padding: const EdgeInsets.only(top: 50, left: 20),
              child: const Text('Radyo Tüneli', style: TextStyle(color: Colors.white, fontSize: 24)),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Ana Sayfa'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.favorite),
              title: const Text('Favoriler'),
              onTap: () {
                Navigator.pop(context);
                ref.read(selectedTabProvider.notifier).state = 1;
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
