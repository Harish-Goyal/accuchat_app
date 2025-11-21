import 'package:AccuChat/Screens/Chat/screens/chat_tasks/Presentation/Controllers/chat_home_controller.dart';
import 'package:AccuChat/Screens/Chat/screens/chat_tasks/Presentation/Controllers/chat_screen_controller.dart';
import 'package:dio/dio.dart' as multi;
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../../../../Services/APIs/local_keys.dart';
import '../../../../../../Services/APIs/post/post_api_service_impl.dart';
import '../../../../../../main.dart';
import '../../../../../../utils/custom_flashbar.dart';
import '../../../../../Home/Presentation/Controller/company_service.dart';
import '../../../../models/get_company_res_model.dart';
import '../../../../models/group_mem_api_res.dart';
import '../../../../models/group_res_model.dart';
import '../../../auth/models/get_uesr_Res_model.dart';

class GrBrMembersController extends GetxController{
  TextEditingController groupNameController = TextEditingController();
  UserDataAPI? groupOrBr;

  bool isUpdate = false;


  String? userId;

  @override
  void onInit() {
    _getMe();
    _getCompany();
    getArguments();
    // if(!kIsWeb) {
      hitAPIToGetMembers();
    // }
    super.onInit();
  }

  getArguments(){
    if(kIsWeb){
      if(Get.parameters!=null) {
        userId = Get.parameters['userId'];
        getUserByIdApi(userId: int.parse(userId??''),comId: myCompany?.companyId);
      }
    }else{
      if(Get.arguments!=null) {
        groupOrBr = Get.arguments['user'];
        groupNameController.text = groupOrBr?.userName??'';
      }
    }
  }


  getUserByIdApi({int? userId,comId}) async {

    Get.find<PostApiServiceImpl>()
        .getUserByApiCall(userID: userId,comid: comId)
        .then((value) async {
      groupOrBr = value.data;
      groupNameController.text = groupOrBr?.userName??'';
      hitAPIToGetMembers();
      update();
    }).onError((error, stackTrace) {
      update();
      errorDialog(error.toString());
    }).whenComplete(() {});
  }



  CompanyData? myCompany = CompanyData();
  _getCompany() {
    final svc = CompanyService.to;
    myCompany = svc.selected;
    update();
  }

  bool isLoading = true;
  List<UserDataAPI> members = [];
  hitAPIToGetMembers() async {
    isLoading = true;
    update();
    Get.find<PostApiServiceImpl>()
        .getGrBrMemberApiCall(id:
    groupOrBr?.userCompany?.userCompanyId,mode: groupOrBr?.userCompany?.isGroup==1?
    "group":"broadcast")
        .then((value) async {
      isLoading = false;
      members = value.data?.members??[];

      update();
    }).onError((error, stackTrace) {
      isLoading = false;
      update();
    });
  }



  GroupResModel groupResModel = GroupResModel();
  updateGroupBroadcastApi({isGroup,isBroadcast}) async {
    SystemChannels.textInput.invokeMethod('TextInput.hide');
    customLoader.show();
    var reqData = multi.FormData.fromMap({
      "id": groupOrBr?.userId,
      "company_id": myCompany?.companyId,
      "name":groupNameController.text,
      "is_group":isGroup,
      "is_broadcast": isBroadcast,
    });
    Get.find<PostApiServiceImpl>()
        .addEditGroupBroadcastApiCall(dataBody: reqData)
        .then((value) {
      customLoader.hide();
      Get.back();
      groupResModel = value;
      groupNameController.clear();
      toast(value.message??'');
      Get.find<ChatHomeController>().hitAPIToGetRecentChats();
      update();
    }).onError((error, stackTrace) {
      update();
      Get.back();
      customLoader.hide();
      errorDialog(error.toString());
    }).whenComplete(() {});
  }


  hitAPIToUpdateMember({bool isGroup = false,id,mode}) async {
    customLoader.show();
    Map<String, dynamic> req = {
      "group_id": groupOrBr?.userCompany?.userCompanyId, // Group companyID
      "company_id": myCompany?.companyId,
      "member_id": [id],//member company ID
      "mode":mode,
      "is_group": isGroup ? 1 : 0,
      'is_admin':mode=='set_admin'?1:0
    };

    Get.find<PostApiServiceImpl>()
        .addMemberToGrBrApiCall(dataBody: req)
        .then((value) async {
      customLoader.hide();
      Get.find<ChatScreenController>().hitAPIToGetMembers(groupOrBr);
      hitAPIToGetMembers();
      update();
    }).onError((error, stackTrace) {
      customLoader.hide();
    });
  }


 hitAPIToDeleteGrBr({bool isGroup = false}) async {
    customLoader.show();
    Map<String, dynamic> req = {
      "company_id": myCompany?.companyId,
      "entity_uc_id":groupOrBr?.userCompany?.userCompanyId, // the group's/broadcast's user_company_id
      "is_broadcast": isGroup ? 0 : 1,    // 0 = group, 1 = broadcast
    };

    Get.find<PostApiServiceImpl>()
        .deleteGrBrApiCall(dataBody: req)
        .then((value) async {
      customLoader.hide();
      Get.back();
      Get.back();
      Get.find<ChatHomeController>().hitAPIToGetRecentChats();

      update();
    }).onError((error, stackTrace) {
      customLoader.hide();
    });
  }



  UserDataAPI? me = UserDataAPI();
  _getMe(){
    me = getUser();
    update();
  }

}