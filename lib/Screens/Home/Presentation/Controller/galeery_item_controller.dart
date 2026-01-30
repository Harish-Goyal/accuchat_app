import 'package:get/get.dart';
import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:AccuChat/Screens/Chat/screens/chat_tasks/Presentation/Controllers/save_in_accuchat_gallery_controller.dart';
import 'package:AccuChat/Screens/Home/Presentation/Controller/genere_controller.dart';
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
import '../../../../utils/custom_flashbar.dart';
import '../../../../utils/helper.dart';
import '../../../../utils/helper_widget.dart';
import '../../../Chat/helper/dialogs.dart';
import '../../../Chat/models/gallery_node.dart';
import '../../../Chat/models/get_company_res_model.dart';
import '../../../Chat/screens/auth/models/get_uesr_Res_model.dart';
import '../../../Chat/screens/chat_tasks/Presentation/dialogs/save_in_gallery_dialog.dart';
import '../../Models/get_folder_items_res_model.dart';
import '../../Models/get_folder_res_model.dart';
import '../../Models/pickes_file_item.dart';
import '../View/folder_items_view.dart';
import 'company_service.dart';
import '../../../../utils/helper.dart';

class GalleryItemController extends GetxController{
  GalleryItemController({required this.folderData});

  FolderData? folderData;

  FolderItemsResModel folderItemsRes = FolderItemsResModel();

  List<FolderData>? folderItems = [];
  final filterFolderItems = <FolderData>[].obs;
  List<FolderData>? searchResultsItems = [];
  RxBool isLoadingItems = false.obs;
  RxBool hasMoreItems = false.obs;
  RxBool isPageLoadingItems = false.obs;
  RxInt pageItem = 1.obs;
  late ScrollController scrollControllerItem;
  CompanyData? myCompany = CompanyData();
  TextEditingController txtController = TextEditingController();


  @override
  void onInit() {

    _init();
    super.onInit();
  }

  _init() {
    scrollControllerItem = ScrollController();
    getCompany();
    resetPagination();
    hitApiToGetFolderItems(reset: true);
    scrollListenerItem();
  }

  void resetPagination() {
    pageItem.value = 1;
    hasMoreItems.value = true;
    filterFolderItems.clear();
    isLoadingItems.value = true;
  }
  getCompany() {
    final svc = CompanyService.to;
    myCompany = svc.selected;
    update();
  }
  void scrollListenerItem() {
    scrollControllerItem.addListener(() {
      if (!scrollControllerItem.hasClients) return;

      final pos = scrollControllerItem.position;

      // ✅ If not scrollable yet, don't paginate
      if (pos.maxScrollExtent <= 0) return;

      // ✅ Trigger when user is near bottom
      const threshold = 200.0;
      final nearBottom = pos.extentAfter < threshold;

      if (nearBottom && !isPageLoadingItems.value && hasMoreItems.value) {
        hitApiToGetFolderItems();
      }
    });
  }


  final TextEditingController itemSearchCtrl = TextEditingController();
  RxString itemQuery = ''.obs;
  Timer? searchDelay;
  RxBool get isSearchingItem =>(itemQuery.value.trim().isNotEmpty).obs;
  RxBool isSearchingIconItem = false.obs;
  void onSearchItem(String query,FolderData? folder) {
    searchDelay?.cancel();
    searchDelay = Timer(const Duration(milliseconds: 400), () {
      itemQuery.value = query.trim().toLowerCase();
      pageItem.value = 1;
      // hasMore = false;
      filterFolderItems.clear();
      hitApiToGetFolderItems(searchText: itemQuery.value.isEmpty ? null : itemQuery.value,reset: true);
    });
  }

  Future<void> hitApiToGetFolderItems({bool reset = false, String? searchText}) async {
    if (isPageLoadingItems.value) return;

    if (reset) {
      pageItem.value = 1;
      hasMoreItems.value = true;
      filterFolderItems.clear();
    }

    if (!hasMoreItems.value) return;

    isPageLoadingItems.value = true;
    if (pageItem.value == 1) isLoadingItems.value = true;

    try {
      final res = await Get.find<PostApiServiceImpl>().getFolderItemsApiCall(
        page: pageItem.value,
        ucID: myCompany?.userCompanies?.userCompanyId,
        folderName: folderData?.folderName,
        searchText: searchText,
      );

      // ✅ Map rows to FolderData if API returns Map/dynamic
      final rows = (res.data?.rows ?? []);

      if (pageItem.value == 1) {
        filterFolderItems.assignAll(rows); // ✅ better than addAll for first page
      } else {
        filterFolderItems.addAll(rows);
      }

      if (rows.isNotEmpty) {
        pageItem.value++;
        const pageSize = 15;
        hasMoreItems.value = rows.length == pageSize;
      } else {
        hasMoreItems.value = false;
      }

    } catch (e) {
      // handle/log
    } finally {
      isLoadingItems.value = false;        // ✅ set loading false at the end
      isPageLoadingItems.value = false;
    }
  }

/*  Future<void> hitApiToGetFolderItems({bool reset = false,searchText}) async {
    if (isPageLoadingItems.value) return;

    if (reset) {
      pageItem.value = 1;
      hasMoreItems.value = true;
      isLoadingItems.value = true;
      filterFolderItems?.clear();
    }

    if (!hasMoreItems.value) return;

    isPageLoadingItems.value = true;
    if (pageItem.value == 1) isLoadingItems.value = true;
    update();
    try {
      final res = await Get.find<PostApiServiceImpl>().getFolderItemsApiCall(
          page: pageItem.value,
          ucID: myCompany?.userCompanies?.userCompanyId,
          folderName: folderData?.folderName,searchText: searchText);

      isLoadingItems.value = false;

      final rows = res.data?.rows ?? [];

      if (rows.isNotEmpty) {
        filterFolderItems?.addAll(rows);
        pageItem.value++;
        const pageSize = 15;
        hasMoreItems.value = rows.length == pageSize;
      } else {
        hasMoreItems.value= false;
      }
      update();
      _ensureScrollableAndPrefetch();
    } catch (e) {
      isLoadingItems.value = false;
      update();
    } finally {
      isPageLoadingItems.value = false;
      update();
    }
  }*/

