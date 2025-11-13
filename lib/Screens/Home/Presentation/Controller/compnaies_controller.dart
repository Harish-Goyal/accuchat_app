import 'package:AccuChat/Screens/Chat/screens/auth/models/get_uesr_Res_model.dart';
import 'package:AccuChat/Screens/Home/Presentation/Controller/company_service.dart';
import 'package:AccuChat/utils/custom_flashbar.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../Services/APIs/local_keys.dart';
import '../../../../Services/APIs/post/post_api_service_impl.dart';
import '../../../../Services/subscription/billing_controller.dart';
import '../../../../routes/app_routes.dart';
import '../../../Chat/api/apis.dart';
import '../../../Chat/models/get_company_res_model.dart';
import '../../../Chat/screens/auth/models/pending_invites_res_model.dart';
import '../../Models/get_pending_sent_invites_res_model.dart';
import '../View/buy_company_pack.dart';
import '../View/buy_users_dialog.dart';

class CompaniesController extends GetxController {
  @override
  void onInit() {
    getCompany();
    _getMe();
    hitAPIToGetCompanies();
    hitAPIToGetPendingInvites();
    hitAPIToGetSentInvites();
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
    final svc = CompanyService.to;
    selCompany = svc.selected;
    return selCompany;
  }

  UserDataAPI? me = UserDataAPI();

  _getMe() {
    me = getUser();
    update();
  }

  bool isLoadingInvited= false;
  List<PendingInvitesList> pendingInvitesList = [];
  hitAPIToGetPendingInvites() async {
    isLoadingInvited = true;
    update();
    Get.find<PostApiServiceImpl>()
        .pendingInviteListApiCall()
        .then((value) async {
      pendingInvitesList = value.data ?? [];
      isLoadingInvited = false;
      update();
    }).onError((error, stackTrace) {
      isLoadingInvited = false;
      update();
    });
  }


  List<SentInvitesData> sentInviteList=[];

  hitAPIToGetSentInvites() async {

    Get.find<PostApiServiceImpl>()
        .getPendingSentInvitesApiCall(selCompany?.companyId)
        .then((value) async {
      sentInviteList = value.data ?? [];
    }).onError((error, stackTrace) {
    });
  }


