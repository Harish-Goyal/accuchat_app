import 'package:AccuChat/Constants/themes.dart';
import 'package:AccuChat/Screens/Chat/helper/dialogs.dart';
import 'package:AccuChat/Screens/Chat/models/get_company_res_model.dart';
import 'package:AccuChat/Screens/Chat/screens/chat_tasks/Presentation/Controllers/chat_home_controller.dart';
import 'package:AccuChat/Screens/Chat/screens/chat_tasks/Presentation/Controllers/chat_screen_controller.dart';
import 'package:AccuChat/Screens/Chat/screens/chat_tasks/Presentation/Controllers/task_home_controller.dart';
import 'package:AccuChat/Screens/Home/Presentation/Controller/compnaies_controller.dart';
import 'package:AccuChat/Screens/Home/Presentation/Controller/gallery_controller.dart';
import 'package:AccuChat/Screens/Home/Presentation/Controller/home_controller.dart';
import 'package:AccuChat/Screens/Home/Presentation/View/pending_invites_animated.dart';
import 'package:AccuChat/Screens/Home/Presentation/View/show_company_members.dart';
import 'package:AccuChat/Services/APIs/api_ends.dart';
import 'package:AccuChat/Services/subscription/billing_controller.dart';
import 'package:AccuChat/main.dart';
import 'package:AccuChat/utils/circleContainer.dart';
import 'package:AccuChat/utils/helper_widget.dart';
import 'package:AccuChat/utils/networl_shimmer_image.dart';
import 'package:AccuChat/utils/text_style.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import '../../../../Constants/assets.dart';
import '../../../../Constants/colors.dart';
import '../../../../Services/APIs/auth_service/auth_api_services_impl.dart';
import '../../../../Services/hive_boot.dart';
import '../../../../Services/storage_service.dart';
import '../../../../Services/subscription/billing_service.dart';
import '../../../../routes/app_routes.dart';
import '../../../../utils/chat_presence.dart';
import '../../../../utils/custom_flashbar.dart';
import '../../../../utils/product_shimmer_widget.dart';
import '../../../../utils/shares_pref_web.dart';
import '../../../Chat/api/apis.dart';
import '../../../Chat/api/session_alive.dart';
import '../../../Chat/screens/auth/Presentation/Controllers/create_company_controller.dart';
import '../../../Chat/screens/auth/Presentation/Controllers/landing_screen_controller.dart';
import '../../../Chat/screens/auth/Presentation/Views/create_company_screen.dart';
import '../../../Chat/screens/chat_tasks/Presentation/Controllers/task_controller.dart';
import '../Controller/company_members_controller.dart';
import '../Controller/company_service.dart';
import '../Controller/socket_controller.dart';
import 'home_screen.dart';


class CompanyCardModern extends StatefulWidget {
  final CompanyData companyData;
  final CompaniesController? controller;
  final bool isLanding;

  const CompanyCardModern({
    super.key,
    required this.companyData,
     this.controller,
    required this.isLanding,
  });

  @override
  State<CompanyCardModern> createState() => _CompanyCardModernState();
}

class _CompanyCardModernState extends State<CompanyCardModern> {
  bool isHover = false;

  @override
  Widget build(BuildContext context) {
    final companyData = widget.companyData;
     CompaniesController? controller;
     bool? isSelected;
    if(widget.controller!=null){
      controller = widget.controller;

    isSelected =
          companyData.companyId == controller?.selCompany?.companyId;
    }
   

    return MouseRegion(
      onEnter: (_) => setState(() => isHover = true),
      onExit: (_) => setState(() => isHover = false),
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
        margin: const EdgeInsets.only(bottom: 14),
        transform: Matrix4.identity()
          ..translate(0.0, isHover ? -4 : 0.0),

        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),

          // 🔥 Modern gradient feel
          gradient:isSelected!=null? LinearGradient(
            colors: isSelected
                ? [
              Colors.white,
              perplebr.withOpacity(.03),
            ]
                : [
              Colors.white,
              Colors.grey.shade50,
            ],
          ):LinearGradient(
            colors: 
                [
              Colors.white,
              greyColor.withOpacity(.5),
            ]
          ),

          border:isSelected!=null? Border.all(
            color: isSelected
                ? perplebr.withOpacity(.4)
                : Colors.grey.shade200,
          ):Border.all(
            color:Colors.grey.shade200,
          ),

          boxShadow: [
            BoxShadow(
              color: isHover
                  ? appColorPerple.withOpacity(.15)
                  : Colors.black.withOpacity(.04),
              blurRadius: isHover ? 14 : 6,
              offset: Offset(0, isHover ? 6 : 3),
            ),
          ],
        ),

        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: ()=> controller!=null? _onTapCompany(companyData):_leadingTap(companyData),

