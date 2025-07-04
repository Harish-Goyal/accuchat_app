import 'dart:developer';

import 'package:AccuChat/Screens/Chat/models/chat_user.dart';
import 'package:AccuChat/Screens/Home/Presentation/View/home_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../main.dart';
import '../../../utils/helper_widget.dart';
import '../api/apis.dart';
import 'auth/landing_screen.dart';
import 'auth/login_screen.dart';
import 'chat_home_screen.dart';

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
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      // Not logged in
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => LoginScreenG()));
      return;
    } else {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();


      if (!userDoc.exists) {
        // First-time user or deleted data
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => LoginScreenG()));
        return;
      }
      else {
        ChatUser me = ChatUser.fromJson(userDoc.data()!);
        if(me.selectedCompany==null){
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (_) => LandingPage()));
          return;
        }else {
          // ✅ User is in a company, send to Home
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (_) => ChatsHomeScreen()));
          return;
        }
      }
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
