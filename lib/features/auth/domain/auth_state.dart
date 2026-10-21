import 'dart:ui' show Locale;

import '../../../core/constants/permissions.dart';

sealed class AuthState {
  const AuthState();
}

class AuthStateLoading extends AuthState {
  const AuthStateLoading();
}

class AuthStateUnauthenticated extends AuthState {
  const AuthStateUnauthenticated();
}

class AuthStateAuthenticated extends AuthState {
  const AuthStateAuthenticated({required this.user});

  final AppUser user;
}

class AppUser {
  const AppUser({
    required this.id,
    required this.username,
    required this.fullName,
    required this.fullNameAr,
    required this.branchId,
    required this.roleNames,
    required this.permissions,
    required this.mustChangePin,
  });

  final String id;
  final String username;
  final String fullName;
  final String? fullNameAr;
  final String? branchId;
  final List<String> roleNames;
  final List<String> permissions;
  final bool mustChangePin;

  bool get isAdmin =>
      permissions.contains(PermissionCodes.all) || roleNames.contains('admin');

  bool hasPermission(String code) =>
      code == PermissionCodes.all ||
      permissions.contains(PermissionCodes.all) ||
      permissions.contains(code);

  String displayName(Locale locale) =>
      locale.languageCode == 'ar' && fullNameAr?.isNotEmpty == true
          ? fullNameAr!
          : fullName;
}

enum LoginError {
  invalidCredentials,
  inactive,
  locked,
}

sealed class LoginResult {
  const LoginResult();
}

class LoginSuccess extends LoginResult {
  const LoginSuccess({required this.user, required this.mustChangePin});

  final AppUser user;
  final bool mustChangePin;
}

class LoginFailure extends LoginResult {
  const LoginFailure(this.error, {this.retryAfter});

  final LoginError error;
  final Duration? retryAfter;
}
