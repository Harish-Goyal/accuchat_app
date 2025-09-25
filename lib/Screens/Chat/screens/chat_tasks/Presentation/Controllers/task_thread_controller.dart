import 'dart:io';
import 'package:AccuChat/Screens/Chat/models/task_commets_res_model.dart';
import 'package:AccuChat/Screens/Chat/models/task_res_model.dart';
import 'package:AccuChat/Screens/Chat/screens/auth/models/get_uesr_Res_model.dart';
import 'package:AccuChat/utils/custom_flashbar.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../../../../../../Services/APIs/post/post_api_service_impl.dart';
import '../../../../../../utils/helper_widget.dart';
import '../../../../../Home/Presentation/Controller/company_service.dart';
import '../../../../api/apis.dart';
import '../../../../models/chat_user.dart';
import '../../../../models/get_company_res_model.dart';
import '../../../../models/message.dart';

class TaskThreadController extends GetxController {
  TaskData? taskMessage;
  UserDataAPI? currentUser;
  TextEditingController msgController = TextEditingController();
  bool isVisibleUpload = true;
  var conversationId;
  var threadId;

  bool isUploading = false;



  @override
  void onInit() {
    _getCompany();
    getArguments();


    super.onInit();
  }

  getArguments() {
    if(kIsWeb){
      if (Get.parameters != null) {
        final String? taskMessageId = Get.parameters['taskMsgId'];
        final currentUserID = Get.parameters['currentUserId'];

        //TODO implemnets getting  task details
        getTaskByIdApi(taskid: int.parse(taskMessageId??''));
        getUserByIdApi(userId: int.parse(currentUserID??''));

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
        .map((v) => (v.userName ?? '').trim())
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

  var userIDSender;
  var userNameReceiver;
  var userNameSender;
  var userIDReceiver;
  var refIdis;
  TaskComments? replyToMessage;
  ScrollController scrollController = ScrollController();

  scrollListener() {
    scrollController.addListener(() {
      if ((scrollController.position.extentAfter) <= 0 && !isLoading) {
        hasMore = true;
        page++;
        update();
        hitAPIToGetCommentsHistory();
      }
    });
  }

  hitAPIToGetCommentsHistory() async {
    Get.find<PostApiServiceImpl>()
        .getCommentsOnTaskApiCall(
        taskId: taskMessage?.taskId,
        page: page,
        companyId: myCompany?.companyId)
        .then((value) async {
      showPostShimmer = false;
      // chatHisList = value.data?.rows ?? [];
      if ((value.rows ?? []).isNotEmpty) {
        if (page == 1) {
          commentsList =value.rows ?? [];
          isLoading = false;
          hasMore = false;
          update();
        } else {
          commentsList?.addAll(value.rows ?? []);
          isLoading = false;
          hasMore = false;
          update();
        }
      } else {
          isLoading = false;
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
      update();
    }).onError((error, stackTrace) {
      showPostShimmer = false;
      update();
    });
  }


  CompanyData? myCompany = CompanyData();
  _getCompany(){
    final svc     = Get.find<CompanyService>();
    myCompany = svc.selected;
    update();


  }

  Future<void> pickDocument() async {
    final permission = await requestStoragePermission();
    if (!permission) {
      toast("❌ Storage permission denied");
      return;
    }

      isUploading = true;
    update();

    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: [
        'pdf', 'doc', 'docx', 'txt',
        'xls', 'xlsx', 'csv', // Excel formats
        'xml', 'json', // markup/data formats
        // 'exe', 'apk', // executable formats (⚠️ be cautious)
        'ppt', 'pptx', // PowerPoint
        'zip', 'rar', // Archives
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
