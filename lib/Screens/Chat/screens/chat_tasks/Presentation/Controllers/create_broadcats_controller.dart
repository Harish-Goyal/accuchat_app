import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../../../../../Services/APIs/local_keys.dart';
import '../../../../../../Services/APIs/post/post_api_service_impl.dart';
import '../../../../../../main.dart';
import '../../../../../../utils/custom_flashbar.dart';
import '../../../../../Home/Models/company_mem_res_model.dart';
import '../../../../../Home/Presentation/Controller/company_service.dart';
import '../../../../helper/dialogs.dart';
import '../../../../models/group_res_model.dart';
import '../../../../models/get_company_res_model.dart';
import '../../../auth/models/get_uesr_Res_model.dart';
import 'package:dio/dio.dart' as multi;

import 'chat_home_controller.dart';

class CreateBroadcastsController extends GetxController{
  final TextEditingController nameController = TextEditingController();
  final Set<int> selectedUserIds = {};

  @override
  void onInit() {
    super.onInit();
    _getCompany();
    _getMe();
    
    Future.delayed(Duration(milliseconds: 600),()=>hitAPIToGetMember() );
  }


  CompanyData? myCompany = CompanyData();
  _getCompany()async{
    final svc = CompanyService.to;
    myCompany = svc.selected;
    update();
  }

  UserDataAPI? me = UserDataAPI();
  _getMe(){
    me = getUser();
    update();
  }

  bool isLoading = false;

  ComMemResModel comMemResModel = ComMemResModel();
  List<UserDataAPI> allUsers=[];

  hitAPIToGetMember() async {
    isLoading = true;
    update();
    Get.find<PostApiServiceImpl>()
        .getComMemApiCall(myCompany?.companyId)
        .then((value) async {
      isLoading = false;
      comMemResModel=value;
      allUsers = value.data??[];
      update();
    }).onError((error, stackTrace) {
      isLoading = false;
      update();
    });
  }


  GroupResModel groupResModel = GroupResModel();
  Future<void> createBroadcast() async {
    final name = nameController.text.trim();
    if (name.isEmpty) {
      toast("Name and at least one member required");
      return;
    }
    SystemChannels.textInput.invokeMethod('TextInput.hide');
    customLoader.show();
    var reqData = multi.FormData.fromMap({
      "company_id": myCompany?.companyId,
      "name":nameController.text,
      "is_group":"0",
      "is_broadcast": "1",
    });
    Get.find<PostApiServiceImpl>()
        .addEditGroupBroadcastApiCall(dataBody: reqData)
        .then((value) {
      customLoader.hide();
      Get.back();
      groupResModel = value;
      nameController.clear();
      Get.find<ChatHomeController>().localPage = 1;
      Get.find<ChatHomeController>().hitAPIToGetRecentChats(userData:groupResModel.data,page: 1 );
      toast(value.message??'');
      Dialogs.showSnackbar(Get.context!, "Scroll down to see your latest create 'Broadcast'");
      update();
    }).onError((error, stackTrace) {
      update();
      customLoader.hide();
      errorDialog(error.toString());
    }).whenComplete(() {});
  }


}