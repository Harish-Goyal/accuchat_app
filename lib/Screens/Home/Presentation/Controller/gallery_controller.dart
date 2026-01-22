import 'dart:io';
import 'dart:typed_data';

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
import '../../../../utils/helper_widget.dart';
import '../../../Chat/helper/dialogs.dart';
import '../../../Chat/models/gallery_node.dart';
import '../../../Chat/models/get_company_res_model.dart';
import '../../Models/get_folder_items_res_model.dart';
import '../../Models/get_folder_res_model.dart';
import '../View/folder_items_view.dart';
import 'company_service.dart';

class IndexedNode {
  final GalleryNode node;
  final List<GalleryNode> path; // ancestors from root to parent
  IndexedNode({required this.node, required this.path});
}

class GalleryController extends GetxController
    with GetSingleTickerProviderStateMixin {
  late TabController tabController;
  //folder tile
  final RxString renamingId = ''.obs;

  // controllers & focus per node
  final Map<String, TextEditingController> _textCtrls = {};
  final Map<String, FocusNode> _focusNodes = {};

  TextEditingController textCtrlFor(String id, String initial) {
    return _textCtrls.putIfAbsent(
        id, () => TextEditingController(text: initial));
  }

  FocusNode focusNodeFor(String id) {
    return _focusNodes.putIfAbsent(id, () => FocusNode());
  }

  void startRename({required String id, required String currentName}) {
    renamingId.value = id;

    final c = textCtrlFor(id, currentName);
    c.text = currentName;

    // focus + select all
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
      renamingId.value = '';
      return;
    }
    await onRename(newName);
    renamingId.value = '';
  }

  Future<void> renameFolder(String id, String name) async {
    // // await api.renameFolder(id, name);
    // // update in list
    // final idx = items.indexWhere((e) => e.id == id);
    // if (idx != -1) {
    //   items[idx].name = name;
    //    // if folders is RxList
    // }
  }

  void cancelRename() {
    renamingId.value = '';
  }

  // Stack of opened folders (root == empty)

  // List<GalleryNode> get items => _stack.isEmpty ? root : _stack.last.children;
  bool get isRoot => true;
  List<FolderData> get breadcrumbs => List.unmodifiable([]);

  void openFolder(FolderData folder) {
    if ((folder.folderName != null || folder.folderName != '')) return;
    (folderList ?? []).add(folder);
    update();
  }

  bool goUp() {
    if ((folderList ?? []).isNotEmpty) {
      (folderList ?? []).removeLast();
      update();
      return true;
    }
    return false;
  }

  void goToRoot() {
    if ((folderList ?? []).isNotEmpty) {
      (folderList ?? []).clear();
      update();
    }
  }

  void goToCrumb(int index) {
    // index inclusive within stack (0..last)
    if (index < 0 || index >= (folderList ?? []).length) return;
    (folderList ?? []).removeRange(index + 1, (folderList ?? []).length);
    update();
  }

  // Replace with your preview/viewer
  void openLeaf(GalleryNode node) {
    Get.snackbar('Open', node.name ?? '',
        snackPosition: SnackPosition.BOTTOM, duration: Duration(seconds: 6));
  }

  final TextEditingController searchCtrl = TextEditingController();
  String query = '';
  final List<IndexedNode> index = [];

  // Build a flat index for global search
  void _buildIndex() {
    index.clear();
    void walk(List<FolderData> nodes, List<FolderData> path) {
      // for (final n in nodes) {
      //   index.add(IndexedNode(node: n, path: List.unmodifiable(path)));
      //   if (n.isFolder) {
      //     walk(n.children, [...path, n]);
      //   }
      // }
    }
    walk((folderList ?? []), const []);
  }

  List<IndexedNode> get searchResults {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return const [];
    return index
        .where((e) => (e.node.name ?? '').toLowerCase().contains(q))
        .toList();
  }

  bool get isSearching => query.trim().isNotEmpty;
  bool isSearchingIcon = false;
  void onSearchChanged(String v) {
    query = v;
    update();
  }

  // Navigate to a found node's location
  void openSearchResult(IndexedNode hit) {
    // Move to the folder that contains the node (if any)
    // (folderList??[])
    //   ..clear()
    //   ..addAll(hit.path.where((p) => p.isFolder));
    // update();
    // final node = hit.node;
    // if (node.isFolder) {
    //   // If result is a folder, open into it
    //   openFolder(node);
    // } else {
    //   // If result is a file, keep current folder (its parent) and open the leaf
    //   openLeaf(node);
    // }
  }

  // Override lifecycle to wire search + build index
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
    _buildIndex();
    searchCtrl.addListener(() => onSearchChanged(searchCtrl.text));
  }

  CompanyData? myCompany = CompanyData();
  getCompany() {
    final svc = CompanyService.to;
    myCompany = svc.selected;
    update();
  }
