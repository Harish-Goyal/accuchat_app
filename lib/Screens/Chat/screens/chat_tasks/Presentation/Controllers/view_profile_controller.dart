import 'package:AccuChat/Screens/Chat/screens/auth/models/get_uesr_Res_model.dart';
import 'package:AccuChat/main.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../../Services/APIs/post/post_api_service_impl.dart';
import '../../../../../../utils/custom_flashbar.dart';
import '../../../../../Home/Presentation/Controller/company_service.dart';
import '../../../../models/all_media_res_model.dart';
import '../../../../models/chat_user.dart';
import '../../../../models/get_company_res_model.dart';


class ViewProfileController extends GetxController {
  UserDataAPI? user;
  @override
  void onInit() {
    _getCompany();
    getArguments();
    super.onInit();
  }

  getArguments(){
    if(kIsWeb){

      if(Get.parameters!=null) {
        String? userId = Get.parameters['userId'];
        getUserByIdApi(userId: int.parse(userId??''));
      }
    }else{
      if(Get.arguments!=null) {
        user = Get.arguments['user'];
      }
    }

  }


  CompanyData? myCompany = CompanyData();
  _getCompany() {
    final svc = Get.find<CompanyService>();
    myCompany = svc.selected;
    update();
  }

  getUserByIdApi({int? userId}) async {
    Get.find<PostApiServiceImpl>()
        .getUserByApiCall(userID: userId,comid: myCompany?.companyId)
        .then((value) async {
      user = value.data;
      update();
    }).onError((error, stackTrace) {
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
    _fireApiForCurrentTab();
  }


  void _onTabChanged() {
    if (_tabCtrl == null) return;
    // ignore the in-between animation state
    if (_tabCtrl!.indexIsChanging) return;

    tabIndex.value = _tabCtrl!.index;
    _fireApiForCurrentTab();
  }

  void _fireApiForCurrentTab() {
    final idx = _tabCtrl?.index ?? 0;
    final mediaType = (idx == 0) ? 'IMG' : 'DOC';
    getAllMediaAPICall( mediaType, sourceFilter.value);
  }

  getAllMediaAPICall(type,source) async {
    Get.find<PostApiServiceImpl>()
        .getAllMediaAPI(page: 1,source: isTaskMode?'task':'chat',mediaType:type,userCId: user?.userCompany?.userCompanyId )
        .then((value) async {
      profileMediaList.assignAll(value.data?.items??[]);
      update();
    }).onError((error, stackTrace) {
      update();
      errorDialog(error.toString());
    }).whenComplete(() {});
  }


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
  bool isDoc(Items m) {
    final code = (m.mediaType?.code ?? '').toUpperCase();
    if (code == 'DOC') return true;
    final ext = (m.fileName ?? '').toLowerCase();
    return ext.endsWith('.pdf') ||
        ext.endsWith('.doc') || ext.endsWith('.docx') ||
        ext.endsWith('.xls') || ext.endsWith('.xlsx') ||
        ext.endsWith('.ppt') || ext.endsWith('.pptx') ||
        ext.endsWith('.csv') || ext.endsWith('.txt');
  }

  bool isImageOrVideo(Items m) {
    final code = (m.mediaType?.code ?? '').toUpperCase();
    if (code == 'IMG' || code == 'IMAGE' || code == 'PHOTO' || code == 'VID' || code == 'VIDEO') return true;
    final ext = (m.fileName ?? '').toLowerCase();
    return ext.endsWith('.jpg') || ext.endsWith('.jpeg') ||
        ext.endsWith('.png') || ext.endsWith('.gif') ||
        ext.endsWith('.webp') || ext.endsWith('.mp4') ||
        ext.endsWith('.mov') || ext.endsWith('.m4v') || ext.endsWith('.avi');
  }
}