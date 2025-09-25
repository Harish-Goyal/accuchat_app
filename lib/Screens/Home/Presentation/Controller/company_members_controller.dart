import 'package:AccuChat/Screens/Home/Presentation/Controller/compnaies_controller.dart';
import 'package:AccuChat/main.dart';
import 'package:AccuChat/utils/custom_flashbar.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../../../../Services/APIs/local_keys.dart';
import '../../../../Services/APIs/post/post_api_service_impl.dart';
import '../../../Chat/api/apis.dart';
import '../../../Chat/models/invite_model.dart';
import '../../../Chat/models/get_company_res_model.dart';
import '../../../Chat/screens/auth/models/get_uesr_Res_model.dart';
import '../../Models/company_mem_res_model.dart';
import 'company_service.dart';

class CompanyMemberController extends GetxController{

  late Future<List<InvitationModel>> invitationsFuture;

  var companyId;
  var companyName;
  // List<Members> members=[];

  @override
  void onInit() {
    super.onInit();
    getArguments();
    initData();
  }

  getArguments(){
    if (kIsWeb) {
      companyId = Get.parameters['companyId'];
      //company members api
      // members = Get.parameters['members'];
      companyName = Get.parameters['companyName'];
    } else if(Get.arguments!=null){
      companyId = Get.arguments['companyId'];
      // members = Get.arguments['members'];
      companyName = Get.arguments['companyName'];
    }
  }

  bool isLoading = true;
  initData() async {
    _getCompany();
    _getMe();
    hitAPIToGetMember();

  }


  CompanyData? myCompany = CompanyData();
  _getCompany()async{
    final svc     = Get.find<CompanyService>();
    myCompany = svc.selected;
    update();


  }

  UserDataAPI? me = UserDataAPI();
  _getMe(){
    me = getUser();
    update();
  }

  hitAPIToRemoveMember(memId) async {
    customLoader.show();
    Get.find<PostApiServiceImpl>()
        .removeComMemberApiCall(compId: companyId,memberId: memId)
        .then((value) async {
          customLoader.hide();
      toast(value.message??'');
      Get.find<CompaniesController>().hitAPIToGetCompanies();
      hitAPIToGetMember();
      update();
    }).onError((error, stackTrace) {
      update();
      customLoader.hide();
    });
  }


  ComMemResModel comMemResModel = ComMemResModel();
  List<UserDataAPI> members=[];

 hitAPIToGetMember() async {
    Get.find<PostApiServiceImpl>()
        .getComMemApiCall(companyId)
        .then((value) async {
          isLoading = false;
          comMemResModel=value;
          members = value.data??[];
         print("members.length");
         print(members.length);
      update();
    }).onError((error, stackTrace) {
      isLoading = false;
      update();
    });
  }

}