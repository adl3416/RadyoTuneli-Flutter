import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/stations/ui/home_screen.dart';
import '../features/favorites/ui/favorites_screen.dart';
import '../features/settings/ui/settings_screen.dart';
import '../features/player/ui/mini_player.dart';
import '../core/theme/app_theme.dart';
import '../core/theme/theme_registry.dart';
import '../shared/providers/color_scheme_provider.dart';

final selectedTabProvider = StateProvider<int>((ref) => 0);

class MainScreen extends ConsumerWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedTab = ref.watch(selectedTabProvider);

    final screens = [
      const HomeScreen(),
      const FavoritesScreen(),
      const SettingsScreen(),
    ];

    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: IndexedStack(
              index: selectedTab,
              children: screens,
            ),
          ),
          const MiniPlayer(),
        ],
      ),
      bottomNavigationBar: Consumer(
        builder: (context, ref, child) {
          final colorScheme = ref.watch(colorSchemeProvider);
          
          // Get bottom bar colors based on colorScheme
          Color getSelectedItemColor() {
            switch (colorScheme) {
              case 'kanarya':
                return const Color(0xFFFFD700); // Sarı
              case 'aslan':
                return const Color(0xFFFFD700); // Sarı
              case 'karadeniz':
                return const Color(0xFF4169E1); // Mavi
              case 'kartal':
                return const Color(0xFFFFFFFF); // Beyaz
              case 'timsah':
                return AppTheme.timsahWhite; // Use white icons on Timsah bottom bar
              case 'varsayilan':
              default:
                return const Color(0xFF8B5CF6); // Mor
            }
          }

          Color getUnselectedItemColor() {
            switch (colorScheme) {
              case 'kanarya':
                // Use the theme's text color (yellow) for unselected icons in Kanarya
                return AppTheme.kanaryaPrimary.withOpacity(0.85);
              case 'aslan':
                return AppTheme.aslanYellow.withOpacity(0.85);
              case 'karadeniz':
                return AppTheme.karadenizMavi.withOpacity(0.85);
              case 'kartal':
                return AppTheme.kartalWhite.withOpacity(0.85);
              case 'timsah':
                return AppTheme.timsahWhite.withOpacity(0.85);
              case 'varsayilan':
              default:
                // Fallback to a neutral onBackground color
                return Theme.of(context).colorScheme.onBackground.withOpacity(0.7);
            }
          }

          // Prefer registered theme values when available (keeps colors centralized)
          final registryTheme = getThemeByName(ref.watch(colorSchemeProvider));
          final bottomTheme = registryTheme?.bottomNavigationBarTheme;
          var bgColor = bottomTheme?.backgroundColor ?? Theme.of(context).bottomNavigationBarTheme.backgroundColor;
          var selColor = bottomTheme?.selectedItemColor ?? getSelectedItemColor();
          var unselColor = bottomTheme?.unselectedItemColor ?? getUnselectedItemColor();

          // Hard overrides for certain named themes to guarantee bottom nav look
          // Timsah: green background + white icons
          if (ref.watch(colorSchemeProvider) == 'timsah') {
            bgColor = AppTheme.timsahGreen;
            selColor = AppTheme.timsahWhite;
            unselColor = AppTheme.timsahWhite.withOpacity(0.85);
          }

          // Kanarya: use lacivert background and white icons (per request)
          if (ref.watch(colorSchemeProvider) == 'kanarya') {
            bgColor = AppTheme.kanaryaSecondary; // Lacivert
            selColor = AppTheme.kanaryaPrimary; // Sarı when selected
            unselColor = Colors.white.withOpacity(0.85);
          }

          // Aslan: icons normally white, selected yellow
          if (ref.watch(colorSchemeProvider) == 'aslan') {
            // keep the theme's background (red) but ensure icons are visible
            bgColor = AppTheme.aslanRed;
            selColor = AppTheme.aslanYellow;
            unselColor = Colors.white.withOpacity(0.9);
          }

          // Kartal: black background and white icons
          if (ref.watch(colorSchemeProvider) == 'kartal') {
            bgColor = AppTheme.kartalBlack;
            selColor = AppTheme.kartalWhite;
            unselColor = AppTheme.kartalWhite.withOpacity(0.85);
          }

          // Karadeniz Fırtınası: bordo background (keep selected color as theme's blue)
          if (ref.watch(colorSchemeProvider) == 'karadeniz') {
            bgColor = AppTheme.karadenizBordo;
            selColor = AppTheme.karadenizMavi;
            // Make unselected icons clearly visible on bordo background
            unselColor = Colors.white.withOpacity(0.85);
          }

          // Debug: log resolved bottom nav colors for current scheme
          // This helps verify whether the theme registry or fallback values are used.
          // Remove or comment out in production.
          // ignore: avoid_print
          print('🎨 BottomBar colors - scheme: ${ref.watch(colorSchemeProvider)}, bg: $bgColor, selected: $selColor, unselected: $unselColor');

          return Container(
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: Theme.of(context).primaryColor.withOpacity(0.2),
                  width: 0.5,
                ),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  offset: const Offset(0, -1),
                  blurRadius: 10,
                ),
              ],
            ),
            child: BottomNavigationBar(
              currentIndex: selectedTab,
              onTap: (index) {
                // Farklı sekmeler için farklı haptic feedback türleri
                switch (index) {
                  case 0: // Ana Sayfa
                    HapticFeedback.lightImpact();
                    break;
                  case 1: // Favoriler
                    HapticFeedback.mediumImpact();
                    break;
                  case 2: // Ayarlar
                    HapticFeedback.heavyImpact();
                    break;
                  default:
                    HapticFeedback.selectionClick();
                }
                
                // Tab değiştir
                ref.read(selectedTabProvider.notifier).state = index;
              },
              type: BottomNavigationBarType.fixed,
              backgroundColor: bgColor,
              selectedItemColor: selColor,
              unselectedItemColor: unselColor,
              selectedLabelStyle:
                  const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
              unselectedLabelStyle:
                  const TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
              elevation: 0,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home_outlined),
                  activeIcon: Icon(Icons.home),
                  label: 'Ana Sayfa',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.favorite_outline),
                  activeIcon: Icon(Icons.favorite),
                  label: 'Favoriler',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.settings_outlined),
                  activeIcon: Icon(Icons.settings),
                  label: 'Ayarlar',
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