  companyNavigation(value, CompanyData companyData) async {
    final svc = CompanyService.to;
    if (value == "Pending") {
      if(companyData.companyId == selCompany?.companyId) {
        if (kIsWeb) {
          if ((companyData.createdBy == me?.userId)) {
            Get.toNamed(
              "${AppRoutes.invitations_r}?companyID=${companyData.companyId ??
                  0}",
            );
          } else {
            toast("You are not allowed");
          }
        } else {
          if ((companyData.createdBy == me?.userId)) {
            Get.toNamed(AppRoutes.invitations_r, arguments: {
              'companyID': companyData.companyId ?? 0,
            });
          } else {
            toast("You are not allowed");
          }
        }
      }else{
        toast("Please select your company");
      }

    } else if (value == "Invite") {
      if (!kIsWeb) {
        if (companyData.companyId == selCompany?.companyId) {
          if (!kIsWeb) {
            await svc.select(companyData);
            getCompany();
            update();

            Future.delayed(
                const Duration(milliseconds: 500),
                    () =>
                (selCompany?.createdBy) == me?.userId
                    ? _onInvite(companyData)
                    : toast("You are not allowed to perform this action!"));
          } else {
            toast("Please go to mobile app to send invites to user");
          }
        } else {
          toast("Please select your company");
        }
      }else{
        toast("Download mobile apps to Invite your contacts");
      }
    } else if (value == "Update") {
      if(companyData.companyId == selCompany?.companyId) {
      await svc.select(companyData);
      getCompany();
      update();
      Future.delayed(const Duration(milliseconds: 500), () {
        if (kIsWeb) {
          (companyData.createdBy == me?.userId)
              ? Get.toNamed(
            "${AppRoutes.company_update}?companyId=${companyData.companyId
                .toString()}",
          )
              : toast("You are not allowed to perform this action!");
        } else {
          (companyData.createdBy == me?.userId )
              ? Get.toNamed(
            AppRoutes.company_update,
            arguments: {'company': companyData},
          )
              : toast("You are not allowed to perform this action!");
        }
      });
    }else{
      toast("Please select your company");
    }
    } else if (value == "All") {
      if(companyData.companyId == selCompany?.companyId) {
      await svc.select(companyData);
      getCompany();
      update();
        if (kIsWeb) {
          Get.toNamed(
              '${AppRoutes.company_members}?companyId=${companyData
                  .companyId}&companyName=${companyData.companyName ?? ''}');
        } else {
          Get.toNamed(AppRoutes.company_members, arguments: {
            'companyId': companyData.companyId ?? 0,
            'companyName': companyData.companyName ?? ''
          });
        }
      }else{
        toast("Please select your company");
      }
    }
  }

  _onInvite(companyData) {
    if (kIsWeb) {
      Get.toNamed(
          '${AppRoutes.invite_member}?companyId=${companyData.companyId
              .toString()}&invitedBy=${companyData
              .createdBy}&companyName=${companyData.companyName}');
    } else {
      Get.toNamed(AppRoutes.invite_member, arguments: {
        'companyName': companyData.companyName,
        'companyId': companyData.companyId,
        'invitedBy': companyData.createdBy,
      });
    }
  }

  Future<void> onCreateCompanyPressed(BillingController ctrl) async {
    /*   await ctrl.refreshSummary();
    final s = ctrl.summary!;

    // if (s.companiesUsed < s.companiesAllowed) {
    //   Get.toNamed('/companies/create');
    //   return;
    // }
*/
    print(APIs.me.allowedCompanies);
    if(APIs.me.allowedCompanies==0 || APIs.me.allowedCompanies==null) {
      await showDialog<BuyPackResult>(
        context: Get.context!,
        builder: (ctx) => BuyMultipleCompaniesDialog(),
      );


    }else{
      Get.toNamed(
          AppRoutes.create_company,
          arguments: {'isHome': '1'});
    }

/*
final result = await showDialog<_BuyPackResult>(
      context: Get.context!,
      builder: (ctx) => const _BuyCompanyPackDialog(),
    );
*/

    /*if (result == null) return;

    try {
      final payload = await ctrl.service.checkout(
        kind: 'company_pack',
        quantity: 1,
        cycle: result.cycle,
        autoRenew: result.autoRenew,
      );

      //TODO backend
      // await openPaymentFromPayload(payload);

      await ctrl.refreshSummary();
      final s2 = ctrl.summary!;
      if (s2.companiesUsed < s2.companiesAllowed) {
        Get.toNamed('/companies/create');
      }
    } catch (e) {
      Get.snackbar('Payment', 'Failed: $e');
    }*/
  }
}
//   Future<bool> ensureSeatsForInvite({
//     required BillingController ctrl,
//     required String companyId,
//     required int seatsNeeded,
//   }) async {
//     final res = await ctrl.service
//         .ensureSeats(companyId: companyId, seatsNeeded: seatsNeeded);
//
//     if (res.statusCode != 402) return true; // enough seats
//
//     final data = jsonDecode(res.body) as Map<String, dynamic>;
//     final need = (data['data']?['seatsNeeded'] ?? seatsNeeded) as int;
//     final avail = (data['data']?['avail'] ?? 0) as int;
//     final packs = ((need - avail) <= 0) ? 0 : (((need - avail) + 4) ~/ 5);
//
//     if (packs <= 0) return true;
//
//     final result = await showDialog<_BuyPackResult>(
//       context: Get.context!,
//       builder: (ctx) => _BuyUserPackDialog(packs: packs),
//     );
//     if (result == null) return false;
//
//     try {
//       final payload = await ctrl.service.checkout(
//         kind: 'user_pack',
//         companyId: companyId,
//         quantity: packs,
//         cycle: result.cycle,
//         autoRenew: result.autoRenew,
//       );
//       //TODO backend
//       // await openPaymentFromPayload(payload);
//       await ctrl.refreshSummary();
//       return true;
//     } catch (e) {
//       Get.snackbar('Payment', 'Failed: $e');
//       return false;
//     }
//   }
// }