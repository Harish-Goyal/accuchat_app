import 'package:AccuChat/Constants/assets.dart';
import 'package:AccuChat/Constants/colors.dart';
import 'package:AccuChat/Screens/Chat/screens/chat_tasks/Presentation/Controllers/chat_home_controller.dart';
import 'package:AccuChat/Screens/Chat/screens/chat_tasks/Presentation/Controllers/chat_screen_controller.dart';
import 'package:AccuChat/Screens/Chat/screens/chat_tasks/Presentation/Controllers/task_controller.dart';
import 'package:AccuChat/Screens/Chat/screens/chat_tasks/Presentation/Controllers/task_home_controller.dart';
import 'package:AccuChat/Screens/Home/Presentation/Controller/home_controller.dart';
import 'package:AccuChat/utils/text_style.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_snake_navigationbar/flutter_snake_navigationbar.dart';
import 'package:get/get.dart';
import '../../../../main.dart';
import '../../../../routes/app_routes.dart';

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
              SizedBox(
                  width: Get.width * .13,
                  child: buildSideNav(controller)), // For web/tablet
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
                : _bottomNavigationBar(),
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
          // ListTile(
          //   leading: Image.asset(
          //     galleryIcon,
          //     height: 22,
          //   ),
          //   title: const Text('Gallery'),
          //   onTap: () {
          //     controller.updateIndex(3);
          //     Get.back();
          //
          //       isTaskMode = false;
          //     controller.update();
          //   },
          // ),
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

  SnakeNavigationBar _bottomNavigationBar() {
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
      selectedLabelStyle:
          BalooStyles.baloonormalTextStyle(size: 14, color: Colors.white),
      unselectedLabelStyle: BalooStyles.baloonormalTextStyle(size: 14),
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
              if (kIsWeb) {
                Get.find<TaskController>().page = 1;
                Get.find<TaskController>().hitAPIToGetTaskHistory();
              }
            } else {
              if (kIsWeb) {
                Get.put(TaskController(user: controller.user));
                Get.find<TaskController>().page = 1;
                Get.find<TaskController>().hitAPIToGetTaskHistory();
              }
            }
          } else {
            print("calleddddddddddddd============ ");
            isTaskMode = false;

            if (Get.isRegistered<ChatHomeController>()) {
              Get.find<ChatHomeController>().hitAPIToGetRecentChats(page: 1);
            } else {
              Get.put(ChatHomeController());
              Get.find<ChatHomeController>().hitAPIToGetRecentChats(page: 1);
            }
            if (Get.isRegistered<ChatScreenController>()) {
              if (kIsWeb) {
                Get.find<ChatScreenController>().page = 1;
                Get.find<ChatScreenController>().hitAPIToGetChatHistory();
              }
            } else {
              if (kIsWeb) {
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
  return Column(
    children: [
      Expanded(
        child: NavigationRail(
          selectedIndex: controller.currentIndex,
          onDestinationSelected: (index) {
            controller.getCompany();
            controller.updateIndex(index);
            isTaskMode = index == 1;
            final isSetting = index == 3;
            if (isSetting) {
              Get.toNamed(AppRoutes.all_settings);
            }
            if (index == 1 && !isTaskMode) {
              final taskC = Get.find<TaskController>();
              final taskHomeC = Get.find<TaskHomeController>();
              taskHomeC.selectedChat.value = dashboardController.user;
              taskC.replyToMessage=null;
              taskC.user =taskHomeC.selectedChat.value;
              taskC.showPostShimmer =true;
              taskC.page = 1;
              Future.microtask(() {
                taskC.openConversation(taskHomeC.selectedChat.value);
              });} else if (index == 0 && isTaskMode) {

              final taskC = Get.find<ChatScreenController>();
              final taskHomeC = Get.find<ChatHomeController>();
              taskHomeC.selectedChat.value = dashboardController.user;
              taskC.replyToMessage=null;
              taskC.user =taskHomeC.selectedChat.value;
              taskC.showPostShimmer =true;
              taskC.page = 1;

              Future.microtask(() {
                taskC.openConversation(taskHomeC.selectedChat.value);
              });

            }
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
                icon: Image.asset(
                  chatHome,
                  height: 22,
                  color:
                      controller.currentIndex == 0 ? Colors.white : Colors.grey,
                ),
                label: Text(
                  'Chats',
                  style: BalooStyles.baloomediumTextStyle(),
                )),
            NavigationRailDestination(
                icon: Image.asset(
                  tasksHome,
                  height: 22,
                  color:
                      controller.currentIndex == 1 ? Colors.white : Colors.grey,
                ),
                label:
                    Text('Tasks', style: BalooStyles.baloomediumTextStyle())),
            NavigationRailDestination(
                icon: Image.asset(
                  connectedAppIcon,
                  height: 22,
                  color:
                      controller.currentIndex == 2 ? Colors.white : Colors.grey,
                ),
                label: Text(
                  'Your Companies',
                  style: BalooStyles.baloomediumTextStyle(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                )),

            /*        NavigationRailDestination(
                  icon: Image.asset(
                    galleryIcon,
                    height: 22,
                  ),
                  label: Text('Gallery',
                      style: BalooStyles.baloomediumTextStyle())),*/
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
