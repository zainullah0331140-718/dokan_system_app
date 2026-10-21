import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../di/providers.dart';
import '../l10n/l10n_extensions.dart';

final pendingSyncCountProvider = StreamProvider<int>((ref) {
  return ref.watch(outboxDaoProvider).watchPendingCount();
});

class SyncStatusChip extends ConsumerWidget {
  const SyncStatusChip({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pending = ref.watch(pendingSyncCountProvider).value ?? 0;
    final l10n = context.l10n;
    final color = pending == 0
        ? Colors.green
        : pending < 50
            ? Colors.orange
            : Colors.red;
    final icon = pending == 0
        ? Icons.cloud_done_rounded
        : Icons.cloud_upload_rounded;

    return Tooltip(
      message: '${l10n.statPendingSync}: $pending',
      child: Chip(
        visualDensity: VisualDensity.compact,
        avatar: Icon(icon, size: 16, color: color),
        label: Text(
          pending == 0 ? '0' : '$pending',
          style: Theme.of(context).textTheme.labelMedium,
        ),
        side: BorderSide(color: color.withValues(alpha: 0.4)),
      ),
    );
  }
}
