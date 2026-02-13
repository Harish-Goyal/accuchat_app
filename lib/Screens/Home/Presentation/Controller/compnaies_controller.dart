import 'package:AccuChat/Screens/Chat/screens/auth/models/get_uesr_Res_model.dart';
import 'package:AccuChat/Screens/Home/Presentation/Controller/company_service.dart';
import 'package:AccuChat/utils/custom_flashbar.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../Constants/themes.dart';
import '../../../../Services/APIs/local_keys.dart';
import '../../../../Services/APIs/post/post_api_service_impl.dart';
import '../../../../Services/subscription/billing_controller.dart';
import '../../../../main.dart';
import '../../../../routes/app_routes.dart';
import '../../../../utils/helper_widget.dart';
import '../../../../utils/text_style.dart';
import '../../../Chat/api/apis.dart';
import '../../../Chat/models/get_company_res_model.dart';
import '../../../Chat/screens/auth/models/pending_invites_res_model.dart';
import '../../Bindings/home_bindings.dart';
import '../../Models/get_pending_sent_invites_res_model.dart';
import '../View/buy_company_pack.dart';
import '../View/buy_users_dialog.dart';
import '../View/invite_member.dart';
import 'invite_member_controller.dart';

class CompaniesController extends GetxController {
  @override
  void onInit() {
    getCompany();
    // _getMe();
    hitAPIToGetCompanies();
    hitAPIToGetPendingInvites();
    hitAPIToGetSentInvites(companyData: selCompany);
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

  // UserDataAPI? me = UserDataAPI();
  //
  // _getMe() {
  //   me = getUser();
  //   update();
  // }

  bool isLoadingInvited = false;
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

  List<SentInvitesData> sentInviteList = [];

  bool isLoadingPending = true;

  hitAPIToGetSentInvites(
      {CompanyData? companyData, bool isMember = false}) async {
    isLoadingPending = true;
    update();
    await Get.find<PostApiServiceImpl>()
        .getPendingSentInvitesApiCall(companyData?.companyId)
        .then((value) async {
      isLoadingPending = false;
      sentInviteList = value.data ?? [];
    }).onError((error, stackTrace) {
      toast(error.toString());
      customLoader.hide();
    });
  }

  companyNavigation(value, CompanyData companyData) async {
    final svc = CompanyService.to;
    if (value == "Pending") {
      if (companyData.companyId == selCompany?.companyId) {
        if (kIsWeb) {
          if ((companyData.createdBy == APIs.me?.userId)) {
            Get.toNamed(
              "${AppRoutes.invitations_r}?companyID=${companyData.companyId ?? 0}",
            );
          } else {
            toast("You are not allowed");
          }
        } else {
          if ((companyData.createdBy == APIs.me?.userId)) {
            Get.toNamed(AppRoutes.invitations_r, arguments: {
              'companyID': companyData.companyId ?? 0,
            });
          } else {
            toast("You are not allowed");
          }
        }
      } else {
        toast("Please select your company");
      }
    } else if (value == "Invite") {
        if (companyData.companyId == selCompany?.companyId) {
            await svc.select(companyData);
            getCompany();
            update();

            Future.delayed(
                const Duration(milliseconds: 500),
                () => (selCompany?.createdBy) == APIs.me?.userId
                    ? _onInvite(companyData)
                    : toast("You are not allowed to perform this action!"));

        } else {
          toast("Please select your company");
        }



     /*   if (!kIsWeb) {
        if (companyData.companyId == selCompany?.companyId) {
          if (!kIsWeb) {
            await svc.select(companyData);
            getCompany();
            update();

            Future.delayed(
                const Duration(milliseconds: 500),
                () => (selCompany?.createdBy) == APIs.me?.userId
                    ? _onInvite(companyData)
                    : toast("You are not allowed to perform this action!"));
          } else {
            toast("Please go to mobile app to send invites to user");
          }
        } else {
          toast("Please select your company");
        }
      } else {
        toast("Download mobile apps to Invite your contacts");
      }*/
    } else if (value == "Update") {
      if (companyData.companyId == selCompany?.companyId) {
        await svc.select(companyData);
        getCompany();
        update();
        Future.delayed(const Duration(milliseconds: 500), () {
          if (kIsWeb) {
            (companyData.createdBy == APIs.me?.userId)
                ? Get.toNamed(
                    "${AppRoutes.company_update}?companyId=${companyData.companyId.toString()}",
                  )
                : toast("You are not allowed to perform this action!");
          } else {
            (companyData.createdBy == APIs.me?.userId)
                ? Get.toNamed(
                    AppRoutes.company_update,
                    arguments: {'company': companyData},
                  )
                : toast("You are not allowed to perform this action!");
          }
        });
      } else {
        toast("Please select your company");
      }
    } else if (value == "All") {
      if (companyData.companyId == selCompany?.companyId) {
        await svc.select(companyData);
        getCompany();
        update();
        if (kIsWeb) {
          Get.toNamed(
              '${AppRoutes.company_members}?companyId=${companyData.companyId}&companyName=${companyData.companyName ?? ''}');
        } else {
          Get.toNamed(AppRoutes.company_members, arguments: {
            'companyId': companyData.companyId ?? 0,
            'companyName': companyData.companyName ?? ''
          });
        }
      }  else {
        toast("Please select your company");
      }
    }

    else if (value == "Delete") {
      deleteCompany(Get.context!, companyData.companyId);
    }
  }

  Future<void> deleteCompany(BuildContext context, comId) async {

    final ctx = Get.context!;
    final size = MediaQuery.of(ctx).size;

    // Responsive width breakpoints (desktop / tablet / large phone / phone)
    double targetWidth;
    if (size.width >= 1280) {
      targetWidth = size.width * 0.25; // desktop
    } else if (size.width >= 992) {
      targetWidth = size.width * 0.35; // laptop / large tablet
    } else if (size.width >= 768) {
      targetWidth = size.width * 0.5; // tablet
    } else {
      targetWidth = size.width * 0.85; // phones / small windows
    }
    // Keep width within reasonable min/max
    targetWidth = targetWidth.clamp(360.0, 560.0);

    final maxHeight = size.height * 0.90;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: targetWidth,
              maxHeight: maxHeight,
            ),
            child: Material(
              color: Colors.transparent,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: SingleChildScrollView(
                  child: AlertDialog(
                    title: const Text("Delete Company"),
                    backgroundColor: Colors.white,
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        vGap(20),
                        Text(
                          "⚠️ Are you sure you want to delete this company?",
                          style: BalooStyles.balooboldTextStyle(
                              color: AppTheme.redErrorColor, size: 16),
                        ),
                        vGap(20),
                        Text(
                          "All related members, invitations, and references will be permanently removed. You cannot retrieve it again in future, make sure before delete!",
                          style: BalooStyles.baloomediumTextStyle(
                              color: AppTheme.redErrorColor),
                        ),
                        vGap(20),
                      ],
                    ),
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text("Cancel")),
                      ElevatedButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text("Delete")),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    if (confirm != true) return;

