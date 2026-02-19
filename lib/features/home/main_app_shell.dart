import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/api/app_apis.dart';
import '../../../core/theme/me_encontraste_palette.dart';
import 'explore_screen.dart';
import 'favorites_screen.dart';
import 'messages_screen.dart';
import 'notifications_screen.dart';
import 'profile_screen.dart';

class MainAppShell extends StatefulWidget {
  const MainAppShell({
    super.key,
    required this.apis,
    required this.onLogout,
  });

  final AppApis apis;
  final VoidCallback onLogout;

  @override
  State<MainAppShell> createState() => _MainAppShellState();
}

class _MainAppShellState extends State<MainAppShell> {
  int _index = 0;
  static const _duration = Duration(milliseconds: 280);
  static const _curve = Curves.easeOutCubic;

  Widget _pageAt(int index) {
    switch (index) {
      case 0:
        return ExploreScreen(apis: widget.apis);
      case 1:
        return FavoritesScreen(apis: widget.apis);
      case 2:
        return MessagesScreen(apis: widget.apis);
      case 3:
        return NotificationsScreen(apis: widget.apis);
      case 4:
        return ProfileScreen(apis: widget.apis, onLogout: widget.onLogout);
      default:
        return ExploreScreen(apis: widget.apis);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedSwitcher(
        duration: _duration,
        switchInCurve: _curve,
        switchOutCurve: _curve,
        transitionBuilder: (Widget child, Animation<double> animation) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.04, 0),
                end: Offset.zero,
              ).animate(CurvedAnimation(parent: animation, curve: _curve)),
              child: child,
            ),
          );
        },
        child: KeyedSubtree(key: ValueKey<int>(_index), child: _pageAt(_index)),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: MeEncontrastePalette.white,
          boxShadow: [
            BoxShadow(
              color: MeEncontrastePalette.gray200.withValues(alpha: 0.5),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavItem(
                  icon: Icons.explore_outlined,
                  activeIcon: Icons.explore,
                  label: 'Explorar',
                  active: _index == 0,
                  onTap: () => setState(() => _index = 0),
                ),
                _NavItem(
                  icon: Icons.favorite_border,
                  activeIcon: Icons.favorite,
                  label: 'Favoritos',
                  active: _index == 1,
                  onTap: () => setState(() => _index = 1),
                ),
                _NavItem(
                  icon: Icons.chat_bubble_outline,
                  activeIcon: Icons.chat_bubble,
                  label: 'Mensajes',
                  active: _index == 2,
                  onTap: () => setState(() => _index = 2),
                ),
                _NavItem(
                  icon: Icons.notifications_none,
                  activeIcon: Icons.notifications,
                  label: 'Avisos',
                  active: _index == 3,
                  onTap: () => setState(() => _index = 3),
                ),
                _NavItem(
                  icon: Icons.person_outline,
                  activeIcon: Icons.person,
                  label: 'Cuenta',
                  active: _index == 4,
                  onTap: () => setState(() => _index = 4),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = active ? MeEncontrastePalette.primary600 : MeEncontrastePalette.gray500;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: active ? MeEncontrastePalette.primary50 : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedScale(
              scale: active ? 1.15 : 1.0,
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutBack,
              child: Icon(active ? activeIcon : icon, size: 24, color: color),
            ),
            const SizedBox(height: 4),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: GoogleFonts.outfit(
                fontSize: 11,
                color: color,
                fontWeight: active ? FontWeight.w600 : FontWeight.w400,
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }
}
