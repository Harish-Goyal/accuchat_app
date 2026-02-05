import 'package:AccuChat/Services/APIs/api_ends.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
// import 'package:otp_text_field/otp_field.dart';
import '../../../../Services/APIs/auth_service/auth_api_services_impl.dart';
import '../../../../Services/APIs/local_keys.dart';
import '../../../../main.dart';
import '../../../../routes/app_routes.dart';
import '../../../../utils/custom_flashbar.dart';
import '../../AuthResponseModel/loginResModel.dart';
import '../view/otp_verify_screen.dart';
import 'package:dio/dio.dart' as multi;

class LoginController extends GetxController {
  late TextEditingController phoneController;
  late TextEditingController codeController;
  late TextEditingController passwordController;
  late FocusNode phoneFocusNode;
  late FocusNode codeFocusNode;
  late FocusNode passwordFocusNode;
  String errorEmail = '';
  String errorPassword = '';
  String selectedloginType = 'Login with Appcode';

  String deviceName = '';
  String deviceID = '';
  String deviceType = '';
  int type = 0;
  int secondsRemaining = 30;
  bool enableResend = true;
  bool obsecurePassword = true;
  bool isRememberMe = false;
  bool isChecked = false;
  bool isFill = false;
  String otpVal = '';
  ImageProvider? logo;
  LoginResModel loginResponseModel = LoginResModel();
  UserData? userData = UserData();
  String countryCodeVal = '+91';

  @override
  void onInit() {
    phoneController = TextEditingController();
    passwordController = TextEditingController();
    codeController = TextEditingController();
    phoneFocusNode = FocusNode();
    passwordFocusNode = FocusNode();
    codeFocusNode = FocusNode();

    super.onInit();
  }



  updateChecked(val) {
    isChecked = !isChecked;
    update();
  }



  @override
  void onReady() {}

  /*===================================================================== Password Visibility ==========================================================*/
  showOrHidePasswordVisibility() {
    obsecurePassword = !obsecurePassword;
    update();
  }


  hitGoogleAPIToLogin(
      {firstName, lastName, email, profile, dob, address, phone}) {
    customLoader.show();
    FocusManager.instance.primaryFocus!.unfocus();
    var loginReq = {
      "first_name": firstName,
      "last_name": lastName,
      "email": email,
      "profile_img": profile,
      "phone": phone,
      "address": address,
      "birthday": dob,
      "profile_url": profile
    };
    // Get.find<AuthApiServiceImpl>()
    //     .googleLoginApiCall(dataBody: loginReq)
    //     .then((value) async {
    //   customLoader.hide();
    //   // otpResModel = value;
    //   // setUserData(
    //   //     id: otpResModel.users?.id.toString() ?? '',
    //   //     firstName: otpResModel.users?.firstName ?? '',
    //   //     lastname: otpResModel.users?.lastName ?? '',
    //   //     email: otpResModel.users?.email ?? '',
    //   //     phone: otpResModel.users?.phone ?? '',
    //   //     address: otpResModel.users?.address ?? '',
    //   //     dob: otpResModel.users?.birthday ?? '',
    //   //     photo: otpResModel.users?.profileUrl ?? '', gender:  otpResModel.users?.user_gender ?? '');
    //   saveData();
    // }).onError((error, stackTrace) {
    //   customLoader.hide();
    //   errorDialog(error.toString());
    // });
  }

