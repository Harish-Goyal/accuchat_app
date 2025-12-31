import 'dart:async';
import 'package:AccuChat/Screens/Chat/screens/auth/models/get_uesr_Res_model.dart';
import 'package:AccuChat/Screens/Chat/screens/chat_tasks/Presentation/Controllers/chat_screen_controller.dart';
import 'package:AccuChat/main.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../../../../../../Services/APIs/local_keys.dart';
import '../../../../../../Services/APIs/post/post_api_service_impl.dart';
import '../../../../../../utils/custom_flashbar.dart';
import '../../../../../Home/Models/company_mem_res_model.dart';
import '../../../../../Home/Presentation/Controller/company_service.dart';
import '../../../../models/get_company_res_model.dart';
import 'members_gr_br_controller.dart';

class AddGroupMemController extends GetxController {
  UserDataAPI? group;

  @override
  void onInit() {
    super.onInit();
    scrollController = ScrollController();
    scrollListener();
    _getCompany();
    getArguments();
    _getMe();


  }

  getArguments() {
    if(kIsWeb){
      if (Get.parameters != null) {
         String? argUserId = Get.parameters['groupChatId'];
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
      hitAPIToGetMembers();

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
    final svc = CompanyService.to;
    myCompany = svc.selected;
    update();
  }



  late ScrollController scrollController;
  bool isPageLoading =false;
  bool hasMore =false;
  int page = 1;
  String searchText = '';

  RxBool isSearching = false.obs;
  Timer? searchDelay;
  void onSearch(String query) {
    searchDelay?.cancel();
    searchDelay = Timer(const Duration(milliseconds: 400), () {
      searchText = query.trim().toLowerCase();
      page = 1;
      hasMore = false;
      filteredList.clear();
      hitAPIToAllGetMember(search: searchText.isEmpty ? null : searchText,);
    });
  }

  scrollListener() {
    if (kIsWeb) {
      scrollController.addListener(() {
        if (scrollController.position.pixels >=
            scrollController.position.maxScrollExtent - 100 &&
            !isPageLoading && hasMore) {
          // resetPaginationForNewChat();
          hitAPIToAllGetMember();
        }
      });
    } else {
      scrollController.addListener(() {
        if (!scrollController.hasClients) return;

        final position = scrollController.position;

        if (position.maxScrollExtent >0) {
          if (!isPageLoading && hasMore) {
            hitAPIToAllGetMember();
          }
        }
      });
    }
  }
  void resetPaginationForNewChat() {
    page = 1;
    hasMore = true;
    members.clear();
    filteredList.clear();
    isLoading = true;
    update();
  }

  var filteredList = <UserDataAPI>[].obs;
  ComMemResModel comMemResModel = ComMemResModel();
  TextEditingController searchController = TextEditingController();

  hitAPIToAllGetMember({search}) async {

    if(page==1){
      isLoading = true;
      filteredList.clear();
    }
    isPageLoading = true;
    update();
    Get.find<PostApiServiceImpl>()
        .getComMemApiCall(myCompany?.companyId,page,search)
        .then((value) async {
      isLoading = false;
      update();
      comMemResModel=value;
      allUsersList=value.data?.records??[];
      if (allUsersList != null && (allUsersList ?? []).isNotEmpty) {
        if (page == 1) {
          filteredList.assignAll(allUsersList??[]);
          final filteredUsers = allUsersList.where((user) => !membersIds.contains(user.userId)).toList();
          filteredList.value = filteredUsers;
          Get.find<GrBrMembersController>().hitAPIToGetMembers();

        } else {
          filteredList.addAll(allUsersList??[]);
          final filteredUsers = allUsersList.where((user) => !membersIds.contains(user.userId)).toList();
          filteredList.value = filteredUsers;
          Get.find<GrBrMembersController>().hitAPIToGetMembers();
        }

        page++; // next page
      } else {
        hasMore = false;
        isPageLoading = false;
        update();
      }
      isLoading = false;
      isPageLoading = false;
      update();

    }).onError((error, stackTrace) {
      isLoading = false;
      isPageLoading = false;
      update();
      update();
    });
  }












  List<UserDataAPI> allUsersList = [];

/*  hitAPIToAllGetMember() async {
    isLoading = true;
    update();
    Get.find<PostApiServiceImpl>()
        .getComMemApiCall(myCompany?.companyId,1)
        .then((value) async {
      isLoading = false;

      allUsersList = value.data ?? [];
      final filteredUsers = allUsersList.where((user) => !membersIds.contains(user.userId)).toList();
      allUsersList = filteredUsers;
      Get.find<GrBrMembersController>().hitAPIToGetMembers();
      update();
    }).onError((error, stackTrace) {
      isLoading = false;
      update();
    });
  }*/

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
          toast("Member added!");hitAPIToAllGetMember();

         await Get.find<ChatScreenController>().hitAPIToGetMembers(group);
          await Get.find<GrBrMembersController>().hitAPIToGetMembers();
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
      hitAPIToAllGetMember();
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
