import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

const String DD_MM_YYYY = 'dd/MM/yyyy';

extension DateTimeExtension on DateTime {
  /// Return a string representing [date] formatted according to our locale
  String format([String pattern = DD_MM_YYYY, String? locale]) {
    if (locale != null && locale.isNotEmpty) {
      initializeDateFormatting(locale);
    }
    return DateFormat(pattern, locale).format(this);
  }

  String formatForRecord([String pattern = DD_MM_YYYY, String? locale]) {
    if (locale != null && locale.isNotEmpty) {
      initializeDateFormatting(locale);
    }
    return DateFormat(pattern, locale).format(this);
  }

  bool dateInRange(DateTime dateStart, DateTime dateEnd) {
    var start = DateTime(dateStart.year, dateStart.month, dateStart.day -1 );
    var end = DateTime(dateEnd.year, dateEnd.month, dateEnd.day +1 );

    if (start.isBefore(this) && end.isAfter(this)) {
      return true;
    }
    return false;
  }
}
