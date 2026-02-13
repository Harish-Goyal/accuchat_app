import 'package:AccuChat/Constants/assets.dart';
import 'package:AccuChat/Constants/colors.dart';
import 'package:AccuChat/Screens/Chat/screens/chat_tasks/Presentation/Views/task_chat_screen.dart';
import 'package:AccuChat/Screens/Home/Presentation/Controller/company_members_controller.dart';
import 'package:AccuChat/Screens/Home/Presentation/Controller/home_controller.dart';
import 'package:AccuChat/Services/APIs/api_ends.dart';
import 'package:AccuChat/main.dart';
import 'package:AccuChat/utils/loading_indicator.dart';
import 'package:AccuChat/utils/text_style.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:swipe_to/swipe_to.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../../../../routes/app_routes.dart';
import '../../../../utils/data_not_found.dart';
import '../../../../utils/helper_widget.dart';
import '../../../../utils/networl_shimmer_image.dart';
import '../../../Chat/api/apis.dart';
import '../../../Chat/screens/chat_tasks/Presentation/Controllers/chat_home_controller.dart';
import '../../../Chat/screens/chat_tasks/Presentation/Controllers/chat_screen_controller.dart';
import '../../../Chat/screens/chat_tasks/Presentation/Views/chat_screen.dart';
import '../../../Chat/screens/chat_tasks/Presentation/dialogs/profile_dialog.dart';

class CompanyMembers extends GetView<CompanyMemberController> {
  CompanyMembers({super.key});

  DateTime _lastCall = DateTime.fromMillisecondsSinceEpoch(0);

  bool canFetch() {
    final now = DateTime.now();
    if (now.difference(_lastCall).inMilliseconds < 300) return false;
    _lastCall = now;
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final bool isWide = size.width >= 900;
    const double maxContentWidth = 650;

    return Scaffold(
      appBar: _buildAppBar(),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: isWide ? maxContentWidth : double.infinity,
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: isWide ? 16 : 10),
            child: buildCompanyMembersList(),
          ),
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      automaticallyImplyLeading: true,
      backgroundColor: Colors.white,
      elevation: 1,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.white,
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
            : Text(
                ("${(controller.companyName ?? '')}'s Members"),
                style: BalooStyles.balooboldTitleTextStyle(),
              );
      }),
      actions: [
        Obx(() {
          return IconButton(
                  onPressed: () {
                    controller.isSearching.value =
                        !controller.isSearching.value;
                    controller.isSearching.refresh();

                    if (!controller.isSearching.value) {
                      controller.searchText = '';
                      controller.onSearch('');
                      controller.searchController.clear();
                    }
                  },
                  icon: controller.isSearching.value
                      ? const Icon(CupertinoIcons.clear_circled_solid)
                      : Image.asset(searchPng, height: 25, width: 25))
              .paddingOnly(right: 8);
        }),
      ],
    );
  }

  Widget buildCompanyMembersList() {
    return Obx(
      () => controller.isLoading.value
          ? const IndicatorLoading()
          : controller.filteredList.isEmpty
              ? SizedBox(
        height: 80,
        width: 80,
          child: DataNotFoundText())
              : NotificationListener<ScrollNotification>(
                  onNotification: (ScrollNotification n) {
                    if (n is! ScrollEndNotification) {
                      return false;
                    }
                    final m = n.metrics;
                    if (m.extentAfter < 200 &&
                        !controller.isLoading.value &&
                        controller.hasMore &&
                        canFetch()) {
                      controller.hitAPIToGetMember();
                    }
                    return false;
                  },
                  child: ListView.separated(
                    itemCount: controller.filteredList.length,
                    physics: const AlwaysScrollableScrollPhysics(),
                    controller: controller.scrollController,
                    itemBuilder: (context, index) {
                      final memData = controller.filteredList[index];
                      final bool isWide = MediaQuery.of(context).size.width >=
                          900;
                      return SwipeTo(
                        key: ValueKey(memData.userId),
                        iconOnLeftSwipe: Icons.delete_outline,
                        iconColor: Colors.red,
                        onLeftSwipe:
                            (detail) async {
                          controller.removeCompanyMember(memData);
                        },
                        child: ListTile(
                          dense: true,
                          enabled: false,
                          visualDensity: kIsWeb
                              ? const VisualDensity(vertical: -1)
                              : VisualDensity.standard,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 0),
                          leading: memData.userImage == '' ||
                                  memData.userImage == null
                              ? InkWell(
                                  onTap: () {
                                    showDialog(
                                        context: context,
                                        builder: (_) =>
                                            ProfileDialog(user: memData));
                                  },
                                  child: CircleAvatar(
                                      radius: isWide
                                          ? 22
                                          : 20,
                                      backgroundColor:
                                          appColorGreen.withOpacity(.1),
                                      child: Icon(
                                        Icons.person,
                                        size: isWide ? 18 : 15,
                                        color: appColorGreen,
                                      )),
                                )
                              : InkWell(
                                  onTap: () {
                                    showDialog(
                                        context: context,
                                        builder: (_) =>
                                            ProfileDialog(user: memData));
                                  },
                                  child: CircleAvatar(
                                      radius: isWide ? 22 : 20,
                                      backgroundColor:
                                          appColorGreen.withOpacity(.1),
                                      child: SizedBox(
                                        width: 60,
                                        child: CustomCacheNetworkImage(
                                          radiusAll: 100,
                                          width: 60,
                                          height: 60,
                                          boxFit: BoxFit.cover,
                                          defaultImage: userIcon,
                                          borderColor: greyText,
                                          "${ApiEnd.baseUrlMedia}${memData.userImage ?? ''}",
                                        ),
                                      ))),
                          title: InkWell(
                            onLongPress: () {
                              controller.removeCompanyMember(memData);
                            },
                            onTap: () => _goToChat(memData),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  memData.userName != null
                                      ? memData.userName ?? ''
                                      : memData.userCompany?.displayName !=
                                              null
                                          ? memData.userCompany?.displayName ??
                                              ''
                                          : memData.phone ?? '',
                                  style: BalooStyles.baloosemiBoldTextStyle(),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                vGap(4),
                                memData.userName == null &&
                                        memData.userCompany?.displayName ==
                                            null
                                    ? const SizedBox()
                                    : Text(
                                        memData.phone != null
                                            ? memData.phone ?? ''
                                            : memData.email ?? '',
                                        style:
                                            BalooStyles.balooregularTextStyle(),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      )
                              ],
                            ),
                          ),

                          trailing: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    TextButton(
                                        onPressed: () => _goToChat(memData),
                                        style: TextButton.styleFrom(
                                          foregroundColor: appColorGreen,
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 7.0,
                                              vertical:
                                                  3.0),
                                          minimumSize: const Size(0,
                                              0),
                                          tapTargetSize: MaterialTapTargetSize
                                              .shrinkWrap,
                                        ),
                                        child: Image.asset(
                                          chatHome,
                                          color: appColorGreen,
                                          height: 20,
                                        )),
                                    hGap(12),
                                    TextButton(
                                      onPressed: () => _goToTask(memData),
                                      style: TextButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 6, vertical: 3),
                                        minimumSize: const Size(0, 0),
                                        tapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                      ),
                                      child: Image.asset(tasksHome,
                                          color: appColorYellow, height: 20),
                                    ),
                                  ],
                                )
                              ]),
                        ),
                      );
                    },
                    separatorBuilder: (BuildContext context, int index) {
                      return divider().marginSymmetric(horizontal: 20);
                    },
                  ),
                ),
    );
  }

  _goToTask(memData) {
    final dcController = Get.find<DashboardController>();
    dcController.updateIndex(1);

    isTaskMode = true;
    controller.update();
    if(isTaskMode) {
      if(kIsWeb){
        Get.to(()=>TaskScreen(taskUser:memData ,showBack: true,));
      }else{
        Get.toNamed(
          AppRoutes.tasks_li_r,
          arguments: {'user': memData},
        );
      }
    }else{
      if(kIsWeb){
        Get.to(()=>ChatScreen(user: memData,showBack: true,));
      }else{
        Get.toNamed(
          AppRoutes.chats_li_r,
          arguments: {'user': memData},
        );
      }
    }
  }
    Future<void> _goToChat(memData) async {
      DashboardController?   dcController;
      if(Get.isRegistered<DashboardController>()){
        dcController = Get.find<DashboardController>();
      }
      dcController?.updateIndex(0);
      isTaskMode = false;
      if(isTaskMode) {
        if(kIsWeb){
          Get.to(()=>TaskScreen(taskUser: memData ,showBack: true,));
        }else{
          Get.toNamed(AppRoutes.tasks_li_r, arguments: {'user': memData},);
        }
      }else{
        if(kIsWeb){
          Get.to(()=>ChatScreen(user: memData ,showBack: true,));
        }else{
          Get.toNamed(
            AppRoutes.chats_li_r,
            arguments: {'user': memData},
          );
        }
      }

      }

