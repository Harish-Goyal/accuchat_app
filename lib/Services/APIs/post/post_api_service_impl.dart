import 'package:AccuChat/Screens/Chat/models/all_media_res_model.dart';
import 'package:AccuChat/Screens/Chat/models/group_mem_api_res.dart';
import 'package:AccuChat/Screens/Chat/models/task_res_model.dart';
import 'package:AccuChat/Screens/Chat/models/task_status_res_model.dart';
import 'package:AccuChat/Screens/Chat/screens/auth/models/pending_invites_res_model.dart';
import 'package:AccuChat/Screens/Chat/models/recent_chat_user_res_model.dart';
import 'package:AccuChat/Services/APIs/post/post_api_service.dart';
import 'package:AccuChat/Services/APIs/success_res_model.dart';
import 'package:dio/dio.dart' as httpdio;
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import '../../../Screens/Chat/models/accept_invite_res.dart';
import '../../../Screens/Chat/models/chat_history_response_model.dart';
import '../../../Screens/Chat/models/get_single_company_res.dart';
import '../../../Screens/Chat/models/group_res_model.dart';
import '../../../Screens/Chat/models/media_res_model.dart';
import '../../../Screens/Chat/models/create_company_res.dart';
import '../../../Screens/Chat/models/get_company_res_model.dart';
import '../../../Screens/Chat/models/recent_task_user_Res.dart';
import '../../../Screens/Chat/models/single_task_response.dart';
import '../../../Screens/Chat/models/single_user_by_id_res_model.dart';
import '../../../Screens/Chat/models/task_attachment_res_model.dart';
import '../../../Screens/Chat/models/task_commets_res_model.dart';
import '../../../Screens/Home/Models/all_member_res_model.dart';
import '../../../Screens/Home/Models/company_mem_res_model.dart';
import '../../../Screens/Home/Models/get_pending_sent_invites_res_model.dart';
import '../../../Screens/Home/Models/push_register_res_model.dart';
import '../../../Screens/Settings/Model/get_company_roles_res_moel.dart';
import '../../../Screens/Settings/Model/get_nav_permission_res_model.dart';
import '../../../main.dart';
import '../../network_exception.dart';
import '../api_ends.dart';
import '../dio_client.dart';

import '../local_keys.dart';

class PostApiServiceImpl extends GetxService implements PostApiService {
  late DioClient? dioClient;


  @override
  void onInit() {
    super.onInit();
    var dio = Dio();
    dioClient = DioClient(ApiEnd.baseUrl, dio);
    // getDeviceData();
  }



  @override
  Future<CompanyResModel> getJoinedCompanyListApiCall() async {
    try {
      final response =
      await dioClient!.get(ApiEnd.companyListEnd, skipAuth: false);
      return CompanyResModel.fromJson(response);
    } catch (e) {
      return Future.error(NetworkExceptions.getDioException(e));
    }
  }

  @override
  Future<GetSingleCompanyRes> getCompanyByIdApiCall(comId) async {
    try {
      final response =
      await dioClient!.get("${ApiEnd.companyListEnd}/$comId", skipAuth: false);
      return GetSingleCompanyRes.fromJson(response);
    } catch (e) {
      return Future.error(NetworkExceptions.getDioException(e));
    }
  }

  @override
  Future<PendingInvitesResModel> pendingInviteListApiCall({userInput}) async {
    try {
      final response = await dioClient!.get(ApiEnd.pendingInvitesEnd,
          skipAuth: false, queryParameters: {'userInput': userInput});
      return PendingInvitesResModel.fromJson(response);
    } catch (e) {
      return Future.error(NetworkExceptions.getDioException(e));
    }
  }

  @override
  Future<AllMemberResModel> getAllMembersApiCall({comid}) async {
    try {
      final response = await dioClient!.get("api/company/$comid/members",
          skipAuth: false);
      return AllMemberResModel.fromJson(response);
    } catch (e) {
      return Future.error(NetworkExceptions.getDioException(e));
    }
  }

  @override
  Future<PendingSentInvitesResModel> getPendingSentInvitesApiCall(comId) async {
    try {
      final response = await dioClient!.get(ApiEnd.sentInviteListEnd,
          skipAuth: false,queryParameters: {"company_id":comId});
      return PendingSentInvitesResModel.fromJson(response);
    } catch (e) {
      return Future.error(NetworkExceptions.getDioException(e));
    }
  }

