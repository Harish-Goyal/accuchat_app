import 'package:AccuChat/Screens/Chat/models/chat_history_response_model.dart';
import 'package:AccuChat/Screens/Chat/models/recent_chat_user_res_model.dart';
import 'package:dio/dio.dart';
import '../../../Screens/Chat/models/accept_invite_res.dart';
import '../../../Screens/Chat/models/all_media_res_model.dart';
import '../../../Screens/Chat/models/get_single_company_res.dart';
import '../../../Screens/Chat/models/group_mem_api_res.dart';
import '../../../Screens/Chat/models/group_res_model.dart';
import '../../../Screens/Chat/models/media_res_model.dart';
import '../../../Screens/Chat/models/create_company_res.dart';
import '../../../Screens/Chat/models/get_company_res_model.dart';
import '../../../Screens/Chat/models/recent_task_user_Res.dart';
import '../../../Screens/Chat/models/single_task_response.dart';
import '../../../Screens/Chat/models/single_user_by_id_res_model.dart';
import '../../../Screens/Chat/models/task_attachment_res_model.dart';
import '../../../Screens/Chat/models/task_commets_res_model.dart';
import '../../../Screens/Chat/models/task_res_model.dart';
import '../../../Screens/Chat/models/task_status_res_model.dart';
import '../../../Screens/Chat/screens/auth/models/pending_invites_res_model.dart';
import '../../../Screens/Home/Models/all_member_res_model.dart';
import '../../../Screens/Home/Models/company_mem_res_model.dart';
import '../../../Screens/Home/Models/create_folder_res_model.dart';
import '../../../Screens/Home/Models/get_folder_items_res_model.dart';
import '../../../Screens/Home/Models/get_folder_res_model.dart';
import '../../../Screens/Home/Models/get_pending_sent_invites_res_model.dart';
import '../../../Screens/Home/Models/push_register_res_model.dart';
import '../../../Screens/Settings/Model/get_company_roles_res_moel.dart';
import '../../../Screens/Settings/Model/get_nav_permission_res_model.dart';
import '../success_res_model.dart';

abstract class PostApiService {
  Future<CompanyResModel> getJoinedCompanyListApiCall();
  Future<PendingInvitesResModel> pendingInviteListApiCall({userInput});
  Future<CreateCompanyResModel> createCompanyAPICall(
      {required FormData dataBody});
  Future<SuccessResponseModel> sendInvitesToJoinCompanyAPI(
      {required Map<String, dynamic> dataBody});
  Future<AcceptInviteRes> acceptInviteApiCall({id});
  Future<SuccessResponseModel> createRoleApiCall(
      {Map<String, dynamic>? dataBody});
  Future<NavPermissionResModel> getNavigationPermissionApiCall();
  Future<GetCompanyRolesResModel> getCompanyRolesApiCall(companyId);
  Future<SuccessResponseModel> removeComMemberApiCall({compId, memberId});
  Future<PendingSentInvitesResModel> getPendingSentInvitesApiCall(comId);
  Future<MediaResModel> uploadMediaApiCall({FormData? dataBody});
  Future<SuccessResponseModel> deleteSentInvitesApiCall(inviteID);
  Future<GroupResModel> addEditGroupBroadcastApiCall(
      {required FormData dataBody});
  Future<ComMemResModel> getComMemApiCall(comId,page,searchText);
  Future<RecentChatsUserResModel> getRecentChatUserApiCall({comId, page});
  Future<ChatHisResModelAPI> getChatHistoryApiCall(
      {userComId, page, searchText});
  Future<SuccessResponseModel> updateRoleApiCall(
      {Map<String, dynamic>? dataBody, roleId});
  Future<GroupMemberAPIRes> getGrBrMemberApiCall({id, mode});
  Future<SuccessResponseModel> addMemberToGrBrApiCall(
      {Map<String, dynamic>? dataBody});
  Future<SuccessResponseModel> deleteGrBrApiCall(
      {Map<String, dynamic>? dataBody});
  Future<SuccessResponseModel> deleteUserAccountApiCall({userID});
  Future<TaskStatusResModel> getTaskStatusApiCall();
  Future<NavPermissionResModel> getNavPerUSerApiCall(
      {required int comId, required int userComId});
  Future<SuccessResponseModel> deleteCompanyApiCall({compId});
  Future<TaskAttachmentResModel> uplaodTaskAttachmentsAPICall(
      {required FormData dataBody});
  Future<TaskHisResModel> getTaskHistoryApiCall({userComId, page, statusId,searchText});

  Future<RecentTaskUserData> getRecentTaskUserApiCall(
      {comId, page, searchText});

  Future<TaskCommentsResModel> getCommentsOnTaskApiCall(
      {taskId, page, companyId});

  Future<GetSingleCompanyRes> getCompanyByIdApiCall(comId);

  Future<SingleUserResModel> getUserByApiCall({userID, comid});

  Future<SingleTaskRes> getTaskByIdApiCall(taskId);

  Future<TaskMemResponse> getTaskMemberApiCall(taskId);
  Future<PushResgisterResModel> registerPushTokenApiCall(
      {Map<String, dynamic>? dataBody});
  Future<SuccessResponseModel> unregisterPushTokenApiCall(
      {Map<String, dynamic>? dataBody});
  Future<AllMemberResModel> getAllMembersApiCall({comid});

  Future<AllMediaResModel> getAllMediaAPI({int? page,int? userCId,int? comId,String? mediaType,String? source});

  Future<GetFolderResModel> getFolderApiCall({ucId,page});
  Future<CreateFolderResModel> createFolderApiCall({required Map<String, dynamic> dataBody});
  Future<CreateFolderResModel> deleteFolderApiCall({required Map<String, dynamic> dataBody});
  Future<FolderItemsResModel> getFolderItemsApiCall({page,ucID,folderName});
}
