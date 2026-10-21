import 'package:dio/dio.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart' show SqliteException;

import '../l10n/generated/app_localizations.dart';
import 'failures.dart';

Failure mapErrorToFailure(Object error, [StackTrace? stackTrace]) {
  if (error is AppException) return error.failure;
  if (error is Failure) return error;
  if (error is DioException) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
        return NetworkFailure('Connection failed', code: 'net.timeout', cause: error);
      case DioExceptionType.badResponse:
        final status = error.response?.statusCode ?? 0;
        return NetworkFailure('Server responded with $status', code: 'net.$status', cause: error);
      case DioExceptionType.cancel:
        return const NetworkFailure('Request cancelled', code: 'net.cancel');
      case DioExceptionType.badCertificate:
        return const NetworkFailure('Invalid certificate', code: 'net.certificate');
      case DioExceptionType.transformTimeout:
        return const NetworkFailure('Response transformation failed', code: 'net.transform');
      case DioExceptionType.unknown:
        return NetworkFailure('Network error', code: 'net.unknown', cause: error);
    }
  }
  if (error is SqliteException) {
    return DatabaseFailure('SQLite error ${error.resultCode}', code: 'db.sqlite', cause: error);
  }
  if (error is DriftWrappedException || error.toString().contains('Drift')) {
    return DatabaseFailure('Database error', code: 'db.drift', cause: error);
  }
  if (error is StateError) {
    return ValidationFailure(error.message, cause: error);
  }
  if (error is ArgumentError) {
    return ValidationFailure(error.message ?? 'Invalid argument', cause: error);
  }
  if (error is FormatException) {
    return ValidationFailure(error.message, cause: error);
  }
  return UnknownFailure(error.toString(), cause: error);
}

String localizeFailure(Failure failure, AppLocalizations l10n) {
  return switch (failure) {
    DatabaseFailure() => l10n.errorDatabase,
    NetworkFailure() => l10n.errorNetwork,
    ValidationFailure() => l10n.errorValidation,
    PermissionFailure() => l10n.errorPermission,
    AuthFailure() => l10n.errorAuth,
    NotFoundFailure() => l10n.errorNotFound,
    ConflictFailure() => l10n.errorConflict,
    UnknownFailure() => l10n.errorUnknown,
  };
}
