import 'dart:async';

import 'package:AccuChat/Screens/Chat/models/recent_chat_user_res_model.dart';
import 'package:AccuChat/Screens/Home/Presentation/Controller/socket_controller.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:AccuChat/Screens/Home/Presentation/Controller/home_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dio/dio.dart' as multi;
import '../../../../../../Services/APIs/post/post_api_service_impl.dart';
import '../../../../../../Services/storage_service.dart';
import '../../../../../../main.dart';
import '../../../../../../routes/app_routes.dart';
import '../../../../../../utils/custom_flashbar.dart';
import '../../../../../Home/Models/get_pending_sent_invites_res_model.dart';
import '../../../../../Home/Presentation/Controller/company_service.dart';
import '../../../../api/apis.dart';
import '../../../../models/chat_user.dart';
import '../../../../models/group_res_model.dart';
import '../../../../models/get_company_res_model.dart';
import '../../../auth/models/get_uesr_Res_model.dart';
import 'chat_screen_controller.dart';


class ChatHomeController extends GetxController{

  bool isTask = false;

  Rxn<UserDataAPI> selectedChat = Rxn<UserDataAPI>();

  List<ChatUser> list = [];
  List<ChatGroup> grouplist = [];
  final List<ChatUser> searchList = [];
  RxBool isSearching = false.obs;
  // RxBool loadingCompany = false.obs;
  String? selectedCompanyId;
  TextEditingController seacrhCon = TextEditingController();
  String searchQuery = '';
  Future<void> onCompanyChanged(int? companyId) async => hitAPIToGetRecentChats();

  final dash = Get.put(DashboardController());
  var selectedCompany = Rxn<CompanyData>();     // Rx nullable object
  var joinedCompaniesList = <CompanyData>[].obs; // Rx list
  var loadingCompany = false.obs;
  CompanyResModel companyResModel = CompanyResModel();
  hitAPIToGetCompanies() async {
    loadingCompany.value = true;
    Get.find<PostApiServiceImpl>()
        .getJoinedCompanyListApiCall()
        .then((value) async {
      loadingCompany.value = false;
      companyResModel = value;
      joinedCompaniesList.value = value.data ?? [];
      selectedCompany.value = joinedCompaniesList.firstWhere(
            (c) => c.companyId == myCompany?.companyId,  // already logged-in company
        orElse: () => joinedCompaniesList.first,
      );
      update();
    }).onError((error, stackTrace) {
      loadingCompany.value = false;
    });
  }


  @override
  void onInit() {

    getCompany();

    Future.delayed(const Duration(milliseconds: 200),(){
      resetPaginationForNewChat();
      hitAPIToGetRecentChats();
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
    // hitAPIToGetCompanies();
    super.onInit();
  }

  CompanyData? myCompany = CompanyData();
  getCompany(){
    if(Get.isRegistered<CompanyService>()) {
      final svc = CompanyService.to;
      myCompany = svc.selected;
      // selectedCompany.value = svc.selected;
      update();
    }

  }

  List<SentInvitesData> sentInviteList = [];

  bool isLoadingPending = true;

  hitAPIToGetSentInvites(
      {CompanyData? companyData, bool isMember = false}) async {
    isLoadingPending = true;
    update();
    await Get.find<PostApiServiceImpl>()
        .getPendingSentInvitesApiCall(companyData?.companyId)
        .then((value) async {
      isLoadingPending = false;
      sentInviteList = value.data ?? [];
    }).onError((error, stackTrace) {
      toast(error.toString());
      customLoader.hide();
    });
  }

  int page =1;
  bool isLoading =false;
  bool isPageLoading =false;
  bool hasMore = true;
  RecentChatsUserResModel recentChatsUserResModel = RecentChatsUserResModel();
  bool showPostShimmer = true;

  ScrollController scrollController = ScrollController();

  scrollListener() {
    if (kIsWeb) {
      scrollController.addListener(() {
        if (scrollController.position.pixels >=
            scrollController.position.maxScrollExtent - 100 &&
            !isPageLoading && hasMore) {
          // resetPaginationForNewChat();
          hitAPIToGetRecentChats();
        }
      });
    } else {
      scrollController.addListener(() {
        if (scrollController.position.pixels <=
            scrollController.position.minScrollExtent + 50 &&
            !isPageLoading&& hasMore ) {
          // resetPaginationForNewChat();
          hitAPIToGetRecentChats();
        }
      });
    }
  }
  void resetPaginationForNewChat() {
    page = 1;
    hasMore = true;
    filteredList.clear();
    showPostShimmer = true;
    update();
  }

  List<UserDataAPI>? recentChatUserList=[];




  hitAPIToGetRecentChats({String? search}) async {
    if(page==1){
      showPostShimmer = true;
    }
    isPageLoading = true;
    update();
    Get.find<PostApiServiceImpl>()
        .getRecentChatUserApiCall(comId:myCompany?.companyId,page: page,searchText: search??'')
        .then((value) async {
      isLoading = false;
      update();
      recentChatsUserResModel=value;
      recentChatUserList=value.data?.rows??[];
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
        // Get.find<ChatScreenController>().openConversation(selectedChat.value);
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
      update();
    });
  }

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
      Get.find<SocketController>().connectUserEmitter(myCompany?.companyId);
      Get.back();
      groupResModel = value;
      groupController.clear();
      toast(value.message??'');
      hitAPIToGetRecentChats();
      update();
    }).onError((error, stackTrace) {
      update();
      Get.back();
      customLoader.hide();
      errorDialog(error.toString());
    }).whenComplete(() {});
  }

  TextEditingController groupController = TextEditingController();
  DashboardController dashboardController = Get.put(DashboardController());

  // List<dynamic> mergedList = [];
  var filteredList = <UserDataAPI>[].obs;






  Timer? searchDelay;
  void onSearch(String query) {
    searchDelay?.cancel();
    searchDelay = Timer(const Duration(milliseconds: 400), () {
      searchQuery = query.trim().toLowerCase();
      page = 1;
      hasMore = true;
      filteredList.clear();
      update();
      hitAPIToGetRecentChats(search: searchQuery.isEmpty ? null : searchQuery);
    });
  }


}


class AuthGuard extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {

    final String? token = StorageService.getToken();
    final bool loggedIn = StorageService.isLoggedInCheck();

    debugPrint("token=======================");
    debugPrint(token);
    debugPrint(loggedIn.toString());

    if (token == null) return const RouteSettings(name: AppRoutes.login_r);
    if (!loggedIn)   return const RouteSettings(name: AppRoutes.landing_r);
    return null; // allow
  }
}