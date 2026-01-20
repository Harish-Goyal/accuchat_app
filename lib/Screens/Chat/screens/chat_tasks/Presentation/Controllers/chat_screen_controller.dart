import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:AccuChat/Screens/Chat/models/chat_his_res_model.dart';
import 'package:AccuChat/Screens/Chat/models/chat_history_response_model.dart';
import 'package:AccuChat/Screens/Chat/screens/chat_tasks/Presentation/Controllers/task_controller.dart';
import 'package:AccuChat/Screens/Chat/screens/chat_tasks/Presentation/Controllers/task_home_controller.dart';
import 'package:AccuChat/utils/register_image.dart';
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
import '../../../../../../Services/APIs/post/post_api_service_impl.dart';
import '../../../../../../utils/chat_presence.dart';
import '../../../../../../utils/custom_flashbar.dart';
import '../../../../../../utils/helper.dart';
import '../../../../../../utils/helper_widget.dart';
import '../../../../../Home/Presentation/Controller/company_service.dart';
import '../../../../../Home/Presentation/Controller/socket_controller.dart';
import '../../../../api/apis.dart';
import '../../../../helper/dialogs.dart';
import '../../../../models/gallery_create.dart';
import '../../../../models/message.dart';
import '../../../../models/get_company_res_model.dart';
import '../../../auth/models/get_uesr_Res_model.dart';
import 'package:dio/dio.dart' as multi;
import 'package:path/path.dart' as p;
import 'dart:typed_data';
import '../Widgets/all_users_dialog.dart';
import 'chat_home_controller.dart';

class ChatScreenController extends GetxController {
  ChatScreenController({this.user});
  UserDataAPI? user;
  int? currentChatId;
  // Message? forwardMessage;
  final _alreadyEmitted = <int>{};
  String? selectedChatId;
  String validString = '';
  List<Map<String, String>> uploadedAttachments = [];
  List<ChatHisResModel> msgList = [];
  final textController = TextEditingController();
  final FocusNode focusNode = FocusNode();
  FocusNode messageParentFocus = FocusNode(); // for keyboard events only
  FocusNode messageInputFocus = FocusNode();
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
  final ItemPositionsListener itemPositionsListener =
      ItemPositionsListener.create();

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
  final Map<int, int> chatIdToIndex = {};
  final Map<int, GlobalKey> chatIdToKey = {};
  bool isSearching = false;
  String searchQuery = '';
  TextEditingController seacrhCon = TextEditingController();

  Timer? searchDelay;
  void onSearch(String query) {
    searchDelay?.cancel();

    searchDelay = Timer(const Duration(milliseconds: 400), () {
      searchQuery = query.trim().toLowerCase();

      page = 1;
      hasMore = true;
      chatHisList = [];
      update();

      hitAPIToGetChatHistory(searchQuery: searchQuery.isEmpty ? null : searchQuery);
    });

  }


  Timer? _pageDebounce;

  void attachPaginationListener({bool reverseList = true}) {
    itemPositionsListener.itemPositions.addListener(() {
      if (isPageLoading || !hasMore) return;

      final positions = itemPositionsListener.itemPositions.value;
      if (positions.isEmpty) return;

      int minIndex = positions.first.index;
      int maxIndex = positions.first.index;

      for (final p in positions) {
        if (p.index < minIndex) minIndex = p.index;
        if (p.index > maxIndex) maxIndex = p.index;
      }

      // ✅ If you use reverse:true and older messages are at "top",
      // trigger when user reaches the end side.
      final nearEnd = reverseList
          ? (maxIndex >= (flatRows.length - 3))
          : (minIndex <= 2);

      if (!nearEnd) return;

      _pageDebounce?.cancel();
      _pageDebounce = Timer(const Duration(milliseconds: 250), () {
        if (!isPageLoading && hasMore) {
          hitAPIToGetChatHistory();
        }
      });
    });
  }

