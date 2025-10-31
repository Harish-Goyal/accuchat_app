import 'package:AccuChat/routes/app_routes.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'dart:async';
import 'package:AccuChat/utils/custom_flashbar.dart';
import 'package:flutter/material.dart';
import 'package:sms_autofill/sms_autofill.dart';
import '../../../../../../Services/APIs/auth_service/auth_api_services_impl.dart';
import '../../../../../../main.dart';

class LoginGController extends GetxController {
  bool isAnimate = false;





  // OtpFieldController otpFieldController =OtpFieldController();
  TextEditingController otpFieldController = TextEditingController();
  final phoneController = TextEditingController();
  // final otpController = TextEditingController();
  final formGlobalKey = GlobalKey<FormState>();
  String? verificationId;
  bool otpSent = false;

  bool isFill = false;
  String otpVal = '';
  // int secondsRemaining = 60;
  // bool enableResend = false;
  // Timer? timer;
  var _resendToken;

  bool isOtpInProgress = false;


  final emailRegEx = RegExp(r'^[\w\.\-]+@[\w\.\-]+\.\w{2,}$');
  final phoneRegEx = RegExp(r'^\d+$'); // “all digits” check
  bool showCountryCode = false;
  void onTextChanged(String text) {
    final isEmail = emailRegEx.hasMatch(text);
    final isPhone = phoneRegEx.hasMatch(text);
    final wantCountry = isPhone && !isEmail;

    if (wantCountry != showCountryCode) {
      showCountryCode = wantCountry;
      update();
    }
  }

  hitAPIToSendOtp() async {
    FocusManager.instance.primaryFocus!.unfocus();
    customLoader.show();
    var req = {
      "userInput":  phoneController.text.trim(),
    };
    isOtpInProgress = true;
    update();
    Get.find<AuthApiServiceImpl>()
        .signupApiCall(dataBody: req)
        .then((value) async {
      customLoader.hide();
      otpSent = true;
      Get.snackbar("Otp Sent", value.message??'',
          backgroundColor: Colors.white, colorText: Colors.black);
      if(kIsWeb) {
        Get.toNamed(
          "${AppRoutes.verify_otp}?emailOrPhone=${phoneController.text.trim()}",
        );

      }else{
        Get.toNamed(AppRoutes.verify_otp,
            arguments: {
              'emailOrPhone': phoneController.text.trim()
            });
      }
      update();
      // openBottomSheet();
    }).onError((error, stackTrace) {
      customLoader.hide();
      errorDialog(error.toString());
      isOtpInProgress = false;
      update();
    });
  }

