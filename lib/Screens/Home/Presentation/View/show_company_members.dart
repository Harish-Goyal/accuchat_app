import 'package:AccuChat/Constants/assets.dart';
import 'package:AccuChat/Constants/colors.dart';
import 'package:AccuChat/Screens/Chat/api/apis.dart';
import 'package:AccuChat/Screens/Home/Presentation/Controller/company_members_controller.dart';
import 'package:AccuChat/Screens/Home/Presentation/Controller/home_controller.dart';
import 'package:AccuChat/Screens/Home/Presentation/View/home_screen.dart';
import 'package:AccuChat/Services/APIs/api_ends.dart';
import 'package:AccuChat/main.dart';
import 'package:AccuChat/utils/loading_indicator.dart';
import 'package:AccuChat/utils/text_style.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:swipe_to/swipe_to.dart';
import 'package:flutter/foundation.dart' show kIsWeb; // added for web checks

import '../../../../routes/app_routes.dart';
import '../../../../utils/animated_badge.dart';
import '../../../../utils/custom_flashbar.dart';
import '../../../../utils/data_not_found.dart';
import '../../../../utils/helper_widget.dart';
import '../../../../utils/networl_shimmer_image.dart';
import '../../../Chat/models/chat_user.dart';
import '../../../Chat/models/company_model.dart';
import '../../../Chat/models/invite_model.dart';
import '../../../Chat/screens/chat_tasks/Presentation/Views/chat_screen.dart';
import '../../../Chat/screens/chat_tasks/Presentation/dialogs/profile_dialog.dart';

class CompanyMembers extends GetView<CompanyMemberController> {
  CompanyMembers({super.key});

  DashboardController dcController =
  Get.put<DashboardController>(DashboardController());

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final bool isWide = size.width >= 900; // responsive breakpoint
    final double maxContentWidth = 900; // center content on large screens