  void _ensureScrollableAndPrefetch() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!scrollControllerItem.hasClients) return;
      final pos = scrollControllerItem.position;

      // still not scrollable, but more data exists => prefetch next page
      if (pos.maxScrollExtent <= 0 && hasMoreItems.value && !isPageLoadingItems.value) {
        hitApiToGetFolderItems();
      }
    });
  }


/*  hitApiToGetFolderItems({searchText}) async {
    isLoadingItems.value = true;
    Get.find<PostApiServiceImpl>()
        .getFolderItemsApiCall(
        page: pageItem,
        ucID: myCompany?.userCompanies?.userCompanyId,
        folderName: folderData?.folderName,searchText: searchText)
        .then((value) {
      isLoadingItems.value = false;
      update();
      folderItemsRes = value;
      folderItems = folderItemsRes.data?.rows ?? [];
      filterFolderItems.addAll(folderItems??[]);
      Get.to(
            () => FolderItemsScreen(
          folderData: folderData,
        ),
      );
      update();
    }).onError((error, stackTrace) {
      isLoadingItems.value = false;
      update();
      customLoader.hide();
      errorDialog(error.toString());
    }).whenComplete(() {});
  }*/

  hitApiToEditFolderItems(FolderData folder,id,newFolderName) async {
    customLoader.show();
    var reqData = {
      "user_company_id": myCompany?.userCompanies?.userCompanyId,
      "user_gallery_id":id,
      "title": newFolderName,
      // "new_name": newFolderName,
    };
    Get.find<PostApiServiceImpl>()
        .editFolderItemsApiCall(dataBody: reqData)
        .then((value) {
      customLoader.hide();
      resetPagination();
      hitApiToGetFolderItems(reset: true);
      // toast(value.message ?? '');
      update();
    }).onError((error, stackTrace) {
      update();
      Get.back();
      customLoader.hide();
      errorDialog(error.toString());
    }).whenComplete(() {});
  }

  hitApiToDeleteFolderItems(FolderData folder,id) async {
    customLoader.show();
    var reqData = {
      "user_company_id": myCompany?.userCompanies?.userCompanyId,
      "user_gallery_id":id,
      // "new_name": newFolderName,
    };
    Get.find<PostApiServiceImpl>()
        .deleteFolderItemsApiCall(dataBody: reqData)
        .then((value) {
      Get.back();
      customLoader.hide();
      resetPagination();
      hitApiToGetFolderItems(reset: true);
      // toast(value.message ?? '');
      update();
    }).onError((error, stackTrace) {
      update();
      Get.back();
      customLoader.hide();
      errorDialog(error.toString());
    }).whenComplete(() {});
  }

  RxBool isUploading = false.obs;
  List<Map<String, dynamic>> attachedFiles = [];
  List<XFile> images = [];
  final List<PlatformFile> webDocs = [];
  //Upload media
  Future<void> uploadDocumentsApiCall({
    bool isDirect=false,
    required BuildContext ctx,
    required List<PickedFileItem> files, void Function(int sent, int total)? onProgress, folderName, keywords, mediaTitle,FolderData? folder}) async {
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
        "title":txtController.text.trim(),
        "user_company_id":  myCompany?.userCompanies?.userCompanyId,
        "key_words":  keywords,
        'file_path': docParts, // array of docs
      });

      Get.find<PostApiServiceImpl>()
          .uploadFolderMediaApiCall(dataBody: formData)
          .then((value) {
        Navigator.of(ctx).pop();
        isUploading.value  = false;
        customLoader.hide();
        resetPagination();
       hitApiToGetFolderItems(reset: true);

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
    // Hide keyboard
    SystemChannels.textInput.invokeMethod('TextInput.hide');

    if (images.isEmpty) {
      toast('Please select at least one image');
      return;
    }

    try {
      isUploading.value = true;
      // Build Multipart for each XFile (supports web+mobile)
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
        customLoader.hide();
        Navigator.of(ctx).pop();
        isUploading.value  = false;
        resetPagination();
        hitApiToGetFolderItems(reset: true);
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

}