  hitApiToVerifyOtp({otp}) {
    customLoader.show();
    FocusManager.instance.primaryFocus!.unfocus();
    var loginReq = {
      "phone_number": phoneController.text.trim().toLowerCase(),
      "otp_number": otp
    };

    // Get.find<AuthApiServiceImpl>()
    //     .verifyOtpApi(dataBody: loginReq)
    //     .then((value) async {
    //   customLoader.hide();
    //   // otpResModel = value;
    //   //
    //   // setUserData(
    //   //     id: otpResModel.users?.id.toString() ?? '',
    //   //     firstName: otpResModel.users?.firstName ?? '',
    //   //     lastname: otpResModel.users?.lastName ?? '',
    //   //     email: otpResModel.users?.email ?? '',
    //   //     phone: otpResModel.users?.phone ?? '',
    //   //     address: otpResModel.users?.address ?? '',
    //   //     dob: otpResModel.users?.birthday ?? '',
    //   //     photo: otpResModel.users?.profileUrl ?? '', gender: otpResModel.users?.user_gender?? '');
    //   //
    //   // saveData();
    //   // toast(otpResModel.message);
    // }).onError((error, stackTrace) {
    //   customLoader.hide();
    //   errorDialog(error.toString());
    // });
  }

  openBottomSheet() {
    // timer = Timer.periodic(const Duration(seconds: 1), (_) {
    //   if (secondsRemaining != 0) {
    //     secondsRemaining--;
    //     update();
    //   } else {
    //     enableResend = true;
    //     update();
    //   }
    // });
    Get.bottomSheet(
      BottomSheetWidget(),

      backgroundColor: Colors.white,
      // barrierColor: Colors.red[50],
      isDismissible: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20), topRight: Radius.circular(20)),
          side: BorderSide(width: 5, color: Colors.white)),
      enableDrag: false,
    );
  }

  @override
  void dispose() {
    // timer?.cancel();
    super.dispose();
  }

  void resendCode() {
    // secondsRemaining = 30;
    // enableResend = false;
    // hitAPIToLogin();
  }



  // handles google login button click
/*  handleGoogleBtnClick(context) {
    // customLoader.show();
    signInWithGoogle(context).then((user) async {
      //for hiding progress bar
      Get.back();

      if (user != null) {
        debugPrint('\nUser: ${user.displayName}');
        debugPrint('\nUserAdditionalInfo: ${user.email}');

        hitGoogleAPIToLogin(
            firstName: user.displayName,
            lastName: "",
            email: user.email,
            profile: user.photoURL,
            phone: user.phoneNumber,
            dob: "",
            address: "");
        // saveData();
        // if ((await APIs.userExists())) {
        //   Get.offAllNamed(AppRoutes.hotelHomeScreen);
        // } else {
        //   await APIs.createUser().then((value) {
        //     Get.offAllNamed(AppRoutes.hotelHomeScreen);
        //   });
        // }
      }
    });
  }

  Future<User?> signInWithGoogle(BuildContext context) async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      final GoogleSignInAccount? googleSignInAccount =
          await googleSignIn.signIn();
      if (googleSignInAccount != null) {
        final GoogleSignInAuthentication googleSignInAuthentication =
            await googleSignInAccount.authentication;
        final AuthCredential authCredential = GoogleAuthProvider.credential(
            idToken: googleSignInAuthentication.idToken,
            accessToken: googleSignInAuthentication.accessToken);

        // Getting users credential
        UserCredential result =
            await APIs.auth.signInWithCredential(authCredential);
        User? user = result.user;

        if (result != null) {
          debugPrint("email =========>  ${user?.email}");
          debugPrint("name =========>  ${user?.displayName}");
          debugPrint("uid =========>  ${user?.uid}");
          debugPrint("refreshToken =========>  ${user?.refreshToken}");
          debugPrint("getIdToken =========>  ${await user?.getIdToken()}");
          // print("=========> name ${user?.uid}");
          return user;
          // Navigator.pushReplacement(
          //     context, MaterialPageRoute(builder: (context) => H()));
        } // if result not null we simply call the MaterialpageRoute,
        // for go to the HomePage screen
      }
    } catch (e) {
      errorDialog("Something went wrong");
    }
    return null;
  }

  // sign out function
  googleSignOut() async {
    await FirebaseAuth.instance.signOut();
    await GoogleSignIn().signOut();
  }*/
}
