import 'package:AccuChat/Screens/chat_module/models/chat_history_model.dart';
import 'package:AccuChat/Screens/chat_module/models/user_chat_list_model.dart';
import 'package:dio/dio.dart';

import '../../../Screens/chat_module/models/getGroupResModel.dart';
import '../success_res_model.dart';

abstract class ChatApiService {

  Future<UserChatListResModel> getUserChatListApi({FormData? dataBody});

  Future<ChatHistoryResModel> getUserChatHistoryApi({FormData? dataBody});

  Future<GroupMemeberResModel> getGroupMembersApi({FormData? dataBody});

  Future<SuccessResponseModel> editGroupMembersApi({FormData? dataBody});

  Future<SuccessResponseModel> addRemoveGroupMembersApi({FormData? dataBody});

  Future<SuccessResponseModel> deleteGroupOrMemberApi({FormData? dataBody});

  Future<SuccessResponseModel> updateProfileApi({FormData? dataBody});
  // Future<GetProfileResModel> getProfileApi({FormData? dataBody});

}
