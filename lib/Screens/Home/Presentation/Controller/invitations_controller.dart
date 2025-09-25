import 'package:AccuChat/Screens/Home/Models/get_pending_sent_invites_res_model.dart';
import 'package:AccuChat/Services/APIs/post/post_api_service_impl.dart';
import 'package:AccuChat/main.dart';
import 'package:AccuChat/utils/custom_flashbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import '../../../Chat/models/invite_model.dart';

class InvitationsController extends GetxController {
  late Future<List<InvitationModel>> invitationsFuture;
  var comapnyID;

  @override
  void onInit() {
    hitAPIToGetSentInvites();
    getArguments();
    super.onInit();
    initData();
  }

  getArguments(){
    if(Get.arguments!=null){
      comapnyID = Get.arguments['companyID'];
    }
  }


  List<SentInvitesData> sentInviteList=[];

  hitAPIToGetSentInvites() async {
    isLoading =true;
    update();
    Get.find<PostApiServiceImpl>()
        .getPendingSentInvitesApiCall()
        .then((value) async {
      sentInviteList = value.data ?? [];
      isLoading =false;
      update();
    }).onError((error, stackTrace) {
      isLoading =false;
      update();
    });
  }

  bool isLoading = true;
  initData() async {
    hitAPIToGetSentInvites();
  }

  hitAPIToDeleteInvitations(inviteID) async {
    FocusManager.instance.primaryFocus!.unfocus();
    customLoader.show();
    Get.find<PostApiServiceImpl>().deleteSentInvitesApiCall(inviteID).then((value) async {
      customLoader.hide();
      toast(value.message);
      hitAPIToGetSentInvites();
      update();
    }).onError((error, stackTrace) {
      customLoader.hide();
      errorDialog(error.toString());
      update();
    });
  }

}