  @override
  Future<SuccessResponseModel> deleteSentInvitesApiCall(inviteID) async {
    try {
      final response = await dioClient!.delete("${ApiEnd.deleteSentInviteEnd}$inviteID",
          skipAuth: false);
      return SuccessResponseModel.fromJson(response);
    } catch (e) {
      return Future.error(NetworkExceptions.getDioException(e));
    }
  }

  @override
  Future<AcceptInviteRes> acceptInviteApiCall({id}) async {
    try {
      final response = await dioClient!.post('${ApiEnd.acceptInviteEnd}$id',
          skipAuth: false);
      return AcceptInviteRes.fromJson(response);
    } catch (e) {
      return Future.error(NetworkExceptions.getDioException(e));
    }
  }

  @override
  Future<CreateCompanyResModel> createCompanyAPICall(
      {required httpdio.FormData dataBody}) async {
    try {
      final response = await dioClient!
          .post(ApiEnd.createCompanyEnd, skipAuth: false, data: dataBody);
      return CreateCompanyResModel.fromJson(response);
    } catch (e) {
      return Future.error(NetworkExceptions.getDioException(e));
    }
  }

  @override
  Future<TaskAttachmentResModel> uplaodTaskAttachmentsAPICall(
      {required httpdio.FormData dataBody}) async {
    try {
      final response = await dioClient!
          .post(ApiEnd.uploadTaskMediaEnd, skipAuth: false, data: dataBody);
      return TaskAttachmentResModel.fromJson(response);
    } catch (e) {
      return Future.error(NetworkExceptions.getDioException(e));
    }
  }


  @override
  Future<SuccessResponseModel> sendInvitesToJoinCompanyAPI(
      {required Map<String, dynamic> dataBody}) async {
    try {
      final response = await dioClient!
          .post(ApiEnd.sendInvitesEnd, skipAuth: false, data: dataBody);

      return SuccessResponseModel.fromJson(response);
    } catch (e) {
      return Future.error(NetworkExceptions.getDioException(e));
    }
  }

  @override
  Future<SuccessResponseModel> createRoleApiCall(
      {Map<String, dynamic>? dataBody}) async {
    try {
      final response = await dioClient!
          .post(ApiEnd.addRoleEnd, skipAuth: false, data: dataBody);

      return SuccessResponseModel.fromJson(response);
    } catch (e) {
      return Future.error(NetworkExceptions.getDioException(e));
    }
  }

  @override
  Future<NavPermissionResModel> getNavigationPermissionApiCall() async {
    try {
      final response = await dioClient!
          .get(ApiEnd.navigationPermissionEnd, skipAuth: false,
     );

      return NavPermissionResModel.fromJson(response);
    } catch (e) {
      return Future.error(NetworkExceptions.getDioException(e));
    }
  }
  @override
  Future<NavPermissionResModel> getNavPerUSerApiCall({required int comId, required int userComId}) async {
    try {
      final response = await dioClient!
          .get(ApiEnd.userNAvEnd, skipAuth: false,
          queryParameters: {
            "company_id":comId,
            "user_company_role_id":userComId
          });
      return NavPermissionResModel.fromJson(response);
    } catch (e) {
      return Future.error(NetworkExceptions.getDioException(e));
    }
  }

  @override
  Future<GetCompanyRolesResModel> getCompanyRolesApiCall(companyId) async {
    try {
      final response = await dioClient!
          .get('${ApiEnd.companyRolesEnd}$companyId', skipAuth: false);

      return GetCompanyRolesResModel.fromJson(response);
    } catch (e) {
      return Future.error(NetworkExceptions.getDioException(e));
    }
  }

  @override
  Future<SuccessResponseModel> updateRoleApiCall({Map<String,dynamic>? dataBody,roleId}) async {
    try {
      final response = await dioClient!
          .post('${ApiEnd.updateRoleEnd}$roleId', skipAuth: false,data: dataBody);
      return SuccessResponseModel.fromJson(response);
    } catch (e) {
      return Future.error(NetworkExceptions.getDioException(e));
    }
  }

