import 'package:AccuChat/Screens/Chat/api/session_alive.dart';
import 'package:AccuChat/Screens/Chat/models/get_company_res_model.dart';
import 'package:AccuChat/Screens/Home/Presentation/Controller/company_service.dart';
import 'package:AccuChat/Services/APIs/post/post_api_service_impl.dart';
import 'package:AccuChat/utils/helper_widget.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../../Services/APIs/auth_service/auth_api_services_impl.dart';
import '../../../../../../main.dart';
import '../../../../../../routes/app_routes.dart';
import '../../../../../../utils/shares_pref_web.dart';
import '../../models/pending_invites_res_model.dart';

class LandingScreenController extends GetxController {
  @override
  void onInit() {

    initWhenl();
    hitAPIToGetCompanies();
    super.onInit();
  }

  initWhenl() async {
    // final c =Get.put(CompanyService());
    // final d =Get.put(Session(Get.find<AuthApiServiceImpl>(), Get.find<AppStorage>()));
    // c.init();
    // d.initSafe();

  }

  bool loadingCompany = true;
  bool isLoadingPendingInvites = false;

  CompanyResModel companyResModel = CompanyResModel();

  List<CompanyData> joinedCompaniesList = [];


  hitAPIToGetCompanies() async {
    Get.find<PostApiServiceImpl>()
        .getJoinedCompanyListApiCall()
        .then((value) async {
      loadingCompany = false;
      companyResModel=value;
      joinedCompaniesList = companyResModel.data??[];
      update();
    }).onError((error, stackTrace) {
      loadingCompany = false;
      update();
    });
  }


  List<PendingInvitesList> pendingInvites = [];
  hitAPIToGetPendingInvites(userInput) async {
    customLoader.show();
    isLoadingPendingInvites=true;
    update();
    Get.find<PostApiServiceImpl>()
        .pendingInviteListApiCall(userInput:userInput )
        .then((value) async {
      pendingInvites=value.data??[];
      isLoadingPendingInvites=false;
      update();
      customLoader.hide();
      if(pendingInvites.isEmpty){
        showDialog(
          context: Get.context!,
          builder: (_) => AlertDialog(
            title: const Text("Not Invited"),
            backgroundColor: Colors.white,
            content: const Text("You are not invited to any company. You can create your own company! Thanks!"),
            actions: [
              TextButton(
                onPressed: () => Get.back(),
                child: const Text("OK"),
              ),
            ],
          ),
        );
        return;
      }else{
        if(kIsWeb){
          openAcceptInviteDialog();
        }else{
          Get.toNamed(AppRoutes.accept_invite);
        }


      }


    }).onError((error, stackTrace) {
      isLoadingPendingInvites=false;
      update();
      customLoader.hide();
    });
  }





}
