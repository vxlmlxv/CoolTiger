import 'package:flutter/material.dart';

/// Guardian Bottom Navigation Bar with 4 tabs.
///
/// Tabs: 홈 (Home), 보고서 (Report), 설정 (Settings), 사용자 (User)
class GuardianBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const GuardianBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Keep height flexible to avoid small overflows on devices with larger text scales.
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                context: context,
                index: 0,
                icon: Icons.home_outlined,
                selectedIcon: Icons.home,
                label: '홈',
                isSelected: currentIndex == 0,
              ),
              _buildNavItem(
                context: context,
                index: 1,
                icon: Icons.comment_outlined,
                selectedIcon: Icons.comment,
                label: '보고서',
                isSelected: currentIndex == 1,
              ),
              _buildNavItem(
                context: context,
                index: 2,
                icon: Icons.settings_outlined,
                selectedIcon: Icons.settings,
                label: '설정',
                isSelected: currentIndex == 2,
              ),
              _buildNavItem(
                context: context,
                index: 3,
                icon: Icons.account_circle_outlined,
                selectedIcon: Icons.account_circle,
                label: '사용자',
                isSelected: currentIndex == 3,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required int index,
    required IconData icon,
    required IconData selectedIcon,
    required String label,
    required bool isSelected,
  }) {
    final primaryColor = const Color(0xFF625B71); // M3 secondary
    final containerColor = const Color(0xFFE8DEF8); // M3 secondary-container
    final surfaceVariantColor = const Color(
      0xFF49454F,
    ); // M3 on-surface-variant

    final color = isSelected ? primaryColor : surfaceVariantColor;
    final displayIcon = isSelected ? selectedIcon : icon;

    return Expanded(
      child: InkWell(
        onTap: () => onTap(index),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon container
              Container(
                width: 52,
                height: 30,
                decoration: BoxDecoration(
                  color: isSelected ? containerColor : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(child: Icon(displayIcon, size: 24, color: color)),
              ),
              const SizedBox(height: 4),
              // Label
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.5,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
