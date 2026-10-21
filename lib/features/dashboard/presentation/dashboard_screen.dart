import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/l10n_extensions.dart';
import '../../../core/theme/breakpoints.dart';
import '../../../core/widgets/app_error_view.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../../core/widgets/money_text.dart';
import '../../auth/domain/auth_state.dart';
import '../../auth/presentation/session_controller.dart';
import '../data/dashboard_repository.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final stats = ref.watch(dashboardStatsProvider);
    final session = ref.watch(sessionControllerProvider);

    final user = session is AuthStateAuthenticated ? session.user : null;

    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(dashboardStatsProvider),
      child: stats.when(
        loading: () => const FullScreenLoading(),
        error: (error, _) => AppErrorView(
          error: error,
          onRetry: () => ref.invalidate(dashboardStatsProvider),
        ),
        data: (data) {
          final theme = Theme.of(context);
          final crossAxisCount = Breakpoints.isExpanded(context)
              ? 4
              : Breakpoints.isCompact(context)
                  ? 2
                  : 3;
          final aspectRatio = Breakpoints.isCompact(context) ? 1.4 : 1.7;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                l10n.dashboardTitle,
                style: theme.textTheme.headlineSmall
                    ?.copyWith(fontWeight: FontWeight.w700),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (user != null) ...[
                const SizedBox(height: 4),
                Text(
                  '${l10n.currentUser} '
                  '${user.displayName(Localizations.localeOf(context))}',
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      Icon(
                        Icons.verified_user_rounded,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          l10n.databaseReady,
                          style: theme.textTheme.bodyMedium,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              GridView.count(
                crossAxisCount: crossAxisCount,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: aspectRatio,
                children: [
                  _StatCard(
                    icon: Icons.inventory_2_outlined,
                    label: l10n.statProducts,
                    value: '${data.productCount}',
                  ),
                  _StatCard(
                    icon: Icons.people_outline_rounded,
                    label: l10n.statCustomers,
                    value: '${data.customerCount}',
                  ),
                  _StatCard(
                    icon: Icons.point_of_sale_rounded,
                    label: l10n.statTotalSales,
                    value: '${data.todaySalesCount}',
                  ),
                  _StatCard(
                    icon: Icons.sync_rounded,
                    label: l10n.statPendingSync,
                    value: '${data.pendingSync}',
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.navSales,
                        style: theme.textTheme.titleSmall
                            ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                      ),
                      const SizedBox(height: 8),
                      MoneyText(
                        minor: data.todayRevenueMinor,
                        symbol: r'$',
                        style: theme.textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20, color: theme.colorScheme.primary),
            const SizedBox(height: 6),
            Text(
              value,
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
