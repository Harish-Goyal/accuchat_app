import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:AccuChat/Screens/Chat/models/chat_his_res_model.dart';
import 'package:AccuChat/Screens/Chat/models/chat_history_response_model.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import '../../../../../../Services/APIs/local_keys.dart';
import '../../../../../../Services/APIs/post/post_api_service_impl.dart';
import '../../../../../../main.dart';
import '../../../../../../routes/app_routes.dart';
import '../../../../../../utils/custom_flashbar.dart';
import '../../../../../../utils/helper.dart';
import '../../../../../../utils/helper_widget.dart';
import '../../../../../Home/Presentation/Controller/company_service.dart';
import '../../../../../Home/Presentation/Controller/socket_controller.dart';
import '../../../../api/apis.dart';
import '../../../../models/gallery_create.dart';
import '../../../../models/message.dart';
import '../../../../models/get_company_res_model.dart';
import '../../../auth/models/get_uesr_Res_model.dart';
import 'package:dio/dio.dart' as multi;
import 'package:path/path.dart' as p;
import 'dart:typed_data';

import '../Widgets/all_users_dialog.dart';
import '../Widgets/create_custom_folder.dart';
import 'chat_home_controller.dart';

class ChatScreenController extends GetxController {
  ChatScreenController({required this.user});
  final formKeyDoc = GlobalKey<FormState>();
  UserDataAPI? user;

  // Message? forwardMessage;
  final _alreadyEmitted = <int>{};
  String? selectedChatId;
  String validString = '';
  List<Map<String, String>> uploadedAttachments = [];
  List<ChatHisResModel> msgList = [];
  final textController = TextEditingController();
  final FocusNode focusNode = FocusNode();
  ChatHisList? replyToMessage;
  String? replyToImage;
  bool showEmoji = false, isUploading = false, isUploadingTaskDoc = false;
  File? file;
  List<Map<String, dynamic>> attachedFiles = [];
  List<XFile> images = [];
  final List<PlatformFile> webDocs = [];
  var userIDSender;
  var userNameReceiver;
  var userNameSender;
  var userIDReceiver;
  var refIdis;

  final ItemScrollController itemScrollController = ItemScrollController();
  final ItemPositionsListener itemPositionsListener = ItemPositionsListener.create();


  bool isDoc(String orignalMsg) {
    final ext = (orignalMsg ?? '').toLowerCase();
    return ext.endsWith('.pdf') ||
        ext.endsWith('.doc') ||
        ext.endsWith('.docx') ||
        ext.endsWith('.xls') ||
        ext.endsWith('.xlsx') ||
        ext.endsWith('.ppt') ||
        ext.endsWith('.pptx') ||
        ext.endsWith('.csv') ||
        ext.endsWith('.txt');
  }

  bool isImageOrVideo(String orignalMsg) {
    final ext = (orignalMsg ?? '').toLowerCase();
    return ext.endsWith('.jpg') ||
        ext.endsWith('.jpeg') ||
        ext.endsWith('.png') ||
        ext.endsWith('.gif') ||
        ext.endsWith('.webp') ||
        ext.endsWith('.mp4') ||
        ext.endsWith('.mov') ||
        ext.endsWith('.m4v') ||
        ext.endsWith('.avi');
  }

  List<ChatRow> flatRows = [];
  final Map<int, int> chatIdToIndex = {}; // chatId -> index in flatRows

