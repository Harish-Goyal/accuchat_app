import 'dart:async';

import 'package:AccuChat/Constants/assets.dart';
import 'package:AccuChat/Constants/colors.dart';
import 'package:AccuChat/Extension/text_field_extenstion.dart';
import 'package:AccuChat/utils/custom_dialogue.dart';
import 'package:AccuChat/utils/custom_flashbar.dart';
import 'package:AccuChat/utils/loading_indicator.dart';
import 'package:AccuChat/utils/text_style.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:otp_text_field/otp_field.dart';
import 'package:otp_text_field/otp_field_style.dart';
import 'package:otp_text_field/style.dart';
import 'package:sms_autofill/sms_autofill.dart';

import '../../../../Constants/colors.dart' as AppTheme;
import '../../../../Services/APIs/local_keys.dart';
import '../../../../main.dart';
import '../../../../routes/app_routes.dart';
import '../../../../utils/common_textfield.dart';
import '../../../../utils/gradient_button.dart';
import '../../../../utils/helper_widget.dart';
import '../../../Home/Presentation/View/main_screen.dart';
import '../../../Settings/Presentation/Views/settings_screen.dart';
import '../../../Settings/Presentation/Views/static_page.dart';
import '../../api/apis.dart';
import '../../helper/dialogs.dart';
import '../../models/chat_user.dart';
import '../chat_home_screen.dart';
import 'landing_screen.dart';

class LoginScreenG extends StatefulWidget {
  const LoginScreenG({super.key});

  @override
  State<LoginScreenG> createState() => _LoginScreenGState();
}

class _LoginScreenGState extends State<LoginScreenG> {
  bool _isAnimate = false;


  @override
  void dispose() {
    timer!.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    //for auto triggering animation
    Future.delayed(const Duration(milliseconds: 500), () {
      if(mounted) {
        setState(() => _isAnimate = true);
      }
    });

    SmsAutoFill().listenForCode();
  }


