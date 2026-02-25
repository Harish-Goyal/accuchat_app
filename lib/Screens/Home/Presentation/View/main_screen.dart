import 'package:AccuChat/Constants/assets.dart';
import 'package:AccuChat/Constants/colors.dart';
import 'package:AccuChat/Screens/Chat/helper/dialogs.dart';
import 'package:AccuChat/Screens/Chat/screens/chat_tasks/Presentation/Controllers/chat_home_controller.dart';
import 'package:AccuChat/Screens/Chat/screens/chat_tasks/Presentation/Controllers/chat_screen_controller.dart';
import 'package:AccuChat/Screens/Chat/screens/chat_tasks/Presentation/Controllers/task_controller.dart';
import 'package:AccuChat/Screens/Chat/screens/chat_tasks/Presentation/Controllers/task_home_controller.dart';
import 'package:AccuChat/Screens/Home/Presentation/Controller/gallery_controller.dart';
import 'package:AccuChat/Screens/Home/Presentation/Controller/home_controller.dart';
import 'package:AccuChat/utils/bottom_nav_budge.dart';
import 'package:AccuChat/utils/text_style.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:AccuChat/Screens/Reload/reload_factory.dart';
import 'package:flutter_snake_navigationbar/flutter_snake_navigationbar.dart';
import 'package:get/get.dart';
import 'package:sidebarx/sidebarx.dart';
import '../../../../main.dart';
import '../../../../utils/chat_presence.dart';
import '../../../../utils/register_image.dart';
import '../../../Chat/api/apis.dart';

