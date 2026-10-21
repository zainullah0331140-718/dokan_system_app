import 'package:intl/intl.dart';

DateTime _local(DateTime time) => time.toLocal();

String formatDate(DateTime time, {String locale = 'en'}) =>
    DateFormat.yMMMMd(locale).format(_local(time));

String formatShortDate(DateTime time, {String locale = 'en'}) =>
    DateFormat.yMd(locale).format(_local(time));

String formatTime(DateTime time, {String locale = 'en'}) =>
    DateFormat.jm(locale).format(_local(time));

String formatDateTime(DateTime time, {String locale = 'en'}) =>
    '${formatDate(time, locale: locale)} ${formatTime(time, locale: locale)}';

String formatDayKey(DateTime time) {
  final local = _local(time);
  final month = local.month.toString().padLeft(2, '0');
  final day = local.day.toString().padLeft(2, '0');
  return '${local.year}-$month-$day';
}

String formatMonthKey(DateTime time) {
  final local = _local(time);
  final month = local.month.toString().padLeft(2, '0');
  return '${local.year}-$month';
}

String formatInvoicePeriodKey(DateTime time) => formatDayKey(time);