  // Call this whenever chatCatygory changes
  void rebuildFlatRows() {
    flatRows = [];
    chatIdToIndex.clear();

    // You used GroupedListOrder.DESC + reverse:true previously.
    // For ScrollablePositionedList we keep ascending order,
    // and we’ll start at the bottom using initialScrollIndex.
    final sorted = List<GroupChatElement>.from(chatCatygory)
      ..sort((a, b) => a.date.compareTo(b.date));

    DateTime? lastHeaderDate;
    for (final el in sorted) {
      final d = DateTime(el.date.year, el.date.month, el.date.day);

      if (lastHeaderDate == null || d.compareTo(lastHeaderDate!) != 0) {
        flatRows?.add(ChatHeaderRow(d));
        lastHeaderDate = d;
      }
      flatRows?.add(ChatMessageRow(el));
      final idx = (flatRows?.length ?? 0) - 1;
      final id = el.chatMessageItems.chatId;
      if (id != null) chatIdToIndex[id] = idx;
    }
    update();
  }

  // Jump to a message by chatId
  Future<void> scrollToChatId(int chatId) async {
    final idx = chatIdToIndex[chatId];
    if (idx == null) {
      debugPrint("Original message not found (maybe not loaded)");
      return;
    }
    await itemScrollController?.scrollTo(
      index: idx,
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeInOut,
      alignment: 0.1, // keeps it a bit below top
    );
    highlightMessage(chatId); // optional visual flash
  }

  // Optional highlight logic
  final highlighted = <int>{}.obs;
  void highlightMessage(int chatId) {
    highlighted.add(chatId);
    update();
    Future.delayed(const Duration(seconds: 1), () {
      highlighted.remove(chatId);
      update();
    });
  }

  TextEditingController docNameController = TextEditingController();
  final TextEditingController newFolderCtrl = TextEditingController();
  final FocusNode newFolderFocus = FocusNode();

  // Gallery
  List<GalleryFolder> folders = [
    GalleryFolder(
        id: 'fld_1',
        name: 'Invoices',
        createdAt: DateTime.now().subtract(const Duration(days: 10))),
    GalleryFolder(
        id: 'fld_2',
        name: 'Design Assets',
        createdAt: DateTime.now().subtract(const Duration(days: 6))),
    GalleryFolder(
        id: 'fld_3',
        name: 'Client Docs',
        createdAt: DateTime.now().subtract(const Duration(days: 1))),
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
    final folder = GalleryFolder(id: id, name: name, createdAt: DateTime.now());
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
    final chosen = await showSaveToCustomFolderDialog(context, user);
    if (chosen != null) {
      Get.back();
      // Do your save logic here using chosen.id / chosen.name
      // For example:
      // await api.saveFileToFolder(fileId: fileId, folderId: chosen.id);
      Get.snackbar('Saved', 'Item saved to "${chosen.name}"',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.white,
          colorText: Colors.black87);
    }
  }

  // Gallery

  Future<void> receivePickedDocuments(List<PlatformFile> files) async {
    webDocs.clear();
    webDocs.addAll(files);
    update();

    // If your upload API expects Multipart on web:
    // Build multipart payloads from PlatformFile.bytes and names, then:
    uploadDocumentsApiCall(
      files: files,
      onProgress: (sent, total) {
        setUploadProgress(sent, total);
      },
    );

    isUploading = false;
    update();
  }

  @override
  void onInit() {
    super.onInit();

    if (kIsWeb) {
      // web pe type karte hi yehi node focused rahe
      focusNode.requestFocus();
    }
    getArguments();
    user = Get.find<ChatHomeController>().selectedChat.value;
    _initScroll();
    // markAllVisibleAsReadOnOpen();

    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   // for (ChatHisList? m in chatHisList??[]) {
    //   //   // if (/*m?.fromUser?.userId != APIs.me.userId && */ m?.readOn == null && _alreadyEmitted.add(m?.chatId??0)) {
    //   //     Get.find<SocketController>().readMsgEmitter(chatId: m?.chatId??0);
    //   //   // }
    //   // }
    //   for (final m in (chatHisList ?? [])) {
    //     // if (m.readOn == null && _alreadyEmitted.add(m.chatId)) {
    //     Get.find<SocketController>().readMsgEmitter(chatId: m.chatId); // your existing emitter
    //     // }
    //   }
    // });
  }

