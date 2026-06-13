import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../app/main_screen.dart';
import '../../../core/services/update_service.dart';
import '../../../core/utils/snackbar_helper.dart';
import '../../../shared/providers/color_scheme_provider.dart';
import '../../../shared/providers/theme_provider.dart';
import '../../favorites/data/favorites_provider.dart';
import '../../legal/ui/impressum_screen.dart';
import '../../legal/ui/privacy_policy_screen.dart';
import '../../legal/ui/support_screen.dart';
import '../../legal/ui/terms_screen.dart';
import '../../player/data/player_provider.dart';
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
    final updateStatusAsync = ref.watch(appUpdateStatusProvider);

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
                    color: Theme.of(context).colorScheme.surface,
                    child: ListView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 20,
                      ),
                      children: [
                        _buildAppSettingsSection(context, ref, appSettings),
                        const SizedBox(height: 24),
                        _buildUpdateSection(
                          context,
                          ref,
                          updateStatusAsync,
                          shareUrl,
                        ),
                        const SizedBox(height: 24),
                        _buildColorSchemeSection(context, ref),
                        const SizedBox(height: 24),
                        _buildSupportSection(context),
                        const SizedBox(height: 24),
                        _buildLegalSection(context),
                        const SizedBox(height: 24),
                        _buildStoreActionsSection(context, shareUrl),
                        const SizedBox(height: 24),
                        _buildSectionCard(
                          context,
                          _buildSettingsTile(
                            context,
                            'T\u00fcm Verileri Sil',
                            'Ayarlar ve ge\u00e7mi\u015fi temizle',
                            Icons.delete_forever_outlined,
                            () => _showDeleteAllDataDialog(context, ref),
                            Colors.red,
                          ),
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

  Widget _buildSectionCard(
    BuildContext context,
    Widget child, {
    Color? backgroundColor,
    bool showBorder = true,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor ??
            (isDark
                ? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4)
                : (theme.cardTheme.color ?? const Color(0xFFF8F9FA))),
        borderRadius: BorderRadius.circular(20),
        border: showBorder ? Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.04),
          width: 1,
        ) : null,
        boxShadow: isDark ? null : [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  Color _resolvedSectionIconColor(BuildContext context, [Color? preferredColor]) {
    if (preferredColor != null && Theme.of(context).brightness == Brightness.light) {
      return preferredColor;
    }
    
    final colorScheme = Theme.of(context).colorScheme;
    return colorScheme.primary;
  }

  Widget _buildSectionHeader(
    BuildContext context,
    IconData icon,
    String title, [
    Color? color,
  ]) {
    final theme = Theme.of(context);
    final iconColor = _resolvedSectionIconColor(context, color);
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
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
          _buildSectionHeader(context, Icons.palette_outlined, 'Tema Ayarlar\u0131', Colors.amber[700]),
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
    final iconColor = _resolvedSectionIconColor(context, Colors.amber[700]);

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
    final selectedSleepMinutes = ref.watch(sleepTimerMinutesProvider);
    const sleepOptions = [15, 30, 45, 60, 90];
    final sectionColor = Colors.teal[600];

    return _buildSectionCard(
      context,
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            context,
            Icons.settings_suggest_outlined,
            'Uygulama Ayarlar\u0131',
            sectionColor,
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            activeColor: sectionColor,
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
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            activeColor: sectionColor,
            title: Text(
              'Yumusak gecis',
              style: TextStyle(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Text(
              'Istasyon degisirken sesi kisa surede azaltip yeniden ac',
              style: TextStyle(
                color: colorScheme.onSurface.withValues(alpha: 0.72),
              ),
            ),
            value: settings.smoothTransitions,
            onChanged: (val) => ref
                .read(appSettingsProvider.notifier)
                .setSmoothTransitions(val),
          ),
          const SizedBox(height: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.timer_outlined, size: 18, color: sectionColor),
                  const SizedBox(width: 8),
                  Text(
                    'Uyku Modu',
                    style: TextStyle(
                      fontSize: 14,
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).brightness == Brightness.light 
                            ? Colors.white 
                            : colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: colorScheme.onSurface.withValues(alpha: 0.08),
                        ),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<int?>(
                          value: selectedSleepMinutes,
                          isExpanded: true,
                          borderRadius: BorderRadius.circular(12),
                          dropdownColor: Theme.of(context).colorScheme.surface,
                          icon: const Icon(Icons.keyboard_arrow_down_rounded),
                          items: [
                            const DropdownMenuItem<int?>(
                              value: null,
                              child: Text('Kapalı'),
                            ),
                            for (final minutes in sleepOptions)
                              DropdownMenuItem<int?>(
                                value: minutes,
                                child: Text('$minutes dakika'),
                              ),
                          ],
                          onChanged: (value) {
                            final notifier =
                                ref.read(playerStateProvider.notifier);
                            if (value == null) {
                              notifier.clearSleepTimer();
                            } else {
                              notifier.setSleepTimer(value);
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  FilledButton.icon(
                    onPressed: () {
                      final notifier = ref.read(playerStateProvider.notifier);
                      if (selectedSleepMinutes == null) {
                        notifier.setSleepTimer(15);
                      } else {
                        notifier.clearSleepTimer();
                      }
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: selectedSleepMinutes == null ? sectionColor : Colors.red[400],
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: Icon(
                      selectedSleepMinutes == null
                          ? Icons.play_arrow_rounded
                          : Icons.stop_rounded,
                      size: 20,
                    ),
                    label: Text(
                      selectedSleepMinutes == null ? 'Başlat' : 'Durdur',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildColorSchemeSection(BuildContext context, WidgetRef ref) {
    final currentScheme = ref.watch(colorSchemeProvider);
    
    return _buildSectionCard(
      context,
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            context,
            Icons.color_lens_outlined,
            'Renk Temas\u0131',
            Colors.deepPurple,
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 80,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildColorSchemeOption(
                  context,
                  ref,
                  'Varsay\u0131lan',
                  'varsayilan',
                  const Color(0xFF7B56F5),
                  currentScheme == 'varsayilan',
                ),
                _buildColorSchemeOption(
                  context,
                  ref,
                  'Beyaz',
                  'beyaz',
                  Colors.white,
                  currentScheme == 'beyaz',
                ),
                _buildColorSchemeOption(
                  context,
                  ref,
                  'Kanarya',
                  'kanarya',
                  const Color(0xFFFFD700),
                  currentScheme == 'kanarya',
                ),
                _buildColorSchemeOption(
                  context,
                  ref,
                  'Aslan',
                  'aslan',
                  const Color(0xFFFDB813),
                  currentScheme == 'aslan',
                ),
                _buildColorSchemeOption(
                  context,
                  ref,
                  'Kartal',
                  'kartal',
                  const Color(0xFF000000),
                  currentScheme == 'kartal',
                ),
                _buildColorSchemeOption(
                  context,
                  ref,
                  'Timsah',
                  'timsah',
                  const Color(0xFF228B22),
                  currentScheme == 'timsah',
                ),
                _buildColorSchemeOption(
                  context,
                  ref,
                  'F\u0131rt\u0131na',
                  'karadeniz',
                  const Color(0xFF800000),
                  currentScheme == 'karadeniz',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpdateSection(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<UpdateStatus> updateStatusAsync,
    String playStoreUrl,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final sectionColor = Colors.blue[700];

    return _buildSectionCard(
      context,
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            context,
            Icons.system_update_alt_rounded,
            'Guncelleme',
            sectionColor,
          ),
          const SizedBox(height: 16),
          updateStatusAsync.when(
            loading: () => ListTile(
              contentPadding: EdgeInsets.zero,
              leading: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2.2,
                  color: sectionColor,
                ),
              ),
              title: Text(
                'Guncellemeler kontrol ediliyor',
                style: TextStyle(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Text(
                'Google Play durumu sorgulaniyor',
                style: TextStyle(
                  color: colorScheme.onSurface.withValues(alpha: 0.65),
                ),
              ),
            ),
            error: (_, __) => _buildSettingsTile(
              context,
              'Guncelleme kontrol edilemedi',
              'Tekrar denemek icin dokunun',
              Icons.refresh_rounded,
              () => ref.invalidate(appUpdateStatusProvider),
              sectionColor,
            ),
            data: (status) {
              final actionLabel = status.isDownloaded
                  ? 'Kur'
                  : (status.actionType == UpdateActionType.playStoreFallback
                      ? 'Play Store\'u Ac'
                      : 'Guncelle');
              final detailParts = <String>[
                if (status.availableVersionCode != null)
                  'Surum kodu: ${status.availableVersionCode}',
                if (status.stalenessDays != null)
                  '${status.stalenessDays} gundur mevcut',
              ];

              return Column(
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: (status.isUpdateAvailable
                                ? Colors.orange
                                : sectionColor!)
                            .withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        status.isUpdateAvailable
                            ? Icons.notification_important_outlined
                            : Icons.verified_outlined,
                        color: status.isUpdateAvailable
                            ? Colors.orange[700]
                            : sectionColor,
                        size: 22,
                      ),
                    ),
                    title: Text(
                      status.isUpdateAvailable
                          ? 'Yeni guncelleme bulundu'
                          : 'Uygulama guncel',
                      style: TextStyle(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        [
                          status.message,
                          if (detailParts.isNotEmpty) detailParts.join(' • '),
                        ].join('\n'),
                        style: TextStyle(
                          color: colorScheme.onSurface.withValues(alpha: 0.68),
                          height: 1.35,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => ref.invalidate(appUpdateStatusProvider),
                          icon: const Icon(Icons.refresh_rounded, size: 18),
                          label: const Text('Yenile'),
                        ),
                      ),
                      if (status.isUpdateAvailable && status.canTriggerUpdate) ...[
                        const SizedBox(width: 12),
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: () async {
                              if (status.actionType ==
                                  UpdateActionType.playStoreFallback) {
                                final opened = await launchUrl(
                                  Uri.parse(playStoreUrl),
                                  mode: LaunchMode.externalApplication,
                                );
                                if (!opened && context.mounted) {
                                  SnackbarHelper.showError(
                                    context,
                                    'Play Store acilamadi',
                                  );
                                }
                                return;
                              }

                              final started = await UpdateService.startUpdate();
                              if (!context.mounted) return;

                              if (!started) {
                                SnackbarHelper.showError(
                                  context,
                                  'Guncelleme baslatilamadi',
                                );
                                return;
                              }

                              SnackbarHelper.showSuccess(
                                context,
                                status.isDownloaded
                                    ? 'Kurulum baslatildi'
                                    : 'Guncelleme akisi baslatildi',
                              );
                              ref.invalidate(appUpdateStatusProvider);
                            },
                            icon: const Icon(Icons.system_update_alt_rounded, size: 18),
                            label: Text(actionLabel),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildColorSchemeOption(
    BuildContext context,
    WidgetRef ref,
    String name,
    String id,
    Color color,
    bool isSelected,
  ) {
    return GestureDetector(
      onTap: () => ref.read(colorSchemeProvider.notifier).setColorScheme(id),
      child: Container(
        width: 70,
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: isSelected
                    ? Border.all(color: Colors.white, width: 3)
                    : null,
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: isSelected
                  ? const Icon(Icons.check, color: Colors.white, size: 20)
                  : null,
            ),
            const SizedBox(height: 6),
            Text(
              name,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSupportSection(BuildContext context) {
    final theme = Theme.of(context);
    final sectionColor = Colors.blue[700];
    
    return _buildSectionCard(
      context,
      ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            color: theme.brightness == Brightness.light ? const Color(0xFFF8F9FA) : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: theme.brightness == Brightness.light ? Colors.black.withValues(alpha: 0.04) : Colors.white.withValues(alpha: 0.08),
            ),
          ),
          child: ExpansionTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: sectionColor!.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.support_agent_outlined, color: sectionColor, size: 20),
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
                'Radyo T\u00fcneli v2.0.7',
                Icons.info_outline,
                () => _showAboutDialog(context),
              ),
              const SizedBox(height: 4),
            ],
          ),
        ),
      ),
      showBorder: false,
      backgroundColor: Colors.transparent,
    );
  }

  Widget _buildLegalSection(BuildContext context) {
    final theme = Theme.of(context);
    final sectionColor = Colors.blueGrey[600];
    
    return _buildSectionCard(
      context,
      ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            color: theme.brightness == Brightness.light ? const Color(0xFFF8F9FA) : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: theme.brightness == Brightness.light ? Colors.black.withValues(alpha: 0.04) : Colors.white.withValues(alpha: 0.08),
            ),
          ),
          child: ExpansionTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: sectionColor!.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.shield_outlined, color: sectionColor, size: 20),
            ),
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
      ),
      showBorder: false,
      backgroundColor: Colors.transparent,
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
          _buildSectionHeader(context, Icons.apps_rounded, 'Di\u011fer', Colors.blueGrey),
          const SizedBox(height: 12),
          _buildSettingsTile(
            context,
            'Uygulamay\u0131 Payla\u015f',
            'WhatsApp ve di\u011fer uygulamalarda payla\u015f',
            Icons.share_outlined,
            () async {
              await Share.share(shareUrl);
            },
            Colors.blueGrey,
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
            Colors.blueGrey,
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'Radyo T\u00fcneli',
      applicationVersion: '2.0.7',
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
    VoidCallback onTap, [
    Color? color,
  ]) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final iconColor = _resolvedSectionIconColor(context, color);

    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(
        trTitle,
        style: TextStyle(
          color: colorScheme.onSurface,
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
      subtitle: Text(
        deTitle,
        style: TextStyle(
          fontSize: 11,
          color: colorScheme.onSurface.withValues(alpha: 0.6),
        ),
      ),
      trailing: Icon(
        Icons.chevron_right_rounded,
        size: 20,
        color: colorScheme.onSurface.withValues(alpha: 0.3),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
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
    final textColor =
        Theme.of(context).textTheme.bodyLarge?.color ?? colorScheme.onSurface;
    final drawerIconColor = colorScheme.onSurface.withValues(alpha: 0.88);
    final drawerBg = Theme.of(context).appBarTheme.backgroundColor ??
        Theme.of(context).colorScheme.primary;
    final drawerFg = Theme.of(context).appBarTheme.foregroundColor ??
        Theme.of(context).colorScheme.onPrimary;

    return Drawer(
      backgroundColor: colorScheme.surface,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          Container(
            width: double.infinity,
            height: 150,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [drawerBg, Color.lerp(drawerBg, Colors.black, 0.16)!],
              ),
              boxShadow: [
                BoxShadow(
                  color: drawerBg.withValues(alpha: 0.18),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            padding: const EdgeInsets.only(top: 50, left: 20, bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    'assets/images/icon.png',
                    width: 32,
                    height: 32,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Radyo T\u00fcneli',
                  style: TextStyle(
                    color: drawerFg,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          ListTile(
            leading: Icon(Icons.home, color: drawerIconColor),
            title: Text(
              'Ana Sayfa',
              style: TextStyle(color: textColor, fontWeight: FontWeight.w500),
            ),
            onTap: () {
              Navigator.pop(context);
              ref.read(selectedTabProvider.notifier).state = 0;
            },
          ),
          Divider(
            height: 1,
            indent: 16,
            endIndent: 16,
            color: drawerFg.withValues(alpha: 0.12),
          ),
          ListTile(
            leading: const Icon(Icons.favorite, color: Color(0xFFFB7185)),
            title: Text(
              'Favoriler',
              style: TextStyle(color: textColor, fontWeight: FontWeight.w500),
            ),
            onTap: () {
              Navigator.pop(context);
              ref.read(selectedTabProvider.notifier).state = 1;
            },
          ),
          Divider(
            height: 1,
            indent: 16,
            endIndent: 16,
            color: drawerFg.withValues(alpha: 0.12),
          ),
          ListTile(
            leading: Icon(Icons.settings, color: drawerIconColor),
            title: Text(
              'Ayarlar',
              style: TextStyle(color: textColor, fontWeight: FontWeight.w500),
            ),
            onTap: () => Navigator.pop(context),
          ),
          Divider(
            height: 1,
            indent: 16,
            endIndent: 16,
            color: drawerFg.withValues(alpha: 0.12),
          ),
          ExpansionTile(
            leading: Icon(Icons.category_outlined, color: drawerIconColor),
            iconColor: drawerIconColor,
            collapsedIconColor: drawerIconColor,
            title: Text(
              'Kategoriler',
              style: TextStyle(color: textColor, fontWeight: FontWeight.w500),
            ),
            children: [
              _buildDrawerCategoryTile(context, ref, 'muzik', 'Müzik', Icons.music_note),
              _buildDrawerCategoryTile(context, ref, 'turku', 'Türkü', Icons.queue_music),
              _buildDrawerCategoryTile(context, ref, 'haber', 'Haber', Icons.article),
              _buildDrawerCategoryTile(context, ref, 'spor', 'Spor', Icons.sports_soccer),
              _buildDrawerCategoryTile(context, ref, 'dini', 'Dini', Icons.mosque),
              _buildDrawerCategoryTile(context, ref, 'arabesk', 'Arabesk', Icons.mic),
              _buildDrawerCategoryTile(context, ref, 'yerel', 'Yerel', Icons.location_on),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSleepTimerChip(
    BuildContext context, {
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final highlight = _resolvedSectionIconColor(context);

    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? highlight.withValues(alpha: 0.14)
              : Colors.white.withValues(alpha: 0.82),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected
                ? highlight.withValues(alpha: 0.42)
                : colorScheme.onSurface.withValues(alpha: 0.12),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? highlight : colorScheme.onSurface,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildDrawerCategoryTile(
    BuildContext context,
    WidgetRef ref,
    String id,
    String title,
    IconData icon,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final isSelected = ref.watch(selectedCategoryProvider) == id;

    return ListTile(
      contentPadding: const EdgeInsets.only(left: 32, right: 16),
      leading: Icon(
        icon,
        size: 20,
        color: isSelected
            ? _resolvedSectionIconColor(context)
            : colorScheme.onSurface.withValues(alpha: 0.88),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: colorScheme.onSurface,
          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
        ),
      ),
      onTap: () {
        ref.read(selectedCategoryProvider.notifier).state = id;
        ref.read(selectedTabProvider.notifier).state = 0;
        Navigator.pop(context);
      },
    );
  }
}




