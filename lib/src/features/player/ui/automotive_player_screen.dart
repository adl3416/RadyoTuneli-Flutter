import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../stations/domain/station_model.dart';
import '../data/player_provider.dart';

class AutomotivePlayerScreen extends ConsumerWidget {
  const AutomotivePlayerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playerState = ref.watch(playerStateProvider);
    
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              // Header
              Row(
                children: [
                  Icon(
                    Icons.radio,
                    color: AppTheme.orange400,
                    size: 32,
                  ),
                  const SizedBox(width: 16),
                  Text(
                    'Radyo Tüneli',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'ARABA MODU',
                    style: TextStyle(
                      color: AppTheme.orange400,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 40),
              
              // Current Station Display
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppTheme.orange400.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: Column(
                  children: [
                    // Station Logo
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: AppTheme.orange400.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        Icons.radio,
                        color: AppTheme.orange400,
                        size: 60,
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Station Name
                    Text(
                      playerState.currentStation?.name ?? 'Radyo Seçiniz',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // Station Description
                    Text(
                      playerState.currentStation?.artist ?? 'Radyo çalmıyor',
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Status Indicator
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: playerState.isPlaying 
                            ? AppTheme.orange400.withOpacity(0.2)
                            : Colors.grey[800],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            playerState.isPlaying 
                                ? Icons.play_arrow
                                : playerState.isLoading
                                    ? Icons.sync
                                    : Icons.pause,
                            color: playerState.isPlaying 
                                ? AppTheme.orange400
                                : Colors.grey[400],
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            playerState.isPlaying
                                ? 'ÇALIYOR'
                                : playerState.isLoading
                                    ? 'YÜKLENİYOR'
                                    : 'DURAKLATILDI',
                            style: TextStyle(
                              color: playerState.isPlaying 
                                  ? AppTheme.orange400
                                  : Colors.grey[400],
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 40),
              
              // Large Control Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Previous Button
                  _buildLargeButton(
                    icon: Icons.skip_previous,
                    label: 'ÖNCEKİ',
                    onPressed: () {
                      HapticFeedback.mediumImpact();
                      // TODO: Implement previous station
                    },
                  ),
                  
                  // Play/Pause Button
                  _buildLargeButton(
                    icon: playerState.isPlaying 
                        ? Icons.pause
                        : playerState.isLoading
                            ? Icons.sync
                            : Icons.play_arrow,
                    label: playerState.isPlaying ? 'DURAKLAT' : 'ÇALIŞ',
                    isPrimary: true,
                    onPressed: () {
                      HapticFeedback.heavyImpact();
                      if (playerState.isPlaying) {
                        ref.read(playerStateProvider.notifier).pause();
                      } else {
                        // Resume if paused, or play first station if none selected
                        if (playerState.currentStation != null) {
                          ref.read(playerStateProvider.notifier).resume();
                        } else {
                          // TODO: Play first available station
                        }
                      }
                    },
                  ),
                  
                  // Next Button
                  _buildLargeButton(
                    icon: Icons.skip_next,
                    label: 'SONRAKİ',
                    onPressed: () {
                      HapticFeedback.mediumImpact();
                      // TODO: Implement next station
                    },
                  ),
                ],
              ),
              
              const Spacer(),
              
              // Bottom Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildSmallButton(
                    icon: Icons.list,
                    label: 'İSTASYONLAR',
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      Navigator.pop(context);
                    },
                  ),
                  _buildSmallButton(
                    icon: Icons.favorite,
                    label: 'FAVORİLER',
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      // TODO: Show favorites
                    },
                  ),
                  _buildSmallButton(
                    icon: Icons.volume_up,
                    label: 'SES',
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      // TODO: Volume control
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLargeButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    bool isPrimary = false,
  }) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: isPrimary ? AppTheme.orange400 : Colors.grey[800],
            borderRadius: BorderRadius.circular(16),
            boxShadow: isPrimary ? [
              BoxShadow(
                color: AppTheme.orange400.withOpacity(0.3),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ] : null,
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onPressed,
              borderRadius: BorderRadius.circular(16),
              child: Icon(
                icon,
                color: isPrimary ? Colors.black : Colors.white,
                size: 36,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          label,
          style: TextStyle(
            color: isPrimary ? AppTheme.orange400 : Colors.grey[400],
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildSmallButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: Colors.grey[800],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onPressed,
              borderRadius: BorderRadius.circular(12),
              child: Icon(
                icon,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[400],
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}