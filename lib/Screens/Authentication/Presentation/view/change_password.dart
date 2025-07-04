import 'package:AccuChat/Constants/strings.dart';
import 'package:AccuChat/Screens/Authentication/Presentation/controller/change_password_controler.dart';
import 'package:AccuChat/utils/backappbar.dart';
import 'package:AccuChat/utils/gradient_button.dart';
import 'package:AccuChat/utils/helper_widget.dart';
import 'package:AccuChat/utils/text_style.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:AccuChat/Extension/text_field_extenstion.dart';
import '../../../../Constants/assets.dart';
import '../../../../utils/common_textfield.dart';

class ChangePasswordScreen extends GetView<ChangePassController> {
    ChangePasswordScreen({Key? key}) : super(key: key);
   final formChangePassKey = GlobalKey<FormState>();
   @override
   Widget build(BuildContext context) {
     return GetBuilder<ChangePassController>(
       builder: (controller) {
         return Scaffold(
           appBar: backAppBar(title: STRING_changePassword),
           body: SingleChildScrollView(
             child: Column(
               crossAxisAlignment: CrossAxisAlignment.center,
               children: <Widget>[
                 Image.asset(changePassPNG,height: 200 ,width:MediaQuery.of(context).size.width,),
                 getAppLogo(),
                 vGap(10),
                 Text(
                   "Change your password to secure your account!",
                   textAlign: TextAlign.center,
                   style: BalooStyles.baloonormalTextStyle(),
                 ).marginSymmetric(horizontal: 40),


                 vGap(40),
                 _changePasswordFormWidget(),
                 vGap(40),
                 GradientButton(
                   onTap: () {
                     if(formChangePassKey.currentState!.validate()) {
                       controller.hitApiToChangePassword();
                     }
                   }, name: 'Submit',
                 ).marginSymmetric(horizontal: 15),
                 vGap(40),
               ],
             ),
           ),
         );
       }
     );
   }

   Widget _changePasswordFormWidget(){
     return Form(
       key:formChangePassKey ,
       child: Column(
         mainAxisSize: MainAxisSize.min,
         crossAxisAlignment: CrossAxisAlignment.start,
         children: [
           CustomTextField(
             hintText: "Old Password".tr,
             labletext: "Old Password",
             controller: controller.oldPassController,
             obsecureText: controller.obsecurePassword,

             validator: (value) {
               return value?.isEmptyField(messageTitle:"Old Password" );
             },
             prefix: Icon(Icons.lock),
             suffix: IconButton(
                 onPressed: () {
                   controller.showOrHidePasswordVisibility();
                 },
                 icon: Icon(
                   controller.obsecurePassword
                       ? Icons.visibility_off
                       : Icons.visibility,
                   color: Colors.grey,
                 )),
             focusNode: controller.oldPassFocusNode,
             onFieldSubmitted: (String? value) {
               FocusScope.of(Get.context!).requestFocus(controller.newPassFocusNode);
             },

           ),
           vGap(12),
           CustomTextField(
             hintText: "New Password".tr,
             labletext: "New Password",
             controller: controller.newPassController,
             obsecureText: controller.obsecurePassword2,

             validator: (value) {
               return value?.isEmptyField(messageTitle:"New Password" );
             },
             prefix: Icon(Icons.lock),
             suffix: IconButton(
                 onPressed: () {
                   controller.showOrHidePasswordVisibility2();
                 },
                 icon: Icon(
                   controller.obsecurePassword2
                       ? Icons.visibility_off
                       : Icons.visibility,
                   color: Colors.grey,
                 )),
             focusNode: controller.newPassFocusNode,
             onFieldSubmitted: (String? value) {
               FocusScope.of(Get.context!).requestFocus(controller.conPasswordFocusNode);
             },

           ),
           vGap(12),
           CustomTextField(
             hintText: "Confirm Password".tr,
             labletext: "Confirm Password",
             controller: controller.conPasswordController,
             obsecureText: controller.obsecurePassword3,

             validator: (value) {
               return value?.validateConfirmPassword(password: controller.conPasswordController.text,newpassword: controller.newPassController.text);
             },
             prefix: Icon(Icons.lock),
             suffix: IconButton(
                 onPressed: () {
                   controller.showOrHidePasswordVisibility3();
                 },
                 icon: Icon(
                   controller.obsecurePassword3
                       ? Icons.visibility_off
                       : Icons.visibility,
                   color: Colors.grey,
                 )),
             focusNode: controller.conPasswordFocusNode,
             onFieldSubmitted: (String? value) {
               FocusScope.of(Get.context!).unfocus();
             },

           ),
         ],
       ).marginSymmetric(horizontal: 15),
     );
   }


}
