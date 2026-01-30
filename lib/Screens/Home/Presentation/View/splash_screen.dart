import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../../Services/storage_service.dart';
import '../../../../main.dart';
import '../../../../routes/app_routes.dart';

//splash screen
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {



  @override
  void initState() {
    checkUserNavigation(context);

    Future.delayed(const Duration(seconds: 2), () {

      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
          systemNavigationBarColor: Colors.white,
          statusBarColor: Colors.white));

    });
    super.initState();
  }
  Future<void> checkUserNavigation(BuildContext context) async {
    // await APIs.getSelfInfo();
    // await APIs.getSelfInfoProfile();
    final localToken = StorageService.getToken();
    if (localToken != null) {
      // Not logged in
      Get.offAllNamed(AppRoutes.landing_r);
      return;

    } else {
      Get.offAllNamed(AppRoutes.login_r);
      return;
    }
    // await APIs.getSelfInfoProfile();
  }
  @override
  Widget build(BuildContext context) {
    //initializing media query (for getting device screen size)
    mq = MediaQuery.of(context).size;

    return Scaffold(
      //body
      body: Stack(children: [
        //app logo
        Positioned(
            top: mq.height * .15,
            right: mq.width * .25,
            width: mq.width * .5,
            child: Image.asset('assets/images/icon.png')),

        //google login button
        Positioned(
            bottom: mq.height * .15,
            width: mq.width,
            child: const Text('MADE IN INDIA WITH ❤️',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 16, color: Colors.black87, letterSpacing: .5))),
      ]),
    );
  }
}