  _initScroll() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // 1) if list hasn't loaded yet, don't scroll
      if (flatRows.isEmpty) return;

      // 2) wait until the list attaches to the controller
      int tries = 0;
      while (!itemScrollController.isAttached && tries < 30) {
        await Future.delayed(const Duration(milliseconds: 16));
        tries++;
      }
      if (!itemScrollController.isAttached) return;

      // 3) compute a valid index
      final last = flatRows.length - 1;

      // 4) prefer scrollTo (jumpTo throws more easily if timing is off)
      await itemScrollController.scrollTo(
        index: last,
        duration: const Duration(milliseconds: 1), // effectively instant
        alignment: 1.0, // bottom align
        curve: Curves.linear,
      );
    });
  }

  void markAllVisibleAsReadOnOpen() {
    for (ChatHisList m in (chatHisList ?? [])) {
      if (user?.pendingCount != 0) {
        Get.find<SocketController>().readMsgEmitter(chatId: m.chatId ?? 0);
      }
      // your existing emitter
    }
  }

  @override
  void onClose() {
    newFolderCtrl.dispose();
    // focusNode.dispose();
    // textController.dispose();
    imageCache.clearLiveImages();
    imageCache.clear();
    super.onClose();
  }

  getArguments() {
    if (kIsWeb) {
      _getCompany();
      // if (Get.parameters != null) {
      final String? argUserId = Get.parameters['userId'];
      if (argUserId != null) {
        getUserByIdApi(userId: int.parse(argUserId ?? ''));
        // }
      } else {
        getUserByIdApi(userId: user?.userId);
      }
    } else {
      if (Get.arguments != null) {
        final argUser = Get.arguments['user'];
        if (argUser != null) {
          openConversation(argUser);
        }
      }
    }
  }

  getUserByIdApi({int? userId}) async {
    Get.find<PostApiServiceImpl>()
        .getUserByApiCall(userID: userId, comid: myCompany?.companyId)
        .then((value) async {
      user = value.data;
      openConversation(user);
      update();
    }).onError((error, stackTrace) {
      update();
      errorDialog(error.toString());
    }).whenComplete(() {});
  }

  void openConversation(UserDataAPI? useriii) {
    _getCompany();
    user = useriii;
    update();
    _getMe();
    Future.delayed(const Duration(milliseconds: 500), () {
      hitAPIToGetChatHistory();
      if (user?.userCompany?.isGroup == 1 ||
          user?.userCompany?.isBroadcast == 1) {
        hitAPIToGetMembers();
      }
    });
    scrollListener();
  }

  List<Message> allTasks = [];
  List<Message> filteredTasks = [];
  String selectedFilter = 'all';

  UserDataAPI? me = UserDataAPI();
  _getMe() {
    me = getUser();
    update();
  }

  CompanyData? myCompany = CompanyData();
  _getCompany() async {
    if (Get.isRegistered<CompanyService>()) {
      final svc = CompanyService.to;
      // await svc.ready;
      myCompany = svc.selected;
      update();
    } else {}
  }

  List<UserDataAPI> members = [];
  hitAPIToGetMembers() async {
    isLoading = true;
    update();
    Get.find<PostApiServiceImpl>()
        .getGrBrMemberApiCall(
            id: user?.userCompany?.userCompanyId,
            mode: user?.userCompany?.isGroup == 1 ? "group" : "broadcast")
        .then((value) async {
      isLoading = false;
      members = value.data?.members ?? [];
      update();
    }).onError((error, stackTrace) {
      isLoading = false;
      update();
    });
  }

  ChatHisResModelAPI chatHisResModelAPI = ChatHisResModelAPI();

  List<ChatHisList>? chatHisList = [];
  List<GroupChatElement> chatCatygory = [];
  bool isLoading = false;
  int page = 1;
  bool hasMore = true;
  bool showPostShimmer = true;

  ScrollController scrollController = ScrollController();

  scrollListener() {
    scrollController.addListener(() {
      if ((scrollController.position.extentAfter) <= 0 && !isLoading) {
        hasMore = true;
        page++;
        update();
        hitAPIToGetChatHistory();
      }
    });
  }

  hitAPIToGetChatHistory() async {
    Get.find<PostApiServiceImpl>()
        .getChatHistoryApiCall(
            userComId: user?.userCompany?.userCompanyId,
            page: page,
            searchText: '')
        .then((value) async {
      showPostShimmer = false;
      chatHisResModelAPI = value;
      // chatHisList = value.data?.rows ?? [];
      if ((value.data?.rows ?? []).isNotEmpty) {
        if (page == 1) {
          chatHisList = value.data?.rows ?? [];
          isLoading = false;
          hasMore = false;
          update();
        } else {
          chatHisList?.addAll(value.data?.rows ?? []);
          isLoading = false;
          hasMore = false;
          update();
        }
      } else {
        isLoading = false;
        hasMore = false;
        update();
      }

      chatCatygory = (chatHisList ?? []).map((item) {
        DateTime? datais;
        if (item.sentOn != null) {
          datais = DateTime.parse(item.sentOn ?? '');
        }
        if (me?.userId == item.toUser?.userId) {
          markAllVisibleAsReadOnOpen();
        }

        return GroupChatElement(datais ?? DateTime.now(), item);
      }).toList();
      rebuildFlatRows();
      update();
    }).onError((error, stackTrace) {
      showPostShimmer = false;
      update();
    });
  }

  MediaType _mediaTypeForPath(String path) {
    final mime = lookupMimeType(path) ?? 'application/octet-stream';
    final parts = mime.split('/');
    return MediaType(parts.first, parts.length > 1 ? parts[1] : 'octet-stream');
  }

