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
    final recentlyPlayedAsync = ref.watch(recentlyPlayedStationsProvider);
    final searchQuery = ref.watch(searchQueryProvider);

    return Scaffold(
      drawer: _buildDrawer(context),
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
                  // Empty space for symmetry
                  const SizedBox(width: 48),
                ],
              ),
            ),
            
            const SizedBox(height: 8),
            
            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: TextField(
                onChanged: (value) {
                  ref.read(searchQueryProvider.notifier).state = value;
                },
                decoration: InputDecoration(
                  hintText: 'Search for station, genre...',
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
                      'Recently Played',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        // TODO: Implement clear recently played
                      },
                      child: Text(
                        'Clear',
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
                height: 100,
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
                    child: Text('Error loading recent stations: $error'),
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
                        'Failed to load stations',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppTheme.gray500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        error.toString().contains('timeout') 
                            ? 'Connection timeout. Please check your internet.'
                            : 'Please check your internet connection and try again.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.gray500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () => ref.refresh(filteredStationsProvider),
                        icon: const Icon(Icons.refresh),
                        label: const Text('Retry'),
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
            'No stations found',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppTheme.gray500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try searching with different keywords',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppTheme.gray500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
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
            // Drawer Header
            DrawerHeader(
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
                children: [
                  // App Icon
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.all(8),
                      child: VintageRadioLogo(
                        size: 50,
                        primaryColor: Colors.white,
                        accentColor: Color(0xFFE5E7EB),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // App Name
                  Text(
                    'Radyo Tüneli',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Müziğin Renkli Dünyası',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
            
            // Menu Items
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
            _buildDrawerItem(
              context,
              icon: Icons.category_outlined,
              title: 'Kategoriler',
              onTap: () {
                Navigator.pop(context);
                // Navigate to categories if needed
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