  @override
  Future<SuccessResponseModel> removeComMemberApiCall({compId,memberId}) async {
    try {
      final response = await dioClient!
          .delete('api/company/$compId/member/$memberId', skipAuth: false);
      return SuccessResponseModel.fromJson(response);
    } catch (e) {
      return Future.error(NetworkExceptions.getDioException(e));
    }
  }




  @override
  Future<SuccessResponseModel> deleteCompanyApiCall({compId}) async {
    try {
      final response = await dioClient!
          .delete('api/company/delete/$compId', skipAuth: false);
      return SuccessResponseModel.fromJson(response);
    } catch (e) {
      return Future.error(NetworkExceptions.getDioException(e));
    }
  }


  @override
  Future<ComMemResModel> getComMemApiCall(compId,page,searchText) async {
    try {
      final response = await dioClient!
          .get('api/company/active-members/$compId',
          queryParameters: {
            "page":page,
            "limit":10,
            "search":searchText,
          },
          skipAuth: false);
      return ComMemResModel.fromJson(response);
    } catch (e) {
      return Future.error(NetworkExceptions.getDioException(e));
    }
  }

  @override
  Future<TaskMemResponse> getTaskMemberApiCall(taskId) async {
    try {
      final response = await dioClient!
          .get('api/tasks/members/$taskId', skipAuth: false);
      return TaskMemResponse.fromJson(response);
    } catch (e) {
      return Future.error(NetworkExceptions.getDioException(e));
    }
  }

  @override
  Future<RecentChatsUserResModel> getRecentChatUserApiCall(
      {comId, page,searchText}) async {
    try {
      final response = await dioClient!
          .get('api/recent?company_id=$comId&page=$page&limit=10&search=$searchText', skipAuth: false);
      return RecentChatsUserResModel.fromJson(response);
    } catch (e) {
      return Future.error(NetworkExceptions.getDioException(e));
    }
  }

  @override
  Future<RecentTaskUserData> getRecentTaskUserApiCall(
      {comId, page,searchText}) async {
    try {
      final response = await dioClient!
          .get('api/taskslist/recent?company_id=$comId&page=$page&limit=10&search=$searchText', skipAuth: false);
      return RecentTaskUserData.fromJson(response);
    } catch (e) {
      return Future.error(NetworkExceptions.getDioException(e));
    }
  }

  @override
  Future<ChatHisResModelAPI> getChatHistoryApiCall(
      {userComId, page,searchText}) async {
    try {
      final response = await dioClient!
          .get('api/chat-history/$userComId?page=$page&limit=20&text=$searchText', skipAuth: false);
      return ChatHisResModelAPI.fromJson(response);
    } catch (e) {
      return Future.error(NetworkExceptions.getDioException(e));
    }
  }

  @override
  Future<TaskCommentsResModel> getCommentsOnTaskApiCall(
      {taskId, page,companyId}) async {
    try {
      final response = await dioClient!
          .get('api/tasks/$taskId/comments',
          queryParameters: {
            'company_id':companyId,
            'page':page,
            'limit':15,
          },
          skipAuth: false);
      return TaskCommentsResModel.fromJson(response);
    } catch (e) {
      return Future.error(NetworkExceptions.getDioException(e));
    }
  }

  @override
  Future<TaskHisResModel> getTaskHistoryApiCall(
      {userComId, page,statusId,String? fromDate, String? toDate, searchText}) async {
    try {
      final response = await dioClient!
          .get('api/task-history/$userComId',
          queryParameters: {
            'page':page,
            'limit':15,
            'statusId':statusId,
            'startDate':fromDate,
            'endDate':toDate,
            'text':searchText,
          },
          skipAuth: false);
      return TaskHisResModel.fromJson(response);
    } catch (e) {
      return Future.error(NetworkExceptions.getDioException(e));
    }
  }

  @override
  Future<GroupResModel> addEditGroupBroadcastApiCall({httpdio.FormData? dataBody}) async{
    try {
      final response = await dioClient!
          .post(ApiEnd.addEditGroupAndBroadcastEnd, skipAuth: false,data:dataBody );
      return GroupResModel.fromJson(response);
    } catch (e) {
      return Future.error(NetworkExceptions.getDioException(e));
    }
  }