          child: Padding(
            padding: const EdgeInsets.all(14),

            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // 🔥 Avatar with glow
                AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      if (isHover)
                        BoxShadow(
                          color: appColorPerple.withOpacity(.25),
                          blurRadius: 12,
                        ),
                    ],
                  ),
                  child: companyData.logo != null
                      ? CustomCacheNetworkImage(
                    "${ApiEnd.baseUrlMedia}${companyData.logo ?? ''}",
                    radiusAll: 100,
                    height: 50,
                    width: 50,
                    borderColor: appColorYellow,
                    defaultImage: appIcon,
                    boxFit: BoxFit.cover,
                    isApp: true,
                  )
                      : CircleAvatar(
                    radius: 26,
                    backgroundColor: lightGre.withOpacity(.4),
                    child: Text(
                      getInitials(companyData.companyName ?? ''),
                      style: BalooStyles.baloosemiBoldTextStyle(
                        color: greenside,
                        size: 22,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                // 🔥 Content
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name Row
                      Row(
                        children: [
                          if ((isSelected??true) && isSelected!=null)
                            Container(
                              height: 8,
                              width: 8,
                              margin: const EdgeInsets.only(right: 6),
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.greenAccent,
                              ),
                            ),

                          Flexible(
                            child: Text(
                              companyData.companyName ?? '',
                              style: BalooStyles.baloosemiBoldTextStyle(
                                size: 15,

                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 4),
                      if(controller!=null)
                      Text(
                        "Creator: ${companyData.createdBy == APIs.me.userId ? APIs.me.phone : (companyData.companyName ?? '')}",
                        style: BalooStyles.baloonormalTextStyle(size: 13),
                        overflow: TextOverflow.ellipsis,
                      ),
                      if(controller!=null)
                      const SizedBox(height: 4),

                      GestureDetector(
                        onTap: ()=>controller!=null? _onSubtitleTap(companyData):_leadingSubTitleTap(companyData),
                        child: Text(
                          "Members: ${companyData.members?.length ?? 0}",
                          style: BalooStyles.baloonormalTextStyle(
                            size: 13,
                            color: appColorPerple,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // 🔥 3-dot menu
                if (controller!=null && (isSelected??true))
                  PopupMenuButton<String>(
                    icon:  Icon(Icons.more_vert, size: 20,color: perplebr,),
                    onSelected: (value) =>
                        controller?.companyNavigation(value, companyData, () async {
                          if (kIsWeb) {
                            await openMemberDialog(companyData);
                          } else {
                            await Get.toNamed(
                              AppRoutes.company_members,
                              arguments: {
                                'companyId': companyData.companyId ?? 0,
                                'companyName': companyData.companyName ?? '',
                              },
                            );
                          }
                        }),
                    itemBuilder: (context) {
                      final isCreator =
                          companyData.createdBy == APIs.me?.userId;

                      final items = <PopupMenuEntry<String>>[];

                      if (isCreator) {
                        items.addAll([
                          const PopupMenuItem(value: 'Invite', child: Text('Invite')),
                          const PopupMenuItem(value: 'Pending', child: Text('Pending')),
                          const PopupMenuItem(value: 'Update', child: Text('Update')),
                          const PopupMenuItem(value: 'Delete', child: Text('Delete')),
                        ]);
                      }

                      items.add(
                        const PopupMenuItem(value: 'All', child: Text('All Members')),
                      );

                      return items;
                    },
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }


  Future<void> openMemberDialog(CompanyData company) async {
    final c=  Get.put(CompanyMemberController(
        companyId: company.companyId, companyName: company.companyName));

    try {
      await Get.dialog(
        Dialog(
          clipBehavior: Clip.antiAlias,
          insetPadding: const EdgeInsets.all(12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: SizedBox(
            width: kIsWeb ? 550: Get.width * .9,
            height: Get.height * 0.95,
            child: CompanyMembers(),
          ),
        ),
        barrierDismissible: true,
      );
    } finally {
      if (Get.isRegistered<CompanyMemberController>()) {
        Get.delete<CompanyMemberController>();
      }
    }
  }



  Future<void> _onSubtitleTap(CompanyData companyData) async {
    if(widget.controller?.selCompany?.companyId ==companyData.companyId ){
      if (kIsWeb) {
        await openMemberDialog(companyData); // safe + no loader while dialog open
      } else {
        await Get.toNamed(
          AppRoutes.company_members,
          arguments: {
            'companyId': companyData.companyId ?? 0,
            'companyName': companyData.companyName ?? '',
          },
        );
      }
      return;
    }
    customLoader.show();
    isCompanySwitched =true;
    try {
      await widget.controller?.hitAPIToGetSentInvites(
        companyData: companyData,
        isMember: true,
      );

      final svc = CompanyService.to;
      await svc.select(companyData);

      // If getCompany is async, await it. If not, keep as is.
      widget.controller?.getCompany();

      await APIs.refreshMe(companyId: companyData.companyId ?? 0);

      if (Get.isRegistered<SocketController>()) {
        Get.find<SocketController>().connectUserEmitter(companyData.companyId);
      }

      // ✅ Hide loader BEFORE opening dialog/route so UI doesn't look stuck
      customLoader.hide();

      if (kIsWeb) {
        await openMemberDialog(companyData); // safe + no loader while dialog open
      } else {
        await Get.toNamed(
          AppRoutes.company_members,
          arguments: {
            'companyId': companyData.companyId ?? 0,
            'companyName': companyData.companyName ?? '',
          },
        );
      }

      // Cleanup (guard + try/catch so it can't block)
      try {
        if(!kIsWeb && Get.width<500) {
          if (Get.isRegistered<ChatScreenController>()) {
            Get.delete<ChatScreenController>(force: true);
          }
          if (Get.isRegistered<TaskController>()) {
            Get.delete<TaskController>();
          }
        }
        // final chatId = ChatPresence.activeChatId.value;
        // final chatTag = "chat_$chatId";
        // if (Get.isRegistered<ChatScreenController>(tag: chatTag)) {
        //   Get.delete<ChatScreenController>(tag: chatTag, force: true);
        // }
        //
        // final taskId = TaskPresence.activeTaskId.value;
        // final taskTag = "task_$taskId";
        // if (Get.isRegistered<TaskController>(tag: taskTag)) {
        //   Get.delete<TaskController>(tag: taskTag, force: true);
        // }

        if (Get.isRegistered<GalleryController>()) {
          Get.delete<GalleryController>(force: true);
        }
      } catch (_) {}
    } catch (e, st) {
      // If you want: log it / show snackbar
      customLoader.hide(); // extra safety
    } finally {
      // ✅ Guaranteed hide even if anything throws
      customLoader.hide();
      widget.controller?.update();
    }
  }

  Future<void> _onTapCompany(CompanyData companyData) async {
    if(widget.controller?.selCompany?.companyId ==companyData.companyId ){
      toast("You are in ${companyData.companyName}");
      return;
    }
    customLoader.show();
    isCompanySwitched =true;
    try {
      await widget.controller?.hitAPIToGetSentInvites(
        companyData: companyData,
        isMember: false,
      );

      final svc = CompanyService.to;
      // await svc.clearService();
      await svc.select(companyData);
      //
      widget.controller?.getCompany();

      await APIs.refreshMe(companyId: companyData.companyId ?? 0);

      if (Get.isRegistered<SocketController>()) {
        Get.find<SocketController>().connectUserEmitter(companyData.companyId);
      }
      try {
        if(!kIsWeb && Get.width<500) {
          if (Get.isRegistered<ChatScreenController>()) {
            Get.delete<ChatScreenController>(force: true);
          }
          if (Get.isRegistered<TaskController>()) {
            Get.delete<TaskController>();
          }
        }
        if (Get.isRegistered<GalleryController>()) {
          Get.delete<GalleryController>(force: true);
        }

        // if (!Get.isRegistered<DashboardController>()) {
        //   print("Registering DashboardController");
        //   Get.put(DashboardController());
        // } else {
        //   print("DashboardController already registered");
        // }
        // // After company switch, manually update state and call update()// Reset or set to a specific index
        // Get.find<DashboardController>().onInit();
        // Get.find<DashboardController>().update();

      } catch (_) {}
    } catch (e, st) {
      // debugPrint("_onTapCompany error: $e\n$st");
    } finally {

      customLoader.hide();
      widget.controller?.update();
    }
  }


  _leadingTap(companyData) async {

  customLoader.show();
  if(Get.isRegistered<CompanyService>()) {
  final svc = CompanyService.to;
  await svc.select(companyData!);
  }else{
  await StorageService.init();
  await HiveBoot.init();
  await HiveBoot.openBoxOnce<CompanyData>(selectedCompanyBox);
  // await Get.putAsync<CompanyService>(
  //       () async => await CompanyService().init(),
  //   permanent: true,
  // );
  await Get.putAsync<CompanyService>(
  () async => await CompanyService().init(),
  permanent: true,
  );
  final svc = CompanyService.to;
  await svc.select(companyData!);
  }

  Get.putAsync<Session>(() async {
  final s = Session(Get.find<AuthApiServiceImpl>(), Get.find<AppStorage>());

  CompanyData? selCompany;
  try {
  final svc = CompanyService.to;
  // OPTIONAL: if you add a `Future<void> ready` in CompanyService, await it here:
  selCompany = svc.selected; // may be null on clean install
  } catch (_) {}
  // company may not exist yet on fresh install:
  await s.initSafe(companyId: selCompany?.companyId??0);
  return s;
  }, permanent: true);

  // if(!Get.isRegistered<CompanyService>()) {
  //   await StorageService.init();
  //   await HiveBoot.init();
  //   await HiveBoot.openBoxOnce<CompanyData>(selectedCompanyBox);
  //   await Get.putAsync<CompanyService>(
  //         () async => await CompanyService().init(),
  //     permanent: true,
  //   );
  // }

  StorageService.setLoggedIn(true);
  customLoader.hide();
  if(!kIsWeb){
  FirebaseCrashlytics.instance.setUserIdentifier(APIs.me.userId.toString());
  FirebaseCrashlytics.instance.setCustomKey('companyId', companyData.companyId.toString() ?? '');
  FirebaseCrashlytics.instance.setCustomKey('app', 'AccuChat'); // optional

  }

  Get.offAllNamed(AppRoutes.home);

}


_leadingSubTitleTap(companyData)async {

  customLoader.show();
  if(Get.isRegistered<CompanyService>()) {
    final svc = CompanyService.to;
    await svc.select(companyData!);
  }else{
    await StorageService.init();
    await HiveBoot.init();
    await HiveBoot.openBoxOnce<CompanyData>(selectedCompanyBox);
// await Get.putAsync<CompanyService>(
//       () async => await CompanyService().init(),
//   permanent: true,
// );
    await Get.putAsync<CompanyService>(
          () async => await CompanyService().init(),
      permanent: true,
    );
    final svc = CompanyService.to;
    await svc.select(companyData!);
  }
  Get.putAsync<Session>(() async {
    final s = Session(Get.find<AuthApiServiceImpl>(), Get.find<AppStorage>());

    CompanyData? selCompany;
    try {
      final svc = CompanyService.to;
// OPTIONAL: if you add a `Future<void> ready` in CompanyService, await it here:
      selCompany = svc.selected; // may be null on clean install
    } catch (_) {}
// company may not exist yet on fresh install:
    await s.initSafe(companyId: selCompany?.companyId??0);
    return s;
  }, permanent: true);

// if(!Get.isRegistered<CompanyService>()) {
//   await StorageService.init();
//   await HiveBoot.init();
//   await HiveBoot.openBoxOnce<CompanyData>(selectedCompanyBox);
//   await Get.putAsync<CompanyService>(
//         () async => await CompanyService().init(),
//     permanent: true,
//   );
// }

  StorageService.setLoggedIn(true);
  customLoader.hide();
  if(!kIsWeb){
    FirebaseCrashlytics.instance.setUserIdentifier(APIs.me.userId.toString());
    FirebaseCrashlytics.instance.setCustomKey('companyId', companyData.companyId.toString() ?? '');
    FirebaseCrashlytics.instance.setCustomKey('app', 'AccuChat'); // optional

  }
  Get.offAllNamed(AppRoutes.home);

}
}