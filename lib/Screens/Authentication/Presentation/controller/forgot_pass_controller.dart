// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import '../../../../main.dart';
//
//
// class ForgotPassController extends GetxController {
//   late TextEditingController emailController;
//   // ForgotResModel successModel = ForgotResModel();
//   String secretKey = '';
//   @override
//   void onInit() {
//     emailController = TextEditingController();
//     if(Get.arguments!=null){
//       secretKey = Get.arguments['secretKeys'];
//     }
//     super.onInit();
//   }
//
//   @override
//   void onClose() {
//     customLoader.hide();
//     emailController.dispose();
//     super.onClose();
//   }
//
//   // hitApiToForgotPass(){
//   //   customLoader.show();
//   //   Map<String,dynamic>  data= {
//   //        "email_id":emailController.text
//   //   };
//   //   Get.find<AuthApiServiceImpl>().forgotPassApiCall(secretKey: secretKey,dataBody: data).then((value) {
//   //     customLoader.hide();
//   //     successModel=value;
//   //     if(value.statusCode==200) {
//   //       toast(successModel.optNumber.toString() ?? '');
//   //       storage.write(user_key, value.secretKey);
//   //       update();
//   //       Get.toNamed(
//   //           AppRoutes.otpScreen, arguments: {'email': emailController.text});
//   //     }
//   //     else{
//   //       errorDialog(successModel.message.toString() ?? '');
//   //     }
//   //   }).onError((error, stackTrace) {
//   //     customLoader.hide();
//   //     toast(error.toString());
//   //   });
//   // }
//
//
// }
