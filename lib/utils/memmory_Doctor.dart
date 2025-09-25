// memory_doctor.dart
import 'package:AccuChat/Screens/Chat/screens/chat_tasks/Presentation/Controllers/chat_home_controller.dart';
import 'package:AccuChat/Screens/Chat/screens/chat_tasks/Presentation/Controllers/task_home_controller.dart';
import 'package:AccuChat/Screens/Chat/screens/chat_tasks/Presentation/Controllers/view_profile_controller.dart';
import 'package:AccuChat/Screens/Home/Presentation/Controller/home_controller.dart';
import 'package:flutter/painting.dart';
import 'package:get/get.dart';
class MemoryDoctor {
  static Future<void> deflateBeforeNav() async {
    // Clear decoded images
    final cache = PaintingBinding.instance.imageCache;
    cache.clear();
    cache.clearLiveImages();

    // (optional) chhota sa yield so GC chal sake
    await Future<void>.delayed(const Duration(milliseconds: 1));
  }

  static void disposeFeatureControllers() {
    _safeDelete<ChatHomeController>();
    _safeDelete<TaskHomeController>();
    _safeDelete<DashboardController>();
    _safeDelete<ViewProfileController>();
  }

  static void _safeDelete<T extends GetxController>() {
    if (Get.isRegistered<T>()) {
      Get.delete<T>(force: true);
    }
  }
}
