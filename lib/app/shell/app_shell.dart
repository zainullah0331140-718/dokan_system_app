import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n/l10n_extensions.dart';
import '../../core/theme/appearance_controllers.dart';
import '../../core/theme/breakpoints.dart';
import '../../core/widgets/confirm_dialog.dart';
import '../../core/widgets/sync_status_chip.dart';
import '../../features/auth/domain/auth_state.dart';
import '../../features/auth/presentation/session_controller.dart';

class _NavDestination {
  const _NavDestination(this.icon, this.activeIcon, this.label);

  final IconData icon;
  final IconData activeIcon;
  final String label;
}

List<_NavDestination> _destinationsFor(BuildContext context) {
  final l10n = context.l10n;
  return [
    _NavDestination(
      Icons.dashboard_outlined,
      Icons.dashboard,
      l10n.navDashboard,
    ),
    _NavDestination(
      Icons.point_of_sale_outlined,
      Icons.point_of_sale,
      l10n.navSales,
    ),
    _NavDestination(
      Icons.inventory_2_outlined,
      Icons.inventory_2,
      l10n.navProducts,
    ),
    _NavDestination(
      Icons.people_outline_rounded,
      Icons.people_rounded,
      l10n.navCustomers,
    ),
    _NavDestination(
      Icons.warehouse_outlined,
      Icons.warehouse,
      l10n.navInventory,
    ),
    _NavDestination(
      Icons.shopping_cart_outlined,
      Icons.shopping_cart,
      l10n.navPurchases,
    ),
    _NavDestination(
      Icons.bar_chart_outlined,
      Icons.bar_chart,
      l10n.navReports,
    ),
    _NavDestination(
      Icons.schedule_outlined,
      Icons.schedule,
      l10n.navShifts,
    ),
    _NavDestination(
      Icons.settings_outlined,
      Icons.settings,
      l10n.navSettings,
    ),
  ];
}

class AppShell extends ConsumerWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  static const int primaryBranchCount = 4;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final destinations = _destinationsFor(context);
    final currentIndex = navigationShell.currentIndex;
    final isPhone = Breakpoints.isCompact(context);
    final extendedLabels =
        Breakpoints.usesNavigationRailLabels(context);
    final showRailLabels = !extendedLabels &&
        MediaQuery.sizeOf(context).height >= 660;

    void goTo(int index) {
      navigationShell.goBranch(
        index,
        initialLocation: index == navigationShell.currentIndex,
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(destinations[currentIndex].label),
        leading: isPhone ? const DrawerButton() : null,
        actions: const [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4),
            child: SyncStatusChip(),
          ),
          _ThemeMenuButton(),
          _UserMenuButton(),
          SizedBox(width: 4),
        ],
      ),
      drawer: isPhone
          ? _AppDrawer(
              destinations: destinations,
              currentIndex: currentIndex,
              onSelected: goTo,
            )
          : null,
      body: Row(
        children: [
          if (!isPhone)
            NavigationRail(
              selectedIndex: currentIndex,
              onDestinationSelected: goTo,
              extended: extendedLabels,
              labelType: showRailLabels
                  ? NavigationRailLabelType.all
                  : NavigationRailLabelType.none,
              destinations: [
                for (final destination in destinations)
                  NavigationRailDestination(
                    icon: Icon(destination.icon),
                    selectedIcon: Icon(destination.activeIcon),
                    label: Text(destination.label),
                  ),
              ],
            ),
          if (!isPhone) const VerticalDivider(width: 1),
          Expanded(child: navigationShell),
        ],
      ),
      bottomNavigationBar: isPhone && currentIndex < primaryBranchCount
          ? NavigationBar(
              selectedIndex: currentIndex,
              onDestinationSelected: goTo,
              destinations: [
                for (final destination
                    in destinations.take(primaryBranchCount))
                  NavigationDestination(
                    icon: Icon(destination.icon),
                    selectedIcon: Icon(destination.activeIcon),
                    label: destination.label,
                  ),
              ],
            )
          : null,
    );
  }
}

class _AppDrawer extends ConsumerWidget {
  const _AppDrawer({
    required this.destinations,
    required this.currentIndex,
    required this.onSelected,
  });

