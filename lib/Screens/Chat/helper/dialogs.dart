import 'package:AccuChat/Constants/colors.dart';
import 'package:AccuChat/utils/loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Dialogs {
  static void showSnackbar(BuildContext context, String msg) {

    Get.snackbar("Notification", msg, backgroundColor: Colors.grey.shade100,colorText: Colors.black87,duration: const Duration(seconds: 4),boxShadows: [BoxShadow(
      color: appColorGreen.withOpacity(.5),
      blurRadius: 8,

    )],
    overlayColor: Colors.black.withOpacity(.1),
      overlayBlur: 5
    );
  }

  static void showProgressBar(BuildContext context) {
    showDialog(
        context: context,
        builder: (_) => const Center(child: IndicatorLoading()));
  }
}
