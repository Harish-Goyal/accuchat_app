import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dio/dio.dart' as multi;
import '../../../../../../Services/APIs/post/post_api_service_impl.dart';
import '../../../../../../main.dart';
import '../../../../../../routes/app_routes.dart';
import '../../../../../../utils/custom_flashbar.dart';
import '../../../../../../utils/helper_widget.dart';
import '../../../../../Home/Presentation/Controller/company_service.dart';
import '../../../../models/group_res_model.dart';
import '../../../../models/get_company_res_model.dart';
import '../../../../models/recent_task_user_Res.dart';
import '../../../auth/models/get_uesr_Res_model.dart';


class TaskHomeController extends GetxController{

  bool isTask = false;
  // for storing search status
  RxBool isSearching = false.obs;
  TextEditingController seacrhCon = TextEditingController();
  FocusNode searchFocus = FocusNode();
  String searchQuery = '';
  Rxn<UserDataAPI> selectedChat = Rxn<UserDataAPI>();

  Future<void> onCompanyChanged() async => hitAPIToGetRecentTasksUser();

  @override
  void onInit() {
    super.onInit();
    getCompany();

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
  getCompany(){
    final svc = CompanyService.to;
    myCompany = svc.selected;
    update();
    if (!svc.hasCompany){
      Get.offAllNamed(AppRoutes.landing_r);
      return;
    }
  }

  int page =1;
  RxBool isLoading =false.obs;
  RxBool showPostShimmer =false.obs;
  RxBool isPageLoading =false.obs;
  RxBool hasMore = true.obs;
  RecentTaskUserData recentTasksUserResModel = RecentTaskUserData();

  ScrollController scrollController = ScrollController();

  scrollListener() {
    if (kIsWeb) {
      scrollController.addListener(() {
        if (scrollController.position.pixels >=
            scrollController.position.maxScrollExtent - 100 &&
            !isPageLoading.value && hasMore.value) {
          // resetPaginationForNewChat();
          hitAPIToGetRecentTasksUser();
        }
      });
    } else {
      scrollController.addListener(() {
        if (!scrollController.hasClients) return;

        final position = scrollController.position;

        if (position.maxScrollExtent >0) {
          if (!isPageLoading.value && hasMore.value) {
            hitAPIToGetRecentTasksUser();
          }
        }
      });
    }
  }
  List<UserDataAPI>? recentTaskUserList=[];



  void resetPaginationForNewChat() {
    page = 1;
    hasMore.value = true;
    filteredList.clear();
    showPostShimmer.value = true;
    isPageLoading.value = false;
    // update();
  }

  List<UserDataAPI>? recentChatUserList=[];

  hitAPIToGetRecentTasksUser({String? search}) async {
    if(page==1){
      showPostShimmer.value = true;
      filteredList.clear();
    }
    isPageLoading.value = true;
    update();
    Get.find<PostApiServiceImpl>()
        .getRecentTaskUserApiCall(comId:myCompany?.companyId,page: page,searchText: search??'')
        .then((value) async {
      isLoading.value = false;
      update();
      recentTasksUserResModel=value;
      recentTaskUserList=value.data?.rows??[];
      if (value.data?.rows != null && (value.data?.rows ?? []).isNotEmpty) {
        if (page == 1) {
          filteredList.assignAll(recentTaskUserList??[]);
        } else {
          filteredList.addAll(recentTaskUserList??[]);
        }
        if(selectedChat.value?.userId!=null){

        }else{
          selectedChat.value = filteredList[0];
        }
        page++; // next page
      } else {
        hasMore.value = false;
        isPageLoading.value = false;
      }
      showPostShimmer.value = false;
      isPageLoading.value = false;
      update();

    }).onError((error, stackTrace) {
      showPostShimmer.value = false;
      isPageLoading.value = false;
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


  Timer? searchDelay;
  void onSearch(String query) {
    searchDelay?.cancel();
    searchDelay = Timer(const Duration(milliseconds: 400), () {
      searchQuery = query.trim().toLowerCase();
      page = 1;
      hasMore.value = false;
      filteredList.clear();
      update();
      hitAPIToGetRecentTasksUser(search: searchQuery.isEmpty ? null : searchQuery);
    });
  }


}