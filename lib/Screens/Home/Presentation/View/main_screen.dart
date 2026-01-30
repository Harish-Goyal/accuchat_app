import 'package:AccuChat/Constants/assets.dart';
import 'package:AccuChat/Constants/colors.dart';
import 'package:AccuChat/Constants/themes.dart';
import 'package:AccuChat/Screens/Chat/screens/chat_tasks/Presentation/Controllers/chat_home_controller.dart';
import 'package:AccuChat/Screens/Chat/screens/chat_tasks/Presentation/Controllers/chat_screen_controller.dart';
import 'package:AccuChat/Screens/Chat/screens/chat_tasks/Presentation/Controllers/task_controller.dart';
import 'package:AccuChat/Screens/Chat/screens/chat_tasks/Presentation/Controllers/task_home_controller.dart';
import 'package:AccuChat/Screens/Home/Presentation/Controller/gallery_controller.dart';
import 'package:AccuChat/Screens/Home/Presentation/Controller/home_controller.dart';
import 'package:AccuChat/utils/bottom_nav_budge.dart';
import 'package:AccuChat/utils/custom_container.dart';
import 'package:AccuChat/utils/text_style.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_snake_navigationbar/flutter_snake_navigationbar.dart';
import 'package:get/get.dart';
import '../../../../main.dart';
import '../../../../routes/app_routes.dart';
import '../../../../utils/budge_controller.dart';
import '../../../Chat/api/apis.dart';

class AccuChatDashboard extends StatelessWidget {
  final DashboardController controller = Get.put(DashboardController());

  @override
  Widget build(BuildContext context) {
    bool isWideScreen = MediaQuery.of(context).size.width > 800;

    return WillPopScope(onWillPop: () async {
      if (controller.currentIndex != 0) {
        controller.updateIndex(0);
        return false;
      }
      return true;
    }, child: GetBuilder<DashboardController>(builder: (controller) {
      return Scaffold(
        // drawer: isWideScreen ? null : _buildDrawer(), // for mobile
        body: Row(
          children: [
            if (isWideScreen)
              SizedBox(width: Get.width * .13, child: buildSideNav(controller)),
            Expanded(
              child: controller.screens.isEmpty
                  ? const SizedBox()
                  : ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1000),
                      child: controller.screens[controller.currentIndex],
                    ),
            ),
          ],
        ),
        bottomNavigationBar: isWideScreen
            ? null
            : controller.screens.isEmpty
                ? const SizedBox()
                : _bottomNavigationBar(isWideScreen),
      );
    }));
  }

  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: Colors.white,
      elevation: 0,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  appColorGreen.withOpacity(.8),
                  appColorYellow.withOpacity(.8)
                ],
              ),
            ),
            child: const Text('AccuChat Menu',
                style: TextStyle(color: Colors.white, fontSize: 20)),
          ),
          ListTile(
            leading: Image.asset(
              chatHome,
              height: 22,
            ),
            title: const Text('Chats'),
            onTap: () {
              controller.updateIndex(0);
              Get.back();
              isTaskMode = false;
              controller.update();
            },
          ),
          ListTile(
            leading: Image.asset(
              tasksHome,
              height: 22,
            ),
            title: const Text('Tasks'),
            onTap: () {
              controller.updateIndex(1);

              isTaskMode = true;
              Get.back();
              controller.update();
            },
          ),
          ListTile(
            leading: Image.asset(
              connectedAppIcon,
              height: 22,
            ),
            title: const Text('Your Companies'),
            onTap: () {
              controller.updateIndex(2);
              Get.back();

              isTaskMode = false;
              controller.update();
            },
          ),
          ListTile(
            leading: Image.asset(
              galleryIcon,
              height: 22,
            ),
            title: const Text('Gallery'),
            onTap: () {
              controller.updateIndex(3);
              Get.back();

              isTaskMode = false;
              controller.update();
            },
          ),
        ],
      ),
    );
  }

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

  SnakeNavigationBar _bottomNavigationBar(bool isWide) {
    return SnakeNavigationBar.gradient(
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
            isTaskMode = true;
            if (Get.isRegistered<TaskHomeController>()) {
              Get.find<TaskHomeController>().page = 1;
              Get.find<TaskHomeController>().hitAPIToGetRecentTasksUser();
            } else {
              Get.put(TaskHomeController());
              Get.find<TaskHomeController>().page = 1;
              Get.find<TaskHomeController>().hitAPIToGetRecentTasksUser();
            }
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
          } else {
            isTaskMode = false;

            if (Get.isRegistered<ChatHomeController>()) {
              Get.find<ChatHomeController>().hitAPIToGetRecentChats(page: 1);
            } else {
              Get.put(ChatHomeController());
              Get.find<ChatHomeController>().hitAPIToGetRecentChats(page: 1);
            }
            if (Get.isRegistered<ChatScreenController>()) {
              if (kIsWeb && isWide) {
                Get.find<ChatScreenController>().page = 1;
                Get.find<ChatScreenController>().hitAPIToGetChatHistory();
              }
            } else {
              if (kIsWeb && isWide) {
                Get.put(ChatScreenController(user: controller.user));
                Get.find<ChatScreenController>().page = 1;
                Get.find<ChatScreenController>().hitAPIToGetChatHistory();
              }
            }
          }
          controller.update();
        }
      },
      items: controller.barItems,
    );
  }
}

