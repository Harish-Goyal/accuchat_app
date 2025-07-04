
import 'package:AccuChat/utils/helper_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:AccuChat/Screens/splash/presentation/controllers/splash_controller.dart';

import '../../../../Constants/assets.dart';


class SplashScreen extends GetView<SplashController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: GetBuilder<SplashController>(
          builder: (controller) {
            return
              SizedBox(
                height: Get.height,
                width: Get.width,
                child:getAppLogo(height: 40.0),
              ).marginSymmetric(horizontal: 15);
          },
        ));
  }
}