class AccuChatDashboard extends StatelessWidget {
  final controller = Get.put(DashboardController());
  @override
  Widget build(BuildContext context) {
    bool isWideScreen = MediaQuery.of(context).size.width > 800;

    return GetBuilder<DashboardController>(builder: (con) {
        return WillPopScope(onWillPop: () async {
          if (con.currentIndex != 0) {
            con.updateIndex(0);
            return false;
          }
          return true;
        }, child:  Scaffold(
            // drawer: isWideScreen ? null : _buildDrawer(), // for mobile
            body: Row(
              children: [
                if (isWideScreen)
                  buildSideNavSidebarX(con,context),
                Expanded(
                  child: con.screens.isEmpty
                      ? const SizedBox()
                      : ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1000),
                    child: con.screens[con.currentIndex],
                  ),
                ),
              ],
            ),
            bottomNavigationBar: isWideScreen
                ? null
                : con.screens.isEmpty
                    ? const SizedBox()
                    : _bottomNavigationBar(isWideScreen,con),
          )
           );
      }
    );
  }


  Widget buildSideNavSidebarX(DashboardController controller,context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.symmetric(
          vertical: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: SidebarX(
        controller: controller.sidebarXController,
        animationDuration: const Duration(milliseconds: 200),
        theme: SidebarXTheme(
          margin: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: appColorGreen.withOpacity(.1),
            borderRadius: BorderRadius.circular(2),
          ),
          hoverColor: appColorGreen.withOpacity(.2),
          hoverTextStyle: BalooStyles.baloosemiBoldTextStyle(),
          textStyle: BalooStyles.baloomediumTextStyle(color: Colors.black87,),
          selectedTextStyle: BalooStyles.baloomediumTextStyle(color: Colors.white),
          iconTheme: const IconThemeData(color: Colors.black45, size: 20),
          selectedIconTheme: const IconThemeData(color: Colors.white, size: 20),
          itemDecoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
          ),
          selectedItemDecoration: BoxDecoration(
            color: appColorGreen,
            borderRadius: BorderRadius.circular(12),
          ),

        ),
        extendedTheme: const SidebarXTheme(width: 140),
        items: [
          SidebarXItem(
            label: 'Chats',
            iconBuilder: (selected, hovered) => Image.asset(
              chatHome,
              height: 20,
              color: selected ? Colors.white : Colors.grey,
            ).paddingSymmetric(horizontal: 5),
            onTap: () => _handleSidebarTap(controller, 0,context),
          ),
          SidebarXItem(
            label: 'Tasks',
            iconBuilder: (selected, hovered) =>
               Image.asset(
                tasksHome,
                height: 20,
                color: selected ? Colors.white : Colors.grey,
              ).paddingSymmetric(horizontal: 5),

            onTap: () => _handleSidebarTap(controller, 1,context),
          ),
          SidebarXItem(
            label: 'Gallery',
            iconBuilder: (selected, hovered) => Image.asset(
              galleryIcon,
              height: 20,
              color: selected ? Colors.white : Colors.grey,
            ).paddingSymmetric(horizontal: 5),
            onTap: () => _handleSidebarTap(controller, 2,context),
          ),
          SidebarXItem(
            label: 'Companies',
            iconBuilder: (selected, hovered) => Obx(() {
              return Stack(
                clipBehavior: Clip.none,
                children: [
                  Image.asset(
                    connectedAppIcon,
                    height: 20,
                    color: selected ? Colors.white : Colors.grey,
                  ).paddingSymmetric(horizontal: 5),
                  controller.newCompanyChat.value
                      ? Positioned(
                    top: -5,
                    right: -10,
                    child: BottomNavBudge(
                      budgeCount:
                      "${Get.find<ChatHomeController>()?.selectedChat.value?.pendingCount ?? ''}",
                    ),
                  )
                      : const SizedBox(),
                ],
              );
            }),
            onTap: () => _handleSidebarTap(controller, 3,context),
          ),
        ],

        footerItems: [
          SidebarXItem(
            label: 'Settings',
            iconWidget: Image.asset(
              settingPng,
              height: 20,
            ).paddingSymmetric(horizontal: 5),
            onTap: () => _handleSidebarTap(controller, 4,context),
          ),
        ],
      ),
    );
  }

  /*  Widget buildSideNavSidebarX(DashboardController controller) {
    return Container(
      decoration: BoxDecoration(
        border: Border.symmetric(
          vertical: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: SidebarX(
        controller: controller.sidebarXController,
        theme: SidebarXTheme(
          margin: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: appColorGreen.withOpacity(.1),
            borderRadius: BorderRadius.circular(14),
          ),
          hoverColor: appColorGreen.withOpacity(.2),
          hoverTextStyle: BalooStyles.baloosemiBoldTextStyle(),
          textStyle: BalooStyles.baloomediumTextStyle().copyWith(
            color: Colors.black87,
          ),

          selectedTextStyle: BalooStyles.baloomediumTextStyle().copyWith(
            color: Colors.white,
          ),
          iconTheme: const IconThemeData(color: Colors.black45, size: 22),
          selectedIconTheme: const IconThemeData(color: Colors.white, size: 22),
          itemDecoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
          ),
          selectedItemDecoration: BoxDecoration(
            color: appColorGreen,
            borderRadius: BorderRadius.circular(12),
          ),

        ),
        extendedTheme: const SidebarXTheme(width: 180),
        footerBuilder: (context, extended) {
          return Padding(
            padding: const EdgeInsets.all(10),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              hoverColor: Colors.transparent,   // ✅ no hover
              splashColor: Colors.transparent,  // ✅ no splash
              highlightColor: Colors.transparent, // ✅ no highlight
              onTap: () {
                if (kIsWeb) unregisterImage();
                Get.toNamed(AppRoutes.all_settings);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                child: Row(
                  mainAxisAlignment:
                  extended ? MainAxisAlignment.start : MainAxisAlignment.center,
                  children: [
                    Image.asset(settingPng, height: 22, color: Colors.grey),
                    if (extended) ...[
                      const SizedBox(width: 12),
                      Text('Settings',
                          style: BalooStyles.baloomediumTextStyle()
                              .copyWith(color: Colors.black87)),
                    ],
                  ],
                ),
              ),
            ),
          );
        },

        items: [
          SidebarXItem(
            label: 'Chats',
            iconBuilder: (selected, hovered) => Image.asset(
              chatHome,
              height: 22,
              color: selected ? Colors.white : Colors.grey,
            ).paddingSymmetric(horizontal: 8),
            onTap: () => _handleSidebarTap(controller, 0),
          ),
          SidebarXItem(
            label: 'Tasks',
            iconBuilder: (selected, hovered) => Obx(() {
              return Stack(
                clipBehavior: Clip.none,
                children: [
                  Image.asset(
                    tasksHome,
                    height: 22,
                    color: selected ? Colors.white : Colors.grey,
                  ).paddingSymmetric(horizontal: 8),
                  controller.newTask.value
                      ? Positioned(
                    top: -5,
                    right: -10,
                    child: BottomNavBudge(
                      budgeCount:
                      "${Get.find<ChatHomeController>()?.selectedChat.value?.pendingCount ?? ''}",
                    ),
                  )
                      : const SizedBox(),
                ],
              );
            }),
            onTap: () => _handleSidebarTap(controller, 1),
          ),
          SidebarXItem(
            label: 'Gallery',
            iconBuilder: (selected, hovered) => Image.asset(
              galleryIcon,
              height: 22,
              color: selected ? Colors.white : Colors.grey,
            ).paddingSymmetric(horizontal: 8),
            onTap: () => _handleSidebarTap(controller, 2),
          ),
          SidebarXItem(
            label: 'Your Companies',
            iconBuilder: (selected, hovered) => Obx(() {
              return Stack(
                clipBehavior: Clip.none,
                children: [
                  Image.asset(
                    connectedAppIcon,
                    height: 22,
                    color: selected ? Colors.white : Colors.grey,
                  ).paddingSymmetric(horizontal: 8),
                  controller.newCompanyChat.value
                      ? Positioned(
                    top: -5,
                    right: -10,
                    child: BottomNavBudge(
                      budgeCount:
                      "${Get.find<ChatHomeController>()?.selectedChat.value?.pendingCount ?? ''}",
                    ),
                  )
                      : const SizedBox(),
                ],
              );
            }),
            onTap: () => _handleSidebarTap(controller, 3),
          ),
        ],

        /// ✅ Settings fixed at bottom (replaces your bottom InkWell)
       *//* footerItems: [
          SidebarXItem(
            label: 'Settings',
            iconWidget: Image.asset(
              settingPng,
              height: 22,
            ).paddingSymmetric(horizontal: 8),
            onTap: () {
              if (kIsWeb) unregisterImage();
              Get.toNamed(AppRoutes.all_settings);
            },
          ),
        ],*//*
      ),
    );
  }*/

  Future<void> _handleSidebarTap(DashboardController controller, int index,context) async {
    await controller.getCompany();
    if (isCompanySwitched) {
      Dialogs.showSnackbar(context, "Your Company has been change please wait for reload");
      ReloadControllerImpl().refreshApp();
      isCompanySwitched = false;
    }
    controller.updateIndex(index);
    final isSetting = index == 4;
    // if (isSetting) {
    //   // if (kIsWeb) unregisterImage();
    //   // Get.toNamed(AppRoutes.all_settings);
    //   return;
    // }


    isTaskMode = index == 1;


    if (index == 0) {
      ChatHomeController? homec;
      bool isOpen = false;

      if (Get.isRegistered<ChatHomeController>()) {
        homec = Get.find<ChatHomeController>();
      } else {
        homec = Get.put(ChatHomeController());
        isOpen = true;
      }

      final _tagid = ChatPresence.activeChatId.value;
      final _tag = "chat_${_tagid ?? 'mobile'}";

      if (Get.isRegistered<ChatScreenController>(tag: _tag)) {
        if (homec!.filteredList.isNotEmpty) {
          final user = homec.filteredList[0];
          final chatc = Get.find<ChatScreenController>(tag: _tag);

          chatc.replyToMessage = null;
          homec.selectedChat.value = user;
          chatc.user = user;
          chatc.textController.clear();
          chatc.update();
          chatc.showPostShimmer = true;

          if (!isOpen) {
            chatc.getUserByIdApi(userId: user.userId);
          }

          if (homec.selectedChat.value?.pendingCount != 0) {
            chatc.markAllVisibleAsReadOnOpen(
              APIs.me.userCompany?.userCompanyId,
              chatc.user?.userCompany?.userCompanyId,
              chatc.user?.userCompany?.isGroup == 1 ? 1 : 0,
            );
          }
        }
      } else {
        if (homec!.filteredList.isNotEmpty) {
          final user = homec.filteredList[0];
          final userCid = user.userCompany?.userCompanyId;
          final newTag = "chat_${userCid ?? 'mobile'}";

          final chatc = Get.put(ChatScreenController(user: user), tag: newTag);
          chatc.showPostShimmer = true;
          chatc.replyToMessage = null;

          homec.selectedChat.value = user;
          chatc.user = user;

          if (homec.selectedChat.value?.pendingCount != 0) {
            chatc.markAllVisibleAsReadOnOpen(
              APIs.me.userCompany?.userCompanyId,
              chatc.user?.userCompany?.userCompanyId,
              chatc.user?.userCompany?.isGroup == 1 ? 1 : 0,
            );
          }

          homec.selectedChat.refresh();
          chatc.update();
        }
      }
    }

    // ========== TASKS ==========
    if (index == 1) {
      final TaskHomeController taskhomec;
      bool isOpen = false;

      if (Get.isRegistered<TaskHomeController>()) {
        taskhomec = Get.find<TaskHomeController>();
      } else {
        taskhomec = Get.put(TaskHomeController());
        isOpen = true;
      }

      final _tagid = TaskPresence.activeTaskId.value;
      final _tag = "task_${_tagid ?? 'mobile'}";

      if (Get.isRegistered<TaskController>(tag: _tag)) {
        final taskC = Get.find<TaskController>(tag: _tag);
        taskC.replyToMessage = null;

        if (taskhomec.filteredList.isNotEmpty) {
          final user = taskhomec.filteredList[0];
          taskhomec.selectedChat.value = user;
          taskC.user = taskhomec.selectedChat.value;
          taskC.textController.clear();
          taskC.update();
          taskC.showPostShimmer = true;
          taskC.getUserByIdApi(userId: user.userId);
        }
      } else {
        if (taskhomec.filteredList.isNotEmpty) {
          final user = taskhomec.filteredList[0];
          final tagId = user.userCompany?.userCompanyId;
          final newTag = "task_${tagId ?? 'mobile'}";

          final taskC = Get.put(TaskController(user: user), tag: newTag);
          taskhomec.selectedChat.value = user;

          taskC.user = user;
          taskC.textController.clear();
          taskC.page = 1;
          taskC.update();
        }
      }
    }

    // ========== GALLERY ==========
    if (index == 2) {
      if (kIsWeb) unregisterImage();
      if (Get.isRegistered<GalleryController>()) {
        final homec = Get.find<GalleryController>();
        homec.getCompany();
        homec.resetPagination();
        homec.hitApiToGetFolder(reset: true);
        homec.update();
      } else {
        final homec = Get.put(GalleryController());
        homec.getCompany();
        homec.resetPagination();
        homec.hitApiToGetFolder(reset: true);
        homec.update();
      }
    }

    // ========== COMPANIES ==========
    if (index == 3) {
      // keep whatever you do for "Your Companies" screen (if any)
    }
  }

