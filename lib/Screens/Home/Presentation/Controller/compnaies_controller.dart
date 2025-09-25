import 'package:AccuChat/Screens/Chat/screens/auth/models/get_uesr_Res_model.dart';
import 'package:AccuChat/Screens/Home/Presentation/Controller/company_service.dart';
import 'package:AccuChat/utils/custom_flashbar.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../Services/APIs/local_keys.dart';
import '../../../../Services/APIs/post/post_api_service_impl.dart';
import '../../../../main.dart';
import '../../../../routes/app_routes.dart';
import '../../../Chat/models/get_company_res_model.dart';
import '../../Models/get_pending_sent_invites_res_model.dart';

class CompaniesController extends GetxController {
  @override
  void onInit() {
    getCompany();
    _getMe();
    hitAPIToGetCompanies();
    super.onInit();
  }

  void refreshCompanies() async {
    hitAPIToGetCompanies();

    update();
    // homeController.update();
  }

  CompanyResModel companyResModel = CompanyResModel();

  bool loadingCompany = true;
  List<CompanyData> joinedCompaniesList = [];
  hitAPIToGetCompanies() async {
    loadingCompany = true;
    update();
    Get.find<PostApiServiceImpl>()
        .getJoinedCompanyListApiCall()
        .then((value) async {
      loadingCompany = false;
      companyResModel = value;
      joinedCompaniesList = value.data ?? [];
      update();
    }).onError((error, stackTrace) {
      loadingCompany = false;
      update();
    });
  }

  PendingSentInvitesResModel pendingSentInvitesResModel =
      PendingSentInvitesResModel();

  CompanyData? selCompany;

  CompanyData? getCompany() {
    final svc = Get.find<CompanyService>();
    selCompany = svc.selected;
    return selCompany;
  }

  UserDataAPI? me = UserDataAPI();
  _getMe() {
    me = getUser();
    update();
  }

  companyNavigation(value, CompanyData companyData) async {
    final svc = Get.find<CompanyService>();
    if (value == "Pending") {
      Get.toNamed(AppRoutes.invitations_r, arguments: {
        'companyID': companyData.companyId ?? '',
      });
    } else if (value == "Invite") {
      // controller.updateIndex(1);
      // setState(() {
      //   isTaskMode =false;
      // });
      if (!kIsWeb) {
        await svc.select(companyData);
        getCompany();
        update();

        Future.delayed(
            const Duration(milliseconds: 500),
            () => companyData.companyId == selCompany?.companyId &&
                    (selCompany?.createdBy) == me?.userId
                ? _onInvite(companyData)
                : toast("You are not allowed to perform this action!"));
      } else {
        toast("Please go to mobile app to send invites to user");
      }
    } else if (value == "Update") {
      await svc.select(companyData);
      getCompany();
      update();
      Future.delayed(const Duration(milliseconds: 500), () {
        if (kIsWeb) {
          (companyData.createdBy == me?.userId &&
                  companyData.companyId == selCompany?.companyId)
              ? Get.toNamed(
                  "${AppRoutes.company_update}?companyId=${companyData.companyId.toString()}",
                )
              : toast("You are not allowed to perform this action!");
        } else {
          (companyData.createdBy == me?.userId &&
                  companyData.companyId == selCompany?.companyId)
              ? Get.toNamed(
                  AppRoutes.company_update,
                  arguments: {'company': companyData},
                )
              : toast("You are not allowed to perform this action!");
        }
      });
    } else if (value == "All") {
      await svc.select(companyData);
      getCompany();
      update();
      /*Get.toNamed(
          '${AppRoutes.companyMemberRoute}?companyId=${companyData
              .companyId}&companyName=${companyData
              .companyName ??
              ''}');*/
      if (companyData.companyId == selCompany?.companyId) {
        if (kIsWeb) {
          Get.toNamed(
              '${AppRoutes.company_members}?companyId=${companyData.companyId}&companyName=${companyData.companyName ?? ''}');
        } else {
          Get.toNamed(AppRoutes.company_members, arguments: {
            'companyId': companyData.companyId ?? 0,
            'companyName': companyData.companyName ?? ''
          });
        }
      }
    }
  }

  _onInvite(companyData) {
    if (kIsWeb) {
      Get.toNamed(
          '${AppRoutes.invite_member}?companyId=${companyData.companyId.toString()}&invitedBy=${companyData.createdBy}&companyName=${companyData.companyName}');
    } else {
      Get.toNamed(AppRoutes.invite_member, arguments: {
        'companyName': companyData.companyName,
        'companyId': companyData.companyId,
        'invitedBy': companyData.createdBy,
      });
    }
  }
}
