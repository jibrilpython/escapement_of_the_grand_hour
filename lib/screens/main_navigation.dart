import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:escapement_of_the_grand_hour/screens/converter_screen.dart';
import 'package:escapement_of_the_grand_hour/screens/home_screen.dart';
import 'package:escapement_of_the_grand_hour/screens/stats_screen.dart';
import 'package:escapement_of_the_grand_hour/screens/showcase_screen.dart';
import 'package:escapement_of_the_grand_hour/utils/const.dart';
import 'package:google_fonts/google_fonts.dart';

class MainNavigation extends ConsumerStatefulWidget {
  final int index;
  const MainNavigation({super.key, this.index = 0});

  @override
  ConsumerState<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends ConsumerState<MainNavigation> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    ShowcaseScreen(),
    StatsScreen(),
    ConverterScreen(),
  ];

  static const _tabs = [
    _NavTab(Icons.archive_outlined, Icons.archive_rounded, 'Cabinet'),
    _NavTab(Icons.hub_outlined, Icons.hub_rounded, 'Maker Map'),
    _NavTab(Icons.menu_book_outlined, Icons.menu_book_rounded, 'Logbook'),
    _NavTab(Icons.speed_outlined, Icons.speed_rounded, 'Converter'),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.index;
  }

  void _setIndex(int i) {
    if (i == _currentIndex) return;
    HapticFeedback.selectionClick();
    setState(() => _currentIndex = i);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      extendBody: true,
      body: Stack(
        children: [
          IndexedStack(index: _currentIndex, children: _screens),
          Positioned(
            left: 20.w,
            right: 20.w,
            bottom: MediaQuery.of(context).padding.bottom + 16.h,
            child: _buildNav(),
          ),
        ],
      ),
    );
  }

  Widget _buildNav() {
    return Container(
      height: 68.h,
      padding: EdgeInsets.symmetric(horizontal: 6.w),
      decoration: BoxDecoration(
        color: kPanelBg.withValues(alpha: 0.97),
        borderRadius: BorderRadius.circular(kRadiusPill),
        border: Border.all(color: kOutline),
        boxShadow: const [kShadowFloat],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(
          _tabs.length,
          (i) => _buildNavItem(i, _tabs[i]),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, _NavTab tab) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () => _setIndex(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        height: 52.h,
        padding: EdgeInsets.symmetric(horizontal: isSelected ? 16.w : 13.w),
        decoration: BoxDecoration(
          color: isSelected ? kAccent : Colors.transparent,
          borderRadius: BorderRadius.circular(kRadiusPill),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? tab.activeIcon : tab.icon,
              color: isSelected ? kPanelBg : kSecondaryText,
              size: 21.sp,
            ),
            if (isSelected) ...[
              SizedBox(width: 7.w),
              Text(
                tab.label,
                style: GoogleFonts.sourceSans3(
                  color: kPanelBg,
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _NavTab {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const _NavTab(this.icon, this.activeIcon, this.label);
}
