import 'package:flutter/material.dart';

/// Custom app bar for senior users matching Figma design.
///
/// Features:
/// - Orange "효심이" title
/// - Notification bell icon
/// - SOS button with red styling
class SeniorAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback? onNotificationPressed;
  final VoidCallback? onSosPressed;

  const SeniorAppBar({
    super.key,
    this.onNotificationPressed,
    this.onSosPressed,
  });

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      title: Row(
        children: [
          // Logo/Title - Orange "효심이"
          Image.asset(
            '/images/logo.png',
            height: 24,
            errorBuilder: (context, error, stackTrace) {
              // Fallback to text if image not found
              return const Text(
                '효심이',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFFF8D28), // Orange color
                ),
              );
            },
          ),
        ],
      ),
      actions: [
        // Notification bell
        IconButton(
          icon: const Icon(
            Icons.notifications_outlined,
            size: 24,
            color: Color(0xFF49454F),
          ),
          onPressed:
              onNotificationPressed ??
              () {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('알림 기능 준비 중입니다')));
              },
          tooltip: '알림',
        ),
        // SOS button
        Container(
          margin: const EdgeInsets.only(right: 16),
          child: InkWell(
            onTap:
                onSosPressed ??
                () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('긴급 SOS 기능 준비 중입니다')),
                  );
                },
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.phone_in_talk,
                    size: 16,
                    color: const Color(0xFFFF383C),
                  ),
                  const Text(
                    'SOS',
                    style: TextStyle(
                      fontSize: 7,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFFFF383C),
                      height: 2.29,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