/*  Widget buildSideNav(DashboardController controller) {
    return Column(
      children: [
        Expanded(
          child:  Container(
              decoration: BoxDecoration(
                  border: Border.symmetric(vertical: BorderSide(color: Colors.grey.shade200))
              ),
              child: NavigationRail(
                selectedIndex: controller.currentIndex,

                onDestinationSelected: (index) async {
                 await controller.getCompany();
                 if(isCompanySwitched){
                   Dialogs.showSnackbar(Get.context!, "Your Company has been change please wait to reload");
                   final reloadCon = Get.put(ReloadControllerImpl());
                   reloadCon.refreshApp();
                   isCompanySwitched=false;
                 }
                 controller.updateIndex(index);
                  final isSetting = index == 4;
                  if (isSetting) {
                    if (kIsWeb) unregisterImage();
                    Get.toNamed(AppRoutes.all_settings);
                  }

                  // Get.toNamed(AppRoutes.home);
                  isTaskMode = index == 1;
                  if (index == 0) {
                    ChatHomeController? homec;
                    bool isOpen = false;
                    if (Get.isRegistered<ChatHomeController>()) {
                      homec = Get.find<ChatHomeController>();
                    } else {
                      homec = Get.put(ChatHomeController());
                      isOpen = true;
                    }
                    final _tagid = ChatPresence.activeChatId.value;
                    final _tag = "chat_${_tagid ?? 'mobile'}";
                  if (Get.isRegistered<ChatScreenController>(tag: _tag)) {
                    if (homec!.filteredList.isNotEmpty) {
                      final user = homec.filteredList[0];

                      final chatc = Get.find<ChatScreenController>(tag: _tag);
                      chatc.replyToMessage = null;

                      homec.selectedChat.value = user;
                      chatc.user =user;
                      chatc.textController.clear();
                      chatc.update();
                      chatc.showPostShimmer = true;

                      !isOpen? chatc.getUserByIdApi(userId:user.userId ):null;
                      if (homec.selectedChat.value?.pendingCount != 0) {
                        chatc.markAllVisibleAsReadOnOpen(
                            APIs.me.userCompany?.userCompanyId,
                            chatc.user?.userCompany?.userCompanyId,
                            chatc.user?.userCompany?.isGroup == 1 ? 1 : 0);
                      }
                    }
                  } else {
                      if (homec!.filteredList.isNotEmpty) {
                        final user = homec.filteredList[0];
                        final userCid =user.userCompany?.userCompanyId;
                        final _tag = "chat_${userCid ?? 'mobile'}";
                      final chatc =Get.put(ChatScreenController(user: user),tag: _tag);
                        chatc.showPostShimmer = true;
                        chatc.replyToMessage = null;
                        homec.selectedChat.value = user;
                        chatc.user =user;
                        // chatc.openConversation(chatc.user);
                        if (homec.selectedChat.value?.pendingCount != 0) {
                          chatc.markAllVisibleAsReadOnOpen(
                              APIs.me.userCompany?.userCompanyId,
                              chatc.user?.userCompany?.userCompanyId,
                              chatc.user?.userCompany?.isGroup == 1 ? 1 : 0);
                        }
                        homec.selectedChat.refresh();
                        chatc.update();
                      }
                  }
                }

                  if (index == 1) {
                   final TaskHomeController taskhomec;
                    bool isOpen = false;
                    if (Get.isRegistered<TaskHomeController>()) {
                      taskhomec = Get.find<TaskHomeController>();
                    } else {
                      taskhomec = Get.put(TaskHomeController());
                      isOpen = true;
                    }
                    final _tagid = TaskPresence.activeTaskId.value;
                    final _tag = "task_${_tagid ?? 'mobile'}";
                    if (Get.isRegistered<TaskController>(tag: _tag)) {
                      final taskC = Get.find<TaskController>(tag: _tag);
                      taskC.replyToMessage = null;
                      if (taskhomec.filteredList.isNotEmpty) {
                        final user = taskhomec.filteredList[0];
                        taskhomec.selectedChat.value = user;
                        taskC.user = taskhomec.selectedChat.value;
                        taskC.textController.clear();
                        taskC.update();
                        taskC.showPostShimmer = true;
                        taskC.getUserByIdApi(userId: user.userId);
                        // taskC.openConversation(taskhomec.selectedChat.value);

                      }
                    } else {
                        if (taskhomec.filteredList.isNotEmpty) {
                          final user = taskhomec.filteredList[0];
                          final _tagid = user.userCompany?.userCompanyId;
                          final _tag = "task_${_tagid ?? 'mobile'}";
                          final taskC = Get.put(
                            TaskController(user: user),
                            tag: _tag,
                          );
                        taskhomec.selectedChat.value = user;
                        taskC.user =user;
                        taskC.textController.clear();
                        taskC.page =1;
                        taskC.update();
                        // taskC.openConversation(taskhomec.selectedChat.value);
                        }
                    }
                  }

                  if (index == 2) {
                    if (kIsWeb) unregisterImage();
                    if (Get.isRegistered<GalleryController>()) {
                      final homec = Get.find<GalleryController>();
                      homec.getCompany();
                      homec.resetPagination();
                      homec.hitApiToGetFolder(reset: true);
                      homec.update();
                    } else {
                      final homec = Get.put(GalleryController());
                      homec.getCompany();
                      homec.resetPagination();
                      homec.hitApiToGetFolder(reset: true);
                      homec.update();
                    }
                  }

                },
                unselectedIconTheme: const IconThemeData(color: Colors.black45),
                selectedIconTheme: const IconThemeData(color: Colors.white),
                useIndicator: true,
                indicatorColor: appColorGreen,
                labelType: NavigationRailLabelType.all,
                backgroundColor: Colors.white,
                elevation: 5,
                destinations: [
                  NavigationRailDestination(
                      icon:Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Image.asset(
                            chatHome,
                            height: 22,
                            color: controller.currentIndex == 0
                                ? Colors.white
                                : Colors.grey,
                          ),
                          *//*homec!.selectedChat.value?.pendingCount==0||homec!.selectedChat.value?.pendingCount==null ?SizedBox():*//*
                          *//*   controller.newChat.value
                              ? Positioned(
                                  top: -5,
                                  right: -10,
                                  child:Obx(() {
                                    final b = AppBadgeController.to;
                                    return BottomNavBudge(
                                      budgeCount: "${b.otherCompanyDot.value}",
                                    );
                                  }))
                              : SizedBox()*//*
                        ],
                      ),

                      label: Text(
                        'Chats',
                        style: BalooStyles.baloomediumTextStyle(),
                      )),
                  NavigationRailDestination(
                      icon: Obx(
                            () => Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Image.asset(
                              tasksHome,
                              height: 22,
                              color: controller.currentIndex == 1
                                  ? Colors.white
                                  : Colors.grey,
                            ),
                            controller.newTask.value
                                ? Positioned(
                                top: -5,
                                right: -10,
                                child: BottomNavBudge(
                                    budgeCount:
                                    "${Get.find<ChatHomeController>()?.selectedChat.value?.pendingCount ?? ''}"))
                                : const SizedBox()
                          ],
                        ),
                      ),
                      label:
                      Text('Tasks', style: BalooStyles.baloomediumTextStyle())),
                  NavigationRailDestination(
                      icon: Image.asset(
                        galleryIcon,
                        height: 22,
                        color:
                        controller.currentIndex == 2 ? Colors.white : Colors.grey,
                      ),
                      label: Text(
                        'Gallery',
                        style: BalooStyles.baloomediumTextStyle(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      )),
                  NavigationRailDestination(
                      icon: Obx(
                            () => Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Image.asset(
                              connectedAppIcon,
                              height: 22,
                              color: controller.currentIndex == 3
                                  ? Colors.white
                                  : Colors.grey,
                            ),
                            controller.newCompanyChat.value
                                ? Positioned(
                                top: -5,
                                right: -10,
                                child: BottomNavBudge(
                                    budgeCount:
                                    "${Get.find<ChatHomeController>()?.selectedChat.value?.pendingCount ?? ''}"))
                                : const SizedBox()
                          ],
                        ),
                      ),
                      label: Text(
                        'Your Companies',
                        style: BalooStyles.baloomediumTextStyle(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      )),
                ],
              ),
            ),
          ),
        InkWell(
          onTap: () {
            Get.toNamed(AppRoutes.all_settings);
          },
          child: Container(
            padding: const EdgeInsets.all(15),
            margin: const EdgeInsets.all(2),
            color: Colors.white,
            child: Image.asset(
              settingPng,
              height: 22,
            ),
          ),
        )
      ],
    );
  }*/

