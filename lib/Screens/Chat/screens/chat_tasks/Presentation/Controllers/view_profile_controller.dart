import 'package:AccuChat/Screens/Chat/screens/auth/models/get_uesr_Res_model.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../../../../../../Services/APIs/post/post_api_service_impl.dart';
import '../../../../../../utils/custom_flashbar.dart';
import '../../../../../Home/Presentation/Controller/company_service.dart';
import '../../../../models/chat_user.dart';
import '../../../../models/get_company_res_model.dart';


class ViewProfileController extends GetxController {
  UserDataAPI? user;
  @override
  void onInit() {
    _getCompany();
    getArguments();
    super.onInit();
  }

  getArguments(){
    if(kIsWeb){

      if(Get.parameters!=null) {
        String? userId = Get.parameters['userId'];
        getUserByIdApi(userId: int.parse(userId??''));
      }
    }else{
      if(Get.arguments!=null) {
        user = Get.arguments['user'];
      }
    }

  }


  CompanyData? myCompany = CompanyData();
  _getCompany() {
    final svc = Get.find<CompanyService>();
    myCompany = svc.selected;
    update();
  }

  getUserByIdApi({int? userId}) async {
    Get.find<PostApiServiceImpl>()
        .getUserByApiCall(userID: userId,comid: myCompany?.companyId)
        .then((value) async {
      user = value.data;
      update();
    }).onError((error, stackTrace) {
      update();
      errorDialog(error.toString());
    }).whenComplete(() {});
  }
}