import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../favorites/data/favorites_provider.dart';
import '../../player/data/player_provider.dart';
import '../../../shared/providers/color_scheme_provider.dart';
import 'widgets/recently_played_item.dart';
import 'widgets/radio_station_card.dart';
import '../data/stations_provider.dart';

final selectedTabProvider = StateProvider<int>((ref) => 0);

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  late ScrollController _scrollController;
  late TextEditingController _searchController;
  late FocusNode _searchFocusNode;
  bool _isSearchActive = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _searchController = TextEditingController();
    _searchFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredStationsAsync = ref.watch(filteredStationsProvider);
    final recentlyPlayedAsync = ref.watch(actualRecentlyPlayedStationsProvider);
    final playerState = ref.watch(playerStateProvider);
    final favorites = ref.watch(favoritesProvider);
    final searchQuery = ref.watch(searchQueryProvider);
    final colorSchemeStr = ref.watch(colorSchemeProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final appBarBg = _resolveAppBarBg(theme, colorSchemeStr);
    final appBarFg = _resolveAppBarFg(theme, colorSchemeStr);
    final pageBottom = theme.scaffoldBackgroundColor;
    final pageTop = (colorSchemeStr == 'varsayilan' || colorSchemeStr == 'beyaz')
        ? pageBottom
        : Color.lerp(
            appBarBg,
            isDark ? Colors.black : pageBottom,
            isDark ? 0.72 : 0.88,
          )!;

    return Scaffold(
      extendBodyBehindAppBar: true,
      drawer: _buildDrawer(appBarBg, appBarFg),
      body: Container(
        decoration: BoxDecoration(
          color: (colorSchemeStr == 'varsayilan' || colorSchemeStr == 'beyaz')
              ? pageBottom
              : null,
          gradient: (colorSchemeStr == 'varsayilan' || colorSchemeStr == 'beyaz')
              ? null
              : LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [pageTop, pageBottom, pageBottom],
                  stops: const [0.0, 0.22, 1.0],
                ),
        ),
        child: SafeArea(
          bottom: false,
          top: false,
          child: Column(
            children: [
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      appBarBg,
                      Color.lerp(appBarBg, Colors.black, 0.16)!
                    ],
                  ),
                ),
                child: SafeArea(
                  bottom: false,
                  child: Column(
                    children: [
                      if (_isSearchActive)
                        _buildSearchHeader(appBarFg)
                      else
                        _buildNormalHeader(appBarFg),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: filteredStationsAsync.when(
                  data: (filteredStations) {
                    if (filteredStations.isEmpty) {
                      return _buildEmptyState(context);
                    }
                    return ListView.builder(
                      padding: const EdgeInsets.only(bottom: 8),
                      itemCount:
                          filteredStations.length +
                          (searchQuery.isEmpty ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (searchQuery.isEmpty && index == 0) {
                          return _buildRecentlyPlayedSection(colorSchemeStr, theme, recentlyPlayedAsync);
                        }

                        final stationIndex = searchQuery.isEmpty ? index - 1 : index;
                        if (stationIndex < 0 || stationIndex >= filteredStations.length) return const SizedBox.shrink();

                        final station = filteredStations[stationIndex];
                        final isPlaying = playerState.currentStation?.id == station.id && playerState.isPlaying;
                        final isFavorite = favorites.contains(station.id);

                        Color? zebraColor;
                        if (colorSchemeStr == 'beyaz') {
                          final isEven = index % 2 == 0;
                          zebraColor = isEven ? const Color(0xFFFAFBFC) : const Color(0xFFF2F4F6);
                        } else if (colorSchemeStr == 'sade') {
                          final isEven = index % 2 == 0;
                          zebraColor = isEven ? Colors.white : const Color(0xFFE8E8E8);
                        }

                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 1,
                          ),
                          child: RadioStationCard(
                            title: station.name,
                            subtitle: station.genre ?? 'Turkish Radio',
                            imageUrl: station.logoUrl,
                            backgroundColor: zebraColor ?? _cardBackground(colorSchemeStr),
                            isPlaying: isPlaying,
                            isFavorite: isFavorite,
                            onTap: () => ref.read(playerStateProvider.notifier).playStation(station),
                            onFavoriteToggle: () => ref.read(favoritesProvider.notifier).toggleFavorite(station.id),
                            titleColor: _cardTitleColor(colorSchemeStr),
                            subtitleColor: _cardSubtitleColor(colorSchemeStr),
                            playButtonBackgroundColor: _cardPlayButtonBg(colorSchemeStr),
                            playIconColor: _cardPlayIconColor(colorSchemeStr),
                          ),
                        );
                      },
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (err, stack) => Center(child: Text('Hata: $err')),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentlyPlayedSection(String colorSchemeStr, ThemeData theme, AsyncValue<List<dynamic>> recentlyPlayedAsync) {
    return Container(
      color: Colors.transparent,
      padding: const EdgeInsets.fromLTRB(2, 1, 2, 3),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 22,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 9, 12, 1),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Son Dinlenenler',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: const Color(0xFF27314D),
                    ),
                  ),
                  recentlyPlayedAsync.maybeWhen(
                    data: (list) => list.isNotEmpty
                        ? TextButton(
                            onPressed: () => ref.read(recentlyPlayedNotifierProvider.notifier).clearRecent(),
                            child: const Text('Temizle', style: TextStyle(color: AppTheme.gradientBlue)),
                          )
                        : const SizedBox.shrink(),
                    orElse: () => const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 84,
              child: recentlyPlayedAsync.when(
                data: (list) => list.isEmpty
                    ? const Center(child: Text('Henüz radyo dinlemediniz'))
                    : ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: list.length,
                        itemBuilder: (context, i) => RecentlyPlayedStationItem(
                          station: list[i] as dynamic,
                          onTap: () => ref.read(playerStateProvider.notifier).playStation(list[i] as dynamic),
                        ),
                      ),
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 64, color: Colors.grey.withValues(alpha: 0.6)),
          const SizedBox(height: 16),
          const Text('İstasyon bulunamadı'),
        ],
      ),
    );
  }

  Widget _buildDrawer(Color appBarBg, Color appBarFg) {
    final textColor = Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black;
    final drawerAccent =
        appBarBg.computeLuminance() > 0.85 ? const Color(0xFF344054) : appBarBg;
    final favoriteAccent = appBarBg.computeLuminance() > 0.85
        ? const Color(0xFFE11D48)
        : AppTheme.gradientPink;

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          Container(
            width: double.infinity,
            height: 160,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [appBarBg, Color.lerp(appBarBg, Colors.black, 0.16)!],
              ),
            ),
            padding: const EdgeInsets.only(top: 50, left: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(Icons.radio, color: appBarFg, size: 32),
                const SizedBox(height: 10),
                Text('Radyo Tüneli', style: TextStyle(color: appBarFg, fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
              ],
            ),
          ),
          ListTile(
            leading: Icon(Icons.home, color: drawerAccent),
            title: const Text('Ana Sayfa'),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: Icon(Icons.favorite, color: favoriteAccent),
            title: const Text('Favoriler'),
            onTap: () {
              Navigator.pop(context);
              ref.read(selectedTabProvider.notifier).state = 1;
            },
          ),
          ListTile(
            leading: Icon(Icons.settings, color: drawerAccent),
            title: const Text('Ayarlar'),
            onTap: () {
              Navigator.pop(context);
              ref.read(selectedTabProvider.notifier).state = 2;
            },
          ),
           ExpansionTile(
            leading: Icon(Icons.category, color: drawerAccent),
            iconColor: drawerAccent,
            collapsedIconColor: drawerAccent,
            title: const Text('Kategoriler'),
            initiallyExpanded: false,
            children: [
              _buildCategoryItem(null, 'Tümü', Icons.radio_outlined, appBarBg, textColor),
              _buildCategoryItem('muzik', 'Müzik', Icons.music_note_outlined, appBarBg, textColor),
              _buildCategoryItem('turku', 'Türkü', Icons.audiotrack_outlined, appBarBg, textColor),
              _buildCategoryItem('haber', 'Haber', Icons.newspaper_outlined, appBarBg, textColor),
              _buildCategoryItem('spor', 'Spor', Icons.sports_soccer_outlined, appBarBg, textColor),
              _buildCategoryItem('dini', 'Dini', Icons.mosque_outlined, appBarBg, textColor),
              _buildCategoryItem('arabesk', 'Arabesk', Icons.favorite_border, appBarBg, textColor),
              _buildCategoryItem('yerel', 'Yerel', Icons.location_on_outlined, appBarBg, textColor),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(String? id, String title, IconData icon, Color active, Color text) {
    final selected = ref.watch(selectedCategoryProvider);
    final isSelected = selected == id;
    final effectiveActive =
        active.computeLuminance() > 0.85 ? const Color(0xFF344054) : active;
    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? effectiveActive : text.withValues(alpha: 0.6),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isSelected ? effectiveActive : text,
          fontWeight: isSelected ? FontWeight.bold : null,
        ),
      ),
      onTap: () {
        ref.read(selectedCategoryProvider.notifier).state = id;
        Navigator.pop(context);
      },
    );
  }

  Widget _buildNormalHeader(Color headerFg) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Builder(builder: (c) => IconButton(icon: Icon(Icons.menu, color: headerFg), onPressed: () => Scaffold.of(c).openDrawer())),
          Expanded(child: Text('Radyo Tüneli', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: headerFg))),
          IconButton(icon: Icon(Icons.search, color: headerFg), onPressed: () => setState(() => _isSearchActive = true)),
        ],
      ),
    );
  }

  Widget _buildSearchHeader(Color headerFg) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          IconButton(icon: Icon(Icons.arrow_back, color: headerFg), onPressed: () => setState(() => _isSearchActive = false)),
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Ara...',
                border: InputBorder.none,
                hintStyle: TextStyle(color: headerFg.withValues(alpha: 0.7)),
              ),
              style: TextStyle(color: headerFg),
              onChanged: (v) => ref.read(searchQueryProvider.notifier).state = v,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChips(Color bg, Color fg) {
    final selected = ref.watch(selectedCategoryProvider);
    final cats = [ (null, 'Tümü', Icons.radio), ('muzik', 'Müzik', Icons.music_note), ('turku', 'Türkü', Icons.queue_music), ('haber', 'Haber', Icons.article), ('spor', 'Spor', Icons.sports_soccer), ('dini', 'Dini', Icons.mosque), ('arabesk', 'Arabesk', Icons.mic), ('yerel', 'Yerel', Icons.location_on) ];
    return SizedBox(
        height: 50,
        child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: cats.length,
            itemBuilder: (c, i) {
              final isSel = selected == cats[i].$1;
              return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                      label: Text(cats[i].$2),
                      selected: isSel,
                      onSelected: (s) => ref
                          .read(selectedCategoryProvider.notifier)
                          .state = cats[i].$1));
            }));
  }

  Color _resolveAppBarBg(ThemeData t, String s) => s == 'beyaz' ? Colors.white : (t.appBarTheme.backgroundColor ?? t.colorScheme.primary);
  Color _resolveAppBarFg(ThemeData t, String s) => s == 'beyaz' ? Colors.black : (t.appBarTheme.foregroundColor ?? t.colorScheme.onPrimary);
  Color? _cardBackground(String s) => s == 'beyaz' ? const Color(0xFFFAFBFC) : null;
  Color? _cardTitleColor(String s) => null;
  Color? _cardSubtitleColor(String s) => null;
  Color? _cardPlayButtonBg(String s) => null;
  Color? _cardPlayIconColor(String s) => null;
}
