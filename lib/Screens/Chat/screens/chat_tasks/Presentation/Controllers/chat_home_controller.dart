import 'package:AccuChat/Screens/Chat/models/recent_chat_user_res_model.dart';
import 'package:AccuChat/Screens/Home/Presentation/Controller/socket_controller.dart';
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
import '../../../../../Home/Presentation/Controller/company_service.dart';
import '../../../../api/apis.dart';
import '../../../../models/chat_user.dart';
import '../../../../models/group_res_model.dart';
import '../../../../models/get_company_res_model.dart';
import '../../../auth/models/get_uesr_Res_model.dart';


class ChatHomeController extends GetxController{

  bool isTask = false;


  List<ChatUser> list = [];
  List<ChatGroup> grouplist = [];
  final List<ChatUser> searchList = [];
  bool isSearching = false;
  TextEditingController seacrhCon = TextEditingController();
  String searchQuery = '';

  Future<void> onCompanyChanged(int? companyId) async => hitAPIToGetRecentChats();

  final dash = Get.put(DashboardController());
  @override
  void onInit() {

    getCompany();

    Future.delayed(const Duration(milliseconds: 800),(){
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

    super.onInit();
  }

  CompanyData? myCompany = CompanyData();
  getCompany(){
    if(Get.isRegistered<CompanyService>()) {
      final svc = CompanyService.to;
      myCompany = svc.selected;
      update();
    }

  }

  int page =1;
  bool isLoading =false;
  bool hasMore = true;
  RecentChatsUserResModel recentChatsUserResModel = RecentChatsUserResModel();

  ScrollController scrollController = ScrollController();

  scrollListener() {
    scrollController.addListener(() {
      if (scrollController.position.pixels ==
          scrollController.position.maxScrollExtent &&
          !isLoading &&
          hasMore) {
        hitAPIToGetRecentChats();
      }
    });
  }

  List<UserDataAPI>? recentChatUserList=[];

  hitAPIToGetRecentChats() async {
    isLoading=true;
    update();
    Get.find<PostApiServiceImpl>()
        .getRecentChatUserApiCall(comId:myCompany?.companyId,page: page)
        .then((value) async {
      isLoading = false;
      update();
      recentChatsUserResModel=value;
      recentChatUserList=value.data?.rows??[];
      filteredList = recentChatUserList??[];

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
      Get.find<SocketController>().connectUserEmitter();
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
  // List<dynamic> mergedList = [];
  List<UserDataAPI> filteredList = [];

  DashboardController dashboardController = Get.put(DashboardController());

  void onSearch(String query) {
    searchQuery = query.toLowerCase();

    filteredList = recentChatUserList!.where((item) {

        return (item.displayName??'').toLowerCase().contains(searchQuery) ||
            (item.email??'').toLowerCase().contains(searchQuery)||
            (item.userName??'').toLowerCase().contains(searchQuery)||
            (item.phone??'').contains(searchQuery)
        ;

    }).toList();

   update();
  }
}


class AuthGuard extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {

    final String? token = StorageService.getToken();
    final bool loggedIn = StorageService.isLoggedInCheck();

    print("token=======================");
    print(token);
    print(loggedIn);

    if (token == null) return const RouteSettings(name: AppRoutes.login_r);
    if (!loggedIn)   return const RouteSettings(name: AppRoutes.landing_r);
    return null; // allow
  }
}