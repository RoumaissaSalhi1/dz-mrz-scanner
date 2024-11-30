import 'package:get/get.dart';
 import 'package:mrz_new/features/idcard/new_id_card_camera.dart';
import 'package:mrz_new/features/passport/passport_camera.dart';

abstract class HomeController extends GetxController {
  goToPassport();
  goToIdCard();
}

class HomeControllerImp extends HomeController {
  @override
  goToIdCard() {
    Get.to(() => const NewIdCardCamera());
  }

  @override
  goToPassport() {
    Get.to(() => const PassportCamera());
  }
}
