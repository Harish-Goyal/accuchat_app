

import 'package:dio/dio.dart';

import '../../../Screens/Authentication/AuthResponseModel/loginResModel.dart';
import '../success_res_model.dart';

abstract class AuthenticationApi {
  Future<LoginResModel> loginApiCall({FormData? dataBody});

  // Future<OTPResModel> googleLoginApiCall(
  //     {Map<String, dynamic>? dataBody});
  Future<LoginResModel> logoutApiCall({FormData? dataBody});
//   // Future<RegisterModel> registerApiCall({Map<String, dynamic>? dataBody});
//   Future<ForgotResModel> forgotPassApiCall({Map<String, dynamic>? dataBody,required String secretKey});
//   Future<SuccessResponseModel> sendOtpApiCall({Map<String, dynamic>? dataBody,required String secretKey});
//   Future<SuccessResponseModel> resetPasswordApiCall({Map<String, dynamic>? dataBody,required String secretKey});

}
