import 'dart:async';

import 'package:AccuChat/main.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../../../../../../Services/APIs/local_keys.dart';
import '../../../../../../Services/APIs/post/post_api_service_impl.dart';
import '../../../../../Home/Models/company_mem_res_model.dart';
import '../../../../../Home/Presentation/Controller/company_service.dart';
import '../../../../models/chat_user.dart';
import '../../../../models/get_company_res_model.dart';
import '../../../auth/models/get_uesr_Res_model.dart';

class AllUserController extends GetxController{
  AllUserController();
  // int page =1;
  String? isRecent ='true';
  // void onSearch(String query) {
  //   searchQuery = query.toLowerCase();
  //   filteredList = userList.where((item) {
  //     return (item.displayName??'').toLowerCase().contains(searchQuery) ||
  //         (item.email??'').toLowerCase().contains(searchQuery)||
  //         (item.phone??'').toLowerCase().contains(searchQuery)
  //     ;
  //   }).toList();
  //
  //   update();
  // }

  getArguments(){
    if (kIsWeb) {
      isRecent = Get.parameters['isRecent'];
    } else if(Get.arguments!=null){
      isRecent = Get.arguments['isRecent'];
    }
  }
  getAllUsers(){
    if(isRecent == 'true' &&!isTaskMode){
      hitAPIToGetRecentChats(searchText);
    }else{
      hitAPIToGetMember();
    }
  }


  CompanyData? myCompany = CompanyData();
  _getCompany()async{
    final svc = CompanyService.to;
    myCompany = svc.selected;
  }

  UserDataAPI? me = UserDataAPI();
  _getMe(){
    me = getUser();
    update();
  }

  bool isLoading = false;




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
      hitAPIToGetMember(search: searchText.isEmpty ? null : searchText,);
    });
  }

  scrollListener() {
    if (kIsWeb) {
      scrollController.addListener(() {
        if (scrollController.position.pixels >=
            scrollController.position.maxScrollExtent - 100 &&
            !isPageLoading && hasMore) {
          // resetPaginationForNewChat();
          hitAPIToGetMember();
        }
      });
    } else {
      scrollController.addListener(() {
        if (!scrollController.hasClients) return;

        final position = scrollController.position;

        if (position.maxScrollExtent >0) {
          if (!isPageLoading && hasMore) {
            hitAPIToGetMember();
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
  List<UserDataAPI> members=[];

  hitAPIToGetMember({search}) async {
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
      members=value.data?.records??[];
      if (members != null && (members ?? []).isNotEmpty) {
        if (page == 1) {
          filteredList.assignAll(members??[]);

        } else {
          filteredList.addAll(members??[]);
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


  hitAPIToGetRecentChats(String? searchT) async {
    isLoading=true;
    update();
    Get.find<PostApiServiceImpl>()
        .getRecentChatUserApiCall(comId:myCompany?.companyId,page: page,searchText: searchT??'')
        .then((value) async {
      isLoading = false;
      members = value.data?.rows??[];
      filteredList.value = members;
      update();
    }).onError((error, stackTrace) {
      isLoading = false;
      update();
    });
  }


  @override
  void onInit() {
    super.onInit();
    scrollController = ScrollController();
    getArguments();
    scrollListener();
    _getCompany();
    _getMe();

    Future.delayed(const Duration(milliseconds: 400),(){
      getAllUsers();
    });


  }



}