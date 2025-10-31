import 'package:AccuChat/Screens/Chat/models/company_model.dart';
import 'package:AccuChat/Screens/Chat/models/get_company_res_model.dart';
import 'package:AccuChat/Services/APIs/post/post_api_service_impl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../../../../Services/APIs/local_keys.dart';
import '../../../../../../Services/storage_service.dart';
import '../../../../../../main.dart';
import '../../../../../../routes/app_routes.dart';
import '../../../../../../utils/custom_flashbar.dart';
import '../../../../../Home/Presentation/Controller/company_service.dart';
import '../../../../api/apis.dart';
import '../../../../helper/notification_service.dart';
import '../../../../models/chat_user.dart';
import '../../../../models/invite_model.dart';
import '../../models/pending_invites_res_model.dart';

class AcceptInviteController extends GetxController {
  CompanyData company = CompanyData();


  bool isLoading = false;
  // var inviteId;
  @override
  void onInit() {
    hitAPIToGetPendingInvites();
    // getCompanyArguments();
    // invitesFuture = fetchUserInvitations();
    super.onInit();
  }


  hitAPIToAcceptInvite(inviteId,comId) async {
    customLoader.show();
   await Get.find<PostApiServiceImpl>()
        .acceptInviteApiCall(id: inviteId)
        .then((value)  async {
      customLoader.hide();

      update();
      // await NotificationService.sendAcceptInvitationNotification(
      //   targetToken: token,
      //   inviterName: invite.name ?? '',
      //   number: invite.email ?? '',
      //   companyName: invite.company?.name ?? '',
      // );
      getCompanyByIdApi(companyId:comId);

    }).onError((error, stackTrace) {
      customLoader.hide();
      errorDialog(error.toString());
      update();
    });
  }



  CompanyData? companyResponse = CompanyData();

 getCompanyByIdApi({int? companyId}) async {
    customLoader.show();
    Get.find<PostApiServiceImpl>()
        .getCompanyByIdApiCall(companyId)
        .then((value) async {
      customLoader.hide();
      companyResponse = value.data;
      StorageService.setLoggedIn(true);
      StorageService.setCompanyCreated(true);
      final svc = Get.find<CompanyService>();
      await svc.select(companyResponse!);
      Get.offAllNamed(AppRoutes.home);
    }).onError((error, stackTrace) {
      update();
      Get.back();
      customLoader.hide();
      errorDialog(error.toString());
    }).whenComplete(() {});
  }

  List<PendingInvitesList> pendingInvitesList = [];
  hitAPIToGetPendingInvites() async {
    isLoading = true;
    update();
    Get.find<PostApiServiceImpl>()
        .pendingInviteListApiCall()
        .then((value) async {
      pendingInvitesList = value.data ?? [];
      isLoading = false;
      update();
    }).onError((error, stackTrace) {
      isLoading = false;
      update();
    });
  }


  /*Future<void> acceptInvite(InvitationModel invite) async {
      try {
        isLoading = true;
        update();

        // customLoader.show();
        await FirebaseFirestore.instance
            .collection('companies')
            .doc(company.id)
            .collection('members')
            .doc(APIs.me.id)
            .set({
          'role': 'member',
          'joinedAt': DateTime
              .now()
              .millisecondsSinceEpoch
              .toString()
        });
        final companyRef = FirebaseFirestore.instance.collection('companies')
            .doc(company.id);
        await companyRef.update({
          'members': FieldValue.arrayUnion([APIs.me.id]),
        });
        await FirebaseFirestore.instance
            .collection('users')
            .doc(APIs.me.id)
            .update({
          'company': FieldValue.arrayUnion([company.toJson()]),
          'selectedCompany': company.toJson(),
          'companyIds': FieldValue.arrayUnion([company.id]),
          'name': invite.name,
        });


        // Show success message
        toast("🎉 Invitation accepted!");

        // Fetch and update the selected company model
        var cData = await companyRef.get();
        var selectedCompany = CompanyModel.fromJson(cData.data()!);

        // Update the APIs.selectedCompany with the new company data
        APIs.me.selectedCompany = company;

        // Mark the user as logged in
        storage.write(isLoggedIn, true);
        // customLoader.hide();
        isLoading = false;
        update();
        // Navigate to the home screen
        Get.offAllNamed(AppRoutes.home);
        invitesFuture = fetchUserInvitations();
        update();

        ChatUser? chatUser = await APIs.getUserById(invite.invitedBy);


        final token = await APIs.getTargetToken(
            email: chatUser?.email != '' && chatUser?.email != 'null' ? chatUser
                ?.email : "",
            phone: chatUser?.phone != '' && chatUser?.phone != 'null' ? chatUser
                ?.phone : '');
        if (token != null && token != APIs.me.pushToken) {
          await NotificationService.sendAcceptInvitationNotification(
            targetToken: token,
            inviterName: invite.name ?? '',
            number: invite.email ?? '',
            companyName: invite.company?.name ?? '',
          );
          // await LocalNotificationService.showInviteNotification(
          //   title: '📬 You got an invite',
          //   body: 'Join ${company.name??""} now!',
          // );
        }

        // 4. Delete the invitation
        await FirebaseFirestore.instance
            .collection('invitations')
            .doc(invite.id)
            .delete();
      } catch (e) {
        customLoader.hide();
        isLoading = false;
        update();
        toast("❌ Error accepting invite");
        print(e);
      }
    }*/
}
