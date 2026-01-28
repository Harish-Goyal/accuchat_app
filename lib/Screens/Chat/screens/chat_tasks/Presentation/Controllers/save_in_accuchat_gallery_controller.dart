import 'dart:math';
import 'package:AccuChat/Screens/Home/Presentation/Controller/gallery_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../../../../Services/APIs/post/post_api_service_impl.dart';
import '../../../../../../main.dart';
import '../../../../../../utils/custom_flashbar.dart';
import '../../../../../Home/Models/get_folder_res_model.dart';
import '../../../../../Home/Models/pickes_file_item.dart';
import '../../../../../Home/Presentation/Controller/company_service.dart';
import '../../../../models/gallery_create.dart';
import '../../../../models/get_company_res_model.dart';
import '../Widgets/create_custom_folder.dart';


class SaveToGalleryController extends GetxController {

  final formKeyDoc = GlobalKey<FormState>();
  final RxList<SavePreviewItem> items = <SavePreviewItem>[].obs;

  void setItems(List<SavePreviewItem> v) => items.assignAll(v);

  void removeAt(int i) {
    if (i >= 0 && i < items.length) items.removeAt(i);
  }

  TextEditingController docNameController = TextEditingController();
  final TextEditingController newFolderCtrl = TextEditingController();
  final FocusNode newFolderFocus = FocusNode();

  int? currentParentId;

  GetFolderResModel getFolderRes =GetFolderResModel();

  List<FolderData>? folderList = [];

  bool isLoading =false;

  bool hasMore = false;
  bool isPageLoading = false;
  int page = 1;
  late ScrollController scrollController;

  void scrollListener() {
    scrollController.addListener(() {
      if (!scrollController.hasClients) return;

      final pos = scrollController.position;

      // ✅ If not scrollable yet, don't paginate
      if (pos.maxScrollExtent <= 0) return;

      // ✅ Trigger when user is near bottom
      const threshold = 200.0;
      final nearBottom = pos.extentAfter < threshold;

      if (nearBottom && !isPageLoading && hasMore) {
        hitApiToGetFolder();
      }
    });
  }


  Future<void> hitApiToGetFolder({bool reset = false}) async {
    if (isPageLoading) return;

    if (reset) {
      page = 1;
      hasMore = true;
      isLoading = true;
      folderList?.clear();
      update();
    }

    if (!hasMore) return;

    isPageLoading = true;
    if (page == 1) isLoading = true;
    update();
    try {
      final res = await Get.find<PostApiServiceImpl>().getFolderApiCall(
        ucId: myCompany?.userCompanies?.userCompanyId,
        page: page,
      );

      isLoading = false;

      final rows = res.data?.rows ?? [];

      if (rows.isNotEmpty) {
        folderList?.addAll(rows);
        page++;
        const pageSize = 15;
        hasMore = rows.length == pageSize;
      } else {
        hasMore = false;
      }
      update();
      _ensureScrollableAndPrefetch();
    } catch (e) {
      isLoading = false;
      update();
    } finally {
      isPageLoading = false;
      update();
    }
  }

  //Folder Items
  void _ensureScrollableAndPrefetch() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!scrollController.hasClients) return;
      final pos = scrollController.position;

      // still not scrollable, but more data exists => prefetch next page
      if (pos.maxScrollExtent <= 0 && hasMore && !isPageLoading) {
        hitApiToGetFolder();
      }
    });
  }

  hitApiToSaveMediaFromChatApiCall({chatId, folderName,keywords}) async {
    SystemChannels.textInput.invokeMethod('TextInput.hide');
    customLoader.show();
    var reqData = {
      "user_company_id": myCompany?.userCompanies?.userCompanyId,
      "chat_media_id": chatId,
      "folder_name": folderName,
      "title":docNameController.text.trim(),
      "key_words":keywords
    };
    Get.find<PostApiServiceImpl>()
        .saveMediaFromChatApiCall(dataBody: reqData)
        .then((value) {
      Get.back();
      customLoader.hide();
      toast(value.message ?? '');


      update();
    }).onError((error, stackTrace) {
      update();
      Get.back();
      customLoader.hide();
      errorDialog(error.toString());
    }).whenComplete(() {});
  }


  int? selectedFolderId;
  bool showCreateNew = false;
  String? validationError;

  void selectFolder(int? id) {
    selectedFolderId = id;
    update();
  }
  void removeSelectFolder() {
    selectedFolderId = null;
    update();
  }

  void toggleCreateNew(bool value) {
    showCreateNew = value;
    validationError = null;
    if (value) {
      // If user wants to create new, unselect existing
      selectedFolderId = null;
    }
    update();
  }

  bool _isUniqueName(String name) {
    return !(folderList??[])
        .any((f) => (f.folderName??'').toLowerCase() == name.trim().toLowerCase());
  }

  /// Validator used by CustomTextField
  String? validateFolderName(String? value) {
    final v = (value ?? '').trim();

    // Use your extension for the empty case:
    if (v.isEmpty) {
      // Your extension needs a messageTitle; pass "Folder name"
      // Since we can't call the extension here, just return the final message directly:
      return "Folder name can't be empty";
    }

    if (v.length < 2) {
      return 'Folder name must be at least 2 characters';
    }

    if (!_isUniqueName(v)) {
      return 'Folder name already exists';
    }

    return null;
  }


  FolderData? get selectedFolder {
    if (selectedFolderId == null) return null;
    return (folderList??[]).firstWhereOrNull((f) => f.userGalleryId == selectedFolderId);
  }

  void onTapSaveToFolder(BuildContext context, user) async {
     Get.back();
     Get.snackbar('Saved', 'Item saved w2',
         snackPosition: SnackPosition.BOTTOM,
         backgroundColor: Colors.white,
         colorText: Colors.black87,duration: Duration(seconds: 6));
  }

  void loadFolders({int? parentId}) {
    currentParentId = parentId;
    // currentFolders =  (folderList??[]).where((f) => f.userGalleryId == parentId).toList();
    update();
  }

  void openFolder(GalleryFolder folder) {
    // ✅ Guard: same folder already open, don't push again
    // if (currentParentId == folder.id) return;

    // ✅ Guard: if last breadcrumb same, don't duplicate
    // if (breadcrumb.isNotEmpty && breadcrumb.last.id == folder.id) return;
    //
    // breadcrumb.add(folder);
    // loadFolders(parentId: folder.id);
  }

  void goRoot() {
    // breadcrumb.clear();
    loadFolders(parentId: null);
  }

  void goToCrumb(int index) {
    if (index < 0) {
      goRoot();
      return;
    }
    // final target = breadcrumb[index];
    // breadcrumb = breadcrumb.take(index + 1).toList();
    // loadFolders(parentId: target.id);
  }


  @override
  void onInit() {
    super.onInit();
    _init();
  }

  _init(){
    getCompany();
    scrollController = ScrollController();
    resetPagination();
    hitApiToGetFolder(reset: true);
    scrollListener();
    loadFolders(parentId: null);
  }
  void resetPagination() {
    page= 1;
    hasMore= true;
    folderList?.clear();
    isLoading= true;
  }

  CompanyData? myCompany = CompanyData();

  getCompany(){
    final svc = CompanyService.to;
    myCompany = svc.selected;
    update();
  }

  @override
  void dispose() {
    super.dispose();

    newFolderCtrl.dispose();
    imageCache.clearLiveImages();
    imageCache.clear();

  }

  @override
  void onClose() {
    newFolderCtrl.dispose();
    docNameController.dispose();
    newFolderFocus.dispose();
    super.onClose();
  }

}