Widget buildSideNav(DashboardController controller) {
  ChatHomeController? homec;
  if (Get.isRegistered<ChatHomeController>()) {
    homec = Get.find<ChatHomeController>();
  } else {
    homec = Get.put(ChatHomeController());
  }

  return Column(
    children: [
      Expanded(
        child: NavigationRail(
          selectedIndex: controller.currentIndex,
          onDestinationSelected: (index) {
            controller.getCompany();

            final isSetting = index == 4;
            if (isSetting) {
              Get.toNamed(AppRoutes.all_settings);
            }
            // Get.toNamed(AppRoutes.home);

            isTaskMode = index == 1;
            if (index == 0) {
              if (Get.isRegistered<ChatScreenController>()) {
                final chatc = Get.find<ChatScreenController>();
                chatc.replyToMessage = null;
                if (homec!.filteredList.isNotEmpty) {
                  homec.selectedChat.value = homec.filteredList[0];
                  chatc.user = homec.selectedChat.value;
                  chatc.showPostShimmer = true;
                  chatc.openConversation(homec.selectedChat.value);
                  if (homec.selectedChat.value?.pendingCount != 0) {
                    chatc.markAllVisibleAsReadOnOpen(
                        APIs.me?.userCompany?.userCompanyId,
                        chatc.user?.userCompany?.userCompanyId,
                        chatc.user?.userCompany?.isGroup == 1 ? 1 : 0);
                  }
                  homec.selectedChat.refresh();
                  chatc.update();
                }
              } else {
                Future.delayed(Duration(milliseconds: 500), () {
                  if (homec!.filteredList.isNotEmpty) {
                    Get.put(ChatScreenController(user: homec.filteredList[0]));
                    final chatc = Get.find<ChatScreenController>();
                    chatc.replyToMessage = null;
                    homec.selectedChat.value = homec.filteredList[0];
                    chatc.user = homec.selectedChat.value;
                    chatc.showPostShimmer = true;
                    chatc.openConversation(homec.selectedChat.value);
                    if (homec.selectedChat.value?.pendingCount != 0) {
                      chatc.markAllVisibleAsReadOnOpen(
                          APIs.me?.userCompany?.userCompanyId,
                          chatc.user?.userCompany?.userCompanyId,
                          chatc.user?.userCompany?.isGroup == 1 ? 1 : 0);
                    }
                    homec.selectedChat.refresh();
                    chatc.update();
                  }
                });
              }
              // homec.page = 1;
              // homec.hitAPIToGetRecentChats();
            }

            if (index == 1) {
              final homec = Get.find<TaskHomeController>();
              if (Get.isRegistered<TaskController>()) {
                final chatc = Get.find<TaskController>();
                chatc.replyToMessage = null;
                if (homec.filteredList.isNotEmpty) {
                  homec.selectedChat.value = homec.filteredList[0];
                  chatc.user = homec.selectedChat.value;
                  chatc.showPostShimmer = true;
                  chatc.openConversation(homec.selectedChat.value);
                  homec.selectedChat.refresh();
                  chatc.update();
                }
              } else {
                Future.delayed(Duration(milliseconds: 500), () {
                  if (homec.filteredList.isNotEmpty) {
                    Get.put(TaskController(user: homec.filteredList[0]));
                    final chatc = Get.find<TaskController>();
                    chatc.replyToMessage = null;
                    homec.selectedChat.value = homec.filteredList[0];
                    chatc.user = homec.selectedChat.value;
                    chatc.showPostShimmer = true;
                    chatc.openConversation(homec.selectedChat.value);

                    homec.selectedChat.refresh();
                    chatc.update();
                  }
                });
              }
              // homec.page = 1;
              // homec.hitAPIToGetRecentChats();
            }

            if (index == 2) {
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
            controller.updateIndex(index);
            controller.update();
          },
          unselectedIconTheme: const IconThemeData(color: Colors.black45),
          selectedIconTheme: const IconThemeData(color: Colors.white),
          useIndicator: true,
          indicatorColor: appColorGreen,
          labelType: NavigationRailLabelType.all,
          backgroundColor: Colors.white,
          elevation: 1,
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
                      /*homec!.selectedChat.value?.pendingCount==0||homec!.selectedChat.value?.pendingCount==null ?SizedBox():*/
                   /*   controller.newChat.value
                          ? Positioned(
                              top: -5,
                              right: -10,
                              child:Obx(() {
                                final b = AppBadgeController.to;
                                return BottomNavBudge(
                                  budgeCount: "${b.otherCompanyDot.value}",
                                );
                              }))
                          : SizedBox()*/
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
                                      "${homec?.selectedChat.value?.pendingCount ?? ''}"))
                          : SizedBox()
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
                                      "${homec?.selectedChat.value?.pendingCount ?? ''}"))
                          : SizedBox()
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
}