  // Call this whenever chatCatygory changes
  void rebuildFlatRows() {
    flatRows = [];
    chatIdToIndex.clear();

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
      if (id != null) {
        chatIdToIndex[id] = idx;
        chatIdToKey.putIfAbsent(id, () => GlobalKey()); // ✅ ensure key exists
      }
    }
    update();
  }


  // Jump to a message by chatId
  Future<void> scrollToChatId(int chatId) async {
    // ✅ 1) If widget is already built, ensureVisible works even when list not scrollable
    final ctx = chatIdToKey[chatId]?.currentContext;
    if (ctx != null) {
      await Scrollable.ensureVisible(
        ctx,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        alignment: 0.35,
      );
      highlightMessage(chatId); // ✅ always give feedback
      return;
    }

    // ✅ 2) Otherwise use index-based scroll
    final idx = chatIdToIndex[chatId];
    if (idx == null) {
      debugPrint("Original message not found (maybe not loaded)");
      return;
    }

    if (!itemScrollController.isAttached) {
      // list not attached yet (web pe hota hai sometimes) -> run after frame
      WidgetsBinding.instance.addPostFrameCallback((_) {
        scrollToChatId(chatId);
      });
      return;
    }

    // ✅ 3) If already visible, don't depend on scrollTo
    final positions = itemPositionsListener.itemPositions.value;
    final isVisible = positions.any((p) => p.index == idx);
    if (isVisible) {
      highlightMessage(chatId);
      return;
    }

    await itemScrollController.scrollTo(
      index: idx,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
      alignment: 0.35,
    );

    highlightMessage(chatId);
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



  @override
  void onInit() {
    super.onInit();
    _getCompany();
    scrollListener();
    if(Get.isRegistered<ChatHomeController>()){
      Get.find<ChatHomeController>()
          .isOnRecentList.value = false;
    }

    replyToMessage = null;
    // resetPaginationForNewChat();
    getArguments();

    if (kIsWeb) {
      user = Get.find<ChatHomeController>().selectedChat.value;
      // _initScroll();
    }
    // attachPaginationListener(reverseList: true);


    if (kIsWeb) {
      messageInputFocus.requestFocus();
      registerImage((XFile image) {
        _handlePastedImage(image);
      });
    }
  }

  Future<void> _handlePastedImage(XFile file) async {
    // same flow as picker
    images.clear();
    images.add(file);

    await uploadMediaApiCall(
      type: ChatMediaType.IMAGE.name,
    );
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
      withData: true, // we need bytes for XFile.fromData
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
        // length: bytes.length, // optional
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

  void markAllVisibleAsReadOnOpen(toUcID, fromUcId, isGroupChat) {
    Get.find<SocketController>().connectUserEmitter(myCompany?.companyId);
    Get.find<SocketController>().readMsgEmitter(
        toucID: toUcID,
        fromUcID: fromUcId,
        companyId: myCompany?.companyId,
        is_group_chat: isGroupChat);
  }

  @override
  void onClose() {
    if (ChatPresence.activeChatId == user?.userCompany?.userCompanyId) {
      ChatPresence.activeChatId = null;
    }
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
        UserDataAPI argUser = Get.arguments['user'];
        user = argUser;
        if (argUser != null) {
          ChatPresence.activeChatId = argUser?.userCompany?.userCompanyId;
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
      ChatPresence.activeChatId = user?.userCompany?.userCompanyId;

      update();
    }).onError((error, stackTrace) {
      update();
      errorDialog(error.toString());
    }).whenComplete(() {});
  }

  void openConversation(UserDataAPI? useriii) {

    user = useriii;
    update();
    _getMe();
    Future.delayed(const Duration(milliseconds: 500), () {
      resetPaginationForNewChat();
      hitAPIToGetChatHistory();
      messageInputFocus.requestFocus();
      if (user?.userCompany?.isGroup == 1 ||
          user?.userCompany?.isBroadcast == 1) {
        hitAPIToGetMembers(user);
      }
    });
  }

  List<Message> allTasks = [];
  List<Message> filteredTasks = [];
  String selectedFilter = 'all';

  UserDataAPI? me = UserDataAPI();
  TextEditingController updateMsgController = TextEditingController();
  _getMe() {
    me = APIs.me;
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
  hitAPIToGetMembers(UserDataAPI? user) async {
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
  bool isPageLoading = false;

  ScrollController scrollController = ScrollController();
  ScrollController scrollController2 = ScrollController();

  scrollListener() {
    if (kIsWeb) {
      scrollController.addListener(() {
        if (scrollController.position.pixels >=
                scrollController.position.maxScrollExtent - 100 &&
            !isPageLoading &&
            hasMore) {
          // resetPaginationForNewChat();
          hitAPIToGetChatHistory();
        }
      });
    } else {
      scrollController2.addListener(() {
        if (scrollController2.position.pixels <=
            scrollController2.position.minScrollExtent + 50 &&
            !isPageLoading &&
            hasMore) {
          // resetPaginationForNewChat();
          hitAPIToGetChatHistory();
        }
      });
    }
  }

  void resetPaginationForNewChat() {
    page = 1;
    hasMore = true;
    chatHisList = [];
    chatCatygory = [];
    showPostShimmer = true;
    update();
  }

  hitAPIToGetChatHistory({String? searchQuery}) async {

    if (page == 1) {
      showPostShimmer = true;
      chatHisList?.clear();
      chatCatygory.clear();
    }

    isPageLoading = true;
    update();
    Get.find<PostApiServiceImpl>()
        .getChatHistoryApiCall(
            userComId: user?.userCompany?.userCompanyId,
            page: page,
            searchText: searchQuery??'')
        .then((value) async {
      showPostShimmer = false;
      chatHisResModelAPI = value;
      if (value.data?.rows != null && (value.data?.rows ?? []).isNotEmpty) {
        if (page == 1) {
          chatHisList = value.data?.rows ?? [];
        } else {
          chatHisList?.addAll(value.data?.rows ?? []);
        }
        page++;
      }
      else {
        hasMore = false;
        isPageLoading = false;
        update();
      }

      chatCatygory = (chatHisList ?? []).map((item) {
        DateTime? datais;
        if (item.sentOn != null) {
          datais = DateTime.parse(item.sentOn ?? '');
        }

        return GroupChatElement(datais ?? DateTime.now(), item);
      }).toList();
      if (user?.pendingCount != 0) {
        markAllVisibleAsReadOnOpen(
            user?.userCompany?.userCompanyId,
            APIs.me.userCompany?.userCompanyId,
            user?.userCompany?.isGroup == 1 ? 1 : 0);
      }
      rebuildFlatRows();
      showPostShimmer = false;
      isPageLoading = false;
      update();

    }).onError((error, stackTrace) {
      showPostShimmer = false;
      isPageLoading = false;
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
                  : 'direct',
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
   int maxBytes = 15 * 1024 * 1024; // 10MB
  Future<void> pickDocument() async {
    final permission = await requestStoragePermission();
    if (!permission) {
      errorDialog("❌ Storage permission denied");
      return;
    }

    isUploading = true;
    update();

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
      builder: (_) =>  AllUserScreenDialog(),
    );
    if (selectedUser == null) return;
    final socket = Get.find<SocketController>();
    void _afterSendNavigate() {
      textController.clear();
      replyToMessage = null;
      update();

      // Replace current chat screen with the target chat
      if (/*Get.currentRoute == AppRoutes.chats_li_r &&*/
        Get.isRegistered<ChatScreenController>()) {
        Get.find<ChatHomeController>().selectedChat.value = selectedUser;
        Get.find<ChatScreenController>().openConversation(selectedUser);
      } else {
        toast("Something went wrong please refresh and try again");
        // if (kIsWeb) {
        //   Get.to(()=>ChatScreen(user: selectedUser ,showBack: true,));
        //   // Get.offNamed(
        //   //   "${AppRoutes.chats_li_r}?userId=${selectedUser.userId.toString()}",
        //   // );
        // } else {
        //   Get.offNamed(
        //     AppRoutes.chats_li_r,
        //     arguments: {'user': selectedUser},
        //   );
        // }
      }
    }

    // Safety: don’t forward to yourself
    final targetUcId = selectedUser.userCompany?.userCompanyId;
    if (targetUcId != null &&
        me?.userCompany?.userCompanyId != null &&
        targetUcId == me?.userCompany?.userCompanyId) {
      Get.snackbar('Oops', 'You cannot forward a message to yourself.',
          backgroundColor: Colors.white, colorText: Colors.black,duration: Duration(seconds: 6));
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
      receiverId: selectedUser.userId ?? 0,
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
    Get.snackbar('AccuChat', msg, snackPosition: SnackPosition.BOTTOM,duration: Duration(seconds: 6));
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
