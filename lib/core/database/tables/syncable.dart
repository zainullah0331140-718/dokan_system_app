import 'package:drift/drift.dart';

import '../enums.dart';

abstract class SyncableTable extends Table {
  TextColumn get syncStatus =>
      textEnum<SyncStatus>().withDefault(const Constant('local'))();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  IntColumn get version => integer().withDefault(const Constant(1))();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
}
