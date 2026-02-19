import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:AccuChat/Screens/Chat/screens/chat_tasks/Presentation/Controllers/save_in_accuchat_gallery_controller.dart';
import 'package:dio/dio.dart' as multi;
import 'package:path/path.dart' as p;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../Services/APIs/post/post_api_service_impl.dart';
import '../../../../main.dart';
import '../../../../routes/app_routes.dart';
import '../../../../utils/custom_flashbar.dart';
import '../../../../utils/helper.dart';
import '../../../../utils/helper_widget.dart';
import '../../../Chat/helper/dialogs.dart';
import '../../../Chat/models/gallery_node.dart';
import '../../../Chat/models/get_company_res_model.dart';
import '../../../Chat/screens/auth/models/get_uesr_Res_model.dart';
import '../../../Chat/screens/chat_tasks/Presentation/Widgets/all_users_dialog.dart';
import '../../../Chat/screens/chat_tasks/Presentation/dialogs/save_in_gallery_dialog.dart';
import '../../Models/get_folder_res_model.dart';
import '../../Models/pickes_file_item.dart';
import '../View/folder_items_view.dart';
import 'company_service.dart';
import 'galeery_item_controller.dart';

class IndexedNode {
  final GalleryNode node;
  final List<GalleryNode> path;
  IndexedNode({required this.node, required this.path});
}

