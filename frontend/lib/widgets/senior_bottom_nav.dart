import 'package:flutter/material.dart';

/// Custom bottom navigation bar for senior users matching Figma design.
///
/// Features three tabs:
/// - 홈 (Home) with more_horiz icon
/// - 목표 (Goal) with stars icon
/// - 내정보 (My Info) with account_circle icon
class SeniorBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const SeniorBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
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
        child: SizedBox(
          height: 64,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                context: context,
                index: 0,
                icon: Icons.more_horiz,
                label: '홈',
                isSelected: currentIndex == 0,
              ),
              _buildNavItem(
                context: context,
                index: 1,
                icon: Icons.stars,
                label: '목표',
                isSelected: currentIndex == 1,
              ),
              _buildNavItem(
                context: context,
                index: 2,
                icon: Icons.account_circle,
                label: '내정보',
                isSelected: currentIndex == 2,
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
    required String label,
    required bool isSelected,
  }) {
    final color = isSelected
        ? const Color(0xFF21005D) // M3 on-primary-fixed
        : const Color(0xFF4A4459); // M3 on-surface-variant

    return Expanded(
      child: InkWell(
        onTap: () => onTap(index),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon container
              Container(
                width: 56,
                height: 32,
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFFE8DEF8) // M3 secondary-container
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(child: Icon(icon, size: 24, color: color)),
              ),
              const SizedBox(height: 4),
              // Label
              Text(
                label,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
                  height: 0.67,
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
