import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/dokan_database.dart';
import '../../../core/di/providers.dart';
import '../../../core/utils/money.dart';
import '../../../core/widgets/money_text.dart';
import '../../../features/auth/domain/auth_state.dart';
import '../../../features/auth/presentation/session_controller.dart';
import '../data/shifts_providers.dart';

class ShiftsScreen extends ConsumerWidget {
  const ShiftsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final openShift = ref.watch(currentOpenShiftProvider);
    final history = ref.watch(shiftHistoryProvider);

    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          openShift.when(
            loading: () => const LinearProgressIndicator(),
            error: (e, _) => Text('Error: $e'),
            data: (shift) => shift == null
                ? const _ClosedRegisterCard()
                : _OpenRegisterCard(shift: shift),
          ),
          const SizedBox(height: 24),
          Text(
            'Recent shifts',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          history.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Text('Error: $e'),
            data: (list) => list.isEmpty
                ? const Text('No shifts yet')
                : Column(
                    children: [
                      for (final s in list)
                        ListTile(
                          leading: Icon(
                            s.status == ShiftStatus.open
                                ? Icons.lock_open_outlined
                                : Icons.lock_outline,
                          ),
                          title: Text(
                            s.status == ShiftStatus.open ? 'Open' : 'Closed',
                          ),
                          subtitle: Text(
                            _fmt(s.openedAt) +
                                (s.closedAt != null
                                    ? ' → ${_fmt(s.closedAt!)}'
                                    : ''),
                          ),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Text('Expected'),
                              MoneyText(
                                minor: s.expectedCashMinor,
                                symbol: r'$',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              if (s.status == ShiftStatus.closed)
                                MoneyText(
                                  minor: s.differenceMinor,
                                  symbol: r'$',
                                  signed: true,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        color: s.differenceMinor == 0
                                            ? null
                                            : Theme.of(context).colorScheme.error,
                                      ),
                                ),
                            ],
                          ),
                        ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

String _fmt(DateTime dt) {
  final local = dt.toLocal();
  final d = local.day.toString().padLeft(2, '0');
  final m = local.month.toString().padLeft(2, '0');
  final h = local.hour.toString().padLeft(2, '0');
  final min = local.minute.toString().padLeft(2, '0');
  return '$d/$m $h:$min';
}

class _ClosedRegisterCard extends ConsumerWidget {
  const _ClosedRegisterCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionControllerProvider);
    if (session is! AuthStateAuthenticated) {
      return const SizedBox.shrink();
    }
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Register is closed',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 4),
            const Text('Open the register to start selling.'),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () => showOpenRegisterDialog(context, ref, session.user.id,
                  session.user.branchId ?? 'branch-main'),
              icon: const Icon(Icons.lock_open_outlined),
              label: const Text('Open Register'),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> showOpenRegisterDialog(
  BuildContext context,
  WidgetRef ref,
  String userId,
  String branchId,
) async {
  final ctrl = TextEditingController(text: '0');
  final result = await showDialog<int>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Open Register'),
      content: TextField(
        controller: ctrl,
        decoration: const InputDecoration(
          labelText: 'Opening cash',
          border: OutlineInputBorder(),
        ),
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        autofocus: true,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () =>
              Navigator.of(dialogContext).pop(toMinor(ctrl.text)),
          child: const Text('Open'),
        ),
      ],
    ),
  );
  if (result == null) return;
  await ref.read(shiftsDaoProvider).openShift(
        userId: userId,
        branchId: branchId,
        openingCashMinor: result,
      );
  ref.invalidate(currentOpenShiftProvider);
}

class _OpenRegisterCard extends ConsumerWidget {
  const _OpenRegisterCard({required this.shift});

  final Shift shift;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.lock_open_outlined,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Register open',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 24,
              runSpacing: 8,
              children: [
                _stat(context, 'Opening', shift.openingCashMinor),
                _stat(context, 'Cash sales', shift.cashSalesMinor),
                _stat(context, 'Cash in', shift.cashInMinor),
                _stat(context, 'Cash out', shift.cashOutMinor),
                _stat(context, 'Expected', shift.expectedCashMinor),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              children: [
                OutlinedButton.icon(
                  onPressed: () => _cashDialog(context, ref, cashIn: true),
                  icon: const Icon(Icons.add_circle_outline),
                  label: const Text('Cash In'),
                ),
                OutlinedButton.icon(
                  onPressed: () => _cashDialog(context, ref, cashIn: false),
                  icon: const Icon(Icons.remove_circle_outline),
                  label: const Text('Cash Out'),
                ),
                FilledButton.icon(
                  onPressed: () => _closeDialog(context, ref),
                  icon: const Icon(Icons.lock_outline),
                  label: const Text('Close Register'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _stat(BuildContext context, String label, int minor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelMedium),
        MoneyText(
          minor: minor,
          symbol: r'$',
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ],
    );
  }

  Future<void> _cashDialog(BuildContext context, WidgetRef ref,
      {required bool cashIn}) async {
    final amountCtrl = TextEditingController(text: '0');
    final reasonCtrl = TextEditingController();
    final result = await showDialog<(int, String?)>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(cashIn ? 'Cash In' : 'Cash Out'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: amountCtrl,
              decoration: const InputDecoration(
                labelText: 'Amount',
                border: OutlineInputBorder(),
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              autofocus: true,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: reasonCtrl,
              decoration: const InputDecoration(
                labelText: 'Reason (optional)',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext)
                .pop((toMinor(amountCtrl.text), reasonCtrl.text.trim())),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (result == null) return;
    final (amount, reason) = result;
    if (amount <= 0) return;
    final session = ref.read(sessionControllerProvider);
    final userId = session is AuthStateAuthenticated ? session.user.id : null;
    await ref.read(shiftsDaoProvider).addCashTransaction(
          shiftId: shift.id,
          type: cashIn ? ShiftTxType.cashIn : ShiftTxType.cashOut,
          amountMinor: amount,
          reason: reason,
          userId: userId,
        );
    ref.invalidate(currentOpenShiftProvider);
  }

  Future<void> _closeDialog(BuildContext context, WidgetRef ref) async {
    final countedCtrl = TextEditingController(
      text: (shift.expectedCashMinor / 100).toStringAsFixed(2),
    );
    final result = await showDialog<int>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Close Register'),
        content: TextField(
          controller: countedCtrl,
          decoration: const InputDecoration(
            labelText: 'Counted cash',
            border: OutlineInputBorder(),
          ),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.of(dialogContext).pop(toMinor(countedCtrl.text)),
            child: const Text('Close'),
          ),
        ],
      ),
    );
    if (result == null) return;
    await ref.read(shiftsDaoProvider).closeShift(
          shiftId: shift.id,
          countedCashMinor: result,
        );
    ref.invalidate(currentOpenShiftProvider);
    ref.invalidate(shiftHistoryProvider);
  }
}
