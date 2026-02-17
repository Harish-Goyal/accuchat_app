import 'package:AccuChat/Screens/Chat/models/task_commets_res_model.dart';
import 'package:AccuChat/Screens/Chat/models/task_res_model.dart';
import 'package:AccuChat/Screens/Chat/screens/auth/models/get_uesr_Res_model.dart';
import 'package:AccuChat/utils/custom_flashbar.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../../Services/APIs/post/post_api_service_impl.dart';
import '../../../../../../utils/helper_widget.dart';
import '../../../../../Home/Presentation/Controller/company_service.dart';
import '../../../../models/get_company_res_model.dart';

class TaskThreadController extends GetxController {
  TaskData? taskMessage;
  UserDataAPI? currentUser;
  TextEditingController msgController = TextEditingController();
  FocusNode messageParentFocus = FocusNode();
  bool isVisibleUpload = true;
  var conversationId;
  var threadId;

  bool isUploading = false;
  final showUpload = true.obs;
  void resetMessageFocus() {
    messageParentFocus.unfocus();

    // next frame me focus attach karo
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (messageParentFocus.canRequestFocus) {
        messageParentFocus.requestFocus();
      }
    });
  }

  @override
  void onInit() {
    super.onInit();
    scrollController = ScrollController();
    _getCompany();
    getArguments();

  }

  getArguments() {
    if(kIsWeb){
      if (Get.parameters != null) {
        debugPrint("param${Get.parameters['taskMsgId']}");
        final String? taskMessageId = Get.parameters['taskMsgId'];
        final currentUserID = Get.parameters['currentUserId'];

        getUserByIdApi(userId: int.parse(currentUserID??''));
        getTaskByIdApi(taskid: int.parse(taskMessageId??''));
      }
    }
    else{
      if (Get.arguments != null) {
        taskMessage = Get.arguments['taskMsg'];
        currentUser = Get.arguments['currentUser'];
        initData();
        hitAPIToGetCommentsHistory();
        hitAPIToGetAllTaskMember();
      }
    }

  }

  initData() {
    // conversationId = APIs.getConversationID(taskMessage?.fromId ?? '');
    threadId = taskMessage?.createdOn;
  }



  List<UserDataAPI> allUsersList = [];

  hitAPIToGetAllTaskMember() async {
    isLoadingM = true;
    update();
    Get.find<PostApiServiceImpl>()
        .getTaskMemberApiCall(taskMessage?.taskId)
        .then((value) async {
      isLoadingM = false;
      allUsersList = value.data ?? [];
      update();
    }).onError((error, stackTrace) {
      isLoadingM = false;
      update();
    });
  }

  String get joined {
    final names = allUsersList
        .map((v) => (v.userCompany?.displayName !=null?v.userCompany?.displayName ?? '':v.userName!=null?v.userName??'':v.phone??'').trim())
        .where((s) => s.isNotEmpty)
        .toList();
    final unique = <String>{};
    final cleaned = names.where((n) => unique.add(n)).toList();
    return cleaned.join(', ');
  }


  getUserByIdApi({int? userId}) async {
    Get.find<PostApiServiceImpl>()
        .getUserByApiCall(userID: userId,comid: myCompany?.companyId)
        .then((value) async {
      currentUser = value.data;
      update();
    }).onError((error, stackTrace) {
      update();
      errorDialog(error.toString());
    }).whenComplete(() {});
  }

  getTaskByIdApi({int? taskid}) async {
    Get.find<PostApiServiceImpl>()
        .getTaskByIdApiCall(taskid)
        .then((value) async {
      taskMessage = value.data;
      initData();
      hitAPIToGetCommentsHistory();
      hitAPIToGetAllTaskMember();
      update();
    }).onError((error, stackTrace) {
      update();
      errorDialog(error.toString());
    }).whenComplete(() {});
  }


  List<TaskComments>? commentsList = [];
  List<GroupCommentsElement> commentsCategory = [];
  bool isLoading = false;
  bool isLoadingM = false;
  bool isLoadings = false;
  int page = 1;
  bool hasMore = true;
  bool showPostShimmer = true;
  bool isPageLoading = true;

  var userIDSender;
  var userNameReceiver;
  var userNameSender;
  var userIDReceiver;
  var refIdis;
  TaskComments? replyToMessage;
  late final ScrollController scrollController;
  ScrollController scrollController2 = ScrollController();


  scrollListener() {
    if (kIsWeb) {
      scrollController.addListener(() {
        if (scrollController.position.pixels >=
            scrollController.position.maxScrollExtent - 100 &&
            !isPageLoading && hasMore) {
          // resetPaginationForNewChat();
          hitAPIToGetCommentsHistory();
        }
      });
    } else {
      scrollController2.addListener(() {
        if (!scrollController2.hasClients) return;

        final pos = scrollController2.position;

        // NEW: because reverse:true, TOP is maxScrollExtent
        if (pos.pixels >= pos.maxScrollExtent - 80 &&
            !isPageLoading &&hasMore) {
          hitAPIToGetCommentsHistory();
        }
      });
    }
  }
  /* scrollListener() {
    scrollController.addListener(() {
      if ((scrollController.position.extentAfter) <= 0 && !isLoading) {
        hasMore = true;
        page++;
        update();
        hitAPIToGetTaskHistory();
      }
    });
  }*/

  void resetPaginationForNewChat() {
    page = 1;
    hasMore = true;
    commentsList = []; // <--- MOST IMPORTANT
    commentsCategory = [];
    showPostShimmer = true;
    update();
  }

  TaskCommentsResModel commentRes= TaskCommentsResModel();
  hitAPIToGetCommentsHistory() async {
    if(page==1){
      showPostShimmer = true;
      commentsList?.clear();
      commentsCategory?.clear();
    }

    isPageLoading = true;
    update();
    Get.find<PostApiServiceImpl>()
        .getCommentsOnTaskApiCall(
        taskId: taskMessage?.taskId,
        page: page,
        companyId: myCompany?.companyId)
        .then((value) async {
      showPostShimmer = false;
      commentRes = value;
      if (value.rows != null && (value.rows ?? []).isNotEmpty) {
        if (page == 1) {
          commentsList =value.rows ?? [];
        } else {
          commentsList?.addAll(value.rows??[]);
        }
        page++;
      } else {
          isPageLoading = false;
          hasMore = false;
          update();
      }

      commentsCategory = (commentsList ?? []).map((item) {
        DateTime? datais;
        if (item.sentOn != null) {
          datais = DateTime.parse(item.sentOn ?? '');
        }
        return GroupCommentsElement(datais ?? DateTime.now(), item);
      }).toList();
      showPostShimmer = false;
      isPageLoading = false;
      update();

    }).onError((error, stackTrace) {
      showPostShimmer = false;
      isPageLoading = false;
      update();
    });

  }


  final Set<String> processedMsgKeys = <String>{};

  String msgKey(TaskComments m) {
    // Prefer backend unique id if you have it: m.messageId / m.chatHisId etc.
    // If you don’t, build a stable fingerprint:
    return [
      (m.taskCommentId ?? '').toString(),
      (m.sentOn ?? '').toString(),
      (m.fromUser?.userId ?? '').toString(),
      (m.toUser?.userId ?? '').toString(),
      (m.commentText ?? '').toString(),
      (m.media?.toString() ?? ''),
    ].join('|');
  }

  bool markOnce(String key) {
    if (processedMsgKeys.contains(key)) return false;
    processedMsgKeys.add(key);

    // Optional: prevent memory growth (keep last N only)
    if (processedMsgKeys.length > 3000) {
      // super simple trim (not perfect but practical)
      processedMsgKeys.remove(processedMsgKeys.first);
    }
    return true;
  }



  CompanyData? myCompany = CompanyData();
  _getCompany(){
    final svc = CompanyService.to;
    myCompany = svc.selected;
    update();
  }

  Future<void> pickDocument() async {
    final permission = await requestStoragePermission();
    if (!permission) {
      errorDialog("❌ Storage permission denied");
      return;
    }

    isUploading = true;
    update();

    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
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

  /*  if (result != null && result.files.single.path != null) {
      File file = File(result.files.single.path!);
      var ext = file.path.split('.').last;
      final fileName = 'DOC_${DateTime.now().millisecondsSinceEpoch}_${result.files.single.name}';
      final ref = FirebaseStorage.instance.ref().child('media/docs/$fileName');

      await ref.putFile(file,SettableMetadata(contentType: 'media/$ext'));
      final downloadURL = await ref.getDownloadURL();


      // APIs.sendThreadMessage(
      //   conversationId:currentUser?.id,
      //   taskMessageId: taskMessage?.sent??'',
      //   chatUser: currentUser,
      //   msg: downloadURL,
      //   type: Type.doc,);

        isUploading = false;
        update();
    }*/
  }
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  void onClose() {
    // TODO: implement onClose
    super.onClose();
  }
}

class GroupCommentsElement implements Comparable {
  DateTime date;
  TaskComments comments;

  GroupCommentsElement(
      this.date,
      this.comments,
      );

  @override
  int compareTo(other) {
    return date.compareTo(other.date);
  }
}