//Create folder

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
      Get.back();
      customLoader.hide();
      resetPagination();
      hitApiToGetFolder();

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
      hitApiToGetFolder();
      toast(value.message ?? '');
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

      // ✅ If not scrollable yet, don't paginate
      if (pos.maxScrollExtent <= 0) return;

      // ✅ Trigger when user is near bottom
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

/*  hitApiToGetFolder() async {
    SystemChannels.textInput.invokeMethod('TextInput.hide');
    if (page.value == 1) {
      isLoading.value = true;
      folderList?.clear();
    }
    isPageLoading.value = true;
    Get.find<PostApiServiceImpl>()
        .getFolderApiCall(
            ucId: myCompany?.userCompanies?.userCompanyId, page: page)
        .then((value) async {
      isLoading.value = false;
      getFolderRes = value;
      if (value.data?.rows != null && (value.data?.rows ?? []).isNotEmpty) {
        if (page.value == 1) {
          folderList.assignAll(getFolderRes.data?.rows ?? []);
        } else {
          folderList.addAll(getFolderRes.data?.rows ?? []);
        }

        page++; // next page
      } else {
        hasMore.value = false;
        isPageLoading.value = false;
      }
      isLoading.value = false;
      isPageLoading.value = false;
    }).onError((error, stackTrace) {
      isLoading.value = false;
      isPageLoading.value = false;
    });
  }*/

//Create folder

// Folder Items
  FolderItemsResModel folderItemsRes = FolderItemsResModel();

  List<FolderData>? folderItems = [];

  RxBool isLoadingItems = false.obs;

  hitApiToGetFolderItems(folderName) async {
    isLoadingItems.value = true;
    Get.find<PostApiServiceImpl>()
        .getFolderItemsApiCall(
            page: 1,
            ucID: myCompany?.userCompanies?.userCompanyId,
            folderName: folderName)
        .then((value) {
      isLoadingItems.value = false;
      update();
      folderItemsRes = value;
      folderItems = folderItemsRes.data?.rows ?? [];
      Get.to(
        () => FolderItemsScreen(
          folderName: folderName,
        ),
      );
      update();
    }).onError((error, stackTrace) {
      isLoadingItems.value = false;
      update();
      customLoader.hide();
      errorDialog(error.toString());
    }).whenComplete(() {});
  }

  final RxString openedFolder = "".obs;

  Future<void> onFolderTap(String folderName) async {
    // toggle close
    if (openedFolder.value == folderName) {
      openedFolder.value = "";
      return;
    }

    openedFolder.value = folderName;
    await hitApiToGetFolderItems(folderName);
  }

  //Folder Items
  void _ensureScrollableAndPrefetch() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!scrollController.hasClients) return;
      final pos = scrollController.position;

      // still not scrollable, but more data exists => prefetch next page
      if (pos.maxScrollExtent <= 0 && hasMore.value && !isPageLoading.value) {
        hitApiToGetFolder();
      }
    });
  }

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
      // best effort mime guess
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
      allowMultiple: false,
      type: FileType.custom,
      allowCompression: true,
      compressionQuality: 75,
      allowedExtensions: const [
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
        'rar',
        'PDF',
        'DOC',
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

  Future<void> pickDocument() async {
    final permission = await requestStoragePermission();
    if (!permission) {
      errorDialog("❌ Storage permission denied");
      return;
    }

    // isUploading = true;
    // update();

    final result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
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
        'rar',
        'PDF',
        'DOC',
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
      File file = File(result.files.single.path!);
      var ext = file.path.split('.').last;
      final fileName =
          'DOC_${DateTime.now().millisecondsSinceEpoch}_${result.files.single.name}';
      // uploadDocumentsApiCall(
      //   files: result.files,
      //   onProgress: (sent, total) {
      //     setUploadProgress(sent, total);
      //   },
      // );
      //
      // isUploading = false;
      update();
    }
  }
}
