import 'package:flutter/material.dart';

/// A reusable service card widget for the senior home screen.
///
/// Displays a service with a title, subtitle, and action button.
/// Based on the Figma design with rounded corners and proper spacing.
class ServiceCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String buttonText;
  final VoidCallback onPressed;

  const ServiceCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.buttonText,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 9),
      decoration: BoxDecoration(
        color: const Color(0xFFE7E0EC), // Light purple from Figma
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row with title and button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Title
              Flexible(
                child: Padding(
                  padding: const EdgeInsets.only(left: 17, top: 5),
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w600,
                      height: 1.4,
                      letterSpacing: -0.64,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Start button
              GestureDetector(
                onTap: onPressed,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    border: Border.all(color: const Color(0xFFF2F2F7)),
                    borderRadius: BorderRadius.circular(1000),
                  ),
                  child: Text(
                    buttonText,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      height: 0.8,
                      color: Color(0xBF0B0B0B),
                    ),
                  ),
                ),
              ),
            ],
          ),
          // Subtitle
          Padding(
            padding: const EdgeInsets.only(left: 17, top: 8, bottom: 5),
            child: Text(
              subtitle,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w500,
                height: 1.4,
                letterSpacing: -0.4,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
