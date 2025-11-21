import 'package:AccuChat/Screens/Home/Presentation/Controller/company_service.dart';
import 'package:AccuChat/Services/storage_service.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../../../Services/APIs/auth_service/auth_api_services_impl.dart';
import '../../../Services/APIs/post/post_api_service_impl.dart';
import '../../../utils/shares_pref_web.dart';
import '../../Chat/api/session_alive.dart';
import '../../Chat/models/get_company_res_model.dart';
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
  Future<void> dependencies() async {
    // if (!Get.isRegistered<AppStorage>()) {
      Get.putAsync<AppStorage>(() async {
        await AppStorage().init(boxName: 'accu_chat');            // this is safe & idempotent now
        return AppStorage();                // or a service wrapper if you have one
      }, permanent: true);
    // }

    await StorageService.init();

    Get.lazyPut<AuthApiServiceImpl>(
      () => AuthApiServiceImpl(),
    );


    Get.lazyPut<PostApiServiceImpl>(
      () => PostApiServiceImpl(),
    );
    // Get.put(StartupController(), permanent: true);

    Get.putAsync<Session>(() async {
      final s = Session(Get.find<AuthApiServiceImpl>(), Get.find<AppStorage>());

      CompanyData? selCompany;
      try {
        final svc = CompanyService.to;
        // OPTIONAL: if you add a `Future<void> ready` in CompanyService, await it here:
        // await svc.ready;
        selCompany = svc.selected; // may be null on clean install
      } catch (_) {}
      // company may not exist yet on fresh install:
      await s.initSafe(companyId: selCompany?.companyId??0); // <-- works with null/0
      return s;
    }, permanent: true);
  }
}