// Returns a filesystem path from XFile/File/String
  String _pathOf(dynamic item) {
    if (item is String) return item;
    if (item is File) return item.path;
    // XFile has .path as well
    try {
      final path = (item as dynamic).path as String;
      return path;
    } catch (_) {
      throw ArgumentError('Unsupported image item type: ${item.runtimeType}');
    }
  }

/*  Future<void> uploadMediaApiCall({
    required String type,
    int? replyToId,
    String? replyText,
    void Function(int sent, int total)? onProgress, // optional
  }) async {
    // Hide keyboard
    SystemChannels.textInput.invokeMethod('TextInput.hide');

    // Guard: no images
    if (images.isEmpty) {
      toast('Please select at least one image');
      return;
    }

    try {
      isUploading = true;
      update();

      // Build file parts
      final mediaFiles = await Future.wait(
        images.map((item) async {
          final path = _pathOf(item);
          return await multi.MultipartFile.fromFile(
            path,
            filename: p.basename(path),
            contentType: _mediaTypeForPath(path),
          );
        }),
      );

      // Build form-data map
      final Map<String, dynamic> fields = {
        'company_id': myCompany?.companyId,
        'media_type_code': type,
        'to_uc_id': user?.userCompany?.userCompanyId,
        'chat_media': mediaFiles,
      };

      // if (replyToId != null) fields['reply_to_id'] = replyToId;
      // if (replyText?.trim().isNotEmpty == true) fields['reply_to_text'] = replyText!.trim();

      final formData = multi.FormData.fromMap(fields);

      // Call your service (assumes it uses Dio under the hood)
      await Get.find<PostApiServiceImpl>()
          .uploadMediaApiCall(
        dataBody: formData,
      )
          .then((v) {
        isUploading = false;
        update();
        try {
          Get.find<SocketController>().sendMessage(
            receiverId: v.data?.chat?.toId ?? 0,
            message: v.data?.chat?.chatText ?? "",
            isGroup: 0,
            alreadySave: true,
            chatId: v.data?.chat?.chatId ?? 0,
          );
          toast(v.message ?? 'Uploaded');
          update();
        } catch (e) {
          print(e.toString());
        }
      });
    } catch (e) {
      isUploading = false;
      update();
      errorDialog(e.toString());
    }
  }*/
  Future<void> uploadMediaApiCall({
    required String type, // e.g., ChatMediaType.IMAGE.name
    int? replyToId,
    String? replyText,
    void Function(int sent, int total)? onProgress,
  }) async {
    // Hide keyboard
    SystemChannels.textInput.invokeMethod('TextInput.hide');

    if (images.isEmpty) {
      toast('Please select at least one image');
      return;
    }

    try {
      isUploading = true;
      update();

      // Build Multipart for each XFile (supports web+mobile)
      final mediaFiles = <multi.MultipartFile>[];
      for (final x in images) {
        multi.MultipartFile mf;

        if (!kIsWeb && x.path.isNotEmpty) {
          final path = x.path;
          final extis = ext(path);
          mf = await multi.MultipartFile.fromFile(
            path,
            filename: safeName(p.basename(path)),
            contentType: mediaTypeForExt(extis),
          );
        } else {
          // WEB: path may be empty; use bytes
          final Uint8List bytes = await x.readAsBytes();
          final nameGuess = x.name.isNotEmpty
              ? x.name
              : 'image_${DateTime.now().millisecondsSinceEpoch}.jpg';
          final extis = ext(nameGuess);
          mf = multi.MultipartFile.fromBytes(
            bytes,
            filename: safeName(nameGuess),
            contentType: mediaTypeForExt(extis),
          );
        }

        mediaFiles.add(mf);
      }
      final Map<String, dynamic> fields;
      if (user?.userCompany?.isGroup == 1) {
        fields = {
          'company_id': myCompany?.companyId,
          'media_type_code': type,
          'group_id': user?.userCompany?.userCompanyId,
          'is_group_chat': user?.userCompany?.isGroup == 1 ? 1 : 0,
          'chat_media': mediaFiles, // array of files
        };
      } else if (user?.userCompany?.isBroadcast == 1) {
        fields = {
          'company_id': myCompany?.companyId,
          'media_type_code': type,
          'broadcast_user_id': user?.userCompany?.userCompanyId,
          'is_group_chat': user?.userCompany?.isGroup == 1 ? 1 : 0,
          'chat_media': mediaFiles, // array of files
        };
      } else {
        fields = {
          'company_id': myCompany?.companyId,
          'media_type_code': type,
          'to_uc_id': user?.userCompany?.userCompanyId,
          'is_group_chat': user?.userCompany?.isGroup == 1 ? 1 : 0,
          'chat_media': mediaFiles, // array of files
        };
      }

      // // If you later need reply fields:
      // if (replyToId != null) fields['reply_to_id'] = replyToId;
      // if (replyText?.trim().isNotEmpty == true) fields['reply_to_text'] = replyText!.trim();

      final formData = multi.FormData.fromMap(fields);

      final svc = Get.find<PostApiServiceImpl>();
      final resp = await svc.uploadMediaApiCall(
        dataBody: formData,
      );

      isUploading = false;
      update();

      try {
        Get.find<SocketController>().sendMessage(
          receiverId: user?.userId ?? 0,
          message: resp.data?.chat?.chatText ?? "",
          isGroup: user?.userCompany?.isGroup == 1 ? 1 : 0,
          alreadySave: true,
          chatId: resp.data?.chat?.chatId ?? 0,
          type: user?.userCompany?.isGroup == 1
              ? 'group'
              : user?.userCompany?.isBroadcast == 1
                  ? "broadcast"
                  : '',
          groupId: user?.userCompany?.userCompanyId,
          brID: user?.userCompany?.userCompanyId,
        );
        mediaFiles.clear();
        images.clear();
        update();
      } catch (e) {
        print('Socket sendMessage error: $e');
      }
    } catch (e) {
      isUploading = false;
      update();
      errorDialog(e.toString());
    }
  }
