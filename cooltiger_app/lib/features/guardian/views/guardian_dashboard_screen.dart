import 'package:flutter/material.dart';

class GuardianDashboardScreen extends StatefulWidget {
  const GuardianDashboardScreen({super.key});

  static const routeName = 'guardian-dashboard';
  static const routePath = '/';

  @override
  State<GuardianDashboardScreen> createState() => _GuardianDashboardScreenState();
}

class _GuardianDashboardScreenState extends State<GuardianDashboardScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final sections = [
      _DashboardSection(
        title: 'Today\'s Summary',
        subtitle: 'Sentiment, word count, speaking rate at a glance.',
      ),
      _DashboardSection(
        title: 'Conversation Timeline',
        subtitle: 'Stream of recent transcripts with filters.',
      ),
      _DashboardSection(
        title: 'Alerts & Tasks',
        subtitle: 'Automated follow-ups for caregivers.',
      ),
    ];

    return Scaffold(
      body: SafeArea(
        child: Row(
          children: [
            NavigationRail(
              selectedIndex: _selectedIndex,
              onDestinationSelected: (value) => setState(() => _selectedIndex = value),
              labelType: NavigationRailLabelType.selected,
              destinations: const [
                NavigationRailDestination(
                  icon: Icon(Icons.insights_outlined),
                  selectedIcon: Icon(Icons.insights),
                  label: Text('Reports'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.chat_bubble_outline),
                  selectedIcon: Icon(Icons.chat_bubble),
                  label: Text('Conversations'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.warning_amber_outlined),
                  selectedIcon: Icon(Icons.warning_amber),
                  label: Text('Alerts'),
                ),
              ],
            ),
            const VerticalDivider(width: 1),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: sections[_selectedIndex],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardSection extends StatelessWidget {
  const _DashboardSection({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      key: ValueKey(title),
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.headlineLarge),
          const SizedBox(height: 12),
          Text(subtitle, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 24),
          Expanded(
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                color: Theme.of(context).colorScheme.surfaceContainerHigh,
              ),
              child: const Center(
                child: Text('Guardian widgets coming soon'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
