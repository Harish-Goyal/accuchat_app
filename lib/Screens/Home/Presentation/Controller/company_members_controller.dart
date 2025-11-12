import 'package:AccuChat/Screens/Home/Presentation/Controller/compnaies_controller.dart';
import 'package:AccuChat/main.dart';
import 'package:AccuChat/utils/custom_flashbar.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../Services/APIs/local_keys.dart';
import '../../../../Services/APIs/post/post_api_service_impl.dart';
import '../../../../utils/text_style.dart';
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
    final svc = CompanyService.to;
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


  removeCompanyMember(UserDataAPI? memData)async{
    final meId = me?.userId;
    final creatorId = myCompany?.createdBy;
    final targetId = memData?.userId;

    // Basic null-guards
    if (meId == null || creatorId == null || targetId == null) {
      toast("Something went wrong. Please try again.");
      return;
    }

    final isCreator = meId == creatorId;
    final removingCreator = targetId == creatorId;
    final removingSelf = targetId == meId;

    // 1) Never allow removing the company creator
    if (removingCreator) {
      toast("You cannot remove the company creator.");
      return;
    }

    // 2) Block creator from removing themself (if you want this rule)
    if (isCreator && removingSelf) {
      toast("You are not allowed to remove yourself. Transfer ownership or delete the company.");
      return;
    }

    // 3) Only creator can remove members (adjust if you add roles later)
    if (!isCreator) {
      // Option A: block non-creator from removing anyone (including self)
      toast("You don't have permission to remove members.");
      return;

      // Option B (if you want self-leave for non-creator):
      // if (removingSelf) {
      //   final confirmLeave = await showDialog(
      //     context: context,
      //     builder: (_) => AlertDialog(
      //       backgroundColor: Colors.white,
      //       title: const Text("Leave company"),
      //       content: const Text("Are you sure you want to leave this company?"),
      //       actions: [
      //         TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
      //         TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Leave")),
      //       ],
      //     ),
      //   );
      //   if (confirmLeave == true) {
      //     controller.hitAPIToRemoveMember(targetId);
      //   }
      //   return;
      // }
      // return;
    }

    // 4) Creator removing a normal member → confirm dialog
    final who = (memData?.email == null || memData?.email == '' || memData?.email == 'null')
        ? memData?.phone
        : memData?.email;

    final confirm = await showDialog(
      context: Get.context!,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        title: Text("Remove $who"),
        content: const Text("Are you sure you want to remove this member?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(Get.context!, false), child: const Text("Cancel")),
          TextButton(
            onPressed: () => Navigator.pop(Get.context!, true),
            child: Text("Remove", style: BalooStyles.baloosemiBoldTextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      hitAPIToRemoveMember(targetId);
    }
  }

}