  final List<_NavDestination> destinations;
  final int currentIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final session = ref.watch(sessionControllerProvider);
    final user = session is AuthStateAuthenticated ? session.user : null;

    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(
                    Icons.storefront_rounded,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.appTitle,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        if (user != null)
                          Text(
                            user.displayName(Localizations.localeOf(context)),
                            style: Theme.of(context).textTheme.bodySmall,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  for (var i = 0; i < destinations.length; i++)
                    ListTile(
                      leading: Icon(
                        i == currentIndex
                            ? destinations[i].activeIcon
                            : destinations[i].icon,
                      ),
                      title: Text(destinations[i].label),
                      selected: i == currentIndex,
                      onTap: () {
                        Navigator.of(context).pop();
                        onSelected(i);
                      },
                    ),
                ],
              ),
            ),
            const Divider(height: 1),
            const _ThemeMenuTile(),
            ListTile(
              leading: const Icon(Icons.logout_rounded),
              title: Text(l10n.signOut),
              onTap: () async {
                final confirmed = await showConfirmDialog(
                  context,
                  title: l10n.logoutConfirmTitle,
                  message: l10n.logoutConfirmMessage,
                  confirmLabel: l10n.signOut,
                  destructive: true,
                );
                if (!context.mounted) return;
                Navigator.of(context).pop();
                if (confirmed) {
                  ref.read(sessionControllerProvider.notifier).logout();
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ThemeMenuButton extends ConsumerWidget {
  const _ThemeMenuButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(themeModeProvider);
    return PopupMenuButton<ThemeMode>(
      tooltip: context.l10n.theme,
      icon: Icon(
        mode == ThemeMode.dark
            ? Icons.dark_mode_outlined
            : mode == ThemeMode.light
                ? Icons.light_mode_outlined
                : Icons.brightness_auto_outlined,
      ),
      onSelected: (value) =>
          ref.read(themeModeProvider.notifier).set(value),
      itemBuilder: (context) => [
        PopupMenuItem(
          value: ThemeMode.system,
          child: Text(context.l10n.themeSystem),
        ),
        PopupMenuItem(
          value: ThemeMode.light,
          child: Text(context.l10n.themeLight),
        ),
        PopupMenuItem(
          value: ThemeMode.dark,
          child: Text(context.l10n.themeDark),
        ),
      ],
    );
  }
}

class _ThemeMenuTile extends ConsumerWidget {
  const _ThemeMenuTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final mode = ref.watch(themeModeProvider);
    final label = mode == ThemeMode.dark
        ? l10n.themeDark
        : mode == ThemeMode.light
            ? l10n.themeLight
            : l10n.themeSystem;
    return ListTile(
      leading: const Icon(Icons.brightness_6_outlined),
      title: Text(l10n.theme),
      subtitle: Text(label),
      onTap: () {
        final next = switch (mode) {
          ThemeMode.system => ThemeMode.light,
          ThemeMode.light => ThemeMode.dark,
          ThemeMode.dark => ThemeMode.system,
        };
        ref.read(themeModeProvider.notifier).set(next);
      },
    );
  }
}



class _UserMenuButton extends ConsumerWidget {
  const _UserMenuButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final session = ref.watch(sessionControllerProvider);
    if (session is! AuthStateAuthenticated) return const SizedBox.shrink();
    return PopupMenuButton<String>(
      tooltip: session.user.displayName(Localizations.localeOf(context)),
      icon: const Icon(Icons.account_circle_outlined),
      onSelected: (value) async {
        if (value == 'logout') {
          final confirmed = await showConfirmDialog(
            context,
            title: l10n.logoutConfirmTitle,
            message: l10n.logoutConfirmMessage,
            confirmLabel: l10n.signOut,
            destructive: true,
          );
          if (confirmed && context.mounted) {
            ref.read(sessionControllerProvider.notifier).logout();
          }
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem<String>(
          enabled: false,
          child: Text(
            session.user.username,
            style: Theme.of(context).textTheme.labelLarge,
          ),
        ),
        const PopupMenuDivider(),
        PopupMenuItem<String>(
          value: 'logout',
          child: Row(
            children: [
              const Icon(Icons.logout_rounded, size: 20),
              const SizedBox(width: 10),
              Text(l10n.signOut),
            ],
          ),
        ),
      ],
    );
  }
}
