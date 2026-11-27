import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/meal_api.dart';
import '../state/app_nav.dart';
import '../theme.dart';
import '../widgets/floating_nav_bar.dart';
import 'dashboard_screen.dart';
import 'favorites_screen.dart';
import 'menu_screen.dart';

const _navItems = [
  NavItem(Icons.space_dashboard_rounded, 'Beranda', AppColors.green),
  NavItem(Icons.restaurant_menu_rounded, 'Menu', AppColors.orange),
  NavItem(Icons.favorite_rounded, 'Favorit', AppColors.heart),
];

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  final _api = MealApi();

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: AppNav.tab,
      builder: (context, index, _) {
        return AnnotatedRegion<SystemUiOverlayStyle>(
          // Beranda punya latar hijau di atas, tab lain berlatar terang.
          value: index == 0
              ? SystemUiOverlayStyle.light
              : SystemUiOverlayStyle.dark,
          child: Scaffold(
            extendBody: true,
            body: IndexedStack(
              index: index,
              children: [
                DashboardScreen(api: _api),
                MenuScreen(api: _api),
                FavoritesScreen(api: _api),
              ],
            ),
            bottomNavigationBar: FloatingNavBar(
              index: index,
              items: _navItems,
              onTap: (i) => AppNav.tab.value = i,
            ),
          ),
        );
      },
    );
  }
}
