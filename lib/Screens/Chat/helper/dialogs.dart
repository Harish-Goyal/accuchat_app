import 'package:AccuChat/utils/text_style.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Dialogs {
  static void showSnackbar(BuildContext context, String msg) {
    // ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    //     content: Text(msg,style: BalooStyles.baloonormalTextStyle(),),
    //     backgroundColor: Colors.white,
    //     behavior: SnackBarBehavior.floating));

    Get.snackbar("Alert", msg, backgroundColor: Colors.white,colorText: Colors.black,duration: Duration(seconds: 6));
  }

  static void showProgressBar(BuildContext context) {
    showDialog(
        context: context,
        builder: (_) => const Center(child: CircularProgressIndicator()));
  }
}
