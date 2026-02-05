import 'package:AccuChat/Services/APIs/local_keys.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../Services/APIs/api_ends.dart';
import '../../../../Services/APIs/post/post_api_service_impl.dart';
import '../../../../main.dart';
import '../../../../utils/custom_flashbar.dart';
import 'package:dio/dio.dart' as multi;


class ChangePassController extends GetxController {
  late TextEditingController oldPassController;
  late TextEditingController newPassController;
  late TextEditingController conPasswordController;
  late FocusNode oldPassFocusNode;
  late FocusNode newPassFocusNode;
  late FocusNode conPasswordFocusNode;
  bool obsecurePassword = true;
  bool obsecurePassword2 = true;
  bool obsecurePassword3 = true;
  bool isRememberMe = false;

  @override
  void onInit() {
    oldPassController = TextEditingController();
    newPassController = TextEditingController();
    conPasswordController = TextEditingController();
    oldPassFocusNode = FocusNode();
    newPassFocusNode = FocusNode();
    conPasswordFocusNode = FocusNode();
    super.onInit();
  }

  hitApiToChangePassword()async {

  }

  @override
  void onClose() {
    customLoader.hide();
    oldPassController.dispose();
    newPassController.dispose();
    conPasswordController.dispose();
    super.onClose();
  }

  @override
  void onReady() {}

  showOrHidePasswordVisibility() {
    obsecurePassword = !obsecurePassword;
    update();
  }

  showOrHidePasswordVisibility2() {
    obsecurePassword2 = !obsecurePassword2;
    update();
  }

  showOrHidePasswordVisibility3() {
    obsecurePassword3 = !obsecurePassword3;
    update();
  }
}
