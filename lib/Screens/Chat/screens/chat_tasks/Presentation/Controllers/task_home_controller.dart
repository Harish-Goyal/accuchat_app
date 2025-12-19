import 'package:AccuChat/Screens/Chat/models/recent_chat_user_res_model.dart';
import 'package:AccuChat/Screens/Chat/screens/chat_tasks/Presentation/Controllers/task_controller.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:AccuChat/Screens/Home/Presentation/Controller/home_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dio/dio.dart' as multi;
import 'package:http_parser/http_parser.dart';
import '../../../../../../Services/APIs/local_keys.dart';
import '../../../../../../Services/APIs/post/post_api_service_impl.dart';
import '../../../../../../main.dart';
import '../../../../../../utils/custom_flashbar.dart';
import '../../../../../Home/Presentation/Controller/company_service.dart';
import '../../../../api/apis.dart';
import '../../../../models/chat_user.dart';
import '../../../../models/group_res_model.dart';
import '../../../../models/get_company_res_model.dart';
import '../../../../models/recent_task_user_Res.dart';
import '../../../auth/models/get_uesr_Res_model.dart';


class TaskHomeController extends GetxController{

  bool isTask = false;
  // for storing search status
  RxBool isSearching = false.obs;
  TextEditingController seacrhCon = TextEditingController();
  String searchQuery = '';
  Rxn<UserDataAPI> selectedChat = Rxn<UserDataAPI>();

  Future<void> onCompanyChanged() async => hitAPIToGetRecentTasksUser();

  final dash = Get.put(DashboardController());
  @override
  void onInit() {
    super.onInit();
    _getCompany();

    Future.delayed(const Duration(milliseconds: 500),(){
      resetPaginationForNewChat();
      hitAPIToGetRecentTasksUser();
    }
    );
    scrollListener();

    // SystemChannels.lifecycle.setMessageHandler((message) {
    //   if (APIs.auth.currentUser != null) {
    //     if (message.toString().contains('resume')) {
    //       // APIs.updateActiveStatus(true);
    //     }
    //     if (message.toString().contains('pause')) {
    //       // APIs.updateActiveStatus(false);
    //     }
    //   }
    //
    //   return Future.value(message);
    // });


  }

  CompanyData? myCompany = CompanyData();
  _getCompany(){
    final svc = CompanyService.to;
    myCompany = svc.selected;
    update();


  }

  int page =1;
  bool isLoading =false;
  bool showPostShimmer =false;
  bool isPageLoading =false;
  bool hasMore = true;
  RecentTaskUserData recentTasksUserResModel = RecentTaskUserData();

  ScrollController scrollController = ScrollController();

  scrollListener() {
    if (kIsWeb) {
      scrollController.addListener(() {
        if (scrollController.position.pixels >=
            scrollController.position.maxScrollExtent - 100 &&
            !isPageLoading && hasMore) {
          // resetPaginationForNewChat();
          hitAPIToGetRecentTasksUser();
        }
      });
    } else {
      scrollController.addListener(() {
        if (scrollController.position.pixels <=
            scrollController.position.minScrollExtent + 50 &&
            !isPageLoading&& hasMore ) {
          // resetPaginationForNewChat();
          hitAPIToGetRecentTasksUser();
        }
      });
    }
  }
  List<UserDataAPI>? recentTaskUserList=[];

  void resetPaginationForNewChat() {
    page = 1;
    hasMore = true;
    filteredList.clear();
    showPostShimmer = true;
    update();
  }

  List<UserDataAPI>? recentChatUserList=[];

