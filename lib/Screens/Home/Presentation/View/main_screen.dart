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
import '../../../../utils/register_image.dart';
import '../../../Chat/api/apis.dart';

class AccuChatDashboard extends StatefulWidget {
  @override
  State<AccuChatDashboard> createState() => _AccuChatDashboardState();
}



class _AccuChatDashboardState extends State<AccuChatDashboard> {
  ChatHomeController? homec;


  @override
  void initState() {
    if (Get.isRegistered<ChatHomeController>()) {
      homec = Get.find<ChatHomeController>();
    } else {
      homec = Get.put(ChatHomeController());
    }
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    bool isWideScreen = MediaQuery.of(context).size.width > 800;

    return GetBuilder<DashboardController>(builder: (controller) {
        return WillPopScope(onWillPop: () async {
          if (controller.currentIndex != 0) {
            controller.updateIndex(0);
            return false;
          }
          return true;
        }, child:  Scaffold(
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
                    : _bottomNavigationBar(isWideScreen,controller),
          )
           );
      }
    );
  }


  Widget buildSideNav(DashboardController controller) {


    return Column(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
                border: Border.symmetric(vertical: BorderSide(color: Colors.grey.shade200))
            ),
            child: NavigationRail(
              selectedIndex: controller.currentIndex,
              onDestinationSelected: (index) {
                controller.getCompany();
                final isSetting = index == 4;
                if (isSetting) {
                  if (kIsWeb) unregisterImage();
                  Get.toNamed(AppRoutes.all_settings);
                }
                // Get.toNamed(AppRoutes.home);
                isTaskMode = index == 1;
               /* if (index == 0) {
                  var homec;
                  if (!Get.isRegistered<ChatHomeController>()) {
                    homec= Get.put(ChatHomeController(), permanent: true);
                  } else{
                    homec = Get.find<ChatHomeController>();
                  }
                  var chatc;
                  if (!Get.isRegistered<ChatScreenController>()) {
                    chatc =  Get.put(ChatScreenController(user: controller.user), permanent: true);
                  }else{
                    chatc = Get.find<ChatScreenController>();
                  }
                  chatc.replyToMessage = null;

                  // ✅ ONLY AUTO-SELECT if nothing selected yet
                  if (homec.selectedChat.value == null && homec.filteredList.isNotEmpty) {
                    final user = homec.filteredList[0];
                    homec.selectedChat.value = user;
                    chatc.user = user;
                    chatc.textController.clear();
                    chatc.showPostShimmer = true;
                    chatc.openConversation(user);
                  }

                  homec.update();
                  homec.selectedChat.refresh();
                  chatc.update();
                }*/

                if (index == 0) {
                if (Get.isRegistered<ChatScreenController>()) {
                  final chatc = Get.find<ChatScreenController>();
                  chatc.replyToMessage = null;
                  if (homec!.filteredList.isNotEmpty) {
                    final user = homec?.filteredList[0];
                    homec?.selectedChat.value = user;
                    chatc.user =homec?.selectedChat.value;
                    chatc.textController.clear();

                    chatc.update();
                    chatc.showPostShimmer = true;
                    chatc.resetPaginationForNewChat();

                    chatc.openConversation(homec?.selectedChat.value);
                    if (homec?.selectedChat.value?.pendingCount != 0) {
                      chatc.markAllVisibleAsReadOnOpen(
                          APIs.me?.userCompany?.userCompanyId,
                          chatc.user?.userCompany?.userCompanyId,
                          chatc.user?.userCompany?.isGroup == 1 ? 1 : 0);
                    }

                  }
                } else {
                    if (homec!.filteredList.isNotEmpty) {
                      final user = homec?.filteredList[0];
                    final chatc =Get.put(ChatScreenController(user: user));
                      chatc.showPostShimmer = true;
                      chatc.replyToMessage = null;
                      homec?.selectedChat.value = user;
                      chatc.user =homec?.selectedChat.value;
                      // chatc.openConversation(homec.selectedChat.value);
                      if (homec?.selectedChat.value?.pendingCount != 0) {
                        chatc.markAllVisibleAsReadOnOpen(
                            APIs.me?.userCompany?.userCompanyId,
                            chatc.user?.userCompany?.userCompanyId,
                            chatc.user?.userCompany?.isGroup == 1 ? 1 : 0);
                      }
                      homec?.selectedChat.refresh();
                      chatc.update();
                    }

                }
                // homec.page = 1;
                // homec.hitAPIToGetRecentChats();
              }

                if (index == 1) {
                  if (kIsWeb) unregisterImage();
                  final homec = Get.find<TaskHomeController>();
                  if (Get.isRegistered<TaskController>()) {
                    final chatc = Get.find<TaskController>();
                    chatc.replyToMessage = null;
                    if (homec.filteredList.isNotEmpty) {
                      final user = homec?.filteredList[0];
                      homec?.selectedChat.value = user;
                      chatc.user =homec?.selectedChat.value;
                      chatc.textController.clear();
                      chatc.update();
                      chatc.showPostShimmer = true;
                      chatc.resetPaginationForNewChat();
                      chatc.openConversation(homec?.selectedChat.value);
                      // homec.selectedChat.value = homec.filteredList[0];
                      // chatc.user = homec.selectedChat.value;
                      // chatc.showPostShimmer = true;
                      // chatc.openConversation(homec.selectedChat.value);
                      // homec.selectedChat.refresh();
                      // chatc.update();
                    }
                  } else {
                    print("un=registered");
                    // Future.delayed(const Duration(milliseconds: 500), () {
                    //   if (homec.filteredList.isNotEmpty) {
                        final  chatc =  Get.put(TaskController(user: homec.filteredList[0]));
                        // chatc.replyToMessage = null;
                        // homec.selectedChat.value = homec.filteredList[0];
                        // chatc.user = homec.selectedChat.value;
                        // // chatc.showPostShimmer = true;
                        // // chatc.resetPaginationForNewChat();
                        // //
                        chatc.openConversation(homec.selectedChat.value);

                        // homec.selectedChat.refresh();
                      // }
                    // });
                  }
                  // homec.page = 1;
                  // homec.hitAPIToGetRecentChats();
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
                                  "${homec?.selectedChat.value?.pendingCount ?? ''}"))
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
  SnakeNavigationBar _bottomNavigationBar(bool isWide,DashboardController controller) {
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
            if (kIsWeb) unregisterImage();
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
          }

          if(v==0) {
            isTaskMode = false;

            if (Get.isRegistered<ChatHomeController>()) {
              Get.find<ChatHomeController>().hitAPIToGetRecentChats(page: 1);
            } else {
              Get.put(ChatHomeController());
              Get.find<ChatHomeController>().hitAPIToGetRecentChats(page: 1);
            }
            if (Get.isRegistered<ChatScreenController>()) {
              if (kIsWeb && isWide) {
               final con = Get.find<ChatScreenController>();
               con.page = 1;
               con.hitAPIToGetChatHistory('isRegistered bottomnav chat kIsWeb && isWide');
              }
            } else {
              if (kIsWeb && isWide) {
              final con=  Get.put(ChatScreenController(user: controller.user));
              con.page = 1;
              con.hitAPIToGetChatHistory('bottomnav chat kIsWeb && isWide');
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

