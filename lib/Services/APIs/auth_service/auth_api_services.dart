

import 'package:dio/dio.dart';

import '../../../Screens/Authentication/AuthResponseModel/loginResModel.dart';
import '../../../Screens/Chat/screens/auth/models/get_uesr_Res_model.dart';
import '../success_res_model.dart';

abstract class AuthenticationApi {
  Future<LoginResModel> loginApiCall({Map<String,dynamic>? dataBody});
  Future<LoginResModel> signupApiCall({Map<String,dynamic>? dataBody});
  Future<LoginResModel> verifyOtpApiCall({Map<String,dynamic>? dataBody});
  Future<LoginResModel> resentOtpApiCall({Map<String,dynamic>? dataBody});
  Future<LoginResModel> logoutApiCall({FormData? dataBody});
  Future<GetUserResModel> getUserApiCall({Map<String, dynamic>? dataBody,companyId});
  Future<GetUserResModel> updateUserApiCall({FormData? dataBody});

}