  initTimer(){
    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (secondsRemaining != 0) {
        secondsRemaining--;
        if(mounted) {
          setState(() {});
        }
      } else {
        enableResend = true;
        if(mounted) {
          setState(() {});
        }
      }
    });
  }

  void resendCode() {
    secondsRemaining = 30;
    enableResend = false;
    initTimer();
    resentOTP();
    setState(() {});
  }



  // OtpFieldController otpFieldController =OtpFieldController();
  TextEditingController otpFieldController =TextEditingController();
  final phoneController = TextEditingController();
  // final otpController = TextEditingController();
  final formGlobalKey = GlobalKey<FormState>();
  String? verificationId;
  bool otpSent = false;

  bool isFill = false;
  String otpVal= '';
  int secondsRemaining = 60;
  bool enableResend = false;
  Timer? timer;
  var _resendToken;

  bool isOtpInProgress = false;

  void sendOTP() async {
    SystemChannels.textInput.invokeMethod('TextInput.hide');
    customLoader.show();
    if (isOtpInProgress) {
      Get.snackbar("Error", "OTP request is already in progress",backgroundColor: Colors.white,colorText: Colors.black);
      return;
    }
    try {


      setState(() {
        isOtpInProgress = true;
      });
      initTimer();
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: countryCodeVal+phoneController.text.trim(),
        verificationCompleted: (PhoneAuthCredential credential) async {
          await FirebaseAuth.instance.signInWithCredential(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          Get.snackbar("Error", e.message ?? "Verification failed",colorText: Colors.white,backgroundColor: Colors.red);
          customLoader.hide();
        },
        codeSent: (String verId, int? resendToken) {
          customLoader.hide();
          verificationId = verId;
          otpSent = true;
          _resendToken = resendToken;
          Get.snackbar("Otp Sent", "Please check!",backgroundColor: Colors.white,colorText: Colors.black);
          Get.bottomSheet(
            _bottomSheetWidget(context),

            backgroundColor: Colors.white,

            // barrierColor: Colors.red[50],
            isDismissible: false,
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20), topRight: Radius.circular(20)),
                side: BorderSide(width: 5, color: Colors.white)),
            enableDrag: false,
          );
          setState(() {});
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
      setState(() {
        isOtpInProgress = false;
      });
    }
  }

  resentOTP()async{
    try {
      resendCode();
      await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: (countryCodeVal+phoneController.text.trim()),
      forceResendingToken: _resendToken,
      timeout: const Duration(seconds: 60),
      verificationCompleted: (PhoneAuthCredential credential) {},
      verificationFailed: (FirebaseAuthException e) {
        print("❌ Verification failed: ${e.message}");
      },
      codeSent: (String verificationId, int? forceResendingToken) {
        verificationId = verificationId;
        _resendToken = forceResendingToken; // You can update it again if needed
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        verificationId = verificationId;
      },
    );
      // Get.snackbar("OTP Sent", "Please check your sms!",backgroundColor: Colors.white,colorText: Colors.black87);
    }
    catch(e){
      errorDialog("Something wend wrong!");
    }
  }

  void verifyOTP() async {
    final credential = PhoneAuthProvider.credential(
      verificationId: verificationId!,
      smsCode: otpVal,
    );

    try {
      await FirebaseAuth.instance.signInWithCredential(credential).then((userCredential) async {

        final user = userCredential.user;
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
              Navigator.pushReplacement(
                  context, MaterialPageRoute(builder: (_) => LoginScreenG()));
              return;
            }
            else {
              ChatUser me = ChatUser.fromJson(userDoc.data()!);
              if(userDoc.exists){

                Get.offAll(()=>LandingPage());
                storage.write(isFirstTime, false);

                // Navigator.pushReplacement(
                //     context, MaterialPageRoute(builder: (_) => LandingPage()));
                return;
              }/*else {
                if(userDoc.exists && me.company!=null) {
                  // ✅ User is in a company, send to Home
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => AccuChatDashboard()));
                  return;
                }
              }*/
            }






        /*if (APIs.me.companyId == null || APIs.me.companyId.isEmpty) {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => LandingPage()));
          return;
        }else{
          Get.offAll(() => ChatsHomeScreen());
        }*/

        // ✅ User is in a company, send to Home

        // Navigator.pushReplacement(context,
        //     MaterialPageRoute(builder: (_) => const ChatsHomeScreen()));
        } else {
        await APIs.createUser().then((value) async {
        await APIs.getSelfInfo();
        /*if (APIs.me.companyId == null || APIs.me.companyId.isEmpty) {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => LandingPage()));
          return;
        }else{
          Get.offAll(() => ChatsHomeScreen());
        }*/
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (!userDoc.exists) {
          // First-time user or deleted data
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (_) => LoginScreenG()));
          return;
        }
        else {
          ChatUser me = ChatUser.fromJson(userDoc.data()!);
          if(userDoc.exists/* && me.company==null*/){
            storage.write(isFirstTime, false);
            Get.offAll(()=>LandingPage());
            return;
          }/*else {
            if(userDoc.exists && me.company!=null) {
              // ✅ User is in a company, send to Home
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => AccuChatDashboard()));
              return;
            }
          }*/
        }

        // Get.offAllNamed(AppRoutes.home);
        });
        }

        storage.write(isFirstTimeChatKey, isFirstTimeChat);
        }
      });
    } catch (e) {
      setState(() {
        isFill = false;
      });
      Get.snackbar("Error", "Invalid OTP",backgroundColor: Colors.red,colorText: Colors.white);
    }
  }


  // handles google login button click
  _handleGoogleBtnClick() {
    //for showing progress bar
    Dialogs.showProgressBar(context);

    _signInWithGoogle(context).then((user) async {
      //for hiding progress bar
      Navigator.pop(context);

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
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (_) => LoginScreenG()));
            return;
          }
          else {
            ChatUser me = ChatUser.fromJson(userDoc.data()!);
            if(userDoc.exists/* && me.company==null*/){
              storage.write(isFirstTime, false);
              Navigator.pushReplacement(
                  context, MaterialPageRoute(builder: (_) => LandingPage()));
              return;
            }/*else {
              if(userDoc.exists && me.company!=null) {
                // ✅ User is in a company, send to Home
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => AccuChatDashboard()));
                return;
              }
            }*/
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
              Navigator.pushReplacement(
                  context, MaterialPageRoute(builder: (_) => LoginScreenG()));
              return;
            }
            else {
              ChatUser me = ChatUser.fromJson(userDoc.data()!);

              if(userDoc.exists/* && me.company==null*/){
                storage.write(isFirstTime, false);
                Get.offAll(()=>LandingPage());
                return;
              }/*else {
                if(userDoc.exists && me.company!=null) {
                  // ✅ User is in a company, send to Home
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => AccuChatDashboard()));
                  return;
                }
              }*/
            }


            // Get.offAllNamed(AppRoutes.home);
          });
        }

        storage.write(isFirstTimeChatKey, isFirstTimeChat);
      }
    });
  }

  Future<User?> _signInWithGoogle(BuildContext context) async {
    try {
      final googleUser = await GoogleSignIn().signIn();

      if (googleUser == null) {
        // User canceled sign-in
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Google sign-in cancelled")),
        );
        return null;
      }

      final googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
        accessToken: googleAuth.accessToken,
      );

      final userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);

      final user = userCredential.user;

      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Sign-in failed: No user found")),
        );
        return null;
      }

      // Debug prints
      print("✅ Google Sign-In Success");
      print("Email: ${user.email}");
      print("Name: ${user.displayName}");
      print("UID: ${user.uid}");

      return user;
    } catch (e, s) {
      print('❌ Google Sign-In Error: $e');
      print('📍 Stack: $s');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Google Sign-in error: $e")),
      );
      return null;
    }
  }
  String countryCodeVal = '+91';
  @override
  Widget build(BuildContext context) {
    //initializing media query (for getting device screen size)
    // mq = MediaQuery.of(context).size;

    return Scaffold(
      //app bar
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Welcome to AccuChat'),
      ),

      //body
      body: SafeArea(
        child: Stack(children: [
          //app logo
          AnimatedPositioned(
              top:- mq.height * .01,
              right: _isAnimate ? mq.width * .3 : -mq.width * .5,
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
                    hintText: "Phone".tr,
                    controller: phoneController,
                    textInputType: TextInputType.number,
              
                    onFieldSubmitted: (String? value) {
                      FocusScope.of(Get.context!).unfocus();
                    },
                    labletext: "Phone",
              
                    prefix: Container(
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
                            barrierColor: Colors.black26,
                            boxDecoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(0)
                            ),
              
                            onChanged: (value) {
                              countryCodeVal = value.dialCode.toString();
                              setState(() {
              
                              });
                            })),
                    validator: (value) {
                      return value?.validateMobile(phoneController.text);
                    },
                  ),
                  vGap(20),
                  dynamicButton(
                      name: "Send OTP",
                      onTap: () {
                      sendOTP();
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
                              _handleGoogleBtnClick();
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
      ),
    );
  }


  _policyText(){
    return Text.rich(
            TextSpan(
                text: "By continuing with Google Sign-In, you agree to our  ".tr,
                style: BalooStyles.baloonormalTextStyle(size: 14,color: Colors.black54),
                children: [
                  TextSpan(
                    text: "Privacy Policy.".tr,
                    recognizer: new TapGestureRecognizer()
                      ..onTap = () {
                        Get.to(() => HtmlViewer(
                          htmlContent: pvcContent,
                        ));
                      },
                    style: BalooStyles.baloomediumTextStyle(size: 14,color: appColorGreen),
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


  Widget _bottomSheetWidget(context) {
    return  SafeArea(
      child: StatefulBuilder(
        builder: (context,setState) {
          return SingleChildScrollView(
                  child: Column(
                    children: [
                      vGap(30),
                      Text(
                        'We have sent an OTP on your registered mobile number please enter below!',
                        style:  BalooStyles.baloosemiBoldTextStyle(),
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
                          lineStrokeCap: StrokeCap.square
                        ),
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
                            verifyOTP();
                          }
                        },
                      ).paddingSymmetric(horizontal: 5, vertical: 35),

/*
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
*/
                      resendOTPView(context),
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
                      isFill?IndicatorLoading():   GradientButton(
                        onTap: isFill
                            ? () {
                          if (formGlobalKey.currentState?.validate() ?? false) {
                            SystemChannels.textInput.invokeMethod('TextInput.hide');
                            setState(() {isFill = true;});
                            verifyOTP();
                          }
                        }
                            :() {},
                        btnColor: isFill
                            ? AppTheme.appColor:
                        Colors.grey.shade300,
                        name: 'Submit',
                      ).marginOnly(bottom: 80,left: 20,right: 20),
                      /*  Stack(
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
                                      onTap:*//* controller.isFill
                                          ? () {
                                        if (formGlobalKey.currentState?.validate() ?? false) {
                                          controller.hitOtpAPI(otp:controller.otpVal );
                                        }
                                      }
                                          : *//*() {},
                                      btnColor: *//*controller.isFill
                                          ? appColor*//*
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
                    ),*/
                    ],
                  ).marginSymmetric(horizontal: 20,vertical: 15),
                );
        }
      ),
    );

  }

  Widget resendOTPView(context) {
    return Column(
      children: [
        Text.rich(
          TextSpan(
              text: "Didn't receive the OTP? ".tr,
              style:
              BalooStyles.balooregularTextStyle(color: AppTheme.greyText),
              children: [
                TextSpan(
                  text: "Resend Now".tr,
                  recognizer: new TapGestureRecognizer()
                    ..onTap =
                    enableResend ? resendCode : null,
                  style: BalooStyles.balooregularTextStyle(color:  enableResend ? AppTheme.appColor : Colors.grey.shade400),
        
                ),
              ]),
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ).paddingSymmetric(vertical: 30, horizontal: 0),
        
        // Text(secondsRemaining.toString(),style: BalooStyles.baloosemiBoldTextStyle(color: Colors.red),)
      ],
    );
  }

  titleSubtileView(context) {
    return Text.rich(
      TextSpan(
          text: "Please Check your Phone. We've sent you the code at",
          style: BalooStyles.balooregularTextStyle(color: AppTheme.greyText),
          children: [
            TextSpan(
              text: " ${phoneController.text ?? ""}",
              style: BalooStyles.balooboldTitleTextStyle(),
            ),
          ]),
      textAlign: TextAlign.center,
      style: const TextStyle(
        color: Colors.black,
        fontSize: 16,
        fontWeight: FontWeight.w400,
      ),
    );
  }
}
