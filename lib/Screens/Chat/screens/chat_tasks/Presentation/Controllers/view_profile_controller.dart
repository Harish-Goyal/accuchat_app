import 'package:AccuChat/Screens/Chat/screens/auth/models/get_uesr_Res_model.dart';
import 'package:AccuChat/main.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../../../Services/APIs/post/post_api_service_impl.dart';
import '../../../../../../utils/custom_flashbar.dart';
import '../../../../../../utils/helper_widget.dart';
import '../../../../../Home/Presentation/Controller/company_service.dart';
import '../../../../models/all_media_res_model.dart';
import '../../../../models/get_company_res_model.dart';


class ViewProfileController extends GetxController {
  UserDataAPI? user;
  String formattedDate='';
  @override
  void onInit() {

    super.onInit();
    getArguments();
    scrollController.addListener(_onScroll);
    scrollController2.addListener(_onScroll2);
    // scrollListener2();

  }

  bool isLoading =true;

  getArguments(){
    _getCompany();
    if(kIsWeb){
      if(Get.parameters!=null) {
        String? userId = Get.parameters['userId'];

        getUserByIdApi(userId: int.parse(userId??''));
      }
    }else{
      if(Get.arguments!=null) {
        user = Get.arguments['user'];
        formateData(user?.createdOn??'');
        resetPaginationForNewChat();
        _fireApiForCurrentTab();
      }
    }

  }


  void _onScroll() {
    if (!scrollController.hasClients) return;

    final pos = scrollController.position;

    // "near bottom" trigger
    if (pos.extentAfter < 300 && !isPageLoading1 && hasMore) {
      isPageLoading1 = true;        // IMPORTANT: set before await
      _fireApiForCurrentTab();
    }
  }
void _onScroll2() {
    if (!scrollController2.hasClients) return;

    final pos = scrollController2.position;

    // "near bottom" trigger
    if (pos.extentAfter < 300 && !isPageLoading1 && hasMore) {
      isPageLoading1 = true;        // IMPORTANT: set before await
      _fireApiForCurrentTab();
    }
  }

  @override
  void dispose() {
    scrollController.removeListener(_onScroll);
    scrollController.dispose();
    scrollController2.removeListener(_onScroll2);
    scrollController2.dispose();
    super.dispose();
  }

  CompanyData? myCompany;
  _getCompany() {
    final svc = CompanyService.to;
    myCompany = svc.selected;
  }




 formateData(date){
   DateTime parsedDate = DateTime.parse(date);
   formattedDate = DateFormat('d MMM yyyy').format(parsedDate);
 }
  getUserByIdApi({int? userId}) async {
    Get.find<PostApiServiceImpl>()
        .getUserByApiCall(userID: userId,comid: myCompany?.companyId)
        .then((value) async {
      isLoading =false;
      user = value.data;
      formateData(user?.createdOn??'');

      resetPaginationForNewChat();
      _fireApiForCurrentTab();
      update();
    }).onError((error, stackTrace) {
      update();
      isLoading =false;
      update();
      errorDialog(error.toString());
    }).whenComplete(() {});
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


  void _onTabChanged() {
    if (_tabCtrl == null) return;
    // ignore the in-between animation state
    if (_tabCtrl!.indexIsChanging) return;

    tabIndex.value = _tabCtrl!.index;
    resetPaginationForNewChat();
    _fireApiForCurrentTab();
  }

  void _fireApiForCurrentTab() {
    final idx = _tabCtrl?.index ?? 0;
    final mediaTypea = (idx == 0) ? 'IMG' : 'DOC';
    getAllMediaAPICall( mediaTypea, sourceFilter.value);
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



  AllMediaResModel allMEdia = AllMediaResModel();

  getAllMediaAPICall(type,source) async {

    if (page == 1) {
      isLoading = true;
      profileMediaList?.clear();
    }

    isPageLoading1 = true;
    update();

      Get.find<PostApiServiceImpl>()
          .getAllMediaAPI(page: page,comId: myCompany?.companyId,source: isTaskMode?'task':'chat',mediaType:type,userCId: user?.userCompany?.userCompanyId )
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
      isLoading = false;
      isPageLoading1 = false;
      update();
    });
  }

/*  getAllMediaAPICall(type,source) async {
    Get.find<PostApiServiceImpl>()
        .getAllMediaAPI(page: page,source: isTaskMode?'task':'chat',mediaType:type,userCId: user?.userCompany?.userCompanyId )
        .then((value) async {
      profileMediaList.assignAll(value.data?.items??[]);
      update();
      if ((value.data?.items ?? []).isNotEmpty) {
        if (page == 1) {
          profileMediaList.assignAll(value.data?.items??[]);
          isLoading = false;
          hasMore = false;
          update();
        } else {
          profileMediaList.addAll(value.data?.items ?? []);
          isLoading = false;
          hasMore = false;
          update();
        }
      } else {
          isLoading = false;
          hasMore = false;
          update();
      }
    }).onError((error, stackTrace) {
      update();
      errorDialog(error.toString());
    }).whenComplete(() {});
  }*/


  void setSourceFilter(String v) => sourceFilter.value = v;

  List<Items> get _filtered {
    final src = sourceFilter.value.toLowerCase();
    final list = profileMediaList.where((m) {
      final okSrc = (src == 'all') ? true : (m.source?.toLowerCase() == src);
      return okSrc;
    }).toList();

    // sort by uploaded_on desc if present else id desc
    list.sort((a, b) {
      final ad = a.uploadedOn ?? '';
      final bd = b.uploadedOn ?? '';
      if (ad.isEmpty && bd.isEmpty) return (b.id ?? 0).compareTo(a.id ?? 0);
      return bd.compareTo(ad);
    });
    return list;
  }

  // public getters for UI
  List<Items> get mediaItems =>
      _filtered.where((m) => isImageOrVideo(m)).toList();

  List<Items> get docItems =>
      _filtered.where((m) => isDoc(m)).toList();

  // -------- type helpers ----------

}