import 'package:get/get.dart';

class AppBadgeController extends GetxController {
  static AppBadgeController get to => Get.find();

  RxInt chatUnread = 0.obs;

  void setChatUnread(int count) {
    chatUnread.value = count;
  }

  void resetChatUnread() {
    chatUnread.value = 0;
  }
}