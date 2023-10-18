import 'package:get/get.dart';

import '../../../../core/models/day_event_model.dart';
import '../../../../core/user_data/user.dart';

class WorkingOutController extends GetxController {

  bool get showContent => CurrentUser.tariffIsOrion();

  late final List<DayEventModel> dayEvents;

  @override
  void onInit() async {
    // TODO: implement onInit
    super.onInit();


  }

}