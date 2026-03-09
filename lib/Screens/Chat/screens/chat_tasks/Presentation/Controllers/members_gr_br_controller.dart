import 'package:AccuChat/Screens/Chat/screens/chat_tasks/Presentation/Controllers/chat_home_controller.dart';
import 'package:AccuChat/Screens/Chat/screens/chat_tasks/Presentation/Controllers/chat_screen_controller.dart';
import 'package:dio/dio.dart' as multi;
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../../../Services/APIs/post/post_api_service_impl.dart';
import '../../../../../../main.dart';
import '../../../../../../routes/app_routes.dart';
import '../../../../../../utils/chat_presence.dart';
import '../../../../../../utils/custom_flashbar.dart';
import '../../../../../Home/Presentation/Controller/company_service.dart';
import '../../../../models/all_media_res_model.dart';
import '../../../../models/get_company_res_model.dart';
import '../../../../models/group_res_model.dart';
import '../../../auth/models/get_uesr_Res_model.dart';

class GrBrMembersController extends GetxController{
  TextEditingController groupNameController = TextEditingController();
  UserDataAPI? groupOrBr;

  bool isUpdate = false;
  String formattedDate='';

  String? userId;

  @override
  void onInit() {
    _getCompany();
    getArguments();

    super.onInit();
  }
  final RxList<Items> profileMediaList = <Items>[].obs;
  final RxString sourceFilter = 'All'.obs; // All | chat | task


  final RxInt tabIndex = 0.obs;

  // keep a ref to the tab controller we attach from the UI
  TabController? _tabCtrl;

  void attachTabController(TabController t) {
    if (_tabCtrl == t) return;          // avoid re-attaching
    _tabCtrl = t;
    _tabCtrl!.addListener(_onTabChanged);

    // initial fetch for default tab

  }
  formateData(date){
    DateTime parsedDate = DateTime.parse(date);
    formattedDate = DateFormat('d MMM yyyy').format(parsedDate);
  }

  void _onTabChanged() {
    if (_tabCtrl == null) return;
    // ignore the in-between animation state
    if (_tabCtrl!.indexIsChanging) return;

    tabIndex.value = _tabCtrl!.index;
    if(tabIndex.value==0){
      hitAPIToGetMembers();
    }
    resetPaginationForNewChat();
    _fireApiForCurrentTab();
  }




  int page = 1;
  bool hasMore = false;
  bool isPageLoading1 = false;

  ScrollController scrollController = ScrollController();
  ScrollController scrollController2 = ScrollController();

  scrollListener() {

    if (kIsWeb) {
      scrollController.addListener(() {
        if (scrollController.position.pixels >=
            scrollController.position.maxScrollExtent -100 &&
            !isPageLoading1 &&
            hasMore) {
          // resetPaginationForNewChat();
          _fireApiForCurrentTab();
        }
      });
    } else {
      scrollController.addListener(() {
        if (scrollController.position.pixels <=
            scrollController.position.minScrollExtent + 50 &&
            !isPageLoading1 &&
            hasMore) {
          // resetPaginationForNewChat();
          _fireApiForCurrentTab();
        }
      });
    }
  }
  scrollListener2() {

    if (kIsWeb) {
      scrollController2.addListener(() {
        if (scrollController2.position.pixels >=
            scrollController2.position.maxScrollExtent - 60 &&
            !isPageLoading1 &&
            hasMore) {
          // resetPaginationForNewChat();
          _fireApiForCurrentTab();
        }
      });
    } else {
      scrollController2.addListener(() {
        if (scrollController2.position.pixels <=
            scrollController2.position.minScrollExtent + 50 &&
            !isPageLoading1 &&
            hasMore) {
          // resetPaginationForNewChat();
          _fireApiForCurrentTab();
        }
      });
    }
  }

  void resetPaginationForNewChat() {
    page = 1;
    hasMore = true;
    profileMediaList.clear();
    isLoading = true;
    update();
  }

