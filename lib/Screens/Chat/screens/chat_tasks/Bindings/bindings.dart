import 'package:AccuChat/Screens/Chat/screens/chat_tasks/Presentation/Controllers/all_user_controller.dart';
import 'package:AccuChat/Screens/Chat/screens/chat_tasks/Presentation/Controllers/chat_screen_controller.dart';
import 'package:AccuChat/Screens/Chat/screens/chat_tasks/Presentation/Controllers/chats_broadcasts_controller.dart';
import 'package:AccuChat/Screens/Chat/screens/chat_tasks/Presentation/Controllers/create_broadcats_controller.dart';
import 'package:AccuChat/Screens/Chat/screens/chat_tasks/Presentation/Controllers/task_controller.dart';
import 'package:AccuChat/Screens/Chat/screens/chat_tasks/Presentation/Controllers/task_thread_controller.dart';
import 'package:AccuChat/Screens/Chat/screens/chat_tasks/Presentation/Controllers/view_profile_controller.dart';
import 'package:get/get.dart';
import '../../../../Home/Presentation/Controller/socket_controller.dart';
import '../../../api/apis.dart';
import '../Presentation/Controllers/add_broadcard_mem_controller.dart';
import '../Presentation/Controllers/add_group_mem_controller.dart';
import '../Presentation/Controllers/chat_home_controller.dart';
import '../Presentation/Controllers/members_gr_br_controller.dart';
import '../Presentation/Controllers/save_in_accuchat_gallery_controller.dart';
import '../Presentation/Controllers/task_home_controller.dart';

class AddBroadcastsMemBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<AddBroadcastMemController>(AddBroadcastMemController());
  }
}

class AddGroupMemBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<AddGroupMemController>(AddGroupMemController());
  }
}

class GrBrMemberBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<GrBrMembersController>(GrBrMembersController());

  }
}

class AllUserScreenBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<AllUserController>(AllUserController());
  }
}

class GroupChatBinding extends Bindings {
  @override
  void dependencies() {
    // Get.put<GroupController>(GroupController());
  }
}

class ChatHomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<ChatHomeController>(ChatHomeController());
  }
}class TaskHomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<TaskHomeController>(TaskHomeController());
  }
}

class ChatScreenBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<ChatScreenController>(ChatScreenController());

  }
}

class TaskScreenBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<TaskController>(TaskController());
  }
}

class ChatBroadcastBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<ChatsBroadcastsController>(ChatsBroadcastsController());
  }
}

class CreateBroadcastBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<CreateBroadcastsController>(CreateBroadcastsController());
  }
}

class TaskThreadBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TaskThreadController>(() => TaskThreadController(),
        fenix: true);
  }
}
class ViewProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<ViewProfileController>(ViewProfileController());
  }
}
