import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

class K3Controller extends GetxController {

RxList<K3Model> list = [K3Model(1)..selected=true, K3Model(2), K3Model(0),].obs;
  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }
}

class K3Model {
  final int quantity;
  bool selected = false;

  K3Model(this.quantity);
}
