import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../models/gallery_create.dart';
import '../Widgets/create_custom_folder.dart';


class SaveToGalleryController extends GetxController {

  final formKeyDoc = GlobalKey<FormState>();

  TextEditingController docNameController = TextEditingController();
  final TextEditingController newFolderCtrl = TextEditingController();
  final FocusNode newFolderFocus = FocusNode();

  String? currentParentId;            // null = Root
  List<GalleryFolder> breadcrumb = []; // Root -> ...
  List<GalleryFolder> currentFolders = []; // UI ye list show kare


  // Gallery
  final List<GalleryFolder> folders = [
    GalleryFolder(id: 'fld_1', name: 'Invoices', parentId: null, createdAt: DateTime.now()),
    GalleryFolder(id: 'fld_2', name: 'Design Assets', parentId: null, createdAt: DateTime.now()),
    GalleryFolder(id: 'fld_3', name: 'Client Docs', parentId: null, createdAt: DateTime.now()),

    // children of Invoices
    GalleryFolder(id: 'fld_11', name: '2025', parentId: 'fld_1', createdAt: DateTime.now()),
    GalleryFolder(id: 'fld_12', name: '2024', parentId: 'fld_1', createdAt: DateTime.now()),
  ];


  String? selectedFolderId;
  bool showCreateNew = false;
  String? validationError;

  void selectFolder(String? id) {
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
    return !folders
        .any((f) => f.name.toLowerCase() == name.trim().toLowerCase());
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

  GalleryFolder? createFolder() {
    // Run validators
    final valid = formKeyDoc.currentState?.validate() ?? false;
    if (!valid) return null;

    final name = newFolderCtrl.text.trim();
    final id = 'fld_${Random().nextInt(999999)}';
    final folder = GalleryFolder(id: id, name: name, createdAt: DateTime.now(),parentId: Random().nextInt(222).toString());
    folders.insert(0, folder);

    // Auto-select the newly created folder
    selectedFolderId = folder.id;

    // Reset create-new UI
    showCreateNew = false;
    newFolderCtrl.clear();
    update();
    return folder;
  }

  GalleryFolder? get selectedFolder {
    if (selectedFolderId == null) return null;
    return folders.firstWhereOrNull((f) => f.id == selectedFolderId);
  }

  void onTapSaveToFolder(BuildContext context, user) async {
     Get.back();

      Get.snackbar('Saved', 'Item saved w2',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.white,
          colorText: Colors.black87,duration: Duration(seconds: 6));
  }

  void loadFolders({String? parentId}) {
    currentParentId = parentId;
    currentFolders = folders.where((f) => f.parentId == parentId).toList();
    update();
  }

  void openFolder(GalleryFolder folder) {
    // ✅ Guard: same folder already open, don't push again
    if (currentParentId == folder.id) return;

    // ✅ Guard: if last breadcrumb same, don't duplicate
    if (breadcrumb.isNotEmpty && breadcrumb.last.id == folder.id) return;

    breadcrumb.add(folder);
    loadFolders(parentId: folder.id);
  }

  void goRoot() {
    breadcrumb.clear();
    loadFolders(parentId: null);
  }

  void goToCrumb(int index) {
    if (index < 0) {
      goRoot();
      return;
    }
    final target = breadcrumb[index];
    breadcrumb = breadcrumb.take(index + 1).toList();
    loadFolders(parentId: target.id);
  }


  void createFolderInline() {
    final name = newFolderCtrl.text.trim();

    if (name.isEmpty) {
      validationError = "Folder name can't be empty";
      update();
      return;
    }

    // unique check (optional)
    final exists = folders.any((f) =>
    f.parentId == currentParentId &&
        f.name.toLowerCase() == name.toLowerCase());
    if (exists) {
      validationError = "Folder already exists";
      update();
      return;
    }

    final id = 'fld_${Random().nextInt(999999)}';
    final folder = GalleryFolder(
      id: id,
      name: name,
      parentId: currentParentId, // ✅ create in current level
      createdAt: DateTime.now(),
    );

    folders.insert(0, folder);

    // refresh list
    loadFolders(parentId: currentParentId);

    // auto select created folder
    selectedFolderId = folder.id;

    // close create UI
    newFolderCtrl.clear();
    showCreateNew = false;
    validationError = null;
    update();
  }




  @override
  void onInit() {
    super.onInit();
    loadFolders(parentId: null);
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
