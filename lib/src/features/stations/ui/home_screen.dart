import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/stations_provider.dart';
import 'widgets/recently_played_item.dart';
import '../../player/data/player_provider.dart';
import '../../player/ui/automotive_player_screen.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/vintage_radio_logo.dart';
import '../../favorites/data/favorites_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filteredStationsAsync = ref.watch(filteredStationsProvider);
    final recentlyPlayedAsync = ref.watch(actualRecentlyPlayedStationsProvider);
    final searchQuery = ref.watch(searchQueryProvider);
    final sortAtoZ = ref.watch(sortAtoZProvider);
    final selectedCategory = ref.watch(selectedCategoryProvider);

    return Scaffold(
      drawer: _buildDrawer(context, ref),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.headerPurple,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  // Drawer Button
                  Builder(
                    builder: (context) => IconButton(
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        Scaffold.of(context).openDrawer();
                      },
                      icon: const Icon(
                        Icons.menu,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  ),
                  // Title
                  Expanded(
                    child: Text(
                      'Radyo Tüneli',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  // A-Z Sort Button
                  Consumer(
                    builder: (context, ref, child) {
                      final sortAtoZ = ref.watch(sortAtoZProvider);
                      return IconButton(
                        onPressed: () {
                          HapticFeedback.mediumImpact();
                          ref.read(sortAtoZProvider.notifier).state = !sortAtoZ;
                        },
                        icon: Icon(
                          sortAtoZ ? Icons.sort_by_alpha : Icons.sort,
                          color: sortAtoZ ? Colors.white : Colors.white70,
                          size: 28,
                        ),
                        tooltip: sortAtoZ ? 'Normal Sıralama' : 'A-Z Sıralama',
                      );
                    },
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 2),
            
            // Selected Category Indicator
            Consumer(
              builder: (context, ref, child) {
                final selectedCategory = ref.watch(selectedCategoryProvider);
                if (selectedCategory == null) return const SizedBox.shrink();
                
                // Find category name from nested structure
                String categoryName = selectedCategory;
                for (final group in radioCategories.values) {
                  if (group.containsKey(selectedCategory)) {
                    categoryName = group[selectedCategory] ?? selectedCategory;
                    break;
                  }
                }
                
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Chip(
                    backgroundColor: AppTheme.cardPurple,
                    deleteIconColor: Colors.white,
                    onDeleted: () {
                      HapticFeedback.lightImpact();
                      ref.read(selectedCategoryProvider.notifier).state = null;
                    },
                    label: Text(
                      categoryName,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                );
              },
            ),
            
            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: TextField(
                onChanged: (value) {
                  ref.read(searchQueryProvider.notifier).state = value;
                },
                decoration: InputDecoration(
                  hintText: 'İstasyon, türü ara...',
                  prefixIcon: Icon(
                    Icons.search,
                    color: AppTheme.gray500,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppTheme.headerPurple, width: 2),
                  ),
                  suffixIcon: searchQuery.isNotEmpty
                      ? IconButton(
                          onPressed: () {
                            ref.read(searchQueryProvider.notifier).state = '';
                          },
                          icon: Icon(
                            Icons.clear,
                            color: AppTheme.headerPurple,
                          ),
                        )
                      : null,
                ),
              ),
            ),
            
            // Recently Played Section (only show if no search)
            if (searchQuery.isEmpty) ...[
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Son Dinlenenler',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        ref.read(recentlyPlayedNotifierProvider.notifier).clearRecent();
                      },
                      child: Text(
                        'Temizle',
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Recently Played List (Horizontal)
              SizedBox(
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
                        onTap: () {
                          ref.read(playerStateProvider.notifier).playStation(station);
                        },
                      );
                    },
                  ),
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (error, stack) => Center(
                    child: Text('Son dinlenen istasyonlar yüklenemedi: $error'),
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
            ],
            
            // Stations List
            Expanded(
              child: filteredStationsAsync.when(
                data: (filteredStations) {
                  if (filteredStations.isEmpty) {
                    return _buildEmptyState(context, searchQuery);
                  }
                  
                  return CustomScrollView(
                    slivers: [
                      // Section Title
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            searchQuery.isNotEmpty 
                                ? 'Search Results (${filteredStations.length})'
                                : 'All Stations (${filteredStations.length})',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      
                      const SliverToBoxAdapter(child: SizedBox(height: 16)),
                      
                      // List
                      SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final station = filteredStations[index];
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                              child: RadioStationCard(
                                title: station.name,
                                subtitle: station.genre ?? 'Turkish Radio',
                                imageUrl: station.logoUrl,
                                isPlaying: ref.watch(playerStateProvider).currentStation?.id == station.id &&
                                          ref.watch(playerStateProvider).isPlaying,
                                isFavorite: ref.watch(favoritesProvider).contains(station.id),
                                onTap: () {
                                  ref.read(playerStateProvider.notifier).playStation(station);
                                },
                                onFavoriteToggle: () {
                                  ref.read(favoritesProvider.notifier).toggleFavorite(station.id);
                                },
                              ),
                            );
                          },
                          childCount: filteredStations.length,
                        ),
                      ),
                    ],
                  );
                },
                loading: () => const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text(
                        'Loading Turkish radio stations...',
                        style: TextStyle(fontSize: 16),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'This might take a few moments',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                error: (error, stack) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: AppTheme.gray500,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'İstasyonlar yüklenemedi',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppTheme.gray500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        error.toString().contains('timeout') 
                            ? 'Bağlantı zaman aşımı. İnternet bağlantınızı kontrol edin.'
                            : 'İnternet bağlantınızı kontrol edip tekrar deneyin.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.gray500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () => ref.refresh(filteredStationsProvider),
                        icon: const Icon(Icons.refresh),
                        label: const Text('Tekrar Dene'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, String searchQuery) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: AppTheme.gray500,
          ),
          const SizedBox(height: 16),
          Text(
            'İstasyon bulunamadı',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppTheme.gray500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Farklı anahtar kelimelerle aramayı deneyin',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppTheme.gray500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer(BuildContext context, WidgetRef ref) {
    // Tek bir "Kategori Seç" başlığı altında tüm kategoriler ve alt kategoriler açılır olarak gösterilecek
    return Drawer(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.headerPurple,
              AppTheme.cardPurple,
              AppTheme.cardPurpleDark,
            ],
          ),
        ),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
              // Custom Header Container (DrawerHeader yerine)
              Container(
                width: double.infinity,
                height: 220,
                padding: const EdgeInsets.fromLTRB(16, 50, 16, 20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppTheme.headerPurple,
                      AppTheme.cardPurple,
                    ],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // App Icon
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.asset(
                            'assets/images/radio_logo.png',
                            width: 40,
                            height: 40,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    // App Name
                    Text(
                      'Radyo Tüneli',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Müziğin Renkli Dünyası',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
              _buildDrawerItem(
                context,
                icon: Icons.home_outlined,
                title: 'Ana Sayfa',
                onTap: () => Navigator.pop(context),
              ),
              _buildDrawerItem(
                context,
                icon: Icons.favorite_outline,
                title: 'Favoriler',
                onTap: () {
                  Navigator.pop(context);
                  // Navigate to favorites if needed
                },
              ),
              // Tek bir expandable ana kategori
              Consumer(
                builder: (context, ref, child) {
                  final expanded = ref.watch(expandedCategoriesProvider);
                  final isExpanded = expanded.contains('all_categories');
                  return Column(
                    children: [
                      _buildDrawerItem(
                        context,
                        icon: Icons.category,
                        title: 'Kategori Seç',
                        trailing: Icon(
                          isExpanded ? Icons.expand_less : Icons.expand_more,
                          color: Colors.white,
                        ),
                        onTap: () {
                          HapticFeedback.lightImpact();
                          final notifier = ref.read(expandedCategoriesProvider.notifier);
                          final current = Set<String>.from(notifier.state);
                          if (isExpanded) {
                            current.remove('all_categories');
                          } else {
                            current.add('all_categories');
                          }
                          notifier.state = current;
                        },
                      ),
                      if (isExpanded)
                        ...radioCategories.entries.expand((categoryGroup) {
                          final groupKey = categoryGroup.key;
                          final groupData = categoryGroup.value;
                          return groupData.entries
                            .where((entry) => entry.key != 'title')
                            .map((subCategory) => Padding(
                                  padding: const EdgeInsets.only(left: 32),
                                  child: _buildDrawerItem(
                                    context,
                                    icon: _getSubCategoryIcon(subCategory.key),
                                    title: subCategory.value,
                                    onTap: () {
                                      Navigator.pop(context);
                                      ref.read(selectedCategoryProvider.notifier).state = subCategory.key;
                                    },
                                  ),
                                ));
                        }).toList(),
                    ],
                  );
                },
              ),
              _buildDrawerItem(
                context,
                icon: Icons.clear_all,
                title: 'Tüm Kategoriler',
                onTap: () {
                  Navigator.pop(context);
                  ref.read(selectedCategoryProvider.notifier).state = null;
                },
              ),
              _buildDrawerItem(
                context,
                icon: Icons.history_outlined,
                title: 'Son Çalınanlar',
                onTap: () {
                  Navigator.pop(context);
                  // Show recently played
                },
              ),
              // Divider
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Divider(
                  color: Colors.white.withOpacity(0.3),
                ),
              ),
              _buildDrawerItem(
                context,
                icon: Icons.car_rental_outlined,
                title: 'Android Auto',
                onTap: () {
                  Navigator.pop(context);
                  // Navigate to automotive screen
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AutomotivePlayerScreen(),
                    ),
                  );
                },
              ),
              _buildDrawerItem(
                context,
                icon: Icons.settings_outlined,
                title: 'Ayarlar',
                onTap: () {
                  Navigator.pop(context);
                  // Navigate to settings
                },
              ),
              _buildDrawerItem(
                context,
                icon: Icons.info_outline,
                title: 'Hakkında',
                onTap: () {
                  Navigator.pop(context);
                  _showAboutDialog(context);
                },
              ),
            ],
          ),
        ),
      );
  }

  Widget _buildDrawerItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Widget? trailing,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: Colors.white,
        size: 24,
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: trailing,
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  IconData _getCategoryIcon(String categoryKey) {
    switch (categoryKey) {
      case 'muzik':
        return Icons.music_note;
      case 'haber_spor':
        return Icons.newspaper;
      case 'yasam':
        return Icons.people;
      default:
        return Icons.category;
    }
  }

  IconData _getSubCategoryIcon(String subCategoryKey) {
    switch (subCategoryKey) {
      case 'pop':
        return Icons.star;
      case 'rock':
        return Icons.music_note;
      case 'arabesk':
        return Icons.music_note_sharp;
      case 'turku':
        return Icons.piano;
      case '90lar':
        return Icons.library_music;
      case 'klasik':
        return Icons.music_note_outlined;
      case 'jazz':
        return Icons.album;
      case 'elektronik':
        return Icons.graphic_eq;
      case 'haber':
        return Icons.article;
      case 'spor':
        return Icons.sports_soccer;
      case 'ekonomi':
        return Icons.trending_up;
      case 'siyaset':
        return Icons.account_balance;
      case 'cocuk':
        return Icons.child_care;
      case 'dini':
        return Icons.mosque;
      case 'yerel':
        return Icons.location_city;
      case 'saglik':
        return Icons.medical_services;
      case 'egitim':
        return Icons.school;
      default:
        return Icons.radio;
    }
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardPurple,
        title: Row(
          children: [
            Icon(
              Icons.radio,
              color: Colors.white,
            ),
            const SizedBox(width: 8),
            Text(
              'Radyo Tüneli',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
        content: Text(
          'Türkiye\'nin en iyi radyo istasyonlarını dinleyebileceğiniz modern radyo uygulaması.\n\n'
          'Özellikler:\n'
          '• 15+ Radyo İstasyonu\n'
          '• 7 Farklı Kategori\n'
          '• Android Auto / CarPlay Desteği\n'
          '• Haptic Feedback\n'
          '• Modern Mor Tema',
          style: TextStyle(color: Colors.white.withOpacity(0.9)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Tamam',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}