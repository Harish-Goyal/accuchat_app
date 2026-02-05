import 'package:AccuChat/utils/text_style.dart';
import 'package:AccuChat/utils/backappbar.dart';
import 'package:AccuChat/utils/gradient_button.dart';
import 'package:AccuChat/Extension/text_field_extenstion.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../../Constants/assets.dart';
import '../../../../utils/common_textfield.dart';
import '../../../../utils/helper_widget.dart';
import '../controller/loginController.dart';

class LoginScreen extends GetView<LoginController> {
  LoginScreen({super.key});
  final formLoginKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarBrightness: Brightness.light,
      statusBarIconBrightness: Brightness.light,
    ));
    return GetBuilder<LoginController>(builder: (controller) {
      return SafeArea(
        child: Scaffold(
          extendBodyBehindAppBar: true,
          body:  Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              vGap(20),
              backApp(context, "Login"),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: <Widget>[
                      Image.asset(loginPng,height: Get.height*.23,width: Get.width,),

                      // getAppLogo(),
                      vGap(20),
                      Text(
                        "Login with phone or email address and enter correct password!",
                        style: BalooStyles.baloonormalTextStyle(weight: FontWeight.w500),
                        textAlign: TextAlign.center,
                      ).marginSymmetric(horizontal: 20),
                      vGap(20),
                      vGap(20),
                      Container(
                        width: Get.width,
                        child:InputDecorator(
                          decoration: InputDecoration(
                            labelText: 'Login with',
                            hintText: 'Login with',
                            hintStyle: BalooStyles.baloonormalTextStyle(
                                color: Colors.grey),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide:
                                BorderSide(color: Colors.grey.shade400)),
                            enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide:
                                BorderSide(color: Colors.grey.shade400)),
                            labelStyle: BalooStyles.baloonormalTextStyle(),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 9, vertical: 1),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: controller.selectedloginType,
                              hint: Text("Login with",style:BalooStyles.baloomediumTextStyle(),),
                              items: ["Login with Appcode", "Individual Login"]
                                  .map(
                                      (String type) => DropdownMenuItem<String>(
                                    value: type,
                                    child: SizedBox(
                                        width: Get.width*.52,
                                        child: Text(type,style: BalooStyles.baloomediumTextStyle(),)),
                                  ))
                                  .toList(),
                              onChanged: (String? newValue) {
                                if (newValue != null) {
                                  controller.selectedloginType = newValue;
                                  controller.update();
                                }
                              },
                              dropdownColor: Colors.white,
                            ),
                          ),
                        ),
                      ).marginSymmetric(horizontal: 15),

                      controller.selectedloginType=='Login with Appcode'?   CustomTextField(
                        hintText: "Enter App Code".tr,
                        controller: controller.codeController,
                        // textInputType: TextInputType.,

                        focusNode: controller.codeFocusNode,
                        onFieldSubmitted: (String? value) {
                          FocusScope.of(Get.context!)
                              .requestFocus(controller.phoneFocusNode);
                        },
                        labletext: "App Code",

                        validator: (value) {
                          return value?.isEmptyField(messageTitle: "App Code");
                        },
                      ).marginSymmetric(horizontal:15,vertical: 20):SizedBox(),


                      _form(),
                      vGap(30),
        
                      // _forgotYourPasswordUI(context),
                      GradientButton(
                        onTap: () {
                          if (formLoginKey.currentState!.validate()) {
                            // NavigationServices(context).gotoTabScreen();
                            // controller.hitAPIToLogin();
                          }
                        },
                        name: 'Login',
                      ).marginSymmetric(horizontal: 15),
                      vGap(10),
                      /*   InkWell(
                                  onTap: (){
                                    // Get.offAllNamed(AppRoutes.bottomTabScreen);
                                    // storage.write(isFirstTime, false);
                                    // storage.write(isLoggedIn, false);
                                  },
                                  child: Text(
                                    "Skip for now",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  ),
                                ),*/
                    ],
                  ).marginSymmetric(horizontal: 12),
                ),
              )
            ],
          ),
        ),
      );
    });
  }

  _form() {
    return Form(
        key: formLoginKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomTextField(
              hintText: "Username".tr,
              controller: controller.phoneController,
              // textInputType: TextInputType.,

              focusNode: controller.phoneFocusNode,
              onFieldSubmitted: (String? value) {
                FocusScope.of(Get.context!)
                    .requestFocus(controller.passwordFocusNode);
              },
              labletext: "Username",

              // prefix: Container(
              //     margin: const EdgeInsets.only(right: 10),
              //     decoration: BoxDecoration(
              //       borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(30),topLeft: Radius.circular(30)),
              //       // color: Colors.white,
              //       border: Border.all(color: Colors.grey.shade300, width: 0.5),
              //     ),
              //     child: CountryCodePicker(
              //         flagWidth: 15.0,
              //         initialSelection: 'IN',
              //         boxDecoration: const BoxDecoration(color: Colors.transparent),
              //         showCountryOnly: true,
              //         onChanged: (value) {
              //           controller.countryCodeVal = value.dialCode.toString();
              //           controller.update();
              //         })),
              validator: (value) {
                return value?.isEmptyField(messageTitle: "Username");
              },
            ),
            vGap(16),
            CustomTextField(
              hintText: "Password".tr,
              labletext: "Password",
              controller: controller.passwordController,
              obsecureText: controller.obsecurePassword,

              prefix: const Icon(Icons.lock),
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
              focusNode: controller.passwordFocusNode,
              onFieldSubmitted: (String? value) {
                FocusScope.of(Get.context!).unfocus();
              },

              validator: (value) {
                return value?.isEmptyField(messageTitle: "Password");
              },
            ),
          ],
        ).marginSymmetric(horizontal: 15, vertical: 15));
  }

  // goToRegisterView() {
  //   return Text.rich(
  //     TextSpan(
  //         text: "Don't have an account? ".tr,
  //         style: BalooStyles.baloonormalTextStyle(size: 15,color: Colors.black45),
  //         children: [
  //           TextSpan(
  //             text: "Login".tr,
  //             recognizer: new TapGestureRecognizer()
  //               ..onTap = () {
  //                 Get.toNamed(AppRoutes.logIn);
  //               },
  //             style: BalooStyles.balooboldTextStyle(size: 17,color: appColor),
  //           ),
  //         ]),
  //     textAlign: TextAlign.center,
  //     style: const TextStyle(
  //       color: Colors.black,
  //       fontSize: 16,
  //       fontWeight: FontWeight.w500,
  //     ),
  //   );
  // }

  Widget _forgotYourPasswordUI(context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, right: 16, bottom: 8, left: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          InkWell(
            borderRadius: const BorderRadius.all(Radius.circular(8)),
            onTap: () {
              // Get.toNamed(AppRoutes.forgotPasswordScreen);
            },
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "Forgot Password",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).disabledColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  //
  // bool _allValidation() {
  //   bool isValid = true;
  //   if (controller.emailController.text.trim().isEmpty) {
  //     controller.errorEmail = Loc.alized.email_cannot_empty;
  //     isValid = false;
  //   } else if (!Validator.validateEmail(controller.emailController.text.trim())) {
  //     controller.errorEmail = Loc.alized.enter_valid_email;
  //     isValid = false;
  //   } else {
  //     controller.errorEmail = '';
  //   }
  //
  //   if (controller.passwordController.text.trim().isEmpty) {
  //     controller.errorPassword = Loc.alized.password_cannot_empty;
  //     isValid = false;
  //   } else if (controller.passwordController.text.trim().length < 6) {
  //     controller.errorPassword = Loc.alized.valid_password;
  //     isValid = false;
  //   } else {
  //     controller.errorPassword = '';
  //   }
  //   controller.update();
  //   return isValid;
  // }
}
