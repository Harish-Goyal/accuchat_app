import 'package:dio/dio.dart';
import '../success_res_model.dart';

abstract class PostApiService {
  Future<SuccessResponseModel> changePasswordApiCall({FormData? dataBody});


}