    return GetBuilder<CompanyMemberController>(builder: (controller) {
      return Scaffold(
        appBar: AppBar(
          leadingWidth: 30,
          title: Text(
            ("${(controller.companyName ?? '').toUpperCase()}'s Members"),
            style: BalooStyles.balooboldTitleTextStyle(),
          ),
          toolbarHeight: isWide ? 64 : kToolbarHeight, // a bit taller on web
        ),
        // Responsive wrapper: keeps your original list centered and with comfy width on web
        body: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: isWide ? maxContentWidth : double.infinity,
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: isWide ? 16 : 0),
              child: buildCompanyMembersList(),
            ),
          ),
        ),
      );
    });
  }

  Widget buildCompanyMembersList() {
    return Container(
      height: Get.height,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child:controller.isLoading?const IndicatorLoading():
      (controller.members??[]).isEmpty?DataNotFoundText(): ListView.separated(
        shrinkWrap: true,
        itemCount: controller.members?.length??0,
        itemBuilder: (context, index) {
          final memData = controller.members?[index];
          final bool isWide = MediaQuery.of(context).size.width >= 900; // web-aware inside the row
          return SwipeTo(
            iconOnLeftSwipe: Icons.delete_outline,
            iconColor: Colors.red,
            onLeftSwipe: /*(((APIs.me.selectedCompany!.createdBy == user.id) ))
                              ? (de) {
                            if(user.role
                                != 'admin') {
                              errorDialog("Not Allowed Delete!");
                            }else{
                              errorDialog("You cannot delete company here!");
                            }
                          }
                              :*/
                (detail) async {
                  controller.removeCompanyMember(memData);
              /*final meId = controller.me?.userId;
              final creatorId = controller.myCompany?.createdBy;
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
                context: context,
                builder: (_) => AlertDialog(
                  backgroundColor: Colors.white,
                  title: Text("Remove $who"),
                  content: const Text("Are you sure you want to remove this member?"),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: Text("Remove", style: BalooStyles.baloosemiBoldTextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );

              if (confirm == true) {
                controller.hitAPIToRemoveMember(targetId);
              }*/
            },

              child: ListTile(
              dense: true,
              enabled: false,
              visualDensity: kIsWeb ? const VisualDensity(vertical: -1) : VisualDensity.standard, // tighter on web
              contentPadding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
              leading:
                  memData?.userImage == '' ||
                  memData?.userImage == null
                  ? InkWell(
                    onTap: (){
                      showDialog(
                          context: context,
                          builder: (_) => ProfileDialog(user: memData));
                    },
                    child: CircleAvatar(
                    radius: isWide ? 22 : 20, // slightly larger on wide
                    backgroundColor: appColorGreen.withOpacity(.1),
                    child: Icon(
                      Icons.person,
                      size: isWide ? 18 : 15,
                      color: appColorGreen,
                    )),
                  )
                  : InkWell(
          onTap: (){
          showDialog(
          context: context,
          builder: (_) => ProfileDialog(user: memData));
          },
          child:CircleAvatar(
                  radius: isWide ? 22 : 20,
                  backgroundColor: appColorGreen.withOpacity(.1),
                  child: SizedBox(
                    width: 60,
                    child: CustomCacheNetworkImage(
                      radiusAll: 100,
                      width: 60,
                      height: 60,
                      boxFit: BoxFit.cover,
                      defaultImage: userIcon,
                      borderColor: greyText,
                      "${ApiEnd.baseUrlMedia}${memData?.userImage ?? ''}",
                    ),
                  ))),
              title:

                  InkWell(
                    onLongPress: (){
                      controller.removeCompanyMember(memData);
                    },
                    onTap: (){
                      dcController.updateIndex(0);

                      isTaskMode = false;
                      controller.update();
                      // APIs.updateActiveStatus(true);


                      if(isTaskMode) {
                        if(kIsWeb){
                          Get.toNamed(
                            "${AppRoutes.tasks_li_r}?userId=${memData?.userId.toString()}",
                          );
                        }else{
                          Get.toNamed(
                            AppRoutes.tasks_li_r,
                            arguments: {'user': memData},
                          );
                        }
                      }else{
                        if(kIsWeb){
                          Get.toNamed(
                            "${AppRoutes.chats_li_r}?userId=${memData?.userId.toString()}",
                          );
                        }else{
                          Get.toNamed(
                            AppRoutes.chats_li_r,
                            arguments: {'user': memData},
                          );
                        }
                      }
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        memData?.userCompany?.displayName == '' ||
                            memData?.userCompany?.displayName == null
                            ? Text(
                          (memData?.email != null)
                              ? memData?.email ?? ''
                              : memData?.phone ?? '',
                          style: BalooStyles.balooregularTextStyle(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        )
                            : Text(
                          memData?.userCompany?.displayName ?? '',
                          style: BalooStyles.baloosemiBoldTextStyle(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),

                        vGap(4),

                        memData?.userCompany?.displayName == '' ||
                            memData?.userCompany?.displayName == null
                            ? const SizedBox(
                          height: 0,
                        )
                            : Text(
                          memData?.email != null
                              ?memData?.email ?? ''
                              : memData?.phone ?? '',
                          style: BalooStyles.balooregularTextStyle(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),



              trailing: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [

                    // (user.userId == APIs.me.id && user.userId != APIs.me.selectedCompany?.adminUserId)
                    //  ? Text(
                    //                     //   "You",
                    //                     //   style: BalooStyles
                    //                     //       .baloonormalTextStyle(),
                    //                     // )
                    //     :(user.userId == APIs.me.selectedCompany?.adminUserId)?Text(
                    //   "Creator",
                    //   style: BalooStyles
                    //       .baloonormalTextStyle(color:appColorGreen),
                    // ): const SizedBox(),

                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [

                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            TextButton(
                                onPressed: () {

                                  dcController.updateIndex(0);

                                  isTaskMode = false;
                                  controller.update();
                                  // APIs.updateActiveStatus(true);


                                  if(isTaskMode) {
                                    if(kIsWeb){
                                      Get.toNamed(
                                        "${AppRoutes.tasks_li_r}?userId=${memData?.userId.toString()}",
                                      );
                                    }else{
                                      Get.toNamed(
                                        AppRoutes.tasks_li_r,
                                        arguments: {'user': memData},
                                      );
                                    }
                                  }else{
                                    if(kIsWeb){
                                      Get.toNamed(
                                        "${AppRoutes.chats_li_r}?userId=${memData?.userId.toString()}",
                                      );
                                    }else{
                                      Get.toNamed(
                                        AppRoutes.chats_li_r,
                                        arguments: {'user': memData},
                                      );
                                    }
                                  }
                                },
                                style: TextButton.styleFrom(
                                  // backgroundColor: appColorGreen.withOpacity(.1), // Button background color
                                  foregroundColor: appColorGreen,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 7.0,
                                      vertical: 3.0), // reduce as needed
                                  minimumSize: const Size(0,
                                      0), // optional: allows tighter sizing
                                  tapTargetSize: MaterialTapTargetSize
                                      .shrinkWrap, // optional: reduces touch target
                                ),
                                child: Image.asset(chatHome,color: appColorGreen,height: 20,)),

                            Positioned(
                                top: -13,
                                right: -7,
                              child: AnimatedBadge(count:2,),
                            ),
                          ],
                        ),

                        hGap(12),


                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            TextButton(
                                onPressed: () {

                                  dcController.updateIndex(1);

                                  isTaskMode = true;
                                  controller.update();
                                  if(isTaskMode) {


                                    if(kIsWeb){
                                      Get.toNamed(
                                        "${AppRoutes.tasks_li_r}?userId=${memData?.userId.toString()}",
                                      );
                                    }else{
                                      Get.toNamed(
                                        AppRoutes.tasks_li_r,
                                        arguments: {'user': memData},
                                      );
                                    }
                                  }else{
                                    if(kIsWeb){
                                      Get.toNamed(
                                        "${AppRoutes.chats_li_r}?userId=${memData?.userId.toString()}",
                                      );
                                    }else{
                                      Get.toNamed(
                                        AppRoutes.chats_li_r,
                                        arguments: {'user': memData},
                                      );
                                    }
                                  }
                                },
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6.0,
                                      vertical: 3.0), // reduce as needed
                                  minimumSize: const Size(0,
                                      0), // optional: allows tighter sizing
                                  tapTargetSize: MaterialTapTargetSize
                                      .shrinkWrap, // optional: reduces touch target
                                ),
                                child: Image.asset(tasksHome,color: appColorYellow,height: 20,)),

                            Positioned(
                              top: -13,
                              right: -7, // 👈 top-left corner (change to right for top-right)
                              child: AnimatedBadge(count:4,),
                            ),
                          ],
                        ),
                      ],
                    )
                  ]),
              /*trailing: IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          final confirm = await showDialog(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: Text("Remove ${user.name}?"),
                              content: Text("Are you sure you want to remove this member?"),
                              actions: [
                                TextButton(onPressed: () => Navigator.pop(context, false), child: Text("Cancel")),
                                TextButton(onPressed: () => Navigator.pop(context, true), child: Text("Remove")),
                              ],
                            ),
                          );

                          if (confirm == true) {
                            await APIs.removeCompanyMember(user.id, companyId);
                          }
                        },
                      ),*/
            ),
          );
        },
        separatorBuilder: (BuildContext context, int index) {
          return divider().marginSymmetric(horizontal: 20);
        },
      ),
    );
  }
}
