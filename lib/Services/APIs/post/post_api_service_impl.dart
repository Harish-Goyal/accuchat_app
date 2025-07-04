import 'package:AccuChat/Services/APIs/post/post_api_service.dart';
import 'package:AccuChat/Services/APIs/success_res_model.dart';
import 'package:dio/dio.dart' as httpdio;
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import '../../../main.dart';
import '../../network_exception.dart';
import '../api_ends.dart';
import '../dio_client.dart';

import '../local_keys.dart';

class PostApiServiceImpl extends GetxService implements PostApiService {
  late DioClient? dioClient;
  var deviceName, deviceType, deviceID;

  // To getting device type (Android or IOS)
  // getDeviceData() async {
  //   DeviceInfoPlugin info = DeviceInfoPlugin();
  //   if (Platform.isAndroid) {
  //     AndroidDeviceInfo androidDeviceInfo = await info.androidInfo;
  //     deviceName = androidDeviceInfo.model;
  //     deviceID = androidDeviceInfo.device;
  //     deviceType = "1";
  //   } else if (Platform.isIOS) {
  //     IosDeviceInfo iosDeviceInfo = await info.iosInfo;
  //     deviceName = iosDeviceInfo.model;
  //     deviceID = iosDeviceInfo.identifierForVendor;
  //     deviceType = "2";
  //   }
  // }

  @override
  void onInit() {
    super.onInit();
    var dio = Dio();
    dioClient = DioClient(ApiEnd.baseUrl, dio);
    // getDeviceData();
  }



  @override
  Future<SuccessResponseModel> changePasswordApiCall({httpdio.FormData? dataBody}) async {
    var token = await storage.read(LOCALKEY_token);
    try {
      final response = await dioClient!
          .post(ApiEnd.changePassEnd, data: dataBody, skipAuth: false);
      return SuccessResponseModel.fromJson(response);
    } catch (e) {
      return Future.error(NetworkExceptions.getDioException(e));
    }
  }

}
