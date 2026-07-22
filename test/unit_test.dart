
// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:riva_psy/core/models/calendar/month_model.dart';
import 'package:riva_psy/core/models/tariff_model.dart';
import 'package:riva_psy/core/user_data/user.dart';

void main() {
  group('Testing unit cases', (){
    /*test('test month model', () {
      MonthModel monthModel = MonthModel(currentMonth: DateTime(2023, 7), dayEvents: []);
      expect(31, monthModel.getMonthLength(monthModel.currentMonth));
    });*/

   /* test('test month model 2', () {
      MonthModel monthModel = MonthModel(currentMonth: DateTime(2023, 7), dayEvents: []);
      DateTime date = DateTime(monthModel.currentMonth.year, monthModel.currentMonth.month + 1);
      expect(5, monthModel.getInactiveDays(date).length);
    });*/

    /*test('test month model 3', () {
      MonthModel monthModel = MonthModel(currentMonth: DateTime(2023, 7), dayEvents: []);
      expect(42, monthModel.initializeMonth().length);
    });*/
  });

  group('Testing user cases', (){
    test('test month model', () {
      /*final _tariff = TariffModel(name: '', endDate: DateTime(2023, 03, 24), description: '', cost: 1, advantages: []);
        expect(false, CurrentUser.repo.checkActualTariff(_tariff));*/
    });
  });
}
