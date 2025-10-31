import 'package:AccuChat/Screens/Chat/screens/auth/models/get_uesr_Res_model.dart';
import 'package:AccuChat/Screens/Chat/screens/chat_tasks/Presentation/Controllers/chat_screen_controller.dart';
import 'package:AccuChat/main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../../../../../../Services/APIs/local_keys.dart';
import '../../../../../../Services/APIs/post/post_api_service_impl.dart';
import '../../../../../../utils/custom_flashbar.dart';
import '../../../../../Home/Presentation/Controller/company_service.dart';
import '../../../../models/chat_user.dart';
import '../../../../models/get_company_res_model.dart';
import '../../../../models/group_mem_api_res.dart';
import 'members_gr_br_controller.dart';

class AddGroupMemController extends GetxController {
  UserDataAPI? group;

  @override
  void onInit() {
    super.onInit();
    getArguments();
    _getMe();
    _getCompany();
    hitAPIToGetMembers();
    hitAPIToAllGetMember();
  }

  getArguments() {
    if(kIsWeb){
      if (Get.parameters != null) {
        final String? argUserId = Get.parameters['groupChatId'];
        if (argUserId != null) {
          getUserByIdApi(userId: int.parse(argUserId??''));
        }
      }
    }else{
      if (Get.arguments != null) {
        group = Get.arguments['groupChat'];
      }
    }

  }


  getUserByIdApi({int? userId}) async {

    Get.find<PostApiServiceImpl>()
        .getUserByApiCall(userID: userId,comid: myCompany?.companyId)
        .then((value) async {
      group = value.data;
      update();
    }).onError((error, stackTrace) {
      update();
      errorDialog(error.toString());
    }).whenComplete(() {});
  }


  List<int> selectedUserIds = [];
  bool isLoading = false;

  List<int> adminIds = [];

  UserDataAPI? me = UserDataAPI();
  _getMe() async {
    me = await getUser();
    update();
  }

  CompanyData? myCompany = CompanyData();
  _getCompany() {
    final svc = Get.find<CompanyService>();
    myCompany = svc.selected;
    update();
  }

  List<UserDataAPI> allUsersList = [];

  hitAPIToAllGetMember() async {
    isLoading = true;
    update();
    Get.find<PostApiServiceImpl>()
        .getComMemApiCall(myCompany?.companyId)
        .then((value) async {
      isLoading = false;
      allUsersList = value.data ?? [];
      final filteredUsers = allUsersList.where((user) => !membersIds.contains(user.userId)).toList();
      allUsersList = filteredUsers;
      Get.find<GrBrMembersController>().hitAPIToGetMembers();
      // filteredList = userList;
      update();
    }).onError((error, stackTrace) {
      isLoading = false;
      update();
    });
  }

  hitAPIToAddMember({bool isGroup = false}) async {
    customLoader.show();
    Map<String, dynamic> req = {
      "group_id": group?.userCompany?.userCompanyId,
      "company_id": myCompany?.companyId,
      "member_id": selectedUserIds,
      "is_group": isGroup ? 1 : 0,
    };
    Get.find<PostApiServiceImpl>()
        .addMemberToGrBrApiCall(dataBody: req)
        .then((value) async {
          customLoader.hide();
         Get.find<ChatScreenController>().hitAPIToGetMembers();
         Get.find<GrBrMembersController>().hitAPIToGetMembers();
         Get.back();
      update();
    }).onError((error, stackTrace) {
      customLoader.hide();
    });
  }

  List<UserDataAPI> members = [];
  List<int> membersIds = [];
  hitAPIToGetMembers() async {
    isLoading = true;
    update();
    Get.find<PostApiServiceImpl>()
        .getGrBrMemberApiCall(id:
    group?.userCompany?.userCompanyId,mode: group?.userCompany?.isGroup==1?
    "group":"broadcast")
        .then((value) async {
      isLoading = false;
      members = value.data?.members??[];
      for(var i in members){
        membersIds.add(i.userId??0);
      }
      _compute();
      update();
    }).onError((error, stackTrace) {
      isLoading = false;
      update();
    });
  }


  int? currentUcId;

  String query = '';
  List<UserDataAPI> candidates = [];

  void setData({
    required List<UserDataAPI> all,
    required List<UserDataAPI> group,
    int? current,
  }) {
    allUsersList = all;
    members = group;
    me?.userCompany?.companyId = current;
    _compute();
  }

  void updateQuery(String q) {
    query = q;
    _compute();
  }

  void _compute() {
    final existing = members.map((m) => m.userCompany?.userCompanyId).toSet();
    if (currentUcId != null) existing.add(currentUcId!);

    var filtered = allUsersList.where((u) => !existing.contains(u.userCompany?.userCompanyId));

    final s = query.trim().toLowerCase();
    if (s.isNotEmpty) {
      filtered = filtered.where((u) {
        final name  = u.displayName?.toLowerCase();
        final phone = (u.phone ?? '').toLowerCase();
        final email = (u.email ?? '').toLowerCase();
        return (name??'').contains(s) || phone.contains(s) || email.contains(s);
      });
    }

    candidates = filtered.toList()
      ..sort((a, b) => (a.displayName??'').toLowerCase().compareTo((b.displayName??'').toLowerCase()));

    update(); // 🔑 rebuild GetBuilder
  }



}
