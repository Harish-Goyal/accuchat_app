import 'package:AccuChat/Screens/chat_module/presentation/controllers/group_member_controller.dart';
import 'package:AccuChat/Screens/chat_module/presentation/controllers/profile_controller.dart';
import 'package:get/get.dart';

import '../presentation/controllers/chat_detail_controller.dart';
import '../presentation/controllers/user_chat_list_controller.dart';

class ChatBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(ChatDetailController());
  }
}
class ChatUserListBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(UserChatListController());
    Get.put(SocketController());
    // Get.lazyPut<SocketController>(()=>SocketController());
    // Get.lazyPut(()=>SocketController());

  }
}

class GroupMemberBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<UserChatListController>(()=>UserChatListController());
    Get.put(GroupController());
  }
}

class ProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(ProfileController());

  }
}

