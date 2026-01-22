import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../../../../Services/APIs/post/post_api_service_impl.dart';
import '../../../../../../main.dart';
import '../../../../../../utils/custom_flashbar.dart';
import '../../../../../Home/Models/get_folder_res_model.dart';
import '../../../../../Home/Presentation/Controller/company_service.dart';
import '../../../../models/gallery_create.dart';
import '../../../../models/get_company_res_model.dart';
import '../Widgets/create_custom_folder.dart';


class SaveToGalleryController extends GetxController {

  final formKeyDoc = GlobalKey<FormState>();

  TextEditingController docNameController = TextEditingController();
  final TextEditingController newFolderCtrl = TextEditingController();
  final FocusNode newFolderFocus = FocusNode();

  int? currentParentId;            // null = Root
  // List<FolderData> currentFolders = []; // UI ye list show kare

  GetFolderResModel getFolderRes =GetFolderResModel();

  List<FolderData>? folderList = [];

  bool isLoading =false;

  hitApiToGetFolder() async {
    SystemChannels.textInput.invokeMethod('TextInput.hide');
    isLoading=true;
    update();
    Get.find<PostApiServiceImpl>()
        .getFolderApiCall(ucId:myCompany?.userCompanies?.userCompanyId)
        .then((value) {
      isLoading=false;
      update();
      getFolderRes = value;
      folderList = getFolderRes.data?.rows??[];
      update();
    }).onError((error, stackTrace) {
      isLoading=false;
      update();
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
    getCompany();
    hitApiToGetFolder();
    loadFolders(parentId: null);
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
