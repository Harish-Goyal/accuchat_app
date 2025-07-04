import 'package:AccuChat/Screens/chat_module/binding/binding.dart';
import 'package:AccuChat/Screens/chat_module/presentation/controllers/user_chat_list_controller.dart';
import 'package:AccuChat/Services/APIs/Chat_service/chat_api_servcie_impl.dart';
import 'package:get/get.dart';

import '../../../Services/APIs/auth_service/auth_api_services_impl.dart';
import '../../../Services/APIs/post/post_api_service_impl.dart';
import '../presentation/controllers/splash_controller.dart';


class SplashBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SplashController>(
      () => SplashController(),
    );

    // Get.put(() => GetLoginModalService(),permanent: true);
  }
}

class InitBinding extends Bindings {
  @override
  void dependencies() {

    Get.lazyPut<AuthApiServiceImpl>(
      () => AuthApiServiceImpl(),

    );

    Get.lazyPut<PostApiServiceImpl>(
      () => PostApiServiceImpl(),
    );
    // Get.lazyPut<ChatApiServiceImpl>(
    //   () => ChatApiServiceImpl(),
    // );
    // Get.lazyPut<ChatBinding>(
    //   () => ChatBinding(),
    // );
    // Get.lazyPut<GroupMemberBinding>(
    //   () => GroupMemberBinding(),
    // );
// Get.lazyPut<ProfileBinding>(
//       () => ProfileBinding(),
//     );


    // Get.put<ChatUserListBinding>(ChatUserListBinding());
  }
}
