import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/stations/ui/home_screen.dart';
import '../features/favorites/ui/favorites_screen.dart';
import '../features/settings/ui/settings_screen.dart';
import '../features/player/ui/mini_player.dart';
import '../core/theme/app_theme.dart';
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
                return const Color(0xFF228B22); // Yeşil
              case 'varsayilan':
              default:
                return const Color(0xFF8B5CF6); // Mor
            }
          }

          Color getUnselectedItemColor() {
            switch (colorScheme) {
              case 'kanarya':
                return const Color(0xFF001F3F).withOpacity(0.5); // Lacivert
              case 'aslan':
                return const Color(0xFFDC143C).withOpacity(0.5); // Kırmızı
              case 'karadeniz':
                return const Color(0xFF800000).withOpacity(0.5); // Bordo
              case 'kartal':
                return const Color(0xFF000000).withOpacity(0.5); // Siyah
              case 'timsah':
                return const Color(0xFFFFFFFF).withOpacity(0.5); // Beyaz
              case 'varsayilan':
              default:
                return AppTheme.gray500;
            }
          }

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
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              selectedItemColor: getSelectedItemColor(),
              unselectedItemColor: getUnselectedItemColor(),
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
