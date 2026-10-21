import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/dokan_database.dart';
import '../../../core/di/providers.dart';
import '../../../features/auth/domain/auth_state.dart';
import '../../../features/auth/presentation/session_controller.dart';

String? _currentUserId(Ref ref) {
  final session = ref.watch(sessionControllerProvider);
  return session is AuthStateAuthenticated ? session.user.id : null;
}

String _currentBranchId(Ref ref) {
  final session = ref.watch(sessionControllerProvider);
  if (session is AuthStateAuthenticated && session.user.branchId != null) {
    return session.user.branchId!;
  }
  return 'branch-main';
}

final currentOpenShiftProvider = StreamProvider<Shift?>((ref) {
  final userId = _currentUserId(ref);
  if (userId == null) return Stream.value(null);
  final branchId = _currentBranchId(ref);
  return ref.watch(shiftsDaoProvider).watchOpenShift(userId, branchId);
});

final shiftHistoryProvider = StreamProvider<List<Shift>>((ref) {
  return ref.watch(shiftsDaoProvider).watchRecent(limit: 30);
});

final shiftTransactionsProvider =
    StreamProvider.family<List<ShiftTransaction>, String>((ref, shiftId) {
  return ref.watch(shiftsDaoProvider).watchTransactions(shiftId);
});
