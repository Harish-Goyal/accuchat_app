import 'package:AccuChat/Screens/chat_module/models/chat_history_model.dart';
import 'package:AccuChat/Screens/chat_module/models/getGroupResModel.dart';
import 'package:AccuChat/Screens/chat_module/models/user_chat_list_model.dart';
import 'package:AccuChat/Services/APIs/Chat_service/chat_api.dart';
import 'package:AccuChat/Services/APIs/chat_dio_client.dart';
import 'package:AccuChat/Services/APIs/success_res_model.dart';
import 'package:dio/dio.dart' as httpdio;
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import '../../network_exception.dart';
import '../api_ends.dart';

class ChatApiServiceImpl extends GetxService implements ChatApiService {
  late ChatDioClient? dioClient;
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
    dioClient = ChatDioClient(ApiEnd.baseUrlChat, dio);
    // getDeviceData();
  }

  @override
  Future<UserChatListResModel> getUserChatListApi(
      {httpdio.FormData? dataBody}) async {

    try {
      final response = await dioClient!
          .post(ApiEnd.getUserChatListEnd, data: dataBody, skipAuth: false);
      UserChatListResModel chatListResModel =
          UserChatListResModel.fromJson(response);

      return UserChatListResModel.fromJson(response);
    } catch (e) {
      return Future.error(NetworkExceptions.getDioException(e));
    }
  }

  @override
  Future<ChatHistoryResModel> getUserChatHistoryApi(
      {httpdio.FormData? dataBody}) async {

    try {
      final response = await dioClient!
          .post(ApiEnd.getUserChatHistoryEnd, data: dataBody, skipAuth: false);
      return ChatHistoryResModel.fromJson(response);
    } catch (e) {
      return Future.error(NetworkExceptions.getDioException(e));
    }
  }

  @override
  Future<GroupMemeberResModel> getGroupMembersApi(
      {httpdio.FormData? dataBody}) async {

    try {
      final response = await dioClient!
          .post(ApiEnd.getGroupMemberEnd, data: dataBody, skipAuth: false);
      return GroupMemeberResModel.fromJson(response);
    } catch (e) {
      return Future.error(NetworkExceptions.getDioException(e));
    }
  }

  @override
  Future<SuccessResponseModel> editGroupMembersApi(
      {httpdio.FormData? dataBody}) async {

    try {
      final response = await dioClient!
          .post(ApiEnd.getEditGroupEnd, data: dataBody, skipAuth: false);
      return SuccessResponseModel.fromJson(response);
    } catch (e) {
      return Future.error(NetworkExceptions.getDioException(e));
    }
  }

  @override
  Future<SuccessResponseModel> addRemoveGroupMembersApi(
      {httpdio.FormData? dataBody}) async {

    try {
      final response = await dioClient!
          .post(ApiEnd.getaddEditGroupMemberEnd, data: dataBody, skipAuth: false);
      return SuccessResponseModel.fromJson(response);
    } catch (e) {
      return Future.error(NetworkExceptions.getDioException(e));
    }
  }
  @override
  Future<SuccessResponseModel> deleteGroupOrMemberApi(
      {httpdio.FormData? dataBody}) async {

    try {
      final response = await dioClient!
          .post(ApiEnd.getDeleteGroupEnd, data: dataBody, skipAuth: false);
      return SuccessResponseModel.fromJson(response);
    } catch (e) {
      return Future.error(NetworkExceptions.getDioException(e));
    }
  }

  @override
  Future<SuccessResponseModel> updateProfileApi(
      {httpdio.FormData? dataBody}) async {

    try {
      final response = await dioClient!
          .post(ApiEnd.updateProfileEnd, data: dataBody, skipAuth: false);
      return SuccessResponseModel.fromJson(response);
    } catch (e) {
      return Future.error(NetworkExceptions.getDioException(e));
    }
  }

  // @override
  // Future<GetProfileResModel> getProfileApi(
  //     {httpdio.FormData? dataBody}) async {
  //
  //   try {
  //     final response = await dioClient!
  //         .post(ApiEnd.getProfileEnd, data: dataBody, skipAuth: false);
  //     return GetProfileResModel.fromJson(response);
  //   } catch (e) {
  //     return Future.error(NetworkExceptions.getDioException(e));
  //   }
  // }
}