  @override
  Future<MediaResModel> uploadMediaApiCall({httpdio.FormData? dataBody}) async{
    try {
      final response = await dioClient!
          .post(ApiEnd.uploadMediaEnd, skipAuth: false,data:dataBody );
    return MediaResModel.fromJson(response);
    } catch (e) {
      return Future.error(NetworkExceptions.getDioException(e));
    }
  }

  @override
  Future<GroupMemberAPIRes> getGrBrMemberApiCall({id,mode}) async{
    try {
      final response = await dioClient!
          .get("${ApiEnd.groupBrMemEnd}$id?mode=$mode", skipAuth: false );
    return GroupMemberAPIRes.fromJson(response);
    } catch (e) {
      return Future.error(NetworkExceptions.getDioException(e));
    }
  }

  @override
  Future<TaskStatusResModel> getTaskStatusApiCall() async{
    try {
      final response = await dioClient!
          .get(ApiEnd.taskStatusEnd, skipAuth: false );
    return TaskStatusResModel.fromJson(response);
    } catch (e) {
      return Future.error(NetworkExceptions.getDioException(e));
    }
  }

  @override
  Future<SingleTaskRes> getTaskByIdApiCall(taskId) async{
    try {
      final response = await dioClient!
          .get("${ApiEnd.getTaskEnd}/$taskId", skipAuth: false );
    return SingleTaskRes.fromJson(response);
    } catch (e) {
      return Future.error(NetworkExceptions.getDioException(e));
    }
  }
  @override
  Future<SuccessResponseModel> addMemberToGrBrApiCall({Map<String, dynamic>? dataBody}) async{
    try {
      final response = await dioClient!
          .post(ApiEnd.addMember, skipAuth: false,data: dataBody );
    return SuccessResponseModel.fromJson(response);
    } catch (e) {
      return Future.error(NetworkExceptions.getDioException(e));
    }
  }

  @override
  Future<SuccessResponseModel> deleteGrBrApiCall({Map<String, dynamic>? dataBody}) async{
    try {
      final response = await dioClient!
          .post(ApiEnd.deleteGroupBroadcast, skipAuth: false,data: dataBody );
    return SuccessResponseModel.fromJson(response);
    } catch (e) {
      return Future.error(NetworkExceptions.getDioException(e));
    }
  }

  @override
  Future<SuccessResponseModel> deleteUserAccountApiCall({userID}) async {
    try {
      final response = await dioClient!.delete("${ApiEnd.getUserEnd}/$userID/delete",
          skipAuth: false
      );
      return SuccessResponseModel.fromJson(response);
    } catch (e) {
      return Future.error(NetworkExceptions.getDioException(e));
    }
  }


  @override
  Future<SingleUserResModel> getUserByApiCall({userID,comid}) async {
    try {
      final response = await dioClient!.get("api/users/$userID",
          skipAuth: false,
        queryParameters: {
        "company_id":comid
        }
      );
      return SingleUserResModel.fromJson(response);
    } catch (e) {
      return Future.error(NetworkExceptions.getDioException(e));
    }
  }




  @override
  Future<PushResgisterResModel> registerPushTokenApiCall({Map<String, dynamic>? dataBody}) async {
    try {
      final response = await dioClient!.post(ApiEnd.pushRegisterEnd,
          skipAuth: false,
        data: dataBody
      );
      return PushResgisterResModel.fromJson(response);
    } catch (e) {
      return Future.error(NetworkExceptions.getDioException(e));
    }
  }
  @override
  Future<SuccessResponseModel> unregisterPushTokenApiCall({Map<String, dynamic>? dataBody}) async {
    try {
      final response = await dioClient!.post(ApiEnd.pushUnregisterEnd,
          skipAuth: false,
        data: dataBody
      );
      return SuccessResponseModel.fromJson(response);
    } catch (e) {
      return Future.error(NetworkExceptions.getDioException(e));
    }
  }

  @override
  Future<AllMediaResModel> getAllMediaAPI({int? page,int? userCId,int? comId,String? mediaType,String? source}) async {
    try {
      final response = await dioClient!.get("api/user-media",
          skipAuth: false,
       queryParameters: {
        "page":page,
         "page_size":10,
         "media_type":mediaType,
         "source":source,
         "company_id":comId,
         "peer_user_company_id":userCId,
       }
      );
      return AllMediaResModel.fromJson(response);
    } catch (e) {
      return Future.error(NetworkExceptions.getDioException(e));
    }
  }


}
