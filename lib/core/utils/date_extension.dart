import 'package:easy_localization/easy_localization.dart';

extension DateInString on int {
  String dayInText() {
    switch (this) {
      case 1:
        return 'monday'.tr();
      case 2:
        return 'tuesday'.tr();
      case 3:
        return 'wednesday'.tr();
      case 4:
        return 'thursday'.tr();
      case 5:
        return 'friday'.tr();
      case 6:
        return 'saturday'.tr();
      default:
        return 'sunday'.tr();
    }
  }

  String timeFormatted() {
    if (this < 10) {
      return '0$this';
    } else
      return this.toString();
  }

  String monthInText() {
    switch (this) {
      case 1:
        return 'january2'.tr();
      case 2:
        return 'february2'.tr();
      case 3:
        return 'march2'.tr();
      case 4:
        return 'april2'.tr();
      case 5:
        return 'may2'.tr();
      case 6:
        return 'june2'.tr();
      case 7:
        return 'july2'.tr();
      case 8:
        return 'august2'.tr();
      case 9:
        return 'september2'.tr();
      case 10:
        return 'october2'.tr();
      case 11:
        return 'november2'.tr();
      default:
        return 'december2'.tr();
    }
  }
}

extension DateTimeInString on DateTime {
  String dateInText() {
    return '''${this.day} ${this.month.monthInText()} ${this.year}''';
  }
}
