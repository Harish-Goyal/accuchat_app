import 'package:AccuChat/Constants/assets.dart';
import 'package:AccuChat/Constants/themes.dart';
import 'package:AccuChat/Screens/Chat/api/apis.dart';
import 'package:AccuChat/Screens/Home/Presentation/Controller/home_controller.dart';
import 'package:AccuChat/Screens/Home/Presentation/View/connected_app_screen.dart';
import 'package:AccuChat/Screens/Home/Presentation/View/home_screen.dart';
import 'package:AccuChat/utils/custom_flashbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_snake_navigationbar/flutter_snake_navigationbar.dart';
import 'package:get/get.dart';
import '../../../../main.dart';
import '../../../../utils/helper_widget.dart';
import '../../../Chat/models/message.dart';
import '../../../Chat/screens/chat_home_screen.dart';
import 'package:audioplayers/audioplayers.dart';
class AccuChatDashboard extends StatefulWidget {
  @override
  State<AccuChatDashboard> createState() => _AccuChatDashboardState();
}

class _AccuChatDashboardState extends State<AccuChatDashboard> with WidgetsBindingObserver {
  List<Widget> screens = [];
  @override
  void initState() {
    callNetworkCheck();
    WidgetsBinding.instance.addObserver(this);
    screens = [
      HomeScreen(),
      ChatsHomeScreen(isTask: false,),
      ChatsHomeScreen(isTask: true,),
      ConnectedAppsScreen(),
    ];
    super.initState();
  }


  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }


  final player = AudioPlayer();

/*  @override
  void didChangeAppLifecycleState(AppLifecycleState state)async {
    if (state == AppLifecycleState.resumed) {
      await  _checkTasksFromFirestore();
    }
    if (state == AppLifecycleState.paused) {
      await  _checkTasksFromFirestore();
    }  if (state == AppLifecycleState.inactive) {
      await  _checkTasksFromFirestore();
    }
  }*/

  Future<void> _checkTasksFromFirestore() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('chats/${APIs.getConversationID(APIs.me.id)}/messages')
        .where('isTask', isEqualTo: true)
        .get();

    // for (var doc in snapshot.docs) {
    //   final msg = Message.fromJson(doc.data());
    //   if (msg.taskDetails != null && isTaskTimeExceeded(msg.taskDetails!)) {
    //     await player.play(AssetSource('sounds/long-buzzer-38398.mp3'));
    //     break;
    //   }
    // }
  }

  final DashboardController controller = Get.put(DashboardController());

  DateTime? _lastBackPressed;

  Future<bool> _onWillPop() async {
    final now = DateTime.now();

    if (_lastBackPressed == null ||
        now.difference(_lastBackPressed!) > const Duration(seconds: 2)) {
      _lastBackPressed = now;
      toast("Press back again to exit the app");
      return Future.value(false); // don't exit yet
    }

    return Future.value(true); // exit
  }

  callNetworkCheck()async{
    await checkNetworkConnection(context);
  }
  Future<void> checkNetworkConnection(BuildContext context) async {
    final List<ConnectivityResult> connectivityResult = await (Connectivity().checkConnectivity());

// This condition is for demo purposes only to explain every connection type.
// Use conditions which work for your requirements.
    if (connectivityResult.contains(ConnectivityResult.mobile)) {
      // Mobile network available.
    } else if (connectivityResult.contains(ConnectivityResult.wifi)) {
      // Wi-fi is available.
      // Note for Android:
      // When both mobile and Wi-Fi are turned on system will return Wi-Fi only as active network type
    } else if (connectivityResult.contains(ConnectivityResult.ethernet)) {
      // Ethernet connection available.
    } else if (connectivityResult.contains(ConnectivityResult.vpn)) {
      // Vpn connection active.
      // Note for iOS and macOS:
      // There is no separate network interface type for [vpn].
      // It returns [other] on any device (also simulator)
    } else if (connectivityResult.contains(ConnectivityResult.bluetooth)) {
      // Bluetooth connection available.
    } else if (connectivityResult.contains(ConnectivityResult.other)) {
      // Connected to a network which is not in the above mentioned networks.
    } else if (connectivityResult.contains(ConnectivityResult.none)) {
      _showNoNetworkDialog(context);
    }
  }

// Show a dialog if there's no network
  void _showNoNetworkDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Text('No Network Connection'),
          content: const Text('Your mobile data is off or you are not connected to Wi-Fi. Please turn it on to continue using the app.'),
          actions: [
            TextButton(
              onPressed: () {
                // Exit the app if the user presses 'Exit'
                SystemNavigator.pop();
              },
              child: const Text('Exit'),
            ),
            TextButton(
              onPressed: () {
                // Just close the dialog if the user presses 'Cancel'
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }








  @override
  Widget build(BuildContext context) {
    return Obx(() => Scaffold(
          body: WillPopScope( onWillPop: _onWillPop,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: screens[controller.currentIndex.value],
            ),
          ),
          bottomNavigationBar: SnakeNavigationBar.color(
            behaviour: SnakeBarBehaviour.floating,
            backgroundColor: AppTheme.appColor.withOpacity(.1),
            snakeShape: SnakeShape.circle,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            snakeViewColor: AppTheme.appColor,
            selectedItemColor: Colors.white,
            unselectedItemColor: Colors.grey,
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
  }
}
