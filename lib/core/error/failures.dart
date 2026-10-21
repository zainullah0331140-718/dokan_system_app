sealed class Failure {
  const Failure(this.message, {this.code, this.cause});

  final String message;
  final String? code;
  final Object? cause;
}

class DatabaseFailure extends Failure {
  const DatabaseFailure(super.message, {super.code, super.cause});
}

class NetworkFailure extends Failure {
  const NetworkFailure(super.message, {super.code, super.cause});
}

class ValidationFailure extends Failure {
  const ValidationFailure(super.message, {super.code, super.cause});
}

class PermissionFailure extends Failure {
  const PermissionFailure(super.message, {super.code, super.cause});
}

class AuthFailure extends Failure {
  const AuthFailure(super.message, {super.code, super.cause});
}

class NotFoundFailure extends Failure {
  const NotFoundFailure(super.message, {super.code, super.cause});
}

class ConflictFailure extends Failure {
  const ConflictFailure(super.message, {super.code, super.cause});
}

class UnknownFailure extends Failure {
  const UnknownFailure(super.message, {super.code, super.cause});
}

class AppException implements Exception {
  const AppException(this.failure, {this.stackTrace});

  final Failure failure;
  final StackTrace? stackTrace;

  @override
  String toString() => 'AppException(${failure.message})';
}