  hitAPIToGetRecentTasksUser({String? search}) async {
    if(page==1){
      showPostShimmer = true;
    }
    isPageLoading = true;
    update();
    Get.find<PostApiServiceImpl>()
        .getRecentTaskUserApiCall(comId:myCompany?.companyId,page: page,searchText: search??'')
        .then((value) async {
      isLoading = false;
      update();
      recentTasksUserResModel=value;
      recentTaskUserList=value.data?.rows??[];
      if (value.data?.rows != null && (value.data?.rows ?? []).isNotEmpty) {
        if (page == 1) {
          filteredList.value = value.data?.rows ?? [];
        } else {
          filteredList.assignAll(recentChatUserList??[]);
        }
        if(selectedChat.value?.userId!=null){

        }else{
          selectedChat.value = filteredList[0];
        }
        page++; // next page
      } else {
        hasMore = false;
        isPageLoading = false;
        update();
      }
      showPostShimmer = false;
      isPageLoading = false;
      update();
      // filteredList.assignAll(recentChatUserList??[]);
      // if(filteredList.isNotEmpty) {
      //   if(selectedChat.value?.userId!=null){
      //
      //   }else{
      //     selectedChat.value = filteredList[0];
      //   }
      //
      // }
      //
      //
      // final List<UserDataAPI> newItems = [];
      //
      // if (newItems.isNotEmpty) {
      //   page++;
      //   filteredList.addAll(newItems);
      //   if (newItems.length < 20) {
      //     hasMore = false;
      //   }
      //   update();
      // } else {
      //   hasMore = false;
      //   update();
      // }
    }).onError((error, stackTrace) {
      showPostShimmer = false;
      isPageLoading = false;
      update();
    });
  }



/*  hitAPIToGetRecentTasksUser({search}) async {
    isLoading=true;
    update();
    Get.find<PostApiServiceImpl>()
        .getRecentTaskUserApiCall(comId:myCompany?.companyId,page: page)
        .then((value) async {
      isLoading = false;
      recentTasksUserResModel=value;
      recentTaskUserList=recentTasksUserResModel.data?.rows??[];
      filteredList.assignAll(recentTaskUserList??[]);

      if(filteredList.isNotEmpty) {
        if(selectedChat.value?.userId!=null){

        }else{
          selectedChat.value = filteredList[0];
        }
      }

      update();
      final List<UserDataAPI> newItems = [];

      if (newItems.isNotEmpty) {
        page++;
        filteredList.addAll(newItems);
        if (newItems.length < 20) {
          hasMore = false;
        }
        update();
      } else {
        hasMore = false;
        update();
      }

    }).onError((error, stackTrace) {
      isLoading = false;
      update();
    });
  }*/

  GroupResModel groupResModel = GroupResModel();
  createGroupBroadcastApi({isGroup,isBroadcast}) async {
    SystemChannels.textInput.invokeMethod('TextInput.hide');
    customLoader.show();
    var reqData = multi.FormData.fromMap({
      "company_id": myCompany?.companyId,
      "name":groupController.text,
      "is_group":isGroup,
      "is_broadcast": isBroadcast,
    });
    Get.find<PostApiServiceImpl>()
        .addEditGroupBroadcastApiCall(dataBody: reqData)
        .then((value) {
      customLoader.hide();
      Get.back();
      groupResModel = value;
      groupController.clear();
      toast(value.message??'');
      hitAPIToGetRecentTasksUser();
      update();
    }).onError((error, stackTrace) {
      update();
      Get.back();
      customLoader.hide();
      errorDialog(error.toString());
    }).whenComplete(() {});
  }

  TextEditingController groupController = TextEditingController();
  // List<dynamic> mergedList = [];
  final filteredList = <UserDataAPI>[].obs;

  DashboardController dashboardController = Get.put(DashboardController());

  void onSearch(String query) {
    searchQuery = query.toLowerCase();
    if (query.isEmpty) {
      hitAPIToGetRecentTasksUser();
      // filteredList.assignAll(recentTaskUserList ?? []);
    } else {
      // final result = recentTaskUserList!.where((item) {
      //   return (item.displayName ?? '').toLowerCase().contains(searchQuery) ||
      //       (item.email ?? '').toLowerCase().contains(searchQuery) ||
      //       (item.userName ?? '').toLowerCase().contains(searchQuery) ||
      //       (item.phone ?? '').contains(searchQuery);
      // }).toList();
      // filteredList.assignAll(result);
      hitAPIToGetRecentTasksUser(search:query);
    }
  }
}