import 'package:AccuChat/Constants/colors.dart';
import 'package:AccuChat/utils/text_style.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Dialogs {
  static void showSnackbar(BuildContext context, String msg) {

    Get.snackbar("Notification", msg, backgroundColor: Colors.grey.shade100,colorText: Colors.white,duration: Duration(seconds: 3));
  }

  static void showProgressBar(BuildContext context) {
    showDialog(
        context: context,
        builder: (_) => const Center(child: CircularProgressIndicator()));
  }
}
