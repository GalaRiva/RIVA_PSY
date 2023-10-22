extension DateInString on int {
  String dayInText() {
    switch (this) {
      case 1:
        return 'Понедельник';
      case 2:
        return 'Вторник';
      case 3:
        return 'Среда';
      case 4:
        return 'Четверг';
      case 5:
        return 'Пятница';
      case 6:
        return 'Суббота';
      default:
        return 'Воскресение';
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
