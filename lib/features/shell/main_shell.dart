import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_framework/responsive_framework.dart';

import '../../core/l10n/l10n_ext.dart';
import '../../core/utils/adaptive.dart';

/// Root scaffold with the five-tab navigation. Phones get a Material 3
/// NavigationBar; tablets/foldables get a NavigationRail.
class MainShell extends StatelessWidget {
  final StatefulNavigationShell shell;
  const MainShell({super.key, required this.shell});

  void _onSelect(int index) {
    selectionHaptic();
    shell.goBranch(index, initialLocation: index == shell.currentIndex);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final destinations = [
      (Icons.home_rounded, Icons.home_outlined, l10n.home),
      (Icons.receipt_long_rounded, Icons.receipt_long_outlined, l10n.expenses),
      (Icons.pie_chart_rounded, Icons.pie_chart_outline_rounded, l10n.analytics),
      (
        Icons.account_balance_wallet_rounded,
        Icons.account_balance_wallet_outlined,
        l10n.budget
      ),
      (Icons.settings_rounded, Icons.settings_outlined, l10n.settings),
    ];

    final useRail = ResponsiveBreakpoints.of(context).largerThan(TABLET) ||
        ResponsiveBreakpoints.of(context).equals(TABLET);

    if (useRail) {
      return Scaffold(
        body: SafeArea(
          child: Row(
            children: [
              NavigationRail(
                selectedIndex: shell.currentIndex,
                onDestinationSelected: _onSelect,
                labelType: NavigationRailLabelType.all,
                groupAlignment: -0.7,
                destinations: [
                  for (final (selected, unselected, label) in destinations)
                    NavigationRailDestination(
                      icon: Icon(unselected),
                      selectedIcon: Icon(selected),
                      label: Text(label),
                    ),
                ],
              ),
              const VerticalDivider(width: 1),
              Expanded(child: shell),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: shell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: shell.currentIndex,
        onDestinationSelected: _onSelect,
        destinations: [
          for (final (selected, unselected, label) in destinations)
            NavigationDestination(
              icon: Icon(unselected),
              selectedIcon: Icon(selected),
              label: label,
            ),
        ],
      ),
    );
  }
}