/*  Future<void> _goToChat(memData) async {
    // 1) Go Home first (clear stack)
     Get.back();
    // 2) Set dashboard to Chat tab (jo bhi chat index hai)
    final dc = Get.isRegistered<DashboardController>()
        ? Get.find<DashboardController>()
        : Get.put(DashboardController());
    dc.updateIndex(0); // <-- yaha apna chat tab index daalo
    dc.update();
    // 3) Give Home UI/controllers a frame to build
    await Future.delayed(const Duration(milliseconds: 50));
    if (kIsWeb) {
      final _tag = "chat_${memData?.userId ?? 'mobile'}";
      // 4) Ensure Home controller is available
      final homec = Get.isRegistered<ChatHomeController>()
          ? Get.find<ChatHomeController>()
          : Get.put(ChatHomeController());

      // 5) Ensure ChatScreenController exists with correct user
      ChatScreenController chatc;
      if (Get.isRegistered<ChatScreenController>()) {

        chatc = Get.find<ChatScreenController>(tag: _tag);
        chatc.user = memData; // important
      } else {
        chatc = Get.put(ChatScreenController(user: memData),tag: _tag);
      }

      // 6) Select user & open conversation
      homec.selectedChat.value = memData;
      homec.selectedChat.refresh();

      chatc.textController.clear();
      chatc.replyToMessage = null;
      chatc.showPostShimmer = true;

       chatc.openConversation(memData);

      // 7) Mark read
      if ((memData?.pendingCount ?? 0) != 0) {
        chatc.markAllVisibleAsReadOnOpen(
          APIs.me?.userCompany?.userCompanyId,
          memData?.userCompany?.userCompanyId,
          (memData?.userCompany?.isGroup == 1) ? 1 : 0,
        );
      }

      homec.update();
      chatc.update();
    } else {
      // mobile direct chat screen
      Get.toNamed(AppRoutes.chats_li_r, arguments: {'user': memData});
    }
  }*/



}