    deleteCompanyApi(comId);
  }

  deleteCompanyApi(comId) async {
    customLoader.show();
    Get.find<PostApiServiceImpl>()
        .deleteCompanyApiCall(compId: comId)
        .then((value) async {
      toast(value.message);
      toast("✅ Company and related data deleted successfully.");
      customLoader.hide();
      update();
      Get.offAllNamed(AppRoutes.landing_r);
    }).onError((error, stackTrace) {
      update();
      customLoader.hide();
      errorDialog(error.toString());
    }).whenComplete(() {});
  }


  Future<void> openInviteDialog(CompanyData companyData) async {
    // ✅ run bindings FIRST (creates controller etc.)
    final c = Get.isRegistered<InviteMemberController>()
        ? Get.find<InviteMemberController>()
        : Get.put(InviteMemberController());


    c.companyId = companyData.companyId;
    c.companyName = companyData.companyName;
    c.invitedBy = companyData.createdBy;

    c.initFromDialog();
    try {
      await Get.dialog(
        Dialog(
          clipBehavior: Clip.antiAlias,
          insetPadding: const EdgeInsets.all(12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: SizedBox(
            width: Get.width * 0.3,
            height: Get.height * 0.4,
            child: const InviteMembersScreen(),
          ),
        ),
        barrierDismissible: true,
      );
    } finally {
      if (Get.isRegistered<InviteMemberController>()) {
        Get.delete<InviteMemberController>(force: true);
      }
    }
  }


  _onInvite(CompanyData companyData) {
    if (kIsWeb) {
          openInviteDialog(companyData);
      // Get.toNamed(
      //     '${AppRoutes.invite_member}?companyId=${companyData.companyId}&invitedBy=${companyData.createdBy}&companyName=${companyData.companyName}');
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
    if (APIs.me.allowedCompanies == 0 || APIs.me.allowedCompanies == null) {
      await showDialog<BuyPackResult>(
        context: Get.context!,
        builder: (ctx) => BuyMultipleCompaniesDialog(),
      );
    } else {
      Get.toNamed(AppRoutes.create_company, arguments: {'isHome': '1'});
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
