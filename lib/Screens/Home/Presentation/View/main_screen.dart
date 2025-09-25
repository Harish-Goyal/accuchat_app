import 'package:AccuChat/Constants/assets.dart';
import 'package:AccuChat/Constants/colors.dart';
import 'package:AccuChat/Screens/Home/Presentation/Controller/home_controller.dart';
import 'package:AccuChat/utils/text_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_snake_navigationbar/flutter_snake_navigationbar.dart';
import 'package:get/get.dart';
import '../../../../main.dart';

class AccuChatDashboard extends StatelessWidget {


  final DashboardController controller = Get.put(DashboardController());


  @override
  Widget build(BuildContext context) {
    bool isWideScreen = MediaQuery.of(context).size.width > 800;

    return WillPopScope(
      onWillPop: ()async {
        if (controller.currentIndex != 0) {
          controller.updateIndex(0);
          return false;
        }
        return true;
      },
      child: GetBuilder<DashboardController>(
        builder: (controller) {
          return Scaffold(
            drawer: isWideScreen ? null : _buildDrawer(), // for mobile
            body: Row(
              children: [
                if (isWideScreen) _buildSideNav(), // For web/tablet
                Expanded(
                  child: Center(
                    child:controller.screens.isEmpty?SizedBox(): ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1000),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: controller.screens[controller.currentIndex],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            bottomNavigationBar:
            isWideScreen ? null : controller.screens.isEmpty?SizedBox():_bottomNavigationBar(),
          );
        }
      )
    );
  }

  Widget _buildSideNav() {
    return NavigationRail(
      selectedIndex: controller.currentIndex,
      onDestinationSelected: (index) {
        controller.getCompany();
        controller.updateIndex(index);

          isTaskMode = index == 1;

          controller.update();

      },
      labelType: NavigationRailLabelType.all,
      backgroundColor: Colors.white,
      elevation: 5,
      destinations: [

        NavigationRailDestination(
            icon: Image.asset(
              chatHome,
              height: 22,
            ),
            label: Text(
              'Chats',
              style: BalooStyles.baloomediumTextStyle(),
            )),
        NavigationRailDestination(
            icon: Image.asset(
              tasksHome,
              height: 22,
            ),
            label: Text('Tasks', style: BalooStyles.baloomediumTextStyle())),
        NavigationRailDestination(
            icon: Image.asset(
              appHome,
              height: 22,
            ),
            label: Text('Your Companies',
                style: BalooStyles.baloomediumTextStyle())),
      ],
    );
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
              appHome,
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
      LinearGradient(colors: [Colors.white, Colors.white]),
      showSelectedLabels: true,
      currentIndex: controller.currentIndex,
      onTap: (v) {
        controller.updateIndex(v);

          if (v == 1) {
            isTaskMode = true;
          } else {
            isTaskMode = false;
          }

        controller.update();
      },
      items: controller.barItems,

    );
  }
}