  void _fireApiForCurrentTab() {
    final idx = _tabCtrl?.index ?? 0;
    final mediaTypea = (idx == 1) ? 'IMG' : idx==2? 'DOC':"";
    getAllMediaAPICall( mediaTypea, sourceFilter.value);
  }

  AllMediaResModel allMEdia = AllMediaResModel();

  getAllMediaAPICall(type,source) async {

    if (page == 1) {
      isLoading = true;
      profileMediaList?.clear();
    }

    isPageLoading1 = true;
    update();

    await Get.find<PostApiServiceImpl>()
        .getAllMediaAPI(page: page,comId: myCompany?.companyId,source: 'group',mediaType:type,userCId: groupOrBr?.userCompany?.userCompanyId )
        .then((value) async {
      isLoading = false;
      allMEdia = value;
      if (allMEdia.data?.items != null && (allMEdia.data?.items ?? []).isNotEmpty) {
        if (page == 1) {
          profileMediaList.assignAll(allMEdia.data?.items ?? []);
        } else {
          profileMediaList.addAll(allMEdia.data?.items ?? []);
        }

        page++;
      }
      else {
        hasMore = false;
        isPageLoading1 = false;
        update();
      }

      // rebuildFlatRows();
      isLoading = false;
      isPageLoading1 = false;
      update();

    }).onError((error, stackTrace) {

      if(!kIsWeb) {
        FirebaseCrashlytics.instance.recordError(
            error, stackTrace, reason: 'apiCall failed');
      }
      isLoading = false;
      isPageLoading1 = false;
      update();
    });
  }



  getArguments(){
    if(kIsWeb){
      if(Get.parameters!=null) {
        userId = Get.parameters['userId'];
        getUserByIdApi(userId: int.parse(userId??''),comId: myCompany?.companyId);
      }
    }else{
      if(Get.arguments!=null) {
        groupOrBr = Get.arguments['user'];
        groupNameController.text = groupOrBr?.userName??'';
        hitAPIToGetMembers();
      }
    }
  }


  getUserByIdApi({int? userId,comId}) async {

   await  Get.find<PostApiServiceImpl>()
        .getUserByApiCall(userID: userId,comid: comId)
        .then((value) async {
      groupOrBr = value.data;
      groupNameController.text = groupOrBr?.userName??'';
      hitAPIToGetMembers();
      update();
    }).onError((error, stackTrace) {

     if(!kIsWeb) {
       FirebaseCrashlytics.instance.recordError(
           error, stackTrace, reason: 'apiCall failed');
     }
      update();
      errorDialog(error.toString());
    }).whenComplete(() {});
  }



  CompanyData? myCompany = CompanyData();
  _getCompany() {
    final svc = CompanyService.to;
    myCompany = svc.selected;
    update();
  }

  bool isLoading = true;
  List<UserDataAPI> members = [];
  hitAPIToGetMembers() async {
    isLoading = true;
    update();
    await Get.find<PostApiServiceImpl>()
        .getGrBrMemberApiCall(id:
    groupOrBr?.userCompany?.userCompanyId,mode: groupOrBr?.userCompany?.isGroup==1?
    "group":"broadcast")
        .then((value) async {
      isLoading = false;
      members = value.data?.members??[];

      update();
    }).onError((error, stackTrace) {
      if(!kIsWeb) {
        FirebaseCrashlytics.instance.recordError(
            error, stackTrace, reason: 'apiCall failed');
      }
      isLoading = false;
      update();
    });
  }



