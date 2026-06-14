import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/main_screen.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/providers/color_scheme_provider.dart';
import '../../favorites/data/favorites_provider.dart';
import '../../player/data/player_provider.dart';
import '../data/stations_provider.dart';
import 'widgets/radio_station_card.dart';
import 'widgets/recently_played_item.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  late TextEditingController _searchController;
  late FocusNode _searchFocusNode;
  bool _isSearchActive = false;
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
    final pageBottom = Colors.white;
    final pageTop = (colorSchemeStr == 'varsayilan' || colorSchemeStr == 'beyaz')
        ? pageBottom
        : Color.lerp(
            appBarBg,
            isDark ? Colors.black : pageBottom,
            isDark ? 0.72 : 0.88,
          )!;
    final recentCardColor = Color.lerp(
      appBarBg,
      isDark ? Colors.black : Colors.white,
      isDark ? 0.82 : 0.88,
    )!;
    final recentOutline = appBarFg.withValues(alpha: isDark ? 0.16 : 0.12);
    final recentShadowColor = appBarBg.withValues(alpha: isDark ? 0.28 : 0.14);

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
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: _isSearchActive
                            ? _buildSearchHeader(appBarFg)
                            : _buildNormalHeader(appBarFg),
                      ),
                      if (!_isSearchActive)
                        _buildCategoryChips(appBarBg, appBarFg),
                    ],
                  ),
                ),
              ),
              if (false && searchQuery.isEmpty)
                Container(
                  color: Colors.transparent,
                  padding: const EdgeInsets.fromLTRB(2, 1, 2, 3),
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFFFFF),
                      border: Border.all(
                        color: const Color(0xFFFDFEFF),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 14,
                          offset: const Offset(0, 4),
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
                                    ? Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          TextButton(
                                        style: TextButton.styleFrom(
                                           padding: const EdgeInsets.symmetric(
                                             horizontal: 0,
                                             vertical: 2,
                                           ),
                                          minimumSize: Size.zero,
                                          tapTargetSize:
                                              MaterialTapTargetSize.shrinkWrap,
                                          foregroundColor: AppTheme.gradientBlue,
                                        ),
                                        onPressed: () {
                                          HapticFeedback.lightImpact();
                                          ref
                                              .read(
                                                recentlyPlayedNotifierProvider
                                                    .notifier,
                                              )
                                              .clearRecent();
                                        },
                                        child: const Text(
                                          'Temizle',
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color: AppTheme.gradientBlue,
                                          ),
                                        ),
                                      ),
                                          const SizedBox(width: 6),
                                          const Icon(
                                            Icons.delete_outline_rounded,
                                            size: 18,
                                            color: AppTheme.gradientBlue,
                                          ),
                                        ],
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
                            data: (recentlyPlayedStations) =>
                                recentlyPlayedStations.isEmpty
                                    ? Center(
                                        child: Text(
                                          'Hen\u00fcz radyo dinlemediniz',
                                          style: TextStyle(
                                            color: theme
                                                .textTheme.bodyMedium?.color,
                                            fontSize: 13,
                                          ),
                                        ),
                                      )
                                    : ListView.builder(
                                        padding: const EdgeInsets.fromLTRB(8, 0, 8, 4),
                                        scrollDirection: Axis.horizontal,
                                        itemCount:
                                            recentlyPlayedStations.length,
                                        itemBuilder: (context, index) {
                                          final station =
                                              recentlyPlayedStations[index];
                                          return RecentlyPlayedStationItem(
                                            station: station,
                                            onTap: () => ref
                                                .read(
                                                  playerStateProvider.notifier,
                                                )
                                                .playStation(station),
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
                ),
              if (false)
                Padding(
                padding: const EdgeInsets.fromLTRB(18, 10, 18, 8),
                child: Row(
                  children: [
                    Icon(
                      Icons.graphic_eq_rounded,
                      color: AppTheme.gradientBlue,
                      size: 22,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '\u0054\u00FCm Radyolar',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          color: const Color(0xFF27314D),
                        ),
                      ),
                    ),
                  ],
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
                          (searchQuery.isEmpty ? 2 : 1),
                      itemBuilder: (context, index) {
                        if (searchQuery.isEmpty && index == 0) {
                          return Container(
                            color: Colors.transparent,
                            padding: const EdgeInsets.fromLTRB(2, 1, 2, 3),
                            child: Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFFFFF),
                                border: Border.all(
                                  color: const Color(0xFFFDFEFF),
                                  width: 1,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.03),
                                    blurRadius: 14,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                      14,
                                      9,
                                      12,
                                      1,
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Son Dinlenenler',
                                          style: theme.textTheme.titleMedium
                                              ?.copyWith(
                                                fontWeight: FontWeight.w700,
                                                fontSize: 16,
                                                color: colorSchemeStr == 'beyaz' ? AppTheme.beyazTextDark : const Color(0xFF27314D),
                                              ),
                                        ),
                                        recentlyPlayedAsync.maybeWhen(
                                          data: (list) => list.isNotEmpty
                                              ? Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    TextButton(
                                                      style: TextButton.styleFrom(
                                                        padding:
                                                            const EdgeInsets.symmetric(
                                                              horizontal: 0,
                                                              vertical: 2,
                                                            ),
                                                        minimumSize: Size.zero,
                                                        tapTargetSize:
                                                            MaterialTapTargetSize
                                                                .shrinkWrap,
                                                        foregroundColor:
                                                            AppTheme
                                                                .gradientBlue,
                                                      ),
                                                      onPressed: () {
                                                        HapticFeedback
                                                            .lightImpact();
                                                        ref
                                                            .read(
                                                              recentlyPlayedNotifierProvider
                                                                  .notifier,
                                                            )
                                                            .clearRecent();
                                                      },
                                                      child: const Text(
                                                        'Temizle',
                                                        style: TextStyle(
                                                          fontSize: 13,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          color: AppTheme
                                                              .gradientBlue,
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(width: 6),
                                                    const Icon(
                                                      Icons
                                                          .delete_outline_rounded,
                                                      size: 18,
                                                      color: AppTheme
                                                          .gradientBlue,
                                                    ),
                                                  ],
                                                )
                                              : const SizedBox.shrink(),
                                          orElse:
                                              () => const SizedBox.shrink(),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    height: 84,
                                    child: recentlyPlayedAsync.when(
                                      data: (recentlyPlayedStations) =>
                                          recentlyPlayedStations.isEmpty
                                              ? Center(
                                                  child: Text(
                                                    'Hen\u00fcz radyo dinlemediniz',
                                                    style: TextStyle(
                                                      color: theme
                                                          .textTheme
                                                          .bodyMedium
                                                          ?.color,
                                                      fontSize: 13,
                                                    ),
                                                  ),
                                                )
                                              : ListView.builder(
                                                  padding:
                                                      const EdgeInsets.fromLTRB(
                                                        8,
                                                        0,
                                                        8,
                                                        4,
                                                      ),
                                                  scrollDirection:
                                                      Axis.horizontal,
                                                  itemCount:
                                                      recentlyPlayedStations
                                                          .length,
                                                  itemBuilder:
                                                      (context, recentIndex) {
                                                    final station =
                                                        recentlyPlayedStations[recentIndex];
                                                    return RecentlyPlayedStationItem(
                                                      station: station,
                                                      onTap: () => ref
                                                          .read(
                                                            playerStateProvider
                                                                .notifier,
                                                          )
                                                          .playStation(station),
                                                    );
                                                  },
                                                ),
                                      loading:
                                          () => const SizedBox.shrink(),
                                      error:
                                          (_, __) => const SizedBox.shrink(),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }
                        if (index == (searchQuery.isEmpty ? 1 : 0)) {
                          return Padding(
                            padding: const EdgeInsets.fromLTRB(18, 10, 18, 8),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.graphic_eq_rounded,
                                  color: AppTheme.gradientBlue,
                                  size: 22,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    '\u0054\u00FCm Radyolar',
                                    style: theme.textTheme.titleMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 16,
                                          color: colorSchemeStr == 'beyaz' ? AppTheme.beyazTextDark : const Color(0xFF27314D),
                                        ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }
                        final station =
                            filteredStations[index - (searchQuery.isEmpty ? 2 : 1)];
                        
                        // Zebra effect for 'beyaz' and 'sade' themes
                        Color? zebraColor;
                        if (colorSchemeStr == 'beyaz') {
                          zebraColor = Colors.white;
                        } else if (colorSchemeStr == 'sade') {
                          final isEven = (index - (searchQuery.isEmpty ? 2 : 1)) % 2 == 0;
                          zebraColor = isEven ? Colors.white : const Color(0xFFE8E8E8);
                        }

                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
                          child: RadioStationCard(
                            title: station.name,
                            subtitle: station.genre ?? 'Turkish Radio',
                            imageUrl: station.logoUrl,
                            backgroundColor: zebraColor ?? _cardBackground(colorSchemeStr),
                            isPlaying:
                                playerState.currentStation?.id == station.id &&
                                    playerState.isPlaying,
                            isFavorite: favorites.contains(station.id),
                            onTap: () {
                              final current = ref.read(playerStateProvider);
                              final isSameStationLoading =
                                  current.currentStation?.id == station.id &&
                                      current.isLoading;
                              if (isSameStationLoading) return;
                              if (current.currentStation?.id == station.id &&
                                  current.isPlaying) {
                                ref.read(playerStateProvider.notifier).pause();
                              } else {
                                ref
                                    .read(playerStateProvider.notifier)
                                    .playStation(station);
                                if (_isSearchActive) {
                                  setState(() => _isSearchActive = false);
                                  _searchController.clear();
                                  ref.read(searchQueryProvider.notifier).state =
                                      '';
                                  _searchFocusNode.unfocus();
                                }
                              }
                            },
                            onFavoriteToggle: () => ref
                                .read(favoritesProvider.notifier)
                                .toggleFavorite(station.id),
                            titleColor: _cardTitleColor(colorSchemeStr),
                            subtitleColor: _cardSubtitleColor(colorSchemeStr),
                            playButtonBackgroundColor:
                                _cardPlayButtonBg(colorSchemeStr),
                            playIconColor: _cardPlayIconColor(colorSchemeStr),
                          ),
                        );
                      },
                    );
                  },
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (err, stack) => Center(child: Text('Hata: $err')),
                ),
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
            Icons.search_off,
            size: 64,
            color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(
                  alpha: 0.6,
                ),
          ),
          const SizedBox(height: 16),
          const Text('\u0130stasyon bulunamad\u0131'),
        ],
      ),
    );
  }

  Widget _buildDrawer(Color appBarBg, Color appBarFg) {
    final textColor = Theme.of(context).textTheme.bodyLarge?.color ??
        Theme.of(context).colorScheme.onSurface;
    final drawerIconColor =
        appBarBg.computeLuminance() > 0.85 ? const Color(0xFF344054) : appBarBg;

    return Drawer(
      backgroundColor: Theme.of(context).drawerTheme.backgroundColor ??
          Theme.of(context).scaffoldBackgroundColor,
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
                colors: [appBarBg, Color.lerp(appBarBg, Colors.black, 0.16)!],
              ),
              boxShadow: [
                BoxShadow(
                  color: appBarBg.withValues(alpha: 0.18),
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
                Icon(Icons.radio, color: appBarFg, size: 28),
                const SizedBox(height: 6),
                Text(
                  'Radyo T\u00fcneli',
                  style: TextStyle(
                    color: appBarFg,
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
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.w500,
              ),
            ),
            onTap: () => Navigator.pop(context),
          ),
          Divider(
            height: 1,
            indent: 16,
            endIndent: 16,
            color: appBarFg.withValues(alpha: 0.12),
          ),
          ListTile(
            leading: const Icon(Icons.favorite, color: Color(0xFFFB7185)),
            title: Text(
              'Favoriler',
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.w500,
              ),
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
            color: appBarFg.withValues(alpha: 0.12),
          ),
          ListTile(
            leading: Icon(Icons.settings, color: drawerIconColor),
            title: Text(
              'Ayarlar',
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.w500,
              ),
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
            color: appBarFg.withValues(alpha: 0.12),
          ),
          ExpansionTile(
            leading: Icon(Icons.category_outlined, color: drawerIconColor),
            iconColor: drawerIconColor,
            collapsedIconColor: drawerIconColor,
            title: Text(
              'Kategoriler',
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.w500,
              ),
            ),
            children: [
              _buildDrawerCategoryTile(
                id: 'muzik',
                title: 'Müzik',
                icon: Icons.music_note,
                textColor: textColor,
              ),
              _buildDrawerCategoryTile(
                id: 'turku',
                title: 'Türkü',
                icon: Icons.queue_music,
                textColor: textColor,
              ),
              _buildDrawerCategoryTile(
                id: 'haber',
                title: 'Haber',
                icon: Icons.article,
                textColor: textColor,
              ),
              _buildDrawerCategoryTile(
                id: 'spor',
                title: 'Spor',
                icon: Icons.sports_soccer,
                textColor: textColor,
              ),
              _buildDrawerCategoryTile(
                id: 'dini',
                title: 'Dini',
                icon: Icons.mosque,
                textColor: textColor,
              ),
              _buildDrawerCategoryTile(
                id: 'arabesk',
                title: 'Arabesk',
                icon: Icons.mic,
                textColor: textColor,
              ),
              _buildDrawerCategoryTile(
                id: 'yerel',
                title: 'Yerel',
                icon: Icons.location_on,
                textColor: textColor,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerCategoryTile({
    required String id,
    required String title,
    required IconData icon,
    required Color textColor,
  }) {
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
        Navigator.pop(context);
      },
    );
  }

  Widget _buildNormalHeader(Color headerFg) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          Builder(
            builder: (context) => IconButton(
              style: IconButton.styleFrom(
                backgroundColor: Colors.transparent,
                foregroundColor: headerFg,
              ),
              onPressed: () => Scaffold.of(context).openDrawer(),
              icon: Icon(Icons.menu, color: headerFg),
            ),
          ),
          Expanded(
            child: Text(
              'Radyo T\u00fcneli',
              style: TextStyle(
                color: headerFg,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          IconButton(
            style: IconButton.styleFrom(
              backgroundColor: Colors.transparent,
              foregroundColor: headerFg,
            ),
            onPressed: () {
              setState(() => _isSearchActive = true);
              _searchFocusNode.requestFocus();
            },
            icon: Icon(Icons.search, color: headerFg),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChips(Color appBarBg, Color appBarFg) {
    final selectedCategory = ref.watch(selectedCategoryProvider);

    final List<(String?, String, IconData)> categories = [
      (null, 'T\u00fcm\u00fc', Icons.radio),
      ('muzik', 'M\u00fczik', Icons.music_note),
      ('turku', 'T\u00fcrk\u00fc', Icons.queue_music),
      ('haber', 'Haber', Icons.article),
      ('spor', 'Spor', Icons.sports_soccer),
      ('dini', 'Dini', Icons.mosque),
      ('arabesk', 'Arabesk', Icons.mic),
      ('yerel', 'Yerel', Icons.location_on),
    ];

    Widget buildChip((String?, String, IconData) cat) {
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
              color: isSelected ? appBarFg : appBarFg.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? appBarFg : appBarFg.withValues(alpha: 0.18),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  cat.$3,
                  size: 13,
                  color: isSelected ? appBarBg : appBarFg,
                ),
                const SizedBox(width: 4),
                Text(
                  cat.$2,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? appBarBg : appBarFg,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 2, 0, 10),
      child: Row(
        children: [
          buildChip(categories[0]),
          Container(
            width: 1,
            height: 24,
            margin: const EdgeInsets.only(right: 6),
            color: appBarFg.withValues(alpha: 0.35),
          ),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.only(right: 8),
              child: Row(
                children: categories.skip(1).map(buildChip).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchHeader(Color headerFg) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          IconButton(
            style: IconButton.styleFrom(
              backgroundColor: Colors.transparent,
              foregroundColor: headerFg,
            ),
            onPressed: () {
              setState(() => _isSearchActive = false);
              _searchController.clear();
              ref.read(searchQueryProvider.notifier).state = '';
              _searchFocusNode.unfocus();
            },
            icon: Icon(Icons.arrow_back, color: headerFg),
          ),
          Expanded(
            child: TextField(
              controller: _searchController,
              focusNode: _searchFocusNode,
              onChanged: (val) =>
                  ref.read(searchQueryProvider.notifier).state = val,
              style: TextStyle(color: headerFg),
              decoration: InputDecoration(
                hintText: 'Ara...',
                hintStyle: TextStyle(
                  color: headerFg.withValues(alpha: 0.68),
                ),
                filled: true,
                fillColor: headerFg.withValues(alpha: 0.12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _resolveAppBarBg(ThemeData theme, String colorSchemeStr) {
    switch (colorSchemeStr) {
      case 'kanarya':
        return AppTheme.kanaryaSecondary;
      case 'aslan':
        return AppTheme.aslanRed;
      case 'karadeniz':
        return AppTheme.karadenizBordo;
      case 'kartal':
        return AppTheme.kartalBlack;
      case 'timsah':
        return AppTheme.timsahGreen;
      case 'sade':
        return AppTheme.sadeDarkGrey;
      case 'beyaz':
        return AppTheme.beyazBackgroundFull;
      default:
        return theme.appBarTheme.backgroundColor ?? theme.colorScheme.primary;
    }
  }

  Color _resolveAppBarFg(ThemeData theme, String colorSchemeStr) {
    switch (colorSchemeStr) {
      case 'kanarya':
        return AppTheme.kanaryaPrimary;
      case 'aslan':
        return AppTheme.aslanYellow;
      case 'karadeniz':
        return AppTheme.karadenizMavi;
      case 'kartal':
        return AppTheme.kartalWhite;
      case 'timsah':
        return AppTheme.timsahWhite;
      case 'sade':
        return AppTheme.sadeWhite;
      case 'beyaz':
        return AppTheme.beyazTextDark;
      default:
        return theme.appBarTheme.foregroundColor ?? theme.colorScheme.onPrimary;
    }
  }

  Color? _cardBackground(String colorSchemeStr) {
    switch (colorSchemeStr) {
      case 'kanarya':
        return AppTheme.kanaryaSecondary;
      case 'aslan':
        return AppTheme.aslanRed;
      case 'karadeniz':
        return AppTheme.karadenizBordo;
      case 'kartal':
        return AppTheme.kartalBlack;
      case 'timsah':
        return AppTheme.timsahGreen;
      case 'sade':
        return AppTheme.sadeWhite;
      case 'beyaz':
        return AppTheme.beyazCardGrey;
      case 'varsayilan':
        return Colors.white;
      default:
        return null;
    }
  }

  Color? _cardTitleColor(String colorSchemeStr) {
    switch (colorSchemeStr) {
      case 'kanarya':
        return AppTheme.kanaryaPrimary;
      case 'aslan':
        return AppTheme.aslanYellow;
      case 'karadeniz':
        return AppTheme.karadenizMavi;
      case 'kartal':
        return AppTheme.kartalWhite;
      case 'timsah':
        return AppTheme.timsahWhite;
      case 'varsayilan':
        return const Color(0xFF27314D);
      default:
        return null;
    }
  }

  Color? _cardSubtitleColor(String colorSchemeStr) {
    switch (colorSchemeStr) {
      case 'kanarya':
        return AppTheme.kanaryaPrimary.withValues(alpha: 0.9);
      case 'aslan':
        return AppTheme.aslanYellow.withValues(alpha: 0.9);
      case 'karadeniz':
        return AppTheme.karadenizMavi.withValues(alpha: 0.9);
      case 'kartal':
        return AppTheme.kartalWhite.withValues(alpha: 0.9);
      case 'timsah':
        return AppTheme.timsahGreen.withValues(alpha: 0.95);
      case 'varsayilan':
        return const Color(0xFF667085);
      default:
        return null;
    }
  }

  Color? _cardPlayButtonBg(String colorSchemeStr) {
    switch (colorSchemeStr) {
      case 'aslan':
        return AppTheme.aslanYellow;
      case 'karadeniz':
        return AppTheme.karadenizMavi;
      case 'kartal':
        return AppTheme.kartalWhite;
      case 'timsah':
        return AppTheme.timsahWhite;
      default:
        return null;
    }
  }

  Color? _cardPlayIconColor(String colorSchemeStr) {
    switch (colorSchemeStr) {
      case 'aslan':
        return Colors.black;
      case 'karadeniz':
        return AppTheme.karadenizBordo;
      case 'kartal':
        return AppTheme.kartalBlack;
      case 'timsah':
        return AppTheme.timsahGreen;
      default:
        return null;
    }
  }
}

