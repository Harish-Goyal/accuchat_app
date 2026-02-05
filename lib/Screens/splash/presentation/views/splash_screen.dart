
import 'package:AccuChat/Constants/assets.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:AccuChat/Screens/splash/presentation/controllers/splash_controller.dart';

class SplashScreen extends GetView<SplashController> {
  const SplashScreen({super.key});

  static const String asset = appIcon;
  static const double size  = 210;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: GetBuilder<SplashController>(
        builder: (controller) {
          return Center(
            child: AnimatedBuilder(
              animation: controller.c,
              builder: (_, __) {
                return Opacity(
                  opacity: controller.fade.value,
                  child: Transform.rotate(
                    angle: controller.rotate.value,
                    child: Transform.scale(
                      scale: controller.scale.value,
                      child: Image.asset(
                        asset,
                        width: size,
                        height: size,
                        fit: BoxFit.contain,
                        filterQuality: FilterQuality.high,
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        }
      ),
    );
  }
}