/*
  @override
  Widget build(BuildContext context) {
    return Obx(() => Scaffold(
          body: WillPopScope( onWillPop: _onWillPop,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: screens[controller.currentIndex.value],
            ),
          ),
          bottomNavigationBar: SnakeNavigationBar.gradient(
            behaviour: SnakeBarBehaviour.floating,
            backgroundGradient: LinearGradient(colors: [appColorGreen.withOpacity(.2),appColorYellow.withOpacity(.2)]) ,
            snakeShape: SnakeShape.circle,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            snakeViewGradient:LinearGradient(colors: [appColorGreen.withOpacity(.8),appColorYellow.withOpacity(.8)]) ,
            selectedItemGradient: LinearGradient(colors: [Colors.white,Colors.white]) ,
            showSelectedLabels: true,
            currentIndex: controller.currentIndex.value,

            onTap: (v) {
              controller.updateIndex(v);
              // if(v==0){
              //   controller.refreshChats();
              //   if(mounted){
              //     setState(() {
              //
              //      });
              //   }
              // }

              setState(() {
                if (v == 1) {
                  isTaskMode = false;
                }else{
                  isTaskMode = true;
                }
              });
              controller.update();

            },
            items: [
              BottomNavigationBarItem(
                  icon: Image.asset(
                    home,
                    height: 22,
                  ),
                  label: 'Home'),
              BottomNavigationBarItem(
                  icon: Image.asset(
                    chatHome,
                    height: 22,
                  ),
                  label: 'Chats'),
              BottomNavigationBarItem(
                icon: Image.asset(
                  tasksHome,
                  height: 22,
                ),
                label: 'Task',
              ),
              BottomNavigationBarItem(
                  icon: Image.asset(
                    appHome,
                    height: 22,
                  ),
                  label: 'Apps'),
            ],
          ),
        ));
  }*/
  Widget _bottomNavigationBar(bool isWide,DashboardController controller) {
    return  SnakeNavigationBar.gradient(
        behaviour: SnakeBarBehaviour.floating,
        backgroundGradient: LinearGradient(colors: [
          appColorGreen.withOpacity(.2),
          appColorYellow.withOpacity(.2)
        ]),
        snakeShape: SnakeShape.circle,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        snakeViewGradient: LinearGradient(colors: [
          appColorGreen.withOpacity(.8),
          appColorYellow.withOpacity(.8)
        ]),
        selectedItemGradient:
            const LinearGradient(colors: [Colors.white, Colors.white]),
        showSelectedLabels: true,
        selectedLabelStyle: BalooStyles.baloonormalTextStyle(color: Colors.white),
        unselectedLabelStyle: BalooStyles.baloonormalTextStyle(),
        showUnselectedLabels: true,
        currentIndex: controller.currentIndex,
        onTap: (v) async {
          if (controller.bottomNavItems.isNotEmpty) {
            controller.updateIndex(v);
            if (v == 1) {
              if (kIsWeb) unregisterImage();
              isTaskMode = true;
              if (Get.isRegistered<TaskHomeController>()) {
               final tasksHome= Get.find<TaskHomeController>();
                 tasksHome.page = 1;
               tasksHome.hitAPIToGetRecentTasksUser();
              } else {
          final tasksHome= Get.put(TaskHomeController());
                tasksHome.page = 1;
                tasksHome.hitAPIToGetRecentTasksUser();
              }

              if(kIsWeb&&isWide){
                final _tagid = TaskPresence.activeTaskId.value;
                final _tag = "task_${_tagid ?? 'mobile'}";
                if (Get.isRegistered<TaskController>(tag: _tag)) {
                 final taskc= Get.find<TaskController>(tag: _tag);
                 taskc.page = 1;
                 taskc.hitAPIToGetTaskHistory();
              }
              }/*else{
              if (Get.isRegistered<TaskController>()) {
                if (kIsWeb && isWide) {
                  Get.find<TaskController>().page = 1;
                  Get.find<TaskController>().hitAPIToGetTaskHistory();
                }
              } else {
                if (kIsWeb && isWide) {
                  Get.put(TaskController(user: controller.user));
                  Get.find<TaskController>().page = 1;
                  Get.find<TaskController>().hitAPIToGetTaskHistory();
                }
              }
            }*/
            }

            if(v==0) {
              final _tagid = ChatPresence.activeChatId.value;
              final _tag = "chat_${_tagid ?? 'mobile'}";
              isTaskMode = false;
              if (Get.isRegistered<ChatHomeController>()) {
                final chathomec = Get.find<ChatHomeController>();
                chathomec.hitAPIToGetRecentChats(page: 1);
              } else {
                final chathomec =  Get.put(ChatHomeController());
                chathomec.hitAPIToGetRecentChats(page: 1);
              }
              if (kIsWeb && isWide) {
              if (Get.isRegistered<ChatScreenController>(tag: _tag)) {
                 final con = Get.find<ChatScreenController>(tag: _tag);
                 con.page = 1;
                 con.hitAPIToGetChatHistory('isRegistered bottom nav chat kIsWeb && isWide', user: con.user!);
                }
              } /*else {
                if (kIsWeb && isWide) {
                final con=  Get.put(ChatScreenController(user: controller.user),tag: _tag);
                con.page = 1;
                con.hitAPIToGetChatHistory('bottom nav chat kIsWeb && isWide');
                }
              }*/
            }
            controller.update();
          }
        },
        items: controller.barItems,
    );
  }
}

