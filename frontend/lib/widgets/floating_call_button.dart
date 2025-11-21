import 'package:flutter/material.dart';

/// Floating call button for quick access to AI conversation.
///
/// Large orange button with microphone icon that can be reused
/// across different screens. Matches Figma design.
class FloatingCallButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;

  const FloatingCallButton({
    super.key,
    required this.onPressed,
    this.text = '효심이와 대화 바로 시작하기',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 21, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xD9FF8D28), // Orange with 85% opacity
            foregroundColor: const Color(0xFF49454F),
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(100),
            ),
            shadowColor: Colors.black.withOpacity(0.25),
          ).copyWith(elevation: MaterialStateProperty.all(2)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.mic, size: 35, color: Colors.white),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  text,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    height: 1.0,
                    letterSpacing: 0.1,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
