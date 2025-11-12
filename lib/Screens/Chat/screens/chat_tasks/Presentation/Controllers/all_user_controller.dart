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
  bool isSearching = false;
  TextEditingController seacrhCon = TextEditingController();
  String searchQuery = '';
  AllUserController();
  List<UserDataAPI> filteredList = [];
  int page =1;
  String? isRecent ='true';
  void onSearch(String query) {
    searchQuery = query.toLowerCase();
    filteredList = userList.where((item) {
      return (item.displayName??'').toLowerCase().contains(searchQuery) ||
          (item.email??'').toLowerCase().contains(searchQuery)||
          (item.phone??'').toLowerCase().contains(searchQuery)
      ;
    }).toList();

    update();
  }

  getArguments(){
    if (kIsWeb) {
      isRecent = Get.parameters['isRecent'];
    } else if(Get.arguments!=null){
      isRecent = Get.arguments['isRecent'];
    }
  }
  getAllUsers(){
    if(isRecent == 'true' &&!isTaskMode){
      hitAPIToGetRecentChats();
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

  ComMemResModel comMemResModel = ComMemResModel();
  List<UserDataAPI> userList=[];

  hitAPIToGetMember() async {
    isLoading = true;
    update();
    Get.find<PostApiServiceImpl>()
        .getComMemApiCall(myCompany?.companyId)
        .then((value) async {
      isLoading = false;
      comMemResModel=value;
      userList = value.data??[];
      filteredList = userList;
      update();
    }).onError((error, stackTrace) {
      isLoading = false;
      update();
    });
  }

  hitAPIToGetRecentChats() async {
    isLoading=true;
    update();
    Get.find<PostApiServiceImpl>()
        .getRecentChatUserApiCall(comId:myCompany?.companyId,page: page)
        .then((value) async {
      isLoading = false;
      userList = value.data?.rows??[];
      filteredList = userList;
      update();
    }).onError((error, stackTrace) {
      isLoading = false;
      update();
    });
  }


  @override
  void onInit() {
    getArguments();
    _getCompany();
    _getMe();

    Future.delayed(const Duration(milliseconds: 400),(){
      getAllUsers();
    });

    super.onInit();
  }



}