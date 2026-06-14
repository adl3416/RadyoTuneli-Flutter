import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:turkradyo/src/core/theme/app_theme.dart';
import 'package:turkradyo/src/features/favorites/data/favorites_provider.dart';
import 'package:turkradyo/src/features/favorites/ui/favorites_screen.dart';
import 'package:turkradyo/src/features/settings/ui/settings_screen.dart';
import 'package:turkradyo/src/features/stations/data/stations_provider.dart';
import 'package:turkradyo/src/features/stations/domain/station_model.dart';
import 'package:turkradyo/src/features/stations/ui/home_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Home drawer icons stay visible on light surfaces', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _buildTestApp(
        const HomeScreen(),
        overrides: [
          filteredStationsProvider.overrideWith((ref) async => <Station>[]),
          actualRecentlyPlayedStationsProvider.overrideWith(
            (ref) async => <Station>[],
          ),
        ],
      ),
    );

    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();

    expect(_drawerIcon(tester, Icons.home).color, isNot(Colors.white));
    expect(_drawerIcon(tester, Icons.favorite).color, isNot(Colors.white));
    expect(_drawerIcon(tester, Icons.settings).color, isNot(Colors.white));

    await tester.pump(const Duration(seconds: 31));
  });

  testWidgets('Favorites drawer icons stay visible on light surfaces', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _buildTestApp(
        const FavoritesScreen(),
        overrides: [
          sortedFavoriteStationsProvider.overrideWith(
            (ref) async => <Station>[],
          ),
        ],
      ),
    );

    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();

    expect(_drawerIcon(tester, Icons.home).color, isNot(Colors.white));
    expect(_drawerIcon(tester, Icons.favorite).color, isNot(Colors.white));
    expect(_drawerIcon(tester, Icons.settings).color, isNot(Colors.white));
  });

  testWidgets('Settings drawer icons stay visible on light surfaces', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_buildTestApp(const SettingsScreen()));

    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();

    expect(_drawerIcon(tester, Icons.home).color, isNot(Colors.white));
    expect(_drawerIcon(tester, Icons.favorite).color, isNot(Colors.white));
    expect(_drawerIcon(tester, Icons.settings).color, isNot(Colors.white));
  });
}

Widget _buildTestApp(
  Widget child, {
  List<Override> overrides = const [],
}) {
  return ProviderScope(
    overrides: overrides,
    child: MaterialApp(
      theme: AppTheme.lightTheme,
      home: child,
    ),
  );
}

Icon _drawerIcon(WidgetTester tester, IconData iconData) {
  final finder = find.descendant(
    of: find.byType(Drawer),
    matching: find.byWidgetPredicate(
      (widget) => widget is Icon && widget.icon == iconData,
    ),
  );

  return tester.widget<Icon>(finder.first);
}
