import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'router/app_router.dart';

/// Supported runtime targets for the unified CoolTiger codebase.
enum TargetFlavor { seniorMobile, guardianWeb, seniorWeb }

/// Root application widget that toggles UI/routing per [TargetFlavor].
class CoolTigerApp extends StatefulWidget {
  const CoolTigerApp({super.key, required this.targetFlavor});

  final TargetFlavor targetFlavor;

  @override
  State<CoolTigerApp> createState() => _CoolTigerAppState();
}

class _CoolTigerAppState extends State<CoolTigerApp> {
  late final GoRouter _router = buildAppRouter(widget.targetFlavor);

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'CoolTiger',
      debugShowCheckedModeBanner: false,
      routerConfig: _router,
      theme: _buildTheme(widget.targetFlavor),
    );
  }

  ThemeData _buildTheme(TargetFlavor flavor) {
    final bool guardian = flavor == TargetFlavor.guardianWeb;
    final ColorScheme scheme = guardian
        ? ColorScheme.highContrastLight(
            primary: Colors.indigo.shade600,
            secondary: Colors.orange.shade600,
          )
        : ColorScheme.highContrastDark(
            primary: Colors.orange.shade300,
            secondary: Colors.tealAccent.shade200,
          );

    final baseTextTheme = guardian
        ? ThemeData.light().textTheme
        : ThemeData.dark().textTheme;

    final interTextTheme = GoogleFonts.interTextTheme(baseTextTheme).copyWith(
      headlineLarge:
          GoogleFonts.inter(fontSize: 36, fontWeight: FontWeight.w800),
      headlineMedium:
          GoogleFonts.inter(fontSize: 30, fontWeight: FontWeight.w700),
      titleMedium:
          GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w500),
      bodyLarge: GoogleFonts.inter(fontSize: 20),
      bodyMedium: GoogleFonts.inter(fontSize: 18),
      labelLarge: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600),
    ).apply(
      bodyColor: scheme.onBackground,
      displayColor: scheme.onBackground,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      textTheme: interTextTheme,
      visualDensity: VisualDensity.standard,
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        centerTitle: guardian,
        titleTextStyle: interTextTheme.headlineSmall,
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: scheme.surfaceContainerHighest,
        selectedIconTheme: IconThemeData(color: scheme.primary, size: 24),
        unselectedIconTheme: IconThemeData(color: scheme.onSurfaceVariant),
        selectedLabelTextStyle: interTextTheme.labelLarge,
      ),
    );
  }
}
