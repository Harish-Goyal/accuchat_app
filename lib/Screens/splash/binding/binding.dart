import 'package:AccuChat/Screens/Home/Presentation/Controller/company_service.dart';
import 'package:get/get.dart';

import '../../../Services/APIs/auth_service/auth_api_services_impl.dart';
import '../../../Services/APIs/post/post_api_service_impl.dart';
import '../../Home/Presentation/Controller/socket_controller.dart';
import '../presentation/controllers/splash_controller.dart';


class SplashBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SplashController>(
      () => SplashController(),
    );

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
    Get.put(StartupController(), permanent: true);
  }
}
