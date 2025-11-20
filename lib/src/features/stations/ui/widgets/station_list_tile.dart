import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/utils/snackbar_helper.dart';
import '../../../../core/theme/app_theme.dart';
import 'radio_station_card.dart';
import '../../domain/station_model.dart';
import '../../data/stations_provider.dart';
import '../../../player/data/player_provider.dart';
import '../../../player/domain/player_state_model.dart';
import '../../../favorites/data/favorites_provider.dart';

class StationListTile extends ConsumerWidget {
  final Station station;
  final VoidCallback? onPlayPressed;
  final VoidCallback? onTap;

  const StationListTile({
    super.key,
    required this.station,
    this.onPlayPressed,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playerState = ref.watch(playerStateProvider);
    final isCurrentStation = playerState.currentStation?.id == station.id;
    final isPlaying = isCurrentStation && playerState.isPlaying;
    final isLoading = isCurrentStation && playerState.isLoading;

    // Listen to errors and show snackbar
    ref.listen<PlayerStateModel>(playerStateProvider, (previous, next) {
      if (next.error != null && (previous?.error != next.error)) {
        AppSnackBar.showError(context, next.error!);
        // Clear error after showing
        Future.microtask(
            () => ref.read(playerStateProvider.notifier).clearError());
      }
    });

    return Container(
      // even smaller bottom gap so list items sit tighter
      margin: const EdgeInsets.only(bottom: 2),
      child: RadioStationCard(
        title: station.name,
        subtitle: station.genre ?? 'Radio',
        imageUrl: station.logoUrl,
        isPlaying: isPlaying,
        isFavorite: ref.watch(favoritesProvider).contains(station.id),
        onTap: () {
          if (isLoading) return;
          
          if (isCurrentStation && isPlaying) {
            ref.read(playerStateProvider.notifier).pause();
          } else {
            ref.read(playerStateProvider.notifier).playStation(station);
          }
        },
        onFavoriteToggle: () {
          ref.read(favoritesProvider.notifier).toggleFavorite(station.id);
        },
      ),
    );
  }
}
