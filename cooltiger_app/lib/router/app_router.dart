import 'package:go_router/go_router.dart';

import '../app.dart';
import '../features/guardian/views/guardian_dashboard_screen.dart';
import '../features/senior/views/senior_home_screen.dart';
import '../features/showcase/views/showcase_screen.dart';

/// Builds a [GoRouter] whose routes depend on the running [TargetFlavor].
GoRouter buildAppRouter(TargetFlavor flavor) {
  switch (flavor) {
    case TargetFlavor.seniorMobile:
      return GoRouter(
        initialLocation: SeniorHomeScreen.routePath,
        routes: [
          GoRoute(
            path: SeniorHomeScreen.routePath,
            name: SeniorHomeScreen.routeName,
            builder: (context, state) => const SeniorHomeScreen(),
          ),
        ],
      );
    case TargetFlavor.guardianWeb:
      return GoRouter(
        initialLocation: GuardianDashboardScreen.routePath,
        routes: [
          GoRoute(
            path: GuardianDashboardScreen.routePath,
            name: GuardianDashboardScreen.routeName,
            builder: (context, state) => const GuardianDashboardScreen(),
          ),
        ],
      );
    case TargetFlavor.seniorWeb:
      return GoRouter(
        initialLocation: ShowcaseScreen.routePath,
        routes: [
          GoRoute(
            path: ShowcaseScreen.routePath,
            name: ShowcaseScreen.routeName,
            builder: (context, state) => const ShowcaseScreen(),
          ),
        ],
      );
  }
}
