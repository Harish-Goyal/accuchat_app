import 'package:AccuChat/Screens/Home/Presentation/Controller/home_controller.dart';
import 'package:get/get.dart';

class DashboardBinding extends Bindings{
  @override
  void dependencies() {
    Get.put<DashboardController>(DashboardController());
  }

}