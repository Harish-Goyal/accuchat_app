import 'package:AccuChat/Constants/assets.dart';
import 'package:AccuChat/Screens/Chat/screens/chat_tasks/Presentation/Controllers/all_user_controller.dart';
import 'package:AccuChat/Screens/Chat/screens/chat_tasks/Presentation/Views/task_chat_screen.dart';
import 'package:AccuChat/Services/APIs/api_ends.dart';
import 'package:AccuChat/routes/app_routes.dart';
import 'package:AccuChat/utils/loading_indicator.dart';
import 'package:AccuChat/utils/networl_shimmer_image.dart';
import 'package:AccuChat/utils/text_style.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../../Constants/app_theme.dart';
import '../../../../../../Constants/colors.dart';
import '../../../../../../Constants/colors.dart' as AppTheme;
import '../../../../../../main.dart';
import '../../../../../../utils/helper_widget.dart';
import '../../../../api/apis.dart';
import '../../../../models/chat_user.dart';
import 'chat_screen.dart';

class AllUserScreen extends GetView<AllUserController> {
  AllUserScreen({super.key});

  DateTime _lastCall = DateTime.fromMillisecondsSinceEpoch(0);

  bool canFetch() {
    final now = DateTime.now();
    if (now.difference(_lastCall).inMilliseconds < 300) return false;
    _lastCall = now;
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      appBar: _buildAppBar(),

      // ---------------- WEB RESPONSIVE WRAPPER ADDED ----------------
      body: Obx(
        () => Center(
          child: controller.isLoading.value
              ? IndicatorLoading()
              : ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth:
                        kIsWeb ? 600 : double.infinity, // FIX WIDTH ON WEB
                  ),
                  child: Container(
                    margin:
                        const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: kIsWeb
                          ? [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                spreadRadius: 2,
                                offset: const Offset(0, 3),
                              )
                            ]
                          : [], // mobile keeps simple, no shadow
                    ),
                    child: NotificationListener<ScrollNotification>(
                      onNotification: (ScrollNotification n) {
                        if (n is! ScrollEndNotification)
                          return false; // ✅ avoid spam

                        final m = n.metrics;

                        if (m.extentAfter < 200 &&
                            !controller.isLoading.value &&
                            controller.hasMore &&
                            canFetch()) {
                          controller.hitAPIToGetMember();
                        }
                        return false;
                      },
                      child: ListView.builder(
                          itemCount: controller.filteredList.length ?? 0,
                          physics: AlwaysScrollableScrollPhysics(),
                          controller: controller.scrollController,
                          // shrinkWrap: true,
                          padding: EdgeInsets.zero,
                          itemBuilder: (_, i) {
                            final memData = controller.filteredList[i];
                            return ListTile(
                              leading: SizedBox(
                                width: 50,
                                child: CustomCacheNetworkImage(
                                  "${ApiEnd.baseUrlMedia}${controller.filteredList[i].userImage ?? ''}",
                                  height: 45,
                                  width: 45,
                                  radiusAll: 100,
                                  borderColor: greyText,
                                  boxFit: BoxFit.cover,
                                  defaultImage: userIcon,
                                ),
                              ),
                              title: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    memData.userId == controller.me?.userId
                                        ? "Me"
                                        : memData?.userName != null
                                            ? memData?.userName ?? ''
                                            : memData?.userCompany
                                                        ?.displayName !=
                                                    null
                                                ? memData?.userCompany
                                                        ?.displayName ??
                                                    ''
                                                : memData?.phone ?? '',
                                    style: BalooStyles.baloosemiBoldTextStyle(),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  vGap(4),
                                  memData?.userName != null ||
                                          memData?.userCompany?.displayName !=
                                              null
                                      ? Text(
                                          memData?.phone != null
                                              ? memData?.phone ?? ''
                                              : memData?.email ?? '',
                                          style:
                                              BalooStyles.balooregularTextStyle(
                                                  color: greyText),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        )
                                      : SizedBox(),

                                ],
                              ),
                              onTap: () {
                                if (isTaskMode) {
                                  if (kIsWeb) {
                                    Get.to(() => TaskScreen(
                                          taskUser: controller.filteredList[i],
                                          showBack: true,
                                        ));
                                  } else {
                                    Get.toNamed(AppRoutes.tasks_li_r,
                                        arguments: {
                                          'user': controller.filteredList[i]
                                        });
                                  }
                                } else {
                                  if (kIsWeb) {
                                    Get.to(() => ChatScreen(
                                          user: controller.filteredList[i],
                                          showBack: true,
                                        ));
                                  } else {
                                    Get.toNamed(AppRoutes.chats_li_r,
                                        arguments: {
                                          'user': controller.filteredList[i]
                                        });
                                  }
                                }
                              },
                            );
                          }),
                    ),
                  ),
                ),
        ),
      ),
      // ---------------- END RESPONSIVE WRAPPER ----------------
    ));
  }

  AppBar _buildAppBar() {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Colors.white, // white color
      elevation: 1, // remove shadow
      scrolledUnderElevation: 0, // ✨ prevents color change on scroll
      surfaceTintColor: Colors.white,
      leading: IconButton(
          onPressed: () {
            Get.offAllNamed(AppRoutes.home);
          },
          icon: Icon(
            Icons.arrow_back,
            color: Colors.black,
          )),
      title: Obx(() {
        return controller.isSearching.value
            ? TextField(
                controller: controller.searchController,
                cursorColor: appColorGreen,
                decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Search User by name and phone ...',
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                    constraints: BoxConstraints(maxHeight: 45)),
                autofocus: true,
                style: const TextStyle(fontSize: 13, letterSpacing: 0.5),
                onChanged: (val) {
                  controller.searchText = val;
                  controller.onSearch(val);
                },
              ).marginSymmetric(vertical: 10)
            :

            /*   DropdownButtonHideUnderline(

                        child: DropdownButton<CompanyData>(
                          borderRadius: BorderRadius.circular(12),
                          value: controller.selectedCompany.value,
                          isExpanded: true,

                          icon: const Icon(Icons.arrow_drop_down),
                          dropdownColor: Colors.white,
                          items: controller.joinedCompaniesList.map((company) {
                            return DropdownMenuItem<CompanyData>(
                              value: company,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SizedBox(
                                    width: 40,
                                    child: CustomCacheNetworkImage(
                                      "${ApiEnd.baseUrlMedia}${company?.logo ?? ''}",
                                      radiusAll: 100,
                                      height: 40,
                                      width: 40,
                                      borderColor: appColorYellow,

                                      defaultImage: appIcon,
                                      boxFit: BoxFit.cover,
                                    ),
                                  ),
                                  hGap(10),
                                  Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Chats',
                                        style:
                                        BalooStyles.balooboldTitleTextStyle(
                                            color: AppTheme.appColor,
                                            size: 16),
                                      ).paddingOnly(left: 0, top: 4,bottom: 4),
                                      Text(
                                        (company?.companyName ?? '')
                                            .toUpperCase(),
                                        style: BalooStyles.baloomediumTextStyle(
                                            color: appColorYellow,
                                            size:12
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: (CompanyData? companyData) async {
                            if (companyData == null) return;

                            controller.selectedCompany.value = companyData;
                            controller.update();

                            // --- 🔥 YOUR CHANGE LOGIC ---
                            customLoader.show();

                            controller.hitAPIToGetSentInvites(
                              companyData: companyData,
                              isMember: false,
                            );

                            final svc = CompanyService.to;
                            await svc.select(companyData);

                            controller.getCompany();

                            await APIs.refreshMe(companyId: companyData?.companyId??0);

                            Get.find<SocketController>()
                                .connectUserEmitter(companyData.companyId);

                            controller.resetPaginationForNewChat();
                            controller.hitAPIToGetRecentChats();


                            // Get.find<ChatScreenController>().getArguments();
                            //
                            // if (kIsWeb) {
                            //   Get.find<ChatScreenController>().user = Get.find<ChatHomeController>().selectedChat.value;
                            //   // _initScroll();
                            // }
                            // Get.find<ChatScreenController>().onInit();

                            Get.find<ChatHomeController>().update();
                            Get.find<ChatScreenController>().update();
                            customLoader.hide();
                          },
                        ),
                      )*/

            Text(
                'Users',
                style: BalooStyles.balooboldTitleTextStyle(),
              );
      }),
      actions: [
        Obx(() {
          return IconButton(
              onPressed: () {
                controller.isSearching.value = !controller.isSearching.value;
                controller.isSearching.refresh();

                if (!controller.isSearching.value) {
                  controller.searchText = '';
                  controller.onSearch('');
                  controller.searchController.clear();
                }
                // controller.update();
              },
              icon: controller.isSearching.value
                  ? const Icon(CupertinoIcons.clear_circled_solid)
                  : Image.asset(searchPng, height: 25, width: 25));
        }),
      ],
    );
  }
}
