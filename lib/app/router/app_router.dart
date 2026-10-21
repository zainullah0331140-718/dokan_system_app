import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/permissions.dart';
import '../../core/l10n/l10n_extensions.dart';
import '../../core/widgets/placeholder_view.dart';
import '../../features/auth/domain/auth_state.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/session_controller.dart';
import '../../features/customers/presentation/customers_list_screen.dart';
import '../../features/dashboard/presentation/dashboard_screen.dart';
import '../../features/products/presentation/products_list_screen.dart';
import '../../features/purchases/presentation/purchases_screen.dart';
import '../../features/reports/presentation/reports_screen.dart';
import '../../features/sales/presentation/pos_screen.dart';
import '../../features/shifts/presentation/shifts_screen.dart';
import '../shell/app_shell.dart';

const String loginPath = '/login';
const String forbiddenPath = '/forbidden';

final routerProvider = Provider<GoRouter>((ref) {
  final session = ValueNotifier<AuthState>(
    ref.read(sessionControllerProvider),
  );
  ref.listen<AuthState>(
    sessionControllerProvider,
    (_, next) => session.value = next,
  );
  ref.onDispose(session.dispose);

  final router = GoRouter(
    initialLocation: '/dashboard',
    refreshListenable: session,
    redirect: (context, state) =>
        _redirect(session.value, state.matchedLocation),
    routes: [
      GoRoute(
        path: loginPath,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: forbiddenPath,
        builder: (context, state) => const _ForbiddenScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            AppShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/dashboard',
                builder: (context, state) => const DashboardScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/sales',
                builder: (context, state) => const SalesScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/products',
                builder: (context, state) => const ProductsListScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/customers',
                builder: (context, state) => const CustomersListScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/inventory',
                builder: (context, state) => PlaceholderView(
                  title: context.l10n.navInventory,
                  icon: Icons.warehouse_outlined,
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/purchases',
                builder: (context, state) => const PurchasesScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/reports',
                builder: (context, state) => const ReportsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/shifts',
                builder: (context, state) => const ShiftsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/settings',
                builder: (context, state) => PlaceholderView(
                  title: context.l10n.navSettings,
                  icon: Icons.settings_outlined,
                ),
              ),
            ],
          ),
        ],
      ),
    ],
  );
  ref.onDispose(router.dispose);
  return router;
});

String? _redirect(AuthState session, String location) {
  final atLogin = location == loginPath;

  if (session is! AuthStateAuthenticated) {
    return atLogin ? null : loginPath;
  }
  if (atLogin) {
    return '/dashboard';
  }
  final requiredPermission = _requiredPermission(location);
  if (requiredPermission != null &&
      !session.user.hasPermission(requiredPermission)) {
    return forbiddenPath;
  }
  return null;
}

String? _requiredPermission(String location) {
  if (location.startsWith('/sales')) return PermissionCodes.salesCreate;
  if (location.startsWith('/products')) return PermissionCodes.productsView;
  if (location.startsWith('/customers')) return PermissionCodes.customersView;
  if (location.startsWith('/inventory')) return PermissionCodes.inventoryView;
  if (location.startsWith('/purchases')) return PermissionCodes.purchasesManage;
  if (location.startsWith('/reports')) return PermissionCodes.reportsSales;
  if (location.startsWith('/shifts')) return PermissionCodes.shiftsReport;
  if (location.startsWith('/settings')) return PermissionCodes.settingsManage;
  return null;
}

class _ForbiddenScreen extends StatelessWidget {
  const _ForbiddenScreen();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.navMore)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.lock_outline_rounded,
                size: 64,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                l10n.permissionDenied,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: () => context.go('/dashboard'),
                child: Text(l10n.navDashboard),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
