import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../app/main_screen.dart';
import '../../../core/utils/snackbar_helper.dart';
import '../../../shared/providers/color_scheme_provider.dart';
import '../../../shared/providers/theme_provider.dart';
import '../../favorites/data/favorites_provider.dart';
import '../../legal/ui/impressum_screen.dart';
import '../../legal/ui/privacy_policy_screen.dart';
import '../../legal/ui/support_screen.dart';
import '../../legal/ui/terms_screen.dart';
import '../../stations/data/stations_provider.dart';
import '../data/app_settings_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const shareUrl =
        'https://play.google.com/store/apps/details?id=com.turkradyo.bsr.de.turkradyo';
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final themeMode = ref.watch(themeProvider);
    final appSettings = ref.watch(appSettingsProvider);

    final appBarBg =
        theme.appBarTheme.backgroundColor ?? theme.colorScheme.primary;
    final appBarFg =
        theme.appBarTheme.foregroundColor ?? theme.colorScheme.onPrimary;

    return Scaffold(
      extendBodyBehindAppBar: false,
      drawer: _buildDrawer(context, ref),
      body: Builder(
        builder: (builderContext) {
          return Container(
            color: appBarBg,
            child: Column(
              children: [
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
                    padding: EdgeInsets.fromLTRB(
                      16,
                      MediaQuery.of(context).padding.top + 12,
                      16,
                      16,
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            foregroundColor: appBarFg,
                          ),
                          icon: Icon(Icons.menu, color: appBarFg),
                          onPressed: () => Scaffold.of(builderContext).openDrawer(),
                        ),
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
                Expanded(
                  child: Container(
                    width: double.infinity,
                    color: theme.scaffoldBackgroundColor,
                    child: ListView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 20,
                      ),
                      children: [
                        _buildThemeSection(context, ref, themeMode),
                        const SizedBox(height: 24),
                        _buildAppSettingsSection(context, ref, appSettings),
                        const SizedBox(height: 24),
                        _buildColorSchemeSection(context, ref),
                        const SizedBox(height: 24),
                        _buildSupportSection(context),
                        const SizedBox(height: 24),
                        _buildLegalSection(context),
                        const SizedBox(height: 24),
                        _buildSettingsTile(
                          context,
                          'T\u00fcm Verileri Sil',
                          'Ayarlar ve ge\u00e7mi\u015fi temizle',
                          Icons.delete_forever_outlined,
                          () => _showDeleteAllDataDialog(context, ref),
                        ),
                        if (false)
                        _buildSettingsTile(
                          context,
                          'T\u00fcm Verileri Sil',
                          'Ayarlar ve ge\u00e7mi\u015fi temizle',
                          Icons.delete_forever_outlined,
                          () => _showDeleteAllDataDialog(context, ref),
                        ),
                        const SizedBox(height: 24),
                        _buildStoreActionsSection(context, shareUrl),
                        const SizedBox(height: 24),
                        if (false)
                        _buildSettingsTile(
                          context,
                          'T\u00fcm Verileri Sil',
                          'Ayarlar ve ge\u00e7mi\u015fi temizle',
                          Icons.delete_forever_outlined,
                          () => _showDeleteAllDataDialog(context, ref),
                        ),
                        if (false) const SizedBox(height: 24),
                        if (false)
                        _buildSettingsTile(
                          context,
                          'Uygulamay\u0131 Payla\u015f',
                          'Play Store linkini kopyala',
                          Icons.share_outlined,
                          () {
                            Clipboard.setData(
                              const ClipboardData(text: shareUrl),
                            );
                            SnackbarHelper.showSuccess(
                              context,
                              'Payla\u015f\u0131m linki panoya kopyaland\u0131',
                            );
                          },
                        ),
                        if (false) const SizedBox(height: 24),
                        if (false)
                        _buildSettingsTile(
                          context,
                          'Uygulamay\u0131 De\u011ferlendir',
                          'Play Store linkini kopyala',
                          Icons.star_outline_rounded,
                          () {
                            Clipboard.setData(
                              const ClipboardData(text: shareUrl),
                            );
                            SnackbarHelper.showSuccess(
                              context,
                              'De\u011ferlendirme linki panoya kopyaland\u0131',
                            );
                          },
                        ),
                        const SizedBox(height: 40),
                        Center(
                          child: Column(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Image.asset(
                                  'assets/images/icon.png',
                                  width: 72,
                                  height: 72,
                                  fit: BoxFit.contain,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Radyo T\u00fcneli',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'S\u00fcr\u00fcm 2.0.7',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: colorScheme.onSurface.withValues(
                                    alpha: 0.72,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 120),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionCard(BuildContext context, Widget child) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: child,
    );
  }

  Color _resolvedSectionIconColor(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final primary = colorScheme.primary;
    final onSurface = colorScheme.onSurface;
    final contrastGap =
        (primary.computeLuminance() - colorScheme.surface.computeLuminance())
            .abs();

    if (contrastGap < 0.24) {
      return onSurface.withValues(alpha: 0.86);
    }

    return Color.lerp(primary, onSurface, 0.18) ?? primary;
  }

  Widget _buildSectionHeader(
    BuildContext context,
    IconData icon,
    String title,
  ) {
    final theme = Theme.of(context);
    final iconColor = _resolvedSectionIconColor(context);
    return Row(
      children: [
        Icon(icon, color: iconColor, size: 24),
        const SizedBox(width: 12),
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildThemeSection(
    BuildContext context,
    WidgetRef ref,
    ThemeMode themeMode,
  ) {
    return _buildSectionCard(
      context,
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(context, Icons.palette_outlined, 'Tema Ayarlar\u0131'),
          const SizedBox(height: 16),
          _buildThemeOption(
            context,
            ref,
            'A\u00e7\u0131k Tema',
            ThemeMode.light,
            Icons.light_mode_outlined,
            themeMode,
          ),
          _buildThemeOption(
            context,
            ref,
            'Koyu Tema',
            ThemeMode.dark,
            Icons.dark_mode_outlined,
            themeMode,
          ),
          _buildThemeOption(
            context,
            ref,
            'Sistem Temas\u0131',
            ThemeMode.system,
            Icons.brightness_auto_outlined,
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
    ThemeMode mode,
    IconData icon,
    ThemeMode currentMode,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isSelected = currentMode == mode;
    final iconColor = _resolvedSectionIconColor(context);

    return InkWell(
      onTap: () => ref.read(themeProvider.notifier).setThemeMode(mode),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected
                  ? iconColor
                  : colorScheme.onSurface.withValues(alpha: 0.72),
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                color: isSelected ? iconColor : colorScheme.onSurface,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              ),
            ),
            const Spacer(),
            if (isSelected)
              Icon(Icons.check_circle, size: 20, color: iconColor),
          ],
        ),
      ),
    );
  }

  Widget _buildAppSettingsSection(
    BuildContext context,
    WidgetRef ref,
    AppSettings settings,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    return _buildSectionCard(
      context,
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            context,
            Icons.settings_suggest_outlined,
            'Uygulama Ayarlar\u0131',
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(
              'Otomatik Ba\u015flat',
              style: TextStyle(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Text(
              'Uygulama a\u00e7\u0131ld\u0131\u011f\u0131nda son radyoyu \u00e7al',
              style: TextStyle(
                color: colorScheme.onSurface.withValues(alpha: 0.72),
              ),
            ),
            value: settings.autoPlay,
            onChanged: (val) =>
                ref.read(appSettingsProvider.notifier).setAutoPlay(val),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              'Varsay\u0131lan Ses Seviyesi',
              style: TextStyle(
                fontSize: 14,
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Slider(
            value: settings.volume,
            min: 0.0,
            max: 1.0,
            divisions: 10,
            onChanged: (val) =>
                ref.read(appSettingsProvider.notifier).setVolume(val),
          ),
        ],
      ),
    );
  }

  Widget _buildColorSchemeSection(BuildContext context, WidgetRef ref) {
    return _buildSectionCard(
      context,
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(context, Icons.color_lens_outlined, 'Renk \u015eemas\u0131'),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _buildColorOption(context, ref, 'Varsay\u0131lan', 'purple', Colors.deepPurple),
              _buildColorOption(context, ref, 'Kanarya', 'kanarya', Colors.yellow),
              _buildColorOption(context, ref, 'Aslan', 'aslan', Colors.red),
              _buildColorOption(context, ref, 'Kartal', 'kartal', Colors.black),
              _buildColorOption(context, ref, 'Karadeniz', 'karadeniz', Colors.blue),
              _buildColorOption(context, ref, 'Timsah', 'timsah', Colors.green),
              _buildColorOption(context, ref, 'Sade', 'sade', const Color(0xFF3D3D3D)),
              _buildColorOption(context, ref, 'Beyaz', 'beyaz', Colors.white),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildColorOption(
    BuildContext context,
    WidgetRef ref,
    String name,
    String scheme,
    Color color,
  ) {
    final currentScheme = ref.watch(colorSchemeProvider);
    final isSelected = currentScheme == scheme;
    final textColor = Theme.of(context).colorScheme.onSurface;
    final ringColor = _resolvedSectionIconColor(context);

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
                color: isSelected ? ringColor : Colors.transparent,
                width: 3,
              ),
              boxShadow: [
                if (isSelected)
                  BoxShadow(
                    color: color.withValues(alpha: 0.5),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
              ],
            ),
            child: isSelected ? const Icon(Icons.check, color: Colors.white) : null,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          name,
          style: TextStyle(
            fontSize: 10,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: textColor,
          ),
        ),
      ],
    );
  }

  Widget _buildSupportSection(BuildContext context) {
    final theme = Theme.of(context);
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: theme.dividerColor.withValues(alpha: 0.5)),
        ),
        child: ExpansionTile(
          leading: Icon(
            Icons.support_agent_outlined,
            color: theme.primaryColor,
            size: 24,
          ),
          title: Text(
            'Destek & \u0130leti\u015fim',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          iconColor: theme.colorScheme.onSurface,
          collapsedIconColor: theme.colorScheme.onSurface,
          textColor: theme.colorScheme.onSurface,
          collapsedTextColor: theme.colorScheme.onSurface,
          initiallyExpanded: false,
          shape: const Border(),
          collapsedShape: const Border(),
          children: [
            _buildSettingsTile(
              context,
              'Destek & \u0130leti\u015fim',
              'E-posta, SSS ve hata bildirimi',
              Icons.headset_mic_outlined,
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SupportScreen()),
              ),
            ),
            _buildSettingsTile(
              context,
              'Hakk\u0131nda',
              'Radyo T\u00fcneli v2.0.4',
              Icons.info_outline,
              () => _showAboutDialog(context),
            ),
            const SizedBox(height: 4),
          ],
        ),
      ),
    );
  }

  Widget _buildLegalSection(BuildContext context) {
    final theme = Theme.of(context);
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: theme.dividerColor.withValues(alpha: 0.5)),
        ),
        child: ExpansionTile(
          leading: Icon(Icons.shield_outlined, color: theme.primaryColor, size: 24),
          title: Text(
            'Yasal & Gizlilik',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          iconColor: theme.colorScheme.onSurface,
          collapsedIconColor: theme.colorScheme.onSurface,
          textColor: theme.colorScheme.onSurface,
          collapsedTextColor: theme.colorScheme.onSurface,
          initiallyExpanded: false,
          shape: const Border(),
          collapsedShape: const Border(),
          children: [
            _buildSettingsTile(
              context,
              'Gizlilik Politikas\u0131',
              'Datenschutzerkl\u00e4rung',
              Icons.privacy_tip_outlined,
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen()),
              ),
            ),
            _buildSettingsTile(
              context,
              'Kullan\u0131m Ko\u015fullar\u0131',
              'Nutzungsbedingungen',
              Icons.description_outlined,
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const TermsScreen()),
              ),
            ),
            _buildSettingsTile(
              context,
              'Yasal Bilgiler (\u00a75 TMG)',
              'Impressum',
              Icons.gavel_outlined,
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ImpressumScreen()),
              ),
            ),
            const SizedBox(height: 4),
          ],
        ),
      ),
    );
  }

  Widget _buildMoreActionsSection(
    BuildContext context,
    WidgetRef ref,
    String shareUrl,
  ) {
    return _buildSectionCard(
      context,
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(context, Icons.apps_rounded, 'Di\u011fer'),
          const SizedBox(height: 12),
          _buildSettingsTile(
            context,
            'T\u00fcm Verileri Sil',
            'Ayarlar ve ge\u00e7mi\u015fi temizle',
            Icons.delete_forever_outlined,
            () => _showDeleteAllDataDialog(context, ref),
          ),
          _buildSettingsTile(
            context,
            'Uygulamay\u0131 Payla\u015f',
            'Play Store linkini kopyala',
            Icons.share_outlined,
            () {
              Clipboard.setData(ClipboardData(text: shareUrl));
              SnackbarHelper.showSuccess(
                context,
                'Payla\u015f\u0131m linki panoya kopyaland\u0131',
              );
            },
          ),
          _buildSettingsTile(
            context,
            'Uygulamay\u0131 De\u011ferlendir',
            'Play Store linkini kopyala',
            Icons.star_outline_rounded,
            () {
              Clipboard.setData(ClipboardData(text: shareUrl));
              SnackbarHelper.showSuccess(
                context,
                'De\u011ferlendirme linki panoya kopyaland\u0131',
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStoreActionsSection(BuildContext context, String shareUrl) {
    return _buildSectionCard(
      context,
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(context, Icons.apps_rounded, 'Di\u011fer'),
          const SizedBox(height: 12),
          _buildSettingsTile(
            context,
            'Uygulamay\u0131 Payla\u015f',
            'WhatsApp ve di\u011fer uygulamalarda payla\u015f',
            Icons.share_outlined,
            () async {
              await Share.share(shareUrl);
            },
          ),
          _buildSettingsTile(
            context,
            'Uygulamay\u0131 De\u011ferlendir',
            'Play Store sayfas\u0131n\u0131 a\u00e7',
            Icons.star_outline_rounded,
            () async {
              final opened = await launchUrl(
                Uri.parse(shareUrl),
                mode: LaunchMode.externalApplication,
              );
              if (!opened && context.mounted) {
                SnackbarHelper.showError(
                  context,
                  'Play Store linki a\u00e7\u0131lamad\u0131',
                );
              }
            },
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'Radyo T\u00fcneli',
      applicationVersion: '2.0.4',
      applicationLegalese: '\u00a9 2025 Radyo T\u00fcneli. T\u00fcm haklar\u0131 sakl\u0131d\u0131r.',
      children: const [
        SizedBox(height: 12),
        Text(
          'T\u00fcrk radyo istasyonlar\u0131n\u0131 dinlemek i\u00e7in geli\u015ftirilmi\u015f \u00fccretsiz bir uygulama.',
        ),
      ],
    );
  }

  Widget _buildSettingsTile(
    BuildContext context,
    String trTitle,
    String deTitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final iconColor = _resolvedSectionIconColor(context);

    return ListTile(
      leading: Icon(icon, color: iconColor),
      title: Text(
        trTitle,
        style: TextStyle(
          color: colorScheme.onSurface,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        deTitle,
        style: TextStyle(
          fontSize: 12,
          color: colorScheme.onSurface.withValues(alpha: 0.72),
        ),
      ),
      trailing: Icon(
        Icons.chevron_right,
        size: 20,
        color: colorScheme.onSurface.withValues(alpha: 0.72),
      ),
      onTap: onTap,
    );
  }

  void _showDeleteAllDataDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Verileri Sil'),
        content: const Text(
          'T\u00fcm favorileriniz ve ayarlar\u0131n\u0131z silinecek. Bu i\u015flem geri al\u0131namaz.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('\u0130PTAL'),
          ),
          TextButton(
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.clear();

              ref.invalidate(favoritesProvider);
              ref.invalidate(appSettingsProvider);
              ref.invalidate(recentlyPlayedNotifierProvider);
              ref.invalidate(actualRecentlyPlayedStationsProvider);

              if (context.mounted) {
                Navigator.pop(context);
                SnackbarHelper.showSuccess(
                  context,
                  'T\u00fcm veriler ba\u015far\u0131yla silindi',
                );
              }
            },
            child: const Text('S\u0130L', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final iconColor = _resolvedSectionIconColor(context);
    final drawerBg = Theme.of(context).appBarTheme.backgroundColor ??
        Theme.of(context).colorScheme.primary;
    final drawerFg = Theme.of(context).appBarTheme.foregroundColor ??
        Theme.of(context).colorScheme.onPrimary;

    return Drawer(
      backgroundColor: colorScheme.surface,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            height: 150,
            color: drawerBg,
            padding: const EdgeInsets.only(top: 50, left: 20),
            child: Text(
              'Radyo T\u00fcneli',
              style: TextStyle(color: drawerFg, fontSize: 24),
            ),
          ),
          ListTile(
            leading: Icon(Icons.home, color: iconColor),
            title: Text(
              'Ana Sayfa',
              style: TextStyle(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
            onTap: () {
              Navigator.pop(context);
              ref.read(selectedTabProvider.notifier).state = 0;
            },
          ),
          ListTile(
            leading: Icon(Icons.favorite, color: iconColor),
            title: Text(
              'Favoriler',
              style: TextStyle(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
            onTap: () {
              Navigator.pop(context);
              ref.read(selectedTabProvider.notifier).state = 1;
            },
          ),
          ListTile(
            leading: Icon(Icons.settings, color: iconColor),
            title: Text(
              'Ayarlar',
              style: TextStyle(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
            onTap: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}
