import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../data/stations_provider.dart';
import 'widgets/station_list_tile.dart';
import 'widgets/recently_played_item.dart';
import '../../player/data/player_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filteredStationsAsync = ref.watch(filteredStationsProvider);
    final recentlyPlayedAsync = ref.watch(recentlyPlayedStationsProvider);
    final searchQuery = ref.watch(searchQueryProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              child: Text(
                'Türk Radyosu',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            
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
                    color: AppConstants.textSecondary,
                  ),
                  suffixIcon: searchQuery.isNotEmpty
                      ? IconButton(
                          onPressed: () {
                            ref.read(searchQueryProvider.notifier).state = '';
                          },
                          icon: Icon(
                            Icons.clear,
                            color: AppConstants.textSecondary,
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
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: StationListTile(
                                station: station,
                                onPlayPressed: () {
                                  ref.read(playerStateProvider.notifier).playStation(station);
                                },
                                onTap: () {
                                  // TODO: Navigate to player screen
                                  print('Station tapped: ${station.name}');
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
                        color: AppConstants.textSecondary,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Failed to load stations',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppConstants.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        error.toString().contains('timeout') 
                            ? 'Connection timeout. Please check your internet.'
                            : 'Please check your internet connection and try again.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppConstants.textSecondary,
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
            color: AppConstants.textSecondary,
          ),
          const SizedBox(height: 16),
          Text(
            'No stations found',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppConstants.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try searching with different keywords',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppConstants.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}