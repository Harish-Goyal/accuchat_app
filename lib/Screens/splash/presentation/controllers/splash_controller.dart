import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:AccuChat/main.dart';

import '../../../../Services/APIs/local_keys.dart';
import '../../../../routes/app_routes.dart';
import '../../../Chat/api/apis.dart';
import '../../../Chat/models/chat_user.dart';
import '../../../Chat/screens/auth/landing_screen.dart';
import '../../../Chat/screens/auth/login_screen.dart';
import '../../../Chat/screens/chat_home_screen.dart';
import '../../../Home/Presentation/View/main_screen.dart';

import 'package:in_app_update/in_app_update.dart';
class SplashController extends GetxController {


  @override
  void onInit() {
    callNetworkCheck();
    SystemChannels.textInput.invokeMethod('TextInput.hide');
    update();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        systemNavigationBarColor: Colors.white,
        statusBarColor: Colors.white));

       checkGooglePlayUpdate().then((v){
        return _navigateToNextScreen(Get.context!);
      }); // 🔁 run after screen is rendered

    super.onInit();
  }



  Future<void> checkGooglePlayUpdate() async {
    try {
      final updateInfo = await InAppUpdate.checkForUpdate();
      if (updateInfo.updateAvailability == UpdateAvailability.updateAvailable) {
        await InAppUpdate.performImmediateUpdate();
      }
    }catch(e){
      print(e.toString());
    }
  }

  // getIntialMessage() {
  //   // initBinding();
  //   FirebaseMessaging?.instance.getInitialMessage().then((RemoteMessage? message) async {
  //
  //     if (message != null) {
  //       await   Get.find<GetLoginModalService>().updateFromAPI();
  //       PushNotificationsManager.notificationRedirection(message);
  //     }
  //     else{
  //       final PendingDynamicLinkData? initialLink = await FirebaseDynamicLinks.instance.getInitialLink();
  //       if (initialLink != null) {
  //
  //       await   Get.find<GetLoginModalService>().updateFromAPI();
  //         Get.find<DynamicLinkService>().dynaLinkFunction(initialLink,
  //         onError: (){
  //           _navigateToNextScreen();
  //         }
  //         );
  //       }
  //       else{
  //         _navigateToNextScreen();
  //       }
  //
  //
  //     }
  //   });
  // }

  _navigateToNextScreen(context) =>
      Timer(Duration(milliseconds: 3500), () async {
        checkUserNavigation(context);
      });

  Future<void> checkUserNavigation(BuildContext context) async {
    final currentUser = FirebaseAuth.instance.currentUser;

    // If the user is not signed in
    if (currentUser == null) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => LoginScreenG()));
      return;
    }

    final userDoc = await FirebaseFirestore.instance.collection('users').doc(currentUser.uid).get();

    // If user document doesn't exist
    if (!userDoc.exists) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => LoginScreenG()));
      return;
    }

    // Check if the user has logged in for the first time and hasn't created or joined a company
    if (!((storage.read(isFirstTime) ?? true))) {
      ChatUser me = ChatUser.fromJson(userDoc.data()!);

      // Check if the user has a company assigned to them
      if (me.selectedCompany == null||me.company == null) {
        // If no company is connected, navigate to the landing page (to allow joining/creating a company)
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => LandingPage()));
        return;
      } else {
        // If the user is already connected to a company, navigate to the home screen
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => AccuChatDashboard()));
        return;
      }
    }

    // If the user is logged in and doesn't need to go through the landing page, navigate to home
    if (storage.read(isLoggedIn) ?? true) {
      Get.offAllNamed(AppRoutes.home);
    } else {
      // For any other case, navigate to the landing page
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => LandingPage()));
    }
  }


  callNetworkCheck()async{
    await checkNetworkConnection(Get.context!);
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
}
