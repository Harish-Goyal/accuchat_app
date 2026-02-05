import 'package:AccuChat/Constants/assets.dart';
import 'package:AccuChat/Constants/colors.dart';
import 'package:AccuChat/Extension/text_field_extenstion.dart';
import 'package:AccuChat/Screens/Chat/screens/auth/Presentation/Controllers/login_controller.dart';
import 'package:AccuChat/utils/custom_dialogue.dart';
import 'package:AccuChat/utils/text_style.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../../../../utils/common_textfield.dart';
import '../../../../../../utils/helper_widget.dart';
import '../../../../../Settings/Presentation/Views/settings_screen.dart';
import '../../../../../Settings/Presentation/Views/static_page.dart';

class LoginScreenG extends GetView<LoginGController> {
   LoginScreenG({super.key});
  final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(      scrolledUnderElevation: 0,
        surfaceTintColor: Colors.white,
        automaticallyImplyLeading: false,
        title: const Text('Welcome to AccuChat'),
      ),

      body: GetBuilder<LoginGController>(
        builder: (controller) {
          return SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 600;
                return Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: isWide ? 500 : double.infinity,
                    ),
                    child: SingleChildScrollView(
                        child: Form(
                          key: _formKey,
                          child: Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                children: [
                          Image.asset(
                            appIcon,
                            width: isWide ? Get.width * .1 : Get.width * .3,
                            height: isWide ? Get.width * .1 : Get.width * .3,
                          ),
                          Text(
                            "Login with phone or email address!",
                            style: BalooStyles.baloonormalTextStyle(
                                weight: FontWeight.w500),
                            textAlign: TextAlign.center,
                          ),
                          vGap(30),
                          CustomTextField(
                            hintText: "Email or Phone".tr,
                            controller: controller.phoneController,
                            textInputType: TextInputType.emailAddress,
                            inputFormatters: controller.showCountryCode
                                ? <TextInputFormatter>[
                                    FilteringTextInputFormatter.digitsOnly,
                                    LengthLimitingTextInputFormatter(10),
                                  ]
                                : <TextInputFormatter>[],
                            validator: (value) {
                              return controller.showCountryCode
                                  ? value?.validateMobile(
                                      controller.phoneController.text)
                                  : value?.isValidEmail();
                            },
                            onFieldSubmitted: (String? value) {
                              if(_formKey.currentState!.validate()){
                                FocusScope.of(Get.context!).unfocus();
                                controller.hitAPIToSendOtp();
                              }

                            },
                            labletext: "Phone or Email",
                            prefix: !controller.showCountryCode
                                ? Icon(Icons.email_outlined,
                                    size: 18, color: appColorGreen)
                                : CountryCodePicker(
                              initialSelection: 'IN',
                              showFlagDialog: false,
                              showDropDownButton: false,
                              padding: EdgeInsets.zero,
                              backgroundColor: Colors.transparent,            // just in case
                              boxDecoration: const BoxDecoration(
                                color: Colors.transparent,                    // main container transparent
                              ),
                              builder: (code) {
                                return Container(                             // you control the painting
                                  color: Colors.transparent,
                                  padding: const EdgeInsets.symmetric(horizontal: 8),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (code?.flagUri != null)
                                        Image.asset(code!.flagUri!,
                                            package: 'country_code_picker', width: 20),
                                      const SizedBox(width: 6),
                                      Text(code?.dialCode ?? ''),
                                    ],
                                  ),
                                );
                              },
                              onChanged: (_) {

                              },
                            )
                            ,
                            onChangee:(v){
                              if (controller.showCountryCode) {
                                // Remove all non-digits
                                String cleaned = v.replaceAll(RegExp(r'[^0-9]'), '');

                                // Limit to 10 digits
                                if (cleaned.length > 10) {
                                  cleaned = cleaned.substring(0, 10);
                                }

                                // Only update if different to avoid cursor jump
                                if (cleaned != controller.phoneController.text) {
                                  controller.phoneController.value =
                                      controller.phoneController.value.copyWith(
                                        text: cleaned,
                                        selection: TextSelection.fromPosition(
                                          TextPosition(offset: cleaned.length),
                                        ),
                                      );
                                }
                              }
                              controller.onTextChanged(v);
                            } ,
                          ),
                          vGap(40),
                          dynamicButton(
                            name: "Send OTP",
                            onTap: () {
                              if(_formKey.currentState!.validate()){
                                FocusScope.of(Get.context!).unfocus();
                                controller.hitAPIToSendOtp();
                              }
                            },
                            isShowText: true,
                            isShowIconText: false,
                            gradient: buttonGradient,
                            leanIcon: 'assets/images/google.png',
                          ),
                          /*vGap(35),
                            Row(
                              children: [
                                Expanded(
                                  child: dynamicButton(
                                    name: "Login with Google",
                                    onTap: () => controller.handleGoogleBtnClick(),
                                    isShowText: true,
                                    isShowIconText: true,
                                    gradient: buttonGradient,
                                    leanIcon: 'assets/images/google.png',
                                  ),
                                ),
                              ],
                            ).marginSymmetric(horizontal: 20),*/
                          vGap(20),
                          Row(
                            children: [
                              Flexible(child: _policyText()),
                            ],
                          ).marginSymmetric(vertical: 35, horizontal: 20),
                                                ],
                                              ).paddingSymmetric(vertical: 5, horizontal: 15),
                        )),
                  ),
                );
              },
            ),
          );
        },
      ),

      /*body: GetBuilder<LoginGController>(
        builder: (controller) {
          return SafeArea(
            child: Stack(children: [
              //app logo
              AnimatedPositioned(
                  top:- mq.height * .01,
                  right: controller.isAnimate ? mq.width * .3 : -mq.width * .5,
                  width: mq.width * .4,
                  duration: const Duration(seconds: 1),
                  child: Image.asset(appIcon,width:200,)),

              //google login button

              Positioned(
                top: mq.height * .2,

                left: mq.width * .05,
                width: mq.width * .9,
                height: mq.height * .6,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Flexible(
                            child: Text(
                              "Login with phone or email address!",
                              style: BalooStyles.baloonormalTextStyle(weight: FontWeight.w500),
                              textAlign: TextAlign.center,
                            ).marginSymmetric(horizontal: 20),
                          ),
                        ],
                      ),

                      vGap(30),
                      CustomTextField(
                        hintText: "Email or Phone".tr,
                        controller: controller.phoneController,
                        textInputType:TextInputType.emailAddress,

                        inputFormatters: controller.showCountryCode
                            ? <TextInputFormatter>[
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(10),
                        ]
                            : <TextInputFormatter>[],
                        onFieldSubmitted: (String? value) {
                          FocusScope.of(Get.context!).unfocus();
                        },
                        labletext: controller.showCountryCode ? 'Phone' : 'Email',

                        prefix: !controller.showCountryCode?Container(
                          child: Icon(Icons.email_outlined,size: 18,color: appColorGreen,),
                        ): Container(
                            margin: const EdgeInsets.all(4),
                            // decoration: BoxDecoration(
                            //   borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(30),topLeft: Radius.circular(30)),
                            //   color: Colors.red,
                            //   border: Border.all(color: Colors.grey.shade300, width: 0.5),
                            // ),
                            child: CountryCodePicker(
                                flagWidth: 20.0,
                                initialSelection: 'IN',
                                showCountryOnly: false,
                                padding: EdgeInsets.zero, // No extra padding
                                showFlagDialog: true,
                                backgroundColor: Colors.red,
                                showDropDownButton: false,
                                barrierColor: Colors.black26,
                                enabled: false,
                                boxDecoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(0)
                                ),

                                onChanged: (value) {
                                  // controller.countryCodeVal = value.dialCode.toString();
                                  // controller.update();
                                })),
                        validator: (value) {
                          if( controller.showCountryCode ){
                            return value?.validateMobile(controller.phoneController.text);
                          } else{
                            return value?.isValidEmail();
                          }

                        },
                        onChangee: controller.onTextChanged,
                      ),
                      vGap(20),
                      dynamicButton(
                          name: "Send OTP",
                          onTap: () {
                            controller.hitAPIToSendOtp();
                          },
                          isShowText: true,
                          isShowIconText: false,
                          gradient: buttonGradient,
                          leanIcon: 'assets/images/google.png'),
                      vGap(35),
                      // Text(
                      //   "or,",
                      //   style: BalooStyles.baloonormalTextStyle(weight: FontWeight.w500),
                      //   textAlign: TextAlign.center,
                      // ),
                      // vGap(35),
                      Row(
                        children: [
                          Expanded(
                            child: dynamicButton(
                                name: "Login with Google",
                                onTap: () {
                                  controller.handleGoogleBtnClick();
                                },
                                isShowText: true,
                                isShowIconText: true,
                                gradient: buttonGradient,
                                leanIcon: 'assets/images/google.png'),
                          ),
                        ],
                      ).marginSymmetric(horizontal: Get.height*.03),

                      vGap(20),

                      Row(
                        children: [
                          Flexible(
                            child: _policyText(),
                          ),
                        ],
                      ).marginSymmetric(vertical:  Get.height*.04,horizontal: Get.height*.03),
                    ],
                  ),
                ),
              ),

            ]),
          );
        }
      ),*/
    );
  }

  _policyText() {
    return Text.rich(
      TextSpan(
          text: "By continuing with Google Sign-In, you agree to our  ".tr,
          style:
              BalooStyles.baloonormalTextStyle(size: 14, color: Colors.black54),
          children: [
            TextSpan(
              text: "Privacy Policy.".tr,
              recognizer: new TapGestureRecognizer()
                ..onTap = () {
                  Get.to(() => HtmlViewer(
                        htmlContent: pvcContent,
                      ));
                },
              style: BalooStyles.baloomediumTextStyle(
                  size: 14, color: appColorGreen),
            ),
          ]),
      textAlign: TextAlign.center,
      style: const TextStyle(
        color: Colors.black,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}
