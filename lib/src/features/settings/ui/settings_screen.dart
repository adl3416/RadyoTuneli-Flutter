import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/providers/theme_provider.dart';
import '../../../shared/providers/color_scheme_provider.dart';
import '../../../core/widgets/banner_ad_widget.dart';
import '../data/app_settings_provider.dart';
import '../../../core/utils/snackbar_helper.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final appSettings = ref.watch(appSettingsProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ayarlar'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildThemeSection(context, ref, themeMode),
          const Divider(height: 32),
          _buildAppSettingsSection(context, ref, appSettings),
          const Divider(height: 32),
          _buildColorSchemeSection(context, ref),
          const Divider(height: 32),
          
          // Banner Ad
          const SmallBannerAdWidget(),
          const SizedBox(height: 16),
          
          _buildSettingsTile(
            context,
            'Hakkında',
            'Versiyon 1.0.0',
            Icons.info_outline,
            () {},
          ),
          _buildSettingsTile(
            context,
            'Destek',
            'Sorun bildir veya öneride bulun',
            Icons.support_outlined,
            () {},
          ),
        ],
      ),
    );
  }

  Widget _buildThemeSection(BuildContext context, WidgetRef ref, ThemeMode themeMode) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.palette_outlined,
                color: Theme.of(context).primaryColor,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Tema Ayarları',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildThemeOption(
            context,
            ref,
            'Sistem Ayarı',
            'Cihazın tema ayarını takip et',
            Icons.phone_android,
            ThemeMode.system,
            themeMode,
          ),
          const SizedBox(height: 8),
          _buildThemeOption(
            context,
            ref,
            'Açık Tema',
            'Her zaman açık tema kullan',
            Icons.light_mode,
            ThemeMode.light,
            themeMode,
          ),
          const SizedBox(height: 8),
          _buildThemeOption(
            context,
            ref,
            'Koyu Tema',
            'Her zaman koyu tema kullan',
            Icons.dark_mode,
            ThemeMode.dark,
            themeMode,
          ),
        ],
      ),
    );
  }

  Widget _buildThemeOption(
    BuildContext context,
    WidgetRef ref,
    String title,
    String subtitle,
    IconData icon,
    ThemeMode mode,
    ThemeMode currentMode,
  ) {
    final isSelected = currentMode == mode;
    
    return Container(
      decoration: BoxDecoration(
        color: isSelected 
            ? Theme.of(context).primaryColor.withOpacity(0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isSelected 
              ? Theme.of(context).primaryColor
              : Theme.of(context).iconTheme.color,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isSelected 
                ? Theme.of(context).primaryColor
                : Theme.of(context).textTheme.bodyLarge?.color,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: isSelected 
                ? Theme.of(context).primaryColor.withOpacity(0.7)
                : Theme.of(context).textTheme.bodyMedium?.color,
          ),
        ),
        trailing: isSelected
            ? Icon(
                Icons.check_circle,
                color: Theme.of(context).primaryColor,
              )
            : const Icon(Icons.circle_outlined),
        onTap: () {
          print('🎨 Theme button tapped: $mode');
          ref.read(themeProvider.notifier).setThemeMode(mode);
        },
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildAppSettingsSection(BuildContext context, WidgetRef ref, AppSettings settings) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.settings_outlined,
                color: Theme.of(context).primaryColor,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Uygulama Ayarları',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
                    // Otomatik Oynat
          _buildSwitchTile(
            context,
            'Otomatik Oynat',
            'Uygulamayı açarken son çalınan istasyonu oynat',
            Icons.autorenew,
            settings.autoPlay,
            (value) {
              _handleAutoPlayToggle(ref, context, value);
            },
          ),
          
          const SizedBox(height: 8),
          
          // Bildirimler
          _buildSwitchTile(
            context,
            'Bildirimler',
            'Oynatma bildirimleri ve kontroller',
            Icons.notifications_outlined,
            settings.notificationsEnabled,
            (value) {
              _handleNotificationsToggle(ref, context, value);
            },
          ),
          
          const SizedBox(height: 8),
          
          // Kilit Ekranı Kontrolleri
          _buildSwitchTile(
            context,
            'Kilit Ekranı Kontrolleri',
            'Telefon kilitliyken oynatma kontrolleri göster',
            Icons.lock_outline,
            settings.showLockScreenControls,
            (value) {
              _handleLockScreenToggle(ref, context, value);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildColorSchemeSection(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.palette_outlined,
                color: Theme.of(context).primaryColor,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Farklı Temalar',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Takım Temasını Seç',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 12),
          // Kanarya Teması seçimi
          InkWell(
            onTap: () {
              _showKanaryaThemeOptions(context, ref);
            },
            borderRadius: BorderRadius.circular(12),
            child: _buildColorSchemeOption(
              context,
              'Kanarya',
              '🟡 Sarı-Lacivert',
              const Color(0xFFFFD700),
              const Color(0xFF001F3F),
            ),
          ),
        ],
      ),
    );
  }

  void _showKanaryaThemeOptions(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '🟡 Kanarya Teması Ayarları',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            _buildThemeOptionTile(
              context,
              'Sarı Yoğunluğu',
              'Navigation bar sarı tonu seç',
              Icons.brightness_high,
              ['Açık', 'Normal', 'Koyu'],
              0,
            ),
            const SizedBox(height: 16),
            _buildThemeOptionTile(
              context,
              'Lacivert Yoğunluğu',
              'Tab bar lacivert tonu seç',
              Icons.brightness_4,
              ['Açık', 'Normal', 'Koyu'],
              0,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Kanarya temasını aktif et
                  ref.read(colorSchemeProvider.notifier).setColorScheme('kanarya');
                  SnackbarHelper.showSuccess(context, '🟡 Kanarya Teması Aktif!');
                  Navigator.pop(context);
                },
                child: const Text('Tamam'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeOptionTile(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    List<String> options,
    int selectedIndex,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 36,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: options.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final isSelected = index == selectedIndex;
                return InkWell(
                  onTap: () {
                    print('Selected: ${options[index]}');
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Theme.of(context).primaryColor
                          : Theme.of(context).colorScheme.surface,
                      border: Border.all(
                        color: isSelected
                            ? Theme.of(context).primaryColor
                            : Theme.of(context).dividerColor,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        options[index],
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : Theme.of(context).textTheme.bodySmall?.color,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColorSchemeOption(
    BuildContext context,
    String name,
    String displayName,
    Color primaryColor,
    Color secondaryColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: primaryColor.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              gradient: LinearGradient(
                colors: [primaryColor, secondaryColor],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayName,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Primary: ${primaryColor.value.toRadixString(16)} | Secondary: ${secondaryColor.value.toRadixString(16)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.6),
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: Theme.of(context).primaryColor,
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchTile(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    bool value,
    Function(bool) onChanged,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: value 
            ? Theme.of(context).primaryColor.withOpacity(0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: SwitchListTile(
        secondary: Icon(
          icon,
          color: value 
              ? Theme.of(context).primaryColor
              : Theme.of(context).iconTheme.color,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: value 
                ? Theme.of(context).primaryColor
                : Theme.of(context).textTheme.bodyLarge?.color,
            fontWeight: value ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: value 
                ? Theme.of(context).primaryColor.withOpacity(0.7)
                : Theme.of(context).textTheme.bodySmall?.color,
          ),
        ),
        value: value,
        onChanged: onChanged,
        activeColor: Theme.of(context).primaryColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildSettingsTile(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  void _handleAutoPlayToggle(WidgetRef ref, BuildContext context, bool value) async {
    try {
      await ref.read(appSettingsProvider.notifier).setAutoPlay(value);
      if (context.mounted) {
        if (value) {
          SnackbarHelper.showSuccess(
            context,
            'Otomatik oynat açıldı. Uygulamayı tekrar açtığınızda son çalınan istasyon otomatik başlayacak.',
          );
        } else {
          SnackbarHelper.showInfo(
            context,
            'Otomatik oynat kapatıldı.',
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        SnackbarHelper.showError(context, 'Ayar değiştirilemedi: $e');
      }
    }
  }

  void _handleNotificationsToggle(WidgetRef ref, BuildContext context, bool value) async {
    try {
      await ref.read(appSettingsProvider.notifier).setNotifications(value);
      if (context.mounted) {
        if (value) {
          SnackbarHelper.showSuccess(
            context,
            'Bildirimler açıldı. Artık oynatma kontrolleri görünecek.',
          );
        } else {
          SnackbarHelper.showInfo(
            context,
            'Bildirimler kapatıldı.',
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        SnackbarHelper.showError(context, 'Ayar değiştirilemedi: $e');
      }
    }
  }

  void _handleLockScreenToggle(WidgetRef ref, BuildContext context, bool value) async {
    try {
      await ref.read(appSettingsProvider.notifier).setLockScreenControls(value);
      if (context.mounted) {
        if (value) {
          SnackbarHelper.showSuccess(
            context,
            'Kilit ekranı kontrolleri açıldı. Telefon kilitken de oynatma kontrolleri görünecek.',
          );
        } else {
          SnackbarHelper.showInfo(
            context,
            'Kilit ekranı kontrolleri kapatıldı.',
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        SnackbarHelper.showError(context, 'Ayar değiştirilemedi: $e');
      }
    }
  }
}