  /*void sendOTP() async {
    SystemChannels.textInput.invokeMethod('TextInput.hide');
    otpFieldController.clear();
    otpVal='';
    customLoader.show();
    if (isOtpInProgress) {
      Get.snackbar("Error", "OTP request is already in progress",backgroundColor: Colors.white,colorText: Colors.black);
      return;
    }
    try {

        isOtpInProgress = true;
        update();
      initTimer();
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: countryCodeVal+phoneController.text.trim(),
        verificationCompleted: (PhoneAuthCredential credential) async {
          await FirebaseAuth.instance.signInWithCredential(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          Get.snackbar("Error",  "Otp send failed please check number!",colorText: Colors.white,backgroundColor: Colors.red);
          customLoader.hide();
        },
        codeSent: (String verId, int? resendToken)  {
          customLoader.hide();
          verificationId = verId;
          otpSent = true;
          _resendToken = resendToken;
          Get.snackbar("Otp Sent", "Please check!",backgroundColor: Colors.white,colorText: Colors.black);
          Get.bottomSheet(
           bottomSheetWidget(Get.context!),

            backgroundColor: Colors.white,

            // barrierColor: Colors.red[50],
            isDismissible: false,
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20), topRight: Radius.circular(20)),
                side: BorderSide(width: 5, color: Colors.white)),
            enableDrag: false,
          );
          update();
        },
        codeAutoRetrievalTimeout: (String verId) {
          verificationId = verId;
          customLoader.hide();
        },
      ).then((V){


      });


    }
    catch(e){
      customLoader.hide();
      errorDialog("Something wend wrong!");
    }finally {
      isOtpInProgress = false;
      update();


    }
  }*/

/*  resentOTP(setState) async {
    customLoader.show();
    if (isOtpInProgress) {
      Get.snackbar("Error", "OTP request is already in progress",
          backgroundColor: Colors.white, colorText: Colors.black);
      return;
    }
    try {
      setState(() {
        isOtpInProgress = true;
        enableResend = false;
      });
      timer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (secondsRemaining != 0) {
          secondsRemaining--;
          update();
        } else {
          enableResend = true;
          update();
        }
      });
      await FirebaseAuth.instance
          .verifyPhoneNumber(
        phoneNumber: (countryCodeVal + phoneController.text.trim()),
        forceResendingToken: _resendToken,
        timeout: const Duration(seconds: 60),
        verificationCompleted: (PhoneAuthCredential credential) {},
        verificationFailed: (FirebaseAuthException e) {
          print("❌ Verification failed: ${e.message}");
        },
        codeSent: (String verificationId, int? forceResendingToken) {
          verificationId = verificationId;
          _resendToken = forceResendingToken;
          customLoader.hide();
          otpSent = true;
          Get.snackbar("Otp Sent", "Please check!",
              backgroundColor: Colors.white, colorText: Colors.black);
         *//* Get.bottomSheet(
            bottomSheetWidget(Get.context!),

            backgroundColor: Colors.white,

            // barrierColor: Colors.red[50],
            isDismissible: false,
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20)),
                side: BorderSide(width: 5, color: Colors.white)),
            enableDrag: false,
          );*//*
          setState(() {});
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          verificationId = verificationId;
          customLoader.hide();
        },
      )
          .then((v) {
        customLoader.hide();
      });
      // Get.snackbar("OTP Sent", "Please check your sms!",backgroundColor: Colors.white,colorText: Colors.black87);
    } catch (e) {
      errorDialog("Something wend wrong!");
    } finally {
      setState(() {
        isOtpInProgress = false;
      });
    }
  }*/


/*  // handles google login button click
  handleGoogleBtnClick() {
    //for showing progress bar
    Dialogs.showProgressBar(Get.context!);

    _signInWithGoogle(Get.context!).then((user) async {
      //for hiding progress bar
      Get.back();

      if (user != null) {
        // log('\nUser: ${user.displayName}');
        // log('\nUserAdditionalInfo: ${user.email}');

        if ((await APIs.userExists())) {
          await APIs.getSelfInfo();
          final userDoc = await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();

          if (!userDoc.exists) {
            // First-time user or deleted data
            Get.offAllNamed(AppRoutes.loginGRoute);
            return;
          } else {
            ChatUser me = ChatUser.fromJson(userDoc.data()!);
            if (userDoc.exists *//* && me.company==null*//*) {
              storage.write(isFirstTime, false);
              Get.offAllNamed(AppRoutes.loginGRoute);
              return;
            } *//*else {
              if(userDoc.exists && me.company!=null) {
                // ✅ User is in a company, send to Home
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => AccuChatDashboard()));
                return;
              }
            }*//*
          }

          // Navigator.pushReplacement(context,
          //     MaterialPageRoute(builder: (_) => const ChatsHomeScreen()));
        } else {
          await APIs.createUser().then((value) async {
            await APIs.getSelfInfo();
            final userDoc = await FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .get();

            if (!userDoc.exists) {
              // First-time user or deleted data
              Get.offAllNamed(AppRoutes.loginGRoute);
              return;
            } else {
              ChatUser me = ChatUser.fromJson(userDoc.data()!);

              if (userDoc.exists *//* && me.company==null*//*) {
                storage.write(isFirstTime, false);
                Get.offAllNamed(AppRoutes.landingRoute);
                return;
              } *//*else {
                if(userDoc.exists && me.company!=null) {
                  // ✅ User is in a company, send to Home
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => AccuChatDashboard()));
                  return;
                }
              }*//*
            }

            // Get.offAllNamed(AppRoutes.home);
          });
        }

        storage.write(isFirstTimeChatKey, isFirstTimeChat);
      }
    });
  }*/

  String countryCodeVal = '+91';
  bool isPhoneorEmail = false;

  @override
  void onInit() {
    _updateTimer();
    SmsAutoFill().listenForCode();
    super.onInit();
  }

