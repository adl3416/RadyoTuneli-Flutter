import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/providers/theme_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ayarlar'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildThemeSection(context, ref, themeMode),
          const Divider(height: 32),
                  children: [
          _buildThemeSection(context, ref, themeMode),
          const Divider(height: 32),
          _buildSettingsTile(
            context,
            'Otomatik Oynat',
            'Uygulamayı açarken son çalınan istasyonu oynat',
            Icons.autorenew,
            () {},
          ),
          _buildSettingsTile(
            context,
            'Bildirimler',
            'Oynatma bildirimleri ve kontroller',
            Icons.notifications_outlined,
            () {},
          ),,
          const Divider(height: 32),
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
          ref.read(themeProvider.notifier).setThemeMode(mode);
        },
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
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
}