import 'package:AccuChat/Screens/chat_module/models/getGroupResModel.dart';
import 'package:AccuChat/Screens/chat_module/presentation/controllers/user_chat_list_controller.dart';
import 'package:AccuChat/Services/APIs/Chat_service/chat_api_servcie_impl.dart';
import 'package:AccuChat/routes/app_routes.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart' as multi;

import '../../../../utils/custom_flashbar.dart';
import '../../models/user_chat_list_model.dart';

// Controller
class GroupController extends GetxController {
  void toggleSelect(GroupMemberData? member) {
    member?.isSelectedmember = !member.isSelectedmember; // Toggle the value
    update();
  }

  String groupMembersID = '';
  var selectedMemberIds = '';
  var selectedMemberIdsAdds = '';


  String searchQuary = "";

  late TextEditingController searchMemController;

  void updateSelectedIds() {
    final selectedIds = (membersList ?? [])
        .where((member) => member.isSelectedmember)
        .map((member) => member.user?.userId)
        .join(',');
    selectedMemberIds = selectedIds;
    update();
  }

  GroupMemeberResModel groupMemeberResModel = GroupMemeberResModel();

  List<GroupMemberData>? membersList;

  var createById;
  var groupID;
  var groupName;
  var isGroup;

  bool showPostShimmer = true;
  bool isLoading = false;
  bool isSubmit = false;

  @override
  void onInit() {
    searchMemController =TextEditingController();
    createById = Get.arguments?["created_by_id"];


    groupID = Get.arguments?["group_id"];
    groupName = Get.arguments?["groupName"];
    isGroup = Get.arguments?["is_group"];
    getGroupMembersAPI();


    super.onInit();
  }

  getGroupMembersAPI({groupId}) {
    var reqData = multi.FormData.fromMap({
      // "auth_key": ApiEnd.authKEy,
      "id": groupId ?? groupID,
      "user_name":"",
    });

    Get.find<ChatApiServiceImpl>()
            .getGroupMembersApi(dataBody: reqData)
            .then((value) {
      showPostShimmer = false;
      groupMemeberResModel = value;
      membersList = groupMemeberResModel.body;
      updateSelectedIds();
      update();
    }).onError((error, stackTrace) {
      showPostShimmer = false;
      errorDialog(error.toString());
    }) /*.whenComplete((){
      getOfflineHistory();
    })*/
        ;
  }

  addRemoveGroupMemAPI({groupId, memberIds}) {
    isLoading = true;
    update();
    var reqData = multi.FormData.fromMap({
      // "auth_key": ApiEnd.authKEy,
      "id": groupId ?? groupID,
      "member_id": memberIds,
      "user_id": createById,
      "is_group":isGroup.toString()=="1"?"1":"0",
    });

    Get.find<ChatApiServiceImpl>()
        .addRemoveGroupMembersApi(dataBody: reqData)
        .then((value) {
      isLoading = false;
      update();
    }).onError((error, stackTrace) {
      isLoading = false;
      update();
      errorDialog(error.toString());
    }).whenComplete(() {
      getGroupMembersAPI();
    });
  }




  void toggleSelectAdd(UserChatListData? member) {
    member?.isSelected = !member.isSelected; // Toggle the value
    update();
  }


  void updateSelectedIdsAdds() {
    final selectedIds =(Get.find<UserChatListController>().chatList??[])
        .where((member) => member.isSelected)
        .map((member) => member.userId)
        .join(',');
    selectedMemberIdsAdds = selectedIds;
    update();
  }

  List<UserChatListData> get filteredUsers {
    final groupMemberIds =( membersList??[]).map((member) => member.user?.userId?.toString()).toSet();
    return (Get.find<UserChatListController>().chatList??[]).where((user) => !groupMemberIds.contains(user.userId.toString())&& user.isGroup==null ).toList();
  }



}