  _updateTimer() {
    Future.delayed(const Duration(milliseconds: 500), () {
      isAnimate = true;
      update();
    });
  }

/*  Widget bottomSheetWidget(context) {
    return SafeArea(
      child: StatefulBuilder(builder: (context, setState) {
        return SingleChildScrollView(
          child: Column(
            children: [
              vGap(30),
              Text(
                'We have sent an OTP on your registered mobile number please enter below!',
                style: BalooStyles.baloosemiBoldTextStyle(),
                textAlign: TextAlign.center,
              ).paddingSymmetric(horizontal: 15),
              vGap(30),

              PinFieldAutoFill(
                codeLength: 6,
                // cursor: Cursor(color: appColorGreen),

                controller: otpFieldController,
                decoration: UnderlineDecoration(
                    textStyle: TextStyle(fontSize: 20, color: Colors.black),
                    colorBuilder: FixedColorBuilder(appColorGreen),
                    lineStrokeCap: StrokeCap.square),
                currentCode: otpFieldController.text,
                onCodeSubmitted: (code) {
                  // if (code != null && code.length == 6) {
                  //   otpVal = code;
                  //   isFill = true;
                  //   setState(() {});
                  //   verifyOTP();
                  // }
                },
                onCodeChanged: (code) {
                  if (code != null && code.length == 6) {
                    SystemChannels.textInput.invokeMethod('TextInput.hide');
                    otpVal = code;
                    isFill = true;
                    setState(() {});
                    verifyOTP(setState);
                  }
                },
              ).paddingSymmetric(horizontal: 5, vertical: 35),

*//*
                      OTPTextField(
                      length: 6,
                      controller: otpFieldController,
                      width: Get.width,
                      keyboardType: TextInputType.number,
                      fieldWidth: 45,
                      fieldStyle: FieldStyle.box,
                      style: const TextStyle(fontSize: 15),
                      onCompleted: (val) {

                  isFill = true;
                        otpVal = val;
                        setState(() {

                       });
                       verifyOTP();

                      },
                      onChanged: (otp){

                      },
                      otpFieldStyle: OtpFieldStyle(
                        backgroundColor: Colors.white,
                        enabledBorderColor: Colors.grey.shade300,
                        borderColor: Colors.grey.shade300,
                        focusBorderColor: AppTheme.appColor,
                      ),
                    ).paddingSymmetric(horizontal: 5,vertical: 35),
*//*
              resendOTPView(context, setState),
              // GetBuilder<LoginController>(
              //   builder: (controller) {
              //     return Center(
              //       child: Text(
              //         '${controller.secondsRemaining}',
              //         style:  TextStyles(context).title(),
              //       ),
              //     );
              //   }
              // ),
              vGap(20),
              isFill
                  ? IndicatorLoading()
                  : GradientButton(
                      onTap: isFill
                          ? () {
                              if (formGlobalKey.currentState?.validate() ??
                                  false) {
                                SystemChannels.textInput
                                    .invokeMethod('TextInput.hide');
                                setState(() {
                                  isFill = true;
                                });
                                verifyOTP(setState);
                              }
                            }
                          : () {},
                      btnColor:
                          isFill ? AppTheme.appColor : Colors.grey.shade300,
                      name: 'Submit',
                    ).marginOnly(bottom: 80, left: 20, right: 20),
              *//*  Stack(
                      alignment: Alignment.topCenter,
                      children: [
                        Container(
                            height: Get.height,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              // borderRadius: BorderRadius.only(bottomLeft: Radius.circular(20),bottomRight: Radius.circular(20))
                            ),
                            alignment: Alignment.topCenter,
                            child: Container(
                                height: Get.height * .53,
                                decoration:  BoxDecoration(
                                    color: AppTheme.primaryColor,
                                    // color: appColor,
                                    // gradient: appBarGradient(),
                                    borderRadius: BorderRadius.only(
                                        bottomLeft: Radius.circular(20),
                                        bottomRight: Radius.circular(20))),
                                child: Container(
                                    padding: const EdgeInsets.fromLTRB(60, 0, 60, 70),
                                    child: Image.asset(Localfiles.appIcon)))),
                        Positioned(
                          left: 15,
                          right: 15,
                          bottom: 30,
                          child: Container(
                              height:
                              Get.height < 650 ? Get.height * .44 : Get.height * .5,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  color: Colors.white,
                                  boxShadow: [
                                    BoxShadow(color: Colors.grey.shade500, blurRadius: 7)
                                  ]),
                              padding: const EdgeInsets.all(0),
                              child: ListView(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 30),
                                  children: [
                                    OTPTextField(
                                      length: 6,
                                      controller: controller.otpFieldController,
                                      width: Get.width,
                                      fieldWidth: 45,
                                      fieldStyle: FieldStyle.box,
                                      style: const TextStyle(fontSize: 17),
                                      onCompleted: (val) {
                                        // controller.isFill = true;
                                        // controller.otpVal = val;
                                        // controller.update();
                                        // controller.hitOtpAPI(otp: val);
                                      },
                                      otpFieldStyle: OtpFieldStyle(
                                        backgroundColor: Colors.white,
                                        enabledBorderColor: Colors.grey.shade300,
                                        borderColor: Colors.grey.shade300,
                                        focusBorderColor: AppTheme.primaryColor,
                                      ),
                                    ),
                                    resendOTPView(context),
                                    Center(
                                      child: Text(
                                        '${controller.secondsRemaining}',
                                        style:  TextStyles(context).title(),
                                      ),
                                    ),
                                    vGap(20),
                                    GradientButton(
                                      onTap:*//* *//* controller.isFill
                                          ? () {
                                        if (formGlobalKey.currentState?.validate() ?? false) {
                                          controller.hitOtpAPI(otp:controller.otpVal );
                                        }
                                      }
                                          : *//* *//*() {},
                                      btnColor: *//* *//*controller.isFill
                                          ? appColor*//* *//*
                                      Colors.grey.shade300,
                                      name: 'Submit',
                                    ).marginOnly(bottom: 20),
                                  ])),
                        ),

                        Positioned(
                          top: Get.height*.3,

                          left: 0,
                          right: 0,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              vGap(20),
                              Text(
                                "Verification",
                                style: BalooStyles.balooregularTextStyle(),
                                textAlign: TextAlign.center,
                              ),  vGap(10),Text(
                                "Enter OTP, that is sent to your registered mobile number.",
                                style:TextStyles(context).description(),
                                textAlign: TextAlign.center,
                              ).paddingSymmetric(horizontal: 30),
                            ],
                          ),
                        ),
                        Positioned(top: 40, left: 15, child: backIcon()
                        )
                      ],
                    ),*//*
            ],
          ).marginSymmetric(horizontal: 20, vertical: 15),
        );
      }),
    );
  }*/




}