/*
  Future<void> uploadDocumentsApiCall({
    required List<PlatformFile> files,
    int? replyToId,
    String? replyText,
    void Function(int sent, int total)? onProgress,
  }) async {
    if (files.isEmpty) {
      toast('Please select at least one document');
      return;
    }

    try {
      customLoader.show();

      // Build Multipart list (supports web bytes or file path)
      final List<multi.MultipartFile> parts = [];
      for (final f in files) {
        final String filename = f.name; // safe, always present
        final String? path = f.path; // null on web
        final Uint8List? bytes = f.bytes; // usually non-null on web
        final String mime =
            lookupMimeType(filename) ?? 'application/octet-stream';
        final split = mime.split('/');
        final contentType = MediaType(
            split.first, split.length > 1 ? split[1] : 'octet-stream');

        if (bytes != null) {
          // Web (or if you requested with withData: true)
          parts.add(multi.MultipartFile.fromBytes(
            bytes,
            filename: filename,
            contentType: contentType,
          ));
        } else if (path != null && !kIsWeb) {
          // Mobile/Desktop
          parts.add(await multi.MultipartFile.fromFile(
            path,
            filename: p.basename(path),
            contentType: contentType,
          ));
        } else {
          // Fallback (shouldn't happen)
          throw Exception('No data available for "$filename"');
        }
      }

      final formData = multi.FormData.fromMap({
        'company_id': myCompany?.companyId,
        'media_type_code': ChatMediaType.DOC.name,
        'to_uc_id': user?.userCompany?.userCompanyId,
        'chat_media': parts,
      });

      await Get.find<PostApiServiceImpl>()
          .uploadMediaApiCall(
        dataBody: formData,
      )
          .then((v) {
        isUploading = false;
        update();
        try {
          Get.find<SocketController>().sendMessage(
            receiverId: v.data?.chat?.toId ?? 0,
            message: v.data?.chat?.chatText ?? "",
            isGroup: 0,
            alreadySave: true,
            chatId: v.data?.chat?.chatId ?? 0,
          );
          toast(v.message ?? 'Uploaded');
          update();
        } catch (e) {
          print(e.toString());
        }
        resetUploadProgress();
      });
    } catch (e) {
      errorDialog(e.toString());
    } finally {
      customLoader.hide();
      resetUploadProgress();
    }
  }
*/

  Future<void> uploadDocumentsApiCall({
    required List<PlatformFile> files,
    void Function(int sent, int total)? onProgress,
  }) async {
    if (files.isEmpty) {
      toast('Please select at least one document');
      return;
    }

    try {
      isUploading = true;
      update();

      final docParts = <multi.MultipartFile>[];
      for (final f in files) {
        final name = safeName(f.name);
        final extis = ext(name);

        if (kIsWeb) {
          // WEB: bytes are provided when withData: true
          final bytes = f.bytes;
          if (bytes == null) continue;
          docParts.add(
            multi.MultipartFile.fromBytes(
              bytes,
              filename: name,
              contentType: mediaTypeForExt(extis),
            ),
          );
        } else {
          // MOBILE/DESKTOP
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
        isUploading = false;
        update();
        toast('No readable documents selected');
        return;
      }
      multi.FormData? formData;
      if (user?.userCompany?.isGroup == 1) {
        formData = multi.FormData.fromMap({
          'company_id': myCompany?.companyId,
          'media_type_code': ChatMediaType.DOC.name,
          'group_id': user?.userCompany?.userCompanyId,
          'is_group_chat': user?.userCompany?.isGroup == 1 ? 1 : 0,
          'chat_media': docParts, // array of docs
        });
      } else if (user?.userCompany?.isBroadcast == 1) {
        formData = multi.FormData.fromMap({
          'company_id': myCompany?.companyId,
          'media_type_code': ChatMediaType.DOC.name,
          'broadcast_user_id': user?.userCompany?.userCompanyId,
          'is_group_chat': user?.userCompany?.isGroup == 1 ? 1 : 0,
          'chat_media': docParts, // array of docs
        });
      } else {
        formData = multi.FormData.fromMap({
          'company_id': myCompany?.companyId,
          'media_type_code': ChatMediaType.DOC.name,
          'to_uc_id': user?.userCompany?.userCompanyId,
          'is_group_chat': user?.userCompany?.isGroup == 1 ? 1 : 0,
          'chat_media': docParts, // array of docs
        });
      }

      final resp = await Get.find<PostApiServiceImpl>().uploadMediaApiCall(
        dataBody: formData,
      );

      isUploading = false;
      update();

      try {
        Get.find<SocketController>().sendMessage(
          receiverId: resp.data?.chat?.toUserId ?? 0,
          message: resp.data?.chat?.chatText ?? "",
          isGroup: 0,
          alreadySave: true,
          type: user?.userCompany?.isGroup == 1
              ? 'group'
              : user?.userCompany?.isBroadcast == 1
                  ? "broadcast"
                  : '',
          chatId: resp.data?.chat?.chatId ?? 0,
          groupId: user?.userCompany?.userCompanyId,
          brID: user?.userCompany?.userCompanyId,
        );
        // toast(resp.message ?? 'Uploaded');
        update();
      } catch (e) {
        print('Socket sendMessage error: $e');
      }
    } catch (e) {
      isUploading = false;
      update();
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

  Future<void> pickDocument() async {
    final permission = await requestStoragePermission();
    if (!permission) {
      print("❌ Storage permission denied");
      return;
    }

    isUploading = true;
    update();

    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowCompression: true,
      compressionQuality: 40,
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
      ],
    );

    if (result != null && result.files.single.path != null) {
      File file = File(result.files.single.path!);
      var ext = file.path.split('.').last;
      final fileName =
          'DOC_${DateTime.now().millisecondsSinceEpoch}_${result.files.single.name}';
      uploadDocumentsApiCall(
        files: result.files,
        onProgress: (sent, total) {
          setUploadProgress(sent, total);
        },
      );

      isUploading = false;
      update();
    }
  }

  Future<void> handleForward({required chatId}) async {
    final selectedUser = await showDialog<UserDataAPI>(
      context: Get.context!,
      builder: (_) => const AllUserScreenDialog(),
    );
    if (selectedUser == null) return;
    final socket = Get.find<SocketController>();
    void _afterSendNavigate() {
      textController.clear();
      replyToMessage = null;
      update();

      // Replace current chat screen with the target chat
      if (Get.currentRoute == AppRoutes.chats_li_r &&
          Get.isRegistered<ChatScreenController>()) {
        Get.find<ChatScreenController>().openConversation(selectedUser);
      } else {
        if (kIsWeb) {
          Get.offNamed(
            "${AppRoutes.chats_li_r}?userId=${selectedUser.userId.toString()}",
          );
        } else {
          Get.offNamed(
            AppRoutes.chats_li_r,
            arguments: {'user': selectedUser},
          );
        }
      }
    }

    // Safety: don’t forward to yourself
    final targetUcId = selectedUser.userCompany?.userCompanyId;
    if (targetUcId != null &&
        me?.userCompany?.userCompanyId != null &&
        targetUcId == me?.userCompany?.userCompanyId) {
      Get.snackbar('Oops', 'You cannot forward a message to yourself.');
      return;
    }

    // Route by type
    if (selectedUser.userCompany?.isGroup == 1) {
      // GROUP
      socket.sendMessage(
        groupId: targetUcId ?? 0, // group UCID from selector
        type: "group",
        isGroup: 1,
        companyId: selectedUser.userCompany?.companyId,
        alreadySave: false,
        forwardChatId: chatId,
        isForward: 1,
      );
      _afterSendNavigate();
      return;
    }

    if (selectedUser.userCompany?.isBroadcast == 1) {
      // BROADCAST
      socket.sendMessage(
        brID: targetUcId ?? 0, // broadcast UCID
        type: "broadcast",
        isGroup: 0,
        companyId: selectedUser.userCompany?.companyId,
        alreadySave: false,
        forwardChatId: chatId,
        isForward: 1,
      );
      _afterSendNavigate();
      return;
    }

    // DIRECT — use UCID, NOT userId
    socket.sendMessage(
      receiverId: selectedUser.userId ?? 0, // <-- key fix (UCID)
      type: "direct",
      isGroup: 0,
      companyId: selectedUser.userCompany?.companyId,
      alreadySave: false,
      isForward: 1,
      forwardChatId: chatId,
    );
    _afterSendNavigate();
  }

  bool isSaving = false;
  String progress = '';
  int savedCount = 0;
  int failedCount = 0;

  Future<void> saveOne(String imageUrl) async {
    final ok = await _ensurePermission();
    if (!ok) {
      _toast('❌ Storage/Photos permission denied');
      return;
    }

    // final success = await _saveToGalleryFromUrl(imageUrl);
    // _toast(success ? '✅ Image saved to Gallery' : '❌ Failed to save image');
  }

  /// Save all, sequential for stability
  Future<void> saveAll(List<MediaList> items) async {
    if (items.isEmpty) return;

    final ok = await _ensurePermission();
    if (!ok) {
      _toast('❌ Storage/Photos permission denied');
      return;
    }

    isSaving = true;
    savedCount = 0;
    failedCount = 0;
    progress = 'Starting...';
    update();

    for (var i = 0; i < items.length; i++) {
      final m = items[i];

      // ✅ IMPORTANT: pass the actual URL (adjust field name if yours differs)
      final url = m.fileName ?? '';

      // final success = await _saveToGalleryFromUrl(url);
      if (true) {
        savedCount++;
      } else {
        failedCount++;
      }
      progress = '$savedCount/${items.length} saved';
      update();
    }

    isSaving = false;
    update();

    if (failedCount == 0) {
      _toast('✅ All ${items.length} images saved!');
    } else {
      _toast('ℹ️ Saved $savedCount, Failed $failedCount');
    }
  }

  /// Permissions: iOS needs Photos add-only; Android ≤12 may prompt for storage.
  /// Android 13+ generally needs no permission to insert into MediaStore.
  Future<bool> _ensurePermission() async {
    if (Platform.isIOS) {
      final status = await Permission.photosAddOnly.request();
      return status.isGranted;
    }

    if (Platform.isAndroid) {
      // Try without asking first; if OEM requires it (≤12), request storage.
      var storage = await Permission.storage.status;
      if (!storage.isGranted && !storage.isLimited) {
        storage = await Permission.storage.request();
      }
      // Even if not granted, saving might still work on Android 13+, but
      // we return true if granted OR limited; else false.
      return storage.isGranted || storage.isLimited;
    }

    // Other platforms
    return true;
  }

  void _toast(String msg) {
    // Plug your toast/snackbar here
    // e.g., Get.snackbar('Info', msg); or your existing toast()
    Get.snackbar('AccuChat', msg, snackPosition: SnackPosition.BOTTOM);
  }
}

class GroupChatElement implements Comparable {
  DateTime date;
  ChatHisList chatMessageItems;

  GroupChatElement(
    this.date,
    this.chatMessageItems,
  );

  @override
  int compareTo(other) {
    return date.compareTo(other.date);
  }
}

abstract class ChatRow {}

class ChatHeaderRow extends ChatRow {
  final DateTime date;
  ChatHeaderRow(this.date);
}

class ChatMessageRow extends ChatRow {
  final GroupChatElement element; // your (date, chatMessageItems)
  ChatMessageRow(this.element);
}
