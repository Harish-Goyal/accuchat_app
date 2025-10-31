import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../../Services/storage_service.dart';
import '../../../../routes/app_routes.dart';

import 'package:in_app_update/in_app_update.dart';

import '../../../Chat/api/session_alive.dart';

class SplashController extends GetxController {
  bool _navigated = false;


  @override
  Future<void> onReady() async {
    // Give web a frame so GetX bindings finish
    await Future.delayed(const Duration(milliseconds: 1));

    final session = Get.find<Session>();

    // 1) Wait until Session has loaded cache / set up SWR
    await session.whenReady();

    // 2) Give SWR a short window (optional) to fetch user if needed
    final ok = await session.waitForAuth(timeout: const Duration(milliseconds: 600));

    if (ok) {
      Get.offAllNamed(AppRoutes.home);
    } else {
      Get.offAllNamed(AppRoutes.login_r);
    }
  }

  @override
  void onInit() {
    callNetworkCheck();
    SystemChannels.textInput.invokeMethod('TextInput.hide');

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        systemNavigationBarColor: Colors.white, statusBarColor: Colors.white));

    checkGooglePlayUpdate().then((v) {
      return _navigateToNextScreen();
    }); // 🔁 run after screen is rendered

    super.onInit();
  }

  Future<void> checkGooglePlayUpdate() async {
    try {
      final updateInfo = await InAppUpdate.checkForUpdate();
      if (updateInfo.updateAvailability == UpdateAvailability.updateAvailable) {
        await InAppUpdate.performImmediateUpdate();
      }
    } catch (e) {}
  }

  // getIntialMessage() {
  //   // initBinding();
  //   FirebaseMessaging?.instance.getInitialMessage().then((RemoteMessage? message) async {
  //     if (message != null) {
  //       await   Get.find<GetLoginModalService>().updateFromAPI();
  //       PushNotificationsManager.notificationRedirection(message);
  //     }
  //     else{
  //       final PendingDynamicLinkData? initialLink = await FirebaseDynamicLinks.instance.getInitialLink();
  //       if (initialLink != null) {
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
  //     }
  //   });
  // }

  _navigateToNextScreen() =>
      Timer(Duration(milliseconds: 2000), () async {
        Future.microtask(checkUserNavigation);
      });

  Future<void> checkUserNavigation() async {
    final String? token = StorageService.getToken();
    final bool loggedIn = StorageService.isLoggedInCheck();

    // prevent double navigation if this gets called multiple times
    if (_navigated == true) return;
    _navigated = true;

    // 1) No token => Login
    if (token == null) {
      Get.offAllNamed(AppRoutes.login_r);
      return;
    }

    // 2) Token present + Logged in => Home
    if (loggedIn) {
      Get.offAllNamed(AppRoutes.home);
      return;
    }

    // 3) Token present but not logged in (onboarding/landing)
    Get.offAllNamed(AppRoutes.landing_r);
  }


  callNetworkCheck() async {
    await checkNetworkConnection(Get.context!);
  }

  Future<void> checkNetworkConnection(BuildContext context) async {
    final List<ConnectivityResult> connectivityResult =
        await (Connectivity().checkConnectivity());

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
          content: const Text(
              'Your mobile data is off or you are not connected to Wi-Fi. Please turn it on to continue using the app.'),
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
class StartupController extends GetxController {
  bool _navigated = false;

  @override
  void onReady() {
    super.onReady();
    Future.microtask(checkUserNavigation);
  }

  Future<void> checkUserNavigation() async {
    final String? token = StorageService.getToken();
    final bool loggedIn = StorageService.isLoggedInCheck();

    // prevent double navigation if this gets called multiple times
    if (_navigated == true) return;
    _navigated = true;

    // 1) No token => Login
    if (token == null) {
      Get.offAllNamed(AppRoutes.login_r);
      return;
    }

    // 2) Token present + Logged in => Home
    if (loggedIn) {
      Get.offAllNamed(AppRoutes.home);
      return;
    }

    // 3) Token present but not logged in (onboarding/landing)
    Get.offAllNamed(AppRoutes.landing_r);
  }
}