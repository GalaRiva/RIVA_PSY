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
        return 'Января';
      case 2:
        return 'Февраля';
      case 3:
        return 'Марта';
      case 4:
        return 'Апреля';
      case 5:
        return 'Мая';
      case 6:
        return 'Июня';
      case 7:
        return 'Июля';
      case 8:
        return 'Августа';
      case 9:
        return 'Сентября';
      case 10:
        return 'Октября';
      case 11:
        return 'Ноября';
      default:
        return 'Декабря';
    }
  }
}

extension DateTimeInString on DateTime {
  String dateInText() {
    return '''${this.day} ${this.month.monthInText()} ${this.year}''';
  }
}
