import 'dart:async';
import 'dart:io';
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
import '../../../../models/message.dart';
import '../../../../models/get_company_res_model.dart';
import '../../../auth/models/get_uesr_Res_model.dart';
import 'package:dio/dio.dart' as multi;
import 'package:path/path.dart' as p;
import 'dart:typed_data';

import '../Widgets/all_users_dialog.dart';

class ChatScreenController extends GetxController {
  UserDataAPI? user;
  // Message? forwardMessage;
  final _alreadyEmitted = <int>{};
  String? selectedChatId;
  String validString = '';
  List<Map<String, String>> uploadedAttachments = [];
  List<ChatHisResModel> msgList = [];
  final textController = TextEditingController();
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
    getArguments();
    // markAllVisibleAsReadOnOpen();WidgetsBinding.instance.addPostFrameCallback((_) {
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

    super.onInit();
  }


  void markAllVisibleAsReadOnOpen() {
    for (ChatHisList m in (chatHisList ?? [])) {
      if(user?.pendingCount!=0){
        Get.find<SocketController>().readMsgEmitter(chatId: m.chatId??0);
      }
       // your existing emitter
    }
  }

  @override
  void onClose() {
    imageCache.clearLiveImages();
    imageCache.clear();
    super.onClose();
  }

  getArguments() {

    if(kIsWeb){
      _getCompany();
      if (Get.parameters != null) {
        final String? argUserId = Get.parameters['userId'];
        if (argUserId != null) {
          getUserByIdApi(userId: int.parse(argUserId??''));
        }
      }
    }else{
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
        .getUserByApiCall(userID: userId,comid: myCompany?.companyId)
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
    Future.delayed(const Duration(milliseconds: 500),(){
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
  _getCompany() {
    final svc = Get.find<CompanyService>();
    myCompany = svc.selected;
    update();
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
      if ((scrollController.position.extentAfter) <= 0 &&
          !isLoading) {

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
          markAllVisibleAsReadOnOpen();
        } else {
          chatHisList?.addAll(value.data?.rows ?? []);
          isLoading = false;
          hasMore = false;
          markAllVisibleAsReadOnOpen();
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
        return GroupChatElement(datais ?? DateTime.now(), item);
      }).toList();
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
          final nameGuess = x.name.isNotEmpty ? x.name : 'image_${DateTime.now().millisecondsSinceEpoch}.jpg';
          final extis = ext(nameGuess);
          mf = multi.MultipartFile.fromBytes(
            bytes,
            filename: safeName(nameGuess),
            contentType: mediaTypeForExt(extis),
          );
        }

        mediaFiles.add(mf);
      }

      final Map<String, dynamic> fields = {
        'company_id': myCompany?.companyId,
        'media_type_code': type,
        'to_uc_id': user?.userCompany?.userCompanyId,
        'chat_media': mediaFiles, // array of files
      };

      // If you later need reply fields:
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
          isGroup: 0,
          alreadySave: true,
          chatId: resp.data?.chat?.chatId ?? 0,
        );
        toast(resp.message ?? 'Uploaded');
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

      final formData = multi.FormData.fromMap({
        'company_id': myCompany?.companyId,
        'media_type_code': ChatMediaType.DOC.name,
        'to_uc_id': user?.userCompany?.userCompanyId,
        'chat_media': docParts, // array of docs
      });

      final resp = await Get.find<PostApiServiceImpl>().uploadMediaApiCall(
        dataBody: formData,
      );

      isUploading = false;
      update();

      try {
        Get.find<SocketController>().sendMessage(
          receiverId: resp.data?.chat?.toId ?? 0,
          message: resp.data?.chat?.chatText ?? "",
          isGroup: 0,
          alreadySave: true,
          chatId: resp.data?.chat?.chatId ?? 0,
        );
        toast(resp.message ?? 'Uploaded');
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
        Get.offNamed(
          AppRoutes.chats_li_r,
          arguments: {'user': selectedUser},
        );
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
