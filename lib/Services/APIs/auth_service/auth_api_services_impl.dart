import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_disposable.dart';
import '../../../Screens/Authentication/AuthResponseModel/loginResModel.dart';
import '../../../Screens/Chat/screens/auth/models/get_uesr_Res_model.dart';
import '../../../main.dart';
import '../../network_exception.dart';
import '../api_ends.dart';
import '../dio_client.dart';
import '../local_keys.dart';
import '../success_res_model.dart';
import 'auth_api_services.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;
class AuthApiServiceImpl extends GetxService
    implements AuthenticationApi {
  late DioClient? dioClient;
  // var deviceName, deviceType, deviceID;

  Future<Map<String, dynamic>> getDeviceData() async {
    if (kIsWeb) {
      // ✅ No dart:io calls here
      return {
        'platform': 'web',
        'os': 'web',
        'device': 'browser',
        // keep keys your backend expects, but fill with web-safe values
      };
    }

    // ✅ Mobile/desktop only
    final os = Platform.operatingSystem;         // 'android', 'ios', 'windows', etc.
    final isAndroid = Platform.isAndroid;
    final isIOS = Platform.isIOS;

    return {
      'platform': isAndroid ? 'android' : (isIOS ? 'ios' : os),
      'os': os,
      'device': isAndroid ? 'android-phone' : (isIOS ? 'iphone' : 'desktop'),
    };
  }

/*  getDeviceData() async {
    DeviceInfoPlugin info = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      AndroidDeviceInfo androidDeviceInfo = await info.androidInfo;
      deviceName = androidDeviceInfo.model;
      deviceID = androidDeviceInfo.device;
      deviceType = "Android";
      debugPrint("deviceName ===== ${deviceName}");
      debugPrint("deviceID ===== ${deviceID}");
      debugPrint("deviceType ===== ${deviceType}");
    } else if (Platform.isIOS) {
      IosDeviceInfo iosDeviceInfo = await info.iosInfo;
      deviceName = iosDeviceInfo.model;
      deviceID = iosDeviceInfo.identifierForVendor!;
      deviceType = "Ios";
      debugPrint("deviceName ===== ${deviceName}");
      debugPrint("deviceID ===== ${deviceID}");
      debugPrint("deviceType ===== ${deviceType}");
    }
  }*/

  @override
  void onInit() {
    super.onInit();
    var dio = Dio();
    dioClient = DioClient(ApiEnd.baseUrl, dio);
    getDeviceData();
  }

/*===================================================================== login API Call  ==========================================================*/
  @override
  Future<LoginResModel> loginApiCall(
      {Map<String,dynamic>? dataBody}) async {
    try {
      final response = await dioClient!.post(ApiEnd.loginEnd,
          data: dataBody,
          // skipAuth: true
          );
      return LoginResModel.fromJson(response);
    } catch (e) {
      return Future.error(NetworkExceptions.getDioException(e));
    }
  }


  @override
  Future<LoginResModel> resentOtpApiCall({Map<String, dynamic>? dataBody}) {
    // TODO: implement resentOtpApiCall
    throw UnimplementedError();
  }

  @override
  Future<LoginResModel> signupApiCall({Map<String, dynamic>? dataBody}) async{
    try {
      final response = await dioClient!.post(ApiEnd.signupEnd,
        data: dataBody,
        skipAuth: true
      );
      return LoginResModel.fromJson(response);
    } catch (e) {
      return Future.error(NetworkExceptions.getDioException(e));
    }
  }

  @override
  Future<LoginResModel> verifyOtpApiCall({Map<String, dynamic>? dataBody})async {
    try {
      final response = await dioClient!.post(ApiEnd.verifyOtpEnd,
          data: dataBody,
          skipAuth: true
      );
      return LoginResModel.fromJson(response);
    } catch (e) {
      return Future.error(NetworkExceptions.getDioException(e));
    }
  }
  @override
  Future<GetUserResModel> getUserApiCall({Map<String, dynamic>? dataBody,companyId}) async {
    try {
      final response = await dioClient!.get("${ApiEnd.getUserEnd}/$companyId",
          skipAuth: false
      );
      return GetUserResModel.fromJson(response);
    } catch (e) {
      return Future.error(NetworkExceptions.getDioException(e));
    }
  }


  @override
  Future<GetUserResModel> updateUserApiCall({FormData? dataBody}) async {
    try {
      final response = await dioClient!.post(ApiEnd.updateUserEnd,
          skipAuth: false,
        data: dataBody
      );
      return GetUserResModel.fromJson(response);
    } catch (e) {
      return Future.error(NetworkExceptions.getDioException(e));
    }
  }

  @override
  Future<LoginResModel> logoutApiCall({FormData? dataBody}) {
    // TODO: implement logoutApiCall
    throw UnimplementedError();
  }


  // @override
  // Future<OTPResModel> verifyOtpApi(
  //     {Map<String, dynamic>? dataBody}) async {
  //   try {
  //     final response = await dioClient!.post(ApiEnd.otpEnd,
  //         data: dataBody,
  //       skipAuth: true
  //         );
  //     return OTPResModel.fromJson(response);
  //   } catch (e) {
  //     return Future.error(NetworkExceptions.getDioException(e));
  //   }
  // }
  //
  // @override
  // Future<OTPResModel> googleLoginApiCall(
  //     {Map<String, dynamic>? dataBody}) async {
  //   try {
  //     final response = await dioClient!.post(ApiEnd.googleLoginEnd,
  //         data: dataBody,
  //         );
  //     return OTPResModel.fromJson(response);
  //   } catch (e) {
  //     return Future.error(NetworkExceptions.getDioException(e));
  //   }
  // }
  //
  // @override
  // Future<ForgotResModel> forgotPassApiCall({Map<String, dynamic>? dataBody, required String secretKey})async {
  //   try {
  //     final response = await dioClient!.post(ApiEnd.forgotEnd,
  //         data: dataBody,
  //         options: Options(headers: {"secret_key": secretKey}));
  //     return ForgotResModel.fromJson(response);
  //   } catch (e) {
  //     return Future.error(NetworkExceptions.getDioException(e));
  //   }
  // }

  // @override
  // Future<SuccessResponseModel> sendOtpApiCall({Map<String, dynamic>? dataBody, required String secretKey}) async{
  //   try {
  //     final response = await dioClient!.post(ApiEnd.otpEnd,
  //         data: dataBody,
  //         options: Options(headers: {"secret_key": secretKey}));
  //     return SuccessResponseModel.fromJson(response);
  //   } catch (e) {
  //     return Future.error(NetworkExceptions.getDioException(e));
  //   }
  // }

  // @override
  // Future<SuccessResponseModel> resetPasswordApiCall({Map<String, dynamic>? dataBody, required String secretKey}) async{
  //   try {
  //     final response = await dioClient!.post(ApiEnd.resetEnd,
  //         data: dataBody,
  //         options: Options(headers: {"secret_key": secretKey}));
  //     return SuccessResponseModel.fromJson(response);
  //   } catch (e) {
  //     return Future.error(NetworkExceptions.getDioException(e));
  //   }
  // }


/*===================================================================== registr API Call  ==========================================================*/
// Future<LoginResponseModel> registerApiCall(
//     {Map<String, dynamic>? dataBody}) async {
//   try {
//     final response = await dioClient!.post(ApiEnd.signup, data: dataBody);
//     return LoginResponseModel.fromJson(response);
//   } catch (e) {
//     return Future.error(NetworkExceptions.getDioException(e));
//   }
// }
//

// @override
// Future<UserModel> getProfileApiCall({var id}) async {
//   try {
//     final response =
//         await dioClient!.post(ApiEnd.getProfileEnd + id, skipAuth: false);
//     return UserModel.fromJson(response);
//   } catch (e) {
//     return Future.error(NetworkExceptions.getDioException(e));
//   }
// }
}
