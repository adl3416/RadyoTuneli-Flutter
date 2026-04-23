import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../shared/providers/theme_provider.dart';
import '../../../shared/providers/color_scheme_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../data/app_settings_provider.dart';
import '../../../core/utils/snackbar_helper.dart';
import '../../legal/ui/impressum_screen.dart';
import '../../legal/ui/privacy_policy_screen.dart';
import '../../legal/ui/terms_screen.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final appSettings = ref.watch(appSettingsProvider);
    final colorSchemeStr = ref.watch(colorSchemeProvider);

    Color appBarBg;
    Color appBarFg;

    if (colorSchemeStr == 'karadeniz') {
      appBarBg = AppTheme.karadenizBordo;
      appBarFg = AppTheme.karadenizMavi;
    } else if (colorSchemeStr == 'kartal') {
      appBarBg = AppTheme.kartalBlack;
      appBarFg = AppTheme.kartalWhite;
    } else if (colorSchemeStr == 'timsah') {
      appBarBg = AppTheme.timsahGreen;
      appBarFg = AppTheme.timsahWhite;
    } else if (colorSchemeStr == 'kanarya') {
      appBarBg = AppTheme.kanaryaSecondary;
      appBarFg = AppTheme.kanaryaPrimary;
    } else if (colorSchemeStr == 'aslan') {
      appBarBg = AppTheme.aslanRed;
      appBarFg = AppTheme.aslanYellow;
    } else {
      appBarBg = AppTheme.headerPurple;
      appBarFg = Colors.white;
    }
    
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        toolbarHeight: 0,
        backgroundColor: appBarBg,
        elevation: 0,
      ),
      body: Container(
        color: appBarBg,
        child: Column(
          children: [
            // --- HEADER BAŞLIĞI ---
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: appBarBg,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      'Ayarlar',
                      style: TextStyle(
                        color: appBarFg,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
              // --- AYARLAR LİSTESİ ---
              Expanded(
                child: Container(
                  width: double.infinity,
                  color: Theme.of(context).scaffoldBackgroundColor,
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                    children: [
                      _buildThemeSection(context, ref, themeMode),
                      const SizedBox(height: 24),
                      _buildAppSettingsSection(context, ref, appSettings),
                      const SizedBox(height: 24),
                      _buildColorSchemeSection(context, ref),
                      const Divider(height: 48),
                      
                      _buildSettingsTile(
                        context,
                        'Gizlilik Politikası',
                        'Datenschutzerklärung',
                        Icons.privacy_tip_outlined,
                        () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen())),
                      ),
                      _buildSettingsTile(
                        context,
                        'Yasal Bilgiler (§5 TMG)',
                        'Impressum',
                        Icons.gavel_outlined,
                        () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ImpressumScreen())),
                      ),
                      _buildSettingsTile(
                        context,
                        'Kullanım Koşulları',
                        'Nutzungsbedingungen',
                        Icons.description_outlined,
                        () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TermsScreen())),
                      ),
                      const Divider(height: 32),
                      _buildSettingsTile(
                        context,
                        'Tüm Verileri Sil',
                        'Favoriler, ayarlar ve geçmişi temizle',
                        Icons.delete_forever_outlined,
                        () => _showDeleteAllDataDialog(context, ref),
                      ),
                      const SizedBox(height: 8),
                      _buildSettingsTile(
                        context,
                        'Hakkında',
                        'Versiyon 1.0.0',
                        Icons.info_outline,
                        () {},
                      ),
                      const SizedBox(height: 120), // Bottom player payı
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
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
              Icon(Icons.palette_outlined, color: Theme.of(context).primaryColor, size: 24),
              const SizedBox(width: 12),
              Text('Tema Ayarları', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 16),
          _buildThemeOption(context, ref, 'Açık Tema', ThemeMode.light, Icons.light_mode_outlined, themeMode),
          _buildThemeOption(context, ref, 'Koyu Tema', ThemeMode.dark, Icons.dark_mode_outlined, themeMode),
          _buildThemeOption(context, ref, 'Sistem Teması', ThemeMode.system, Icons.brightness_auto_outlined, themeMode),
        ],
      ),
    );
  }

  Widget _buildThemeOption(BuildContext context, WidgetRef ref, String title, ThemeMode mode, IconData icon, ThemeMode currentMode) {
    final isSelected = currentMode == mode;
    return InkWell(
      onTap: () => ref.read(themeProvider.notifier).setThemeMode(mode),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Icon(icon, size: 20, color: isSelected ? Theme.of(context).primaryColor : null),
            const SizedBox(width: 12),
            Text(title, style: TextStyle(color: isSelected ? Theme.of(context).primaryColor : null, fontWeight: isSelected ? FontWeight.bold : null)),
            const Spacer(),
            if (isSelected) Icon(Icons.check_circle, size: 20, color: Theme.of(context).primaryColor),
          ],
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
              Icon(Icons.settings_suggest_outlined, color: Theme.of(context).primaryColor, size: 24),
              const SizedBox(width: 12),
              Text('Uygulama Ayarları', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            title: const Text('Otomatik Başlat'),
            subtitle: const Text('Uygulama açıldığında son radyoyu çal'),
            value: settings.autoPlay,
            onChanged: (val) => ref.read(appSettingsProvider.notifier).setAutoPlay(val),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text('Varsayılan Ses Seviyesi', style: TextStyle(fontSize: 14)),
          ),
          Slider(
            value: settings.volume,
            min: 0.0,
            max: 1.0,
            divisions: 10,
            onChanged: (val) => ref.read(appSettingsProvider.notifier).setVolume(val),
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
              Icon(Icons.color_lens_outlined, color: Theme.of(context).primaryColor, size: 24),
              const SizedBox(width: 12),
              Text('Renk Şeması', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _buildColorOption(context, ref, 'Varsayılan', 'purple', Colors.deepPurple),
              _buildColorOption(context, ref, 'Kanarya', 'kanarya', Colors.yellow),
              _buildColorOption(context, ref, 'Aslan', 'aslan', Colors.red),
              _buildColorOption(context, ref, 'Kartal', 'kartal', Colors.black),
              _buildColorOption(context, ref, 'Karadeniz', 'karadeniz', Colors.blue),
              _buildColorOption(context, ref, 'Timsah', 'timsah', Colors.green),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildColorOption(BuildContext context, WidgetRef ref, String name, String scheme, Color color) {
    final currentScheme = ref.watch(colorSchemeProvider);
    final isSelected = currentScheme == scheme;
    
    return Column(
        children: [
          InkWell(
            onTap: () => ref.read(colorSchemeProvider.notifier).setColorScheme(scheme),
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? Colors.white : Colors.transparent,
                  width: 3,
                ),
                boxShadow: [
                  if (isSelected) BoxShadow(color: color.withOpacity(0.5), blurRadius: 8, spreadRadius: 2),
                ],
              ),
              child: isSelected ? const Icon(Icons.check, color: Colors.white) : null,
            ),
          ),
          const SizedBox(height: 4),
          Text(name, style: TextStyle(fontSize: 10, fontWeight: isSelected ? FontWeight.bold : null)),
        ],
      );
  }

  Widget _buildSettingsTile(BuildContext context, String trTitle, String deTitle, IconData icon, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon),
      title: Text(trTitle),
      subtitle: Text(deTitle, style: const TextStyle(fontSize: 12)),
      trailing: const Icon(Icons.chevron_right, size: 20),
      onTap: onTap,
    );
  }

  void _showDeleteAllDataDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Verileri Sil'),
        content: const Text('Tüm favorileriniz ve ayarlarınız silinecek. Bu işlem geri alınamaz.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('İPTAL')),
          TextButton(
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.clear();
              if (context.mounted) {
                Navigator.pop(context);
                SnackbarHelper.showSuccess(context, 'Tüm veriler başarıyla silindi');
              }
            },
            child: const Text('SİL', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