class GalleryController extends GetxController
    with GetSingleTickerProviderStateMixin {
  late TabController tabController;
  final RxInt renamingId = 0.obs;

  final Map<String, TextEditingController> _textCtrls = {};
  final Map<String, FocusNode> _focusNodes = {};

  TextEditingController textCtrlFor(int id, String initial) {
    return _textCtrls.putIfAbsent(
        id.toString(), () => TextEditingController(text: initial));
  }

  FocusNode focusNodeFor(int id) {
    return _focusNodes.putIfAbsent(id.toString(), () => FocusNode());
  }

  void startRename({required int id, required String currentName}) {
    renamingId.value = id;

    final c = textCtrlFor(id, currentName);
    c.text = currentName;

    Future.microtask(() {
      final fn = focusNodeFor(id);
      fn.requestFocus();
      c.selection = TextSelection(baseOffset: 0, extentOffset: c.text.length);
    });
  }

  Future<void> submitRename({
    required String id,
    required String oldName,
    required Future<void> Function(String newName) onRename,
  }) async {
    final c = _textCtrls[id];
    final newName = (c?.text ?? '').trim();
    if (newName.isEmpty || newName == oldName) {
      renamingId.value = 0;
      return;
    }
    await onRename(newName);
    renamingId.value = 0;
  }


  final TextEditingController searchCtrl = TextEditingController();
  String query = '';


  bool get isSearching => query.trim().isNotEmpty;
  bool isSearchingIcon = false;
  void onSearchChanged(String v) {
    query = v;
    update();
  }

  @override
  void onInit() {
    super.onInit();
    _init();
  }

  _init() {
    tabController = TabController(length: 2, vsync: this);
    scrollController = ScrollController();
    getCompany();
    resetPagination();
    hitApiToGetFolder(reset: true);
    scrollListener();
    searchCtrl.addListener(() => onSearchChanged(searchCtrl.text));
  }

  CompanyData? myCompany = CompanyData();
  getCompany() {
    final svc = CompanyService.to;
    myCompany = svc.selected;
    update();
    if (!svc.hasCompany){
      Get.offAllNamed(AppRoutes.landing_r);
      return;
    }
  }


//Create folder
  void refreshGallery() async {
  hitApiToGetFolder(reset: true);
  }

  final TextEditingController nameController = TextEditingController();

  final RxBool isSaving = false.obs;
  final RxString error = ''.obs;

  void clearError() => error.value = '';

  hitApiToCreateFolder() async {
    SystemChannels.textInput.invokeMethod('TextInput.hide');
    customLoader.show();
    var reqData = {
      "name": nameController.text.trim(),
      "user_company_id": myCompany?.userCompanies?.userCompanyId,
    };
    Get.find<PostApiServiceImpl>()
        .createFolderApiCall(dataBody: reqData)
        .then((value) {
      nameController.clear();
      Get.back(result: nameController.text.trim());
      customLoader.hide();
      resetPagination();
      hitApiToGetFolder(reset: true);
      toast(value.message ?? '');
      update();
    }).onError((error, stackTrace) {
      update();
      Get.back();
      customLoader.hide();
      errorDialog(error.toString());
    }).whenComplete(() {});
  }

  hitApiToUploadFolderMedia(FolderData folder) async {
    SystemChannels.textInput.invokeMethod('TextInput.hide');
    customLoader.show();
    var reqData = multi.FormData.fromMap({
      "folder_name":nameController.text.trim(),
      "title":nameController.text.trim(),
      "file_path":  myCompany?.userCompanies?.userCompanyId,
      "key_words":  myCompany?.userCompanies?.userCompanyId,
    });

    Get.find<PostApiServiceImpl>()
        .uploadFolderMediaApiCall(dataBody: reqData)
        .then((value) {
      Get.back();
      customLoader.hide();
      resetPagination();
      hitApiToGetFolder(reset: true);

      Get.to(()=>FolderItemsScreen(folderData: folder),
        binding: BindingsBuilder(() {
          final tag = 'folder_${folder.userGalleryId}';
          if (Get.isRegistered<GalleryItemController>(tag: tag)) {
            Get.delete<GalleryItemController>(tag: tag, force: true);
          }
          Get.put(GalleryItemController(folderData: folder), tag: tag);
        }),);
      toast(value.message ?? '');
      update();
    }).onError((error, stackTrace) {
      update();
      Get.back();
      customLoader.hide();
      errorDialog(error.toString());
    }).whenComplete(() {});
  }

  hitApiToDeleteFolder(id) async {
    customLoader.show();
    var reqData = {
      "user_company_id": myCompany?.userCompanies?.userCompanyId,
      "user_gallery_id": id,
    };
    Get.find<PostApiServiceImpl>()
        .deleteFolderApiCall(dataBody: reqData)
        .then((value) {
      Get.back();
      customLoader.hide();
      hitApiToGetFolder(reset: true);
      toast(value.message ?? '');
      update();
    }).onError((error, stackTrace) {
      update();
      Get.back();
      customLoader.hide();
      errorDialog(error.toString());
    }).whenComplete(() {});
  }

  hitApiToEditFolder(folderName,newFolderName) async {
    customLoader.show();
    var reqData = {
      "user_company_id": myCompany?.userCompanies?.userCompanyId,
      "old_name": folderName,
      "new_name": newFolderName,
    };
    Get.find<PostApiServiceImpl>()
        .editFolderApiCall(dataBody: reqData)
        .then((value) {
      customLoader.hide();
      hitApiToGetFolder(reset: true);
      // toast(value.message ?? '');
      update();
    }).onError((error, stackTrace) {
      update();
      Get.back();
      customLoader.hide();
      errorDialog(error.toString());
    }).whenComplete(() {});
  }

  GetFolderResModel getFolderRes = GetFolderResModel();

  void resetPagination() {
    page.value = 1;
    hasMore.value = true;
    folderList.clear();
    isLoading.value = true;
  }

  // List<FolderData>? folderList = [];
  var folderList = <FolderData>[].obs;

  RxBool isLoading = false.obs;
  RxBool hasMore = false.obs;
  RxBool isPageLoading = false.obs;
  RxInt page = 1.obs;
  late ScrollController scrollController;

  void scrollListener() {
    scrollController.addListener(() {
      if (!scrollController.hasClients) return;

      final pos = scrollController.position;

      if (pos.maxScrollExtent <= 0) return;

      const threshold = 200.0;
      final nearBottom = pos.extentAfter < threshold;

      if (nearBottom && !isPageLoading.value && hasMore.value) {
        hitApiToGetFolder();
      }
    });
  }


  Future<void> hitApiToGetFolder({bool reset = false}) async {
    if (isPageLoading.value) return;

    if (reset) {
      page.value = 1;
      hasMore.value = true;
      isLoading.value = true;
      folderList.clear();
    }

    if (!hasMore.value) return;

    isPageLoading.value = true;
    if (page.value == 1) isLoading.value = true;

    try {
      final res = await Get.find<PostApiServiceImpl>().getFolderApiCall(
        ucId: myCompany?.userCompanies?.userCompanyId,
        page: page,
      );

      isLoading.value = false;

      final rows = res.data?.rows ?? [];

      if (rows.isNotEmpty) {
        folderList.addAll(rows);
        page.value++;
        const pageSize = 15; // match backend
        hasMore.value = rows.length == pageSize;
      } else {
        hasMore.value = false;
      }
      _ensureScrollableAndPrefetch();
    } catch (e) {
      isLoading.value = false;
    } finally {
      isPageLoading.value = false;
    }
  }


//Create folder

// Folder Items

  List<FolderData>? searchResults = [];

  hitApiToGetSearchResultItems(searchTxt) async {
    Get.find<PostApiServiceImpl>()
        .getGalleryGlobalSearchApiCall(
            ucId: myCompany?.userCompanies?.userCompanyId,
            search: searchTxt)
        .then((value) {
      searchResults = value.data?.rows ?? [];
      update();
    }).onError((error, stackTrace) {
      update();
      customLoader.hide();
      errorDialog(error.toString());
    }).whenComplete(() {});
  }

  final RxString openedFolder = "".obs;

  //Folder Items


  void _ensureScrollableAndPrefetch() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!scrollController.hasClients) return;
      final pos = scrollController.position;

      if (pos.maxScrollExtent <= 0 && hasMore.value && !isPageLoading.value) {
        hitApiToGetFolder();
      }
    });
  }


  RxBool isUploading = false.obs;
  List<Map<String, dynamic>> attachedFiles = [];
  List<XFile> images = [];
  final List<PlatformFile> webDocs = [];
  Future<void> uploadDocumentsApiCall({bool isDirect=false,required List<PickedFileItem> files, void Function(int sent, int total)? onProgress, folderName, keywords, mediaTitle,FolderData? folder}) async {
    if (files.isEmpty) {
      toast('Please select at least one document');
      return;
    }
    try {
      isUploading.value = true;
      final docParts = <multi.MultipartFile>[];
      for (final f in files) {
        final name = safeName(f.name);
        final extis = ext(name);
        if (kIsWeb) {
          final bytes = f.byte;
          if (bytes == null) continue;
          docParts.add(
            multi.MultipartFile.fromBytes(
              bytes,
              filename: name,
              contentType: mediaTypeForExt(extis),
            ),
          );
        } else {
          final path = f.path;
          if (path == null) continue;
          docParts.add(
            await multi.MultipartFile.fromFile(
              path,
              filename: name,
              contentType: mediaTypeForExt(extis),
            ),
          );
        }
      }

      if (docParts.isEmpty) {
        isUploading.value  = false;
        update();
        toast('No readable documents selected');
        return;
      }
      multi.FormData? formData;
        formData = multi.FormData.fromMap({
          "folder_name":folderName,
          "title":nameController.text.trim(),
          "user_company_id":  myCompany?.userCompanies?.userCompanyId,
          "key_words":  keywords,
          'file_path': docParts, // array of docs
        });

      Get.find<PostApiServiceImpl>()
          .uploadFolderMediaApiCall(dataBody: formData)
          .then((value) {
        Get.back();
        isUploading.value  = false;
        customLoader.hide();
        resetPagination();
        hitApiToGetFolder();
        Get.to(()=>FolderItemsScreen(folderData: folder),
          binding: BindingsBuilder(() {
            final tag = 'folder_${folder?.userGalleryId}';
            if (Get.isRegistered<GalleryItemController>(tag: tag)) {
              Get.delete<GalleryItemController>(tag: tag, force: true);
            }
            Get.put(GalleryItemController(folderData: folder), tag: tag);
          }),);
        // if(!isDirect){
        //   final con = Get.find<GalleryController>();
        //   con.hitApiToGetFolderItems(folder!);
        // }

        toast(value.message ?? '');
      }).onError((error, stackTrace) {
        isUploading.value  = false;
        Get.back();
        customLoader.hide();
        errorDialog(error.toString());
      }).whenComplete(() {});

    } catch (e) {
      isUploading.value = false;
      errorDialog(e.toString());
    }
  }


  Future<void> uploadMediaApiCall({
    void Function(int sent, int total)? onProgress,
    title,
    folderName,
    keywords,
    FolderData? folder,
    required BuildContext ctx,
    bool isDirect=false,
    required List<PickedFileItem> images,
  }) async {
    SystemChannels.textInput.invokeMethod('TextInput.hide');

    if (images.isEmpty) {
      toast('Please select at least one image');
      return;
    }

    try {
      isUploading.value = true;
      final mediaFiles = <multi.MultipartFile>[];
      for (final x in images) {
        multi.MultipartFile mf;
        if (!kIsWeb && (x.path??'').isNotEmpty) {
          final path = x.path;
          final extis = ext(path??'');
          mf = await multi.MultipartFile.fromFile(
            path??'',
            filename: safeName(p.basename(path??'')),
            contentType: mediaTypeForExt(extis),
          );
        } else {
          // WEB: path may be empty; use bytes
          final nameGuess = x.name.isNotEmpty
              ? x.name
              : 'image_${DateTime.now().millisecondsSinceEpoch}.jpg';
          final extis = ext(nameGuess);
          mf = multi.MultipartFile.fromBytes(
            x.byte!,
            filename: safeName(nameGuess),
            contentType: mediaTypeForExt(extis),
          );
        }

        mediaFiles.add(mf);
      }
      final Map<String, dynamic> fields;
      fields ={
        "folder_name":folderName,
        "title":title,
        "user_company_id":  myCompany?.userCompanies?.userCompanyId,
        "key_words":  keywords,
        'file_path': mediaFiles, // array of docs
      };

      final formData = multi.FormData.fromMap(fields);

      Get.find<PostApiServiceImpl>()
          .uploadFolderMediaApiCall(dataBody: formData)
          .then((value) {
        Navigator.of(ctx).pop();
        isUploading.value  = false;
        customLoader.hide();
        Get.to(()=>FolderItemsScreen(folderData: folder),
          binding: BindingsBuilder(() {
            final tag = 'folder_${folder?.userGalleryId}';
            if (Get.isRegistered<GalleryItemController>(tag: tag)) {
              Get.delete<GalleryItemController>(tag: tag, force: true);
            }
            Get.put(GalleryItemController(folderData: folder), tag: tag);
          }),);

        toast(value.message ?? '');
      }).onError((error, stackTrace) {
        isUploading.value  = false;
        Get.back();
        customLoader.hide();
        errorDialog(error.toString());
      }).whenComplete(() {});

    } catch (e) {
      isUploading.value = false;
      errorDialog(e.toString());
    }
  }

  // Upload Media




  @override
  void onClose() {
    super.onClose();
    searchCtrl.dispose();
    tabController.dispose();
    scrollController.dispose();
    for (final c in _textCtrls.values) {
      c.dispose();
    }
    for (final f in _focusNodes.values) {
      f.dispose();
    }
  }

  Future<List<XFile>> pickWebImages({int maxFiles = 10}) async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      compressionQuality: 75,
      allowCompression: true,
      allowedExtensions: const [
        'jpg',
        'jpeg',
        'png',
        'webp',
        'JPG',
        "JPEG",
        "PNG",
        "WEBP"
      ],
      withData: true,
      withReadStream: false,
    );

    if (result == null || result.files.isEmpty) return [];

    final files = result.files.take(maxFiles).where((f) => f.bytes != null);
    final xfiles = <XFile>[];
    for (final f in files) {
      final String name = f.name;
      final Uint8List bytes = f.bytes!;
      final String mime = _guessImageMime(name);
      xfiles.add(XFile.fromData(
        bytes,
        name: name,
        mimeType: mime,
        length: bytes.length,
      ));
    }
    return xfiles;
  }

  String _guessImageMime(String name) {
    final lower = name.toLowerCase();
    if (lower.endsWith('.png')) return 'image/png';
    if (lower.endsWith('.webp')) return 'image/webp';
    if (lower.endsWith('.jpg') || lower.endsWith('.jpeg')) return 'image/jpeg';
    return 'image/*';
  }

  int maxBytes = 15 * 1024 * 1024;
  Future<List<PlatformFile>> pickWebDocs() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowCompression: true,
      compressionQuality: 75,
      allowedExtensions: [
        'pdf',
        'doc',
        'docx',
        'txt',
        'xls',
        'xlsx',
        'csv',
        'xml',
        'json',
        'ppt',
        'pptx',
        'zip',
        'html',
        'php',
        'js',
        'jsx',
        'css',
        'rar',
        'PDF',
        'DOC',
        'HTML',
        'PHP',
        'JS',
        'JSX',
        'CSS',
        'DOCX',
        'TXT',
        'XLS',
        'XLSX',
        'CSV',
        'XML',
        'JSON',
        'PPT',
        'PPTX',
        'ZIP',
        'RAR',
      ],
      withData: true,
      withReadStream: false,
    );
    if (result == null || result.files.isEmpty) return [];

    final f = result.files.single;

    // ✅ Scenario 1: path missing
    if (f.path == null) {
      errorDialog("❌ File path not found");
      return [];
    }
    if (f.size > maxBytes) {
      Dialogs.showSnackbar(Get.context!, "❌ File must be less than 15 MB");
      return [];
    }

    return result.files;
  }

  Future<void> pickDocument({FolderData? folder}) async {
    final permission = await requestStoragePermission();
    if (!permission) {
      errorDialog("❌ Storage permission denied");
      return;
    }

    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowCompression: true,
      compressionQuality: 75,
      withData: kIsWeb,
      allowedExtensions: [
        'pdf',
        'doc',
        'docx',
        'txt',
        'xls',
        'xlsx',
        'csv',
        'xml',
        'json',
        'ppt',
        'pptx',
        'zip',
        'html',
        'php',
        'js',
        'jsx',
        'css',
        'rar',
        'PDF',
        'DOC',
        'HTML',
        'PHP',
        'JS',
        'JSX',
        'CSS',
        'DOCX',
        'TXT',
        'XLS',
        'XLSX',
        'CSV',
        'XML',
        'JSON',
        'PPT',
        'PPTX',
        'ZIP',
        'RAR',
      ],
    );
    if (result == null || result.files.isEmpty) return;

    final f = result.files.single;

    // ✅ Scenario 1: path missing
    if (f.path == null) {
      errorDialog("❌ File path not found");
      return;
    }
    final actualBytes = await File(f.path!).length(); // reliable on mobile
    if (actualBytes > maxBytes) {
      Dialogs.showSnackbar(Get.context!, "❌ File must be less than 15 MB");
      return;
    }

    if (result != null && result.files.single.path != null) {
      final galle =  result.files.map((f) {
        return PickedFileItem(
          name: f.name,
          // byte: f.bytes,         // web always, mobile if withData true
          path: f.path,          // mobile path
          kind: PickedKind.image,
          url: '',
        );
      }).toList();

      final saveC = Get.isRegistered<SaveToGalleryController>()
          ? Get.find<SaveToGalleryController>()
          : Get.put(SaveToGalleryController());
      folder!=null? null:await saveC.hitApiToGetFolder(reset: true);
      if (galle.isNotEmpty) {
        // Navigator.of(Get.context!).pop();
        showDialog(
            context: Get.context!,
            builder: (_) => SaveToCustomFolderDialog(
              user: UserDataAPI(),
              filesImages: galle,
              isImage: false,
              isFromChat: false,
              multi: true,
              isDirect: folder!=null?false:true, folderData: folder,
            ));
        // see helper you’ll paste into your controller below
        // await controller.receivePickedDocuments(docs);
      }
      // uploadDocumentsApiCall(
      //   files: result.files,
      //   onProgress: (sent, total) {
      //     setUploadProgress(sent, total);
      //   },
      //   folderName: saveToGallControlller.selectedFolder?.folderName??'',
      //   mediaTitle: saveToGallControlller.docNameController.text.trim(),
      //   keywords: genre.genresString.value,
      //   folder:saveToGallControlller.selectedFolder,
      //
      // );

      isUploading.value = false;
    }
  }

  double uploadProgress = 0.0; // 0 → 100

  void setUploadProgress(int sent, int total) {
    if (total <= 0) return;
    uploadProgress = (sent / total) * 100;
    update(); // rebuild widgets using this controller
  }

  void resetUploadProgress() {
    uploadProgress = 0.0;
    update();
  }

  Future<void> handleOnShareWithinAccuchat({context}) async {
    final selectedUser = await showDialog<UserDataAPI>(
      context: Get.context!,
      builder: (_) => AllUserScreenDialog(),
    );
    if (selectedUser == null) return;
    Dialogs.showSnackbar(context, "Under development");

  }

}
