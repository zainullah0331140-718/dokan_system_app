import 'package:flutter/material.dart';

import '../error/error_mapping.dart';
import '../l10n/l10n_extensions.dart';
import 'empty_state.dart';

class AppErrorView extends StatelessWidget {
  const AppErrorView({
    super.key,
    required this.error,
    this.onRetry,
    this.icon,
  });

  final Object error;
  final VoidCallback? onRetry;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final failure = mapErrorToFailure(error);
    return EmptyState(
      icon: icon ?? Icons.error_outline_rounded,
      title: localizeFailure(failure, l10n),
      action: onRetry == null
          ? null
          : FilledButton.tonalIcon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: Text(l10n.retry),
            ),
    );
  }
}