  GroupResModel groupResModel = GroupResModel();
  updateGroupBroadcastApi({isGroup,isBroadcast}) async {
    SystemChannels.textInput.invokeMethod('TextInput.hide');
    customLoader.show();
    var reqData = multi.FormData.fromMap({
      "id": groupOrBr?.userId,
      "company_id": myCompany?.companyId,
      "name":groupNameController.text,
      "is_group":isGroup,
      "is_broadcast": isBroadcast,
    });
   await Get.find<PostApiServiceImpl>()
        .addEditGroupBroadcastApiCall(dataBody: reqData)
        .then((value) async {
      customLoader.hide();
      Get.back();
      groupResModel = value;
      groupNameController.clear();
      toast(value.message??'');
      groupOrBr = groupResModel.data;
      Get.offAllNamed(AppRoutes.home);
     //  final _tagid = groupOrBr?.userCompany?.userCompanyId;
     //  final _tag = "chat_${_tagid ?? 'mobile'}";
     //  ChatScreenController? chatc;
     //  if(Get.isRegistered<ChatScreenController>(tag: _tag)){
     //    chatc =Get.find<ChatScreenController>(tag: _tag);
     //  }
     //  else{
     //    chatc = Get.put(ChatScreenController());
     //  }
     //  final chath =Get.find<ChatHomeController>();
     //  await chath.hitAPIToGetRecentChats(page: 1);
     // final i = chath.filteredList.indexWhere((e)=>groupOrBr?.userCompany?.userCompanyId==chatc?.user?.userCompany?.userCompanyId );
     //  chath.filteredList[i]= groupOrBr!;
     //  chath.filteredList.refresh();
     //  chatc?.user?.userCompany?.displayName = groupOrBr?.userCompany?.displayName;
     //  chatc?.user?.userName = groupOrBr?.userName;
     //  chatc?.refresh();
      update();
    }).onError((error, stackTrace) {
      update();
      if(!kIsWeb) {
        FirebaseCrashlytics.instance.recordError(
            error, stackTrace, reason: 'apiCall failed');
      }
      Get.back();
      customLoader.hide();
      errorDialog(error.toString());
    }).whenComplete(() {});
  }


  hitAPIToUpdateMember({bool isGroup = false,id,mode}) async {
    customLoader.show();
    Map<String, dynamic> req = {
      "group_id": groupOrBr?.userCompany?.userCompanyId, // Group companyID
      "company_id": myCompany?.companyId,
      "member_id": [id],//member company ID
      "mode":mode,
      "is_group": isGroup ? 1 : 0,
      'is_admin':mode=='set_admin'?1:0
    };

   await Get.find<PostApiServiceImpl>()
        .addMemberToGrBrApiCall(dataBody: req)
        .then((value) async {
      customLoader.hide();
      isLoading =true;
      hitAPIToGetMembers();
      // final _tagid = ChatPresence.activeChatId.value;
      // final _tag = "chat_${_tagid ?? 'mobile'}";
      // Get.find<ChatScreenController>(tag: _tag).hitAPIToGetMembers(groupOrBr);
      update();
    }).onError((error, stackTrace) {

     if(!kIsWeb) {
       FirebaseCrashlytics.instance.recordError(
           error, stackTrace, reason: 'apiCall failed');
     }
      customLoader.hide();
    });
  }


 hitAPIToDeleteGrBr({bool isGroup = false}) async {
    customLoader.show();
    Map<String, dynamic> req = {
      "company_id": myCompany?.companyId,
      "entity_uc_id":groupOrBr?.userCompany?.userCompanyId, // the group's/broadcast's user_company_id
      "is_broadcast": isGroup ? 0 : 1,    // 0 = group, 1 = broadcast
    };

    await Get.find<PostApiServiceImpl>()
        .deleteGrBrApiCall(dataBody: req)
        .then((value) async {
      customLoader.hide();
      // Get.find<ChatHomeController>().hitAPIToGetRecentChats();
      Get.offAllNamed(AppRoutes.home);
      update();
    }).onError((error, stackTrace) {

      if(!kIsWeb) {
        FirebaseCrashlytics.instance.recordError(
            error, stackTrace, reason: 'apiCall failed');
      }
      customLoader.hide();
    });
  }





}