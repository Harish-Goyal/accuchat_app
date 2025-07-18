import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_disposable.dart';
import '../../../Screens/Authentication/AuthResponseModel/loginResModel.dart';
import '../../../main.dart';
import '../../network_exception.dart';
import '../api_ends.dart';
import '../dio_client.dart';
import '../local_keys.dart';
import '../success_res_model.dart';
import 'auth_api_services.dart';
class AuthApiServiceImpl extends GetxService
    implements AuthenticationApi {
  late DioClient? dioClient;
  var deviceName, deviceType, deviceID;

  getDeviceData() async {
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
  }

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
      {FormData? dataBody}) async {
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
Future<LoginResModel> logoutApiCall({FormData? dataBody}) async {
  var token = await storage.read(LOCALKEY_token);
  try {
    final response = await dioClient!
        .post(ApiEnd.logoutEnd, data: dataBody, skipAuth: false);
    return LoginResModel.fromJson(response);
  } catch (e) {
    return Future.error(NetworkExceptions.getDioException(e));
  }
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
