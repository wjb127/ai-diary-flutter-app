import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../services/localization_service.dart';

class MainScreen extends StatefulWidget {
  final Widget child;
  
  const MainScreen({super.key, required this.child});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  void _onItemTapped(int index, BuildContext context) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        context.goNamed('home');
        break;
      case 1:
        context.goNamed('diary');
        break;
      case 2:
        context.goNamed('profile');
        break;
      case 3:
        context.goNamed('subscription');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    // 현재 경로에 따라 선택된 인덱스 업데이트
    final location = GoRouterState.of(context).uri.toString();
    if (location == '/') {
      _selectedIndex = 0;
    } else if (location == '/diary') {
      _selectedIndex = 1;
    } else if (location == '/profile') {
      _selectedIndex = 2;
    } else if (location == '/subscription') {
      _selectedIndex = 3;
    }

    return Consumer<LocalizationService>(
      builder: (context, localizationService, child) {
        final localizations = AppLocalizations(localizationService.currentLanguage);
        
        return Scaffold(
          body: widget.child,
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 20,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildNavItem(
                      icon: Icons.home_outlined,
                      activeIcon: Icons.home,
                      label: localizations.navHome,
                      index: 0,
                    ),
                    _buildNavItem(
                      icon: Icons.edit_outlined,
                      activeIcon: Icons.edit,
                      label: localizations.navDiary,
                      index: 1,
                    ),
                    _buildNavItem(
                      icon: Icons.person_outline,
                      activeIcon: Icons.person,
                      label: localizations.navProfile,
                      index: 2,
                    ),
                    _buildNavItem(
                      icon: Icons.star_outline,
                      activeIcon: Icons.star,
                      label: localizations.navSubscription,
                      index: 3,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required int index,
  }) {
    final isSelected = _selectedIndex == index;
    
    return GestureDetector(
      onTap: () => _onItemTapped(index, context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF6366F1).withValues(alpha: 0.1) : null,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              color: isSelected ? const Color(0xFF6366F1) : const Color(0xFF64748B),
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? const Color(0xFF6366F1) : const Color(0xFF64748B),
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}