import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/snackbar_helper.dart';
import '../../player/data/recently_played_provider.dart';
import '../../stations/data/stations_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recentlyPlayedCount = ref.watch(recentlyPlayedProvider).length;
    final favoriteCount = ref.watch(favoriteStationsCountProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ayarlar'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Statistics Section
          _buildSectionHeader(context, 'İstatistikler'),
          _buildStatCard(
            context,
            'Favori İstasyonlar',
            favoriteCount.toString(),
            Icons.favorite,
            AppConstants.vibrantRed,
          ),
          const SizedBox(height: 12),
          _buildStatCard(
            context,
            'Son Çalınanlar',
            recentlyPlayedCount.toString(),
            Icons.history,
            AppConstants.primaryAccent,
          ),

          const SizedBox(height: 32),

          // Data Management Section
          _buildSectionHeader(context, 'Veri Yönetimi'),
          _buildSettingsTile(
            context,
            'Favorileri Temizle',
            'Tüm favori istasyonları kaldır',
            Icons.favorite_border,
            () => _clearFavorites(context, ref),
            isDestructive: true,
          ),
          _buildSettingsTile(
            context,
            'Geçmişi Temizle',
            'Son çalınan istasyonları temizle',
            Icons.history,
            () => _clearRecentlyPlayed(context, ref),
          ),

          const SizedBox(height: 32),

          // About Section
          _buildSectionHeader(context, 'Hakkında'),
          _buildSettingsTile(
            context,
            'Uygulama Sürümü',
            '1.0.0',
            Icons.info_outline,
            null,
          ),
          _buildSettingsTile(
            context,
            'Geliştirici',
            'Turkish Radio Team',
            Icons.code,
            null,
          ),
          _buildSettingsTile(
            context,
            'Geri Bildirim Gönder',
            'Önerilerinizi bizimle paylaşın',
            Icons.feedback_outlined,
            () => _showFeedbackDialog(context),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppConstants.primaryAccent,
            ),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppConstants.textSecondary,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    VoidCallback? onTap, {
    bool isDestructive = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: (isDestructive
                            ? AppConstants.vibrantRed
                            : AppConstants.primaryAccent)
                        .withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    icon,
                    color: isDestructive
                        ? AppConstants.vibrantRed
                        : AppConstants.primaryAccent,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: isDestructive
                                  ? AppConstants.vibrantRed
                                  : null,
                            ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppConstants.textSecondary,
                            ),
                      ),
                    ],
                  ),
                ),
                if (onTap != null)
                  Icon(
                    Icons.chevron_right,
                    color: AppConstants.textSecondary,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _clearFavorites(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppConstants.surface,
        title: const Text(
          'Favorileri Temizle',
          style: TextStyle(color: AppConstants.textPrimary),
        ),
        content: const Text(
          'Tüm favori istasyonları kaldırmak istediğinize emin misiniz? Bu işlem geri alınamaz.',
          style: TextStyle(color: AppConstants.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () {
              ref.read(favoriteNotifierProvider.notifier).clearAll();
              Navigator.of(context).pop();
              AppSnackBar.showSuccess(context, 'Tüm favoriler temizlendi');
            },
            child: const Text(
              'Temizle',
              style: TextStyle(color: AppConstants.vibrantRed),
            ),
          ),
        ],
      ),
    );
  }

  void _clearRecentlyPlayed(BuildContext context, WidgetRef ref) {
    ref.read(recentlyPlayedProvider.notifier).clearAll();
    AppSnackBar.showSuccess(context, 'Dinleme geçmişi temizlendi');
  }

  void _showFeedbackDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppConstants.surface,
        title: const Text(
          'Geri Bildirim',
          style: TextStyle(color: AppConstants.textPrimary),
        ),
        content: const Text(
          'Önerileriniz ve geri bildirimleriniz için teşekkürler! Lütfen app store\'da değerlendirme yapın veya destek ekibiyle iletişime geçin.',
          style: TextStyle(color: AppConstants.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }
}
