import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/di/providers.dart';
import '../data/auth_repository.dart';
import '../domain/auth_state.dart';

part 'session_controller.g.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.watch(databaseProvider));
});

@Riverpod(keepAlive: true)
class SessionController extends _$SessionController {
  @override
  AuthState build() => const AuthStateUnauthenticated();

  Future<LoginResult> login({
    required String username,
    required String pin,
  }) async {
    final result = await ref
        .read(authRepositoryProvider)
        .login(username: username, pin: pin);
    if (result is LoginSuccess) {
      state = AuthStateAuthenticated(user: result.user);
    }
    return result;
  }

  void logout() {
    state = const AuthStateUnauthenticated();
  }

  void updateUser(AppUser user) {
    final current = state;
    if (current is AuthStateAuthenticated) {
      state = AuthStateAuthenticated(user: user);
    }
  }
}
