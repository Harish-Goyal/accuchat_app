import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../Constants/themes.dart';
import 'error_toast.dart';

toast(
  message, {
  int seconds = 1,
  String? title,
}) =>
    EdgeAlert.show(Get.context!,
        description: message ?? "",
        gravity: EdgeAlert.BOTTOM,
        duration: seconds,
        backgroundColor: AppTheme.appColor);

errorDialog(message) {
  EdgeAlert.show(Get.context!,
      description: message,

      gravity: EdgeAlert.BOTTOM,
      backgroundColor: AppTheme.redErrorColor,);
}
