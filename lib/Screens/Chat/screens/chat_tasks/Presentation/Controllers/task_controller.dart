import 'dart:async';
import 'dart:io';
import 'package:AccuChat/Screens/Chat/models/chat_his_res_model.dart';
import 'package:AccuChat/Screens/Chat/models/chat_history_response_model.dart';
import 'package:AccuChat/Screens/Chat/models/task_res_model.dart';
import 'package:AccuChat/Screens/Chat/screens/chat_tasks/Presentation/Controllers/task_home_controller.dart';
import 'package:AccuChat/Screens/Chat/screens/chat_tasks/Presentation/Controllers/task_thread_controller.dart';
import 'package:AccuChat/Screens/Chat/screens/chat_tasks/Presentation/Views/taskThreadScreenWEb.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:mime/mime.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../../../../Services/APIs/local_keys.dart';
import '../../../../../../Services/APIs/post/post_api_service_impl.dart';
import '../../../../../../routes/app_routes.dart';
import '../../../../../../utils/chat_presence.dart';
import '../../../../../../utils/custom_flashbar.dart';
import '../../../../../../utils/helper.dart';
import '../../../../../Home/Presentation/Controller/company_service.dart';
import '../../../../../Home/Presentation/Controller/socket_controller.dart';
import '../../../../../Settings/Model/get_nav_permission_res_model.dart';
import '../../../../helper/dialogs.dart';
import '../../../../models/get_company_res_model.dart';
import '../../../../models/task_status_res_model.dart';
import '../../../auth/models/get_uesr_Res_model.dart';
import 'package:dio/dio.dart' as multi;
import 'package:path/path.dart' as p;
import '../../Bindings/bindings.dart';
import '../Views/task_chat_screen.dart';
import '../Widgets/all_users_dialog.dart';

class TaskController extends GetxController {
  TaskController({this.user});
  UserDataAPI? user;
  String? selectedChatId;
  String validString = '';
  List<Map<String, String>> uploadedAttachments = [];
  List<ChatHisResModel> msgList = [];
  final textController = TextEditingController();
  ChatHisList? replyToMessage;
  bool showEmoji = false, isUploading = false, isUploadingTaskDoc = false;
  File? file;
  List<Map<String, dynamic>> attachedFiles = [];
  List<String> removedMediaIds = [];
  List<XFile> images = [];

  var userIDSender;
  var userNameReceiver;
  var userNameSender;
  var userIDReceiver;
  var refIdis;

 // Helper: safe MediaType (or null if unknown)
  MediaType? _mediaTypeForPath(String path) {
    final mime = lookupMimeType(path);
    if (mime == null) return null;
    final parts = mime.split('/');
    if (parts.length != 2) return null;
    return MediaType(parts[0], parts[1]);
  }

  @override
  void onInit() {
    super.onInit();
    getArguments();
    // if (kIsWeb) {
    //   user = Get.find<TaskHomeController>().selectedChat.value;
    // }

    getUserNavigation();
    scrollListener();

  }

  @override
  void onClose() {
    if (TaskPresence.activeTaskId.value == user?.userCompany?.userCompanyId) {
      TaskPresence.activeTaskId.value = null;
    }
    imageCache.clearLiveImages();
    imageCache.clear();
    super.onClose();
  }

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

/*
  Future<void> getArguments() async {
    // always ensure company first (because API/socket depends on it)
    // await _getCompany();

    // 1) If navigation passed arguments (works in same session on web too)
    final args = Get.arguments;
    if (args != null && args is Map && args['user'] != null) {
      user = args['user'] as UserDataAPI;
       openConversation(user);
      return;
    }

    // 2) Fallback to URL params/query (works after refresh / direct link)
    final userIdStr =
        Get.parameters['userId'];

    if (userIdStr != null && userIdStr.isNotEmpty) {
      final id = int.tryParse(userIdStr);
      if (id != null) {
         getUserByIdApi(userId: id); // ensure this returns user
        // if (user != null) openConversation(user);
      }
      return;
    }

    // 3) Nothing provided: keep empty or show placeholder
  }
*/


  void getArguments() {
    if (kIsWeb) {
      _getCompany();

      // ✅ If controller already has a user (selected from list), don't override it via route params
      if (user?.userId != null) {
        openConversation(user);
      }else {
        final String? argUserId = Get.parameters['userId'];
        if (argUserId != null && argUserId.isNotEmpty) {
          getUserByIdApi(userId: int.parse(argUserId));
        }
      }
      return;
    }

    // mobile flow
    if (Get.arguments != null) {
      final UserDataAPI argUser = Get.arguments['user'];
      user = argUser;
      if (user != null) openConversation(user);
    }
  }

/*  getArguments() {
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
        if (user != null) {
          // ChatPresence.activeChatId.value = argUser?.userCompany?.userCompanyId;
          openConversation(user);
        }
      }
    }
  }*/
 /* getArguments() {
    if(kIsWeb){
      _getCompany();
      if (Get.parameters != null) {
        if( Get.parameters['user']==null){
          final String? argUserId = Get.parameters['userId'];
          if (argUserId != null) {
            getUserByIdApi(userId: int.parse(argUserId));
          }
        } else {
          getUserByIdApi(userId: user?.userId);
        }
        }

    }else{
      if (Get.arguments != null) {
        UserDataAPI argUser = Get.arguments['user'];
        user = argUser;
        if (argUser != null) {
          // ChatPresence.activeChatId.value = argUser.userCompany?.userCompanyId;
          openConversation(argUser);
        }
      }
    }

  }*/

   getUserByIdApi({int? userId}) async {
   await Get.find<PostApiServiceImpl>()
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
    user = useriii;
    TaskPresence.activeTaskId.value = user?.userCompany?.userCompanyId;
    // _getCompany();
    Future.microtask(() {
      resetPaginationForNewChat();
      hitAPIToGetTaskHistory();
      hitAPIToGetTaskStatus();
    });

  }

  String selectedFilter = 'all';

  // UserDataAPI? me = UserDataAPI();
  // _getMe() {
  //   me = getUser();
  //   update();
  // }

  CompanyData? myCompany = CompanyData();
  _getCompany() async {
    final svc = CompanyService.to;
    myCompany = svc.selected;
  }

  List<StatusData> taskStatus = [];
  hitAPIToGetTaskStatus() async {
    isLoadings = true;
    update();
    Get.find<PostApiServiceImpl>().getTaskStatusApiCall().then((value) async {
      isLoadings = false;
      taskStatus = value.data ?? [];
      update();
    }).onError((error, stackTrace) {
      isLoadings = false;
      update();
    });
  }

  goToTaskThread(GroupTaskElement element){
    Get.find<SocketController>().joinTaskEmitter(taskId: element.taskMsg.taskId??0);
    // Set the message being replied to
    refIdis = element.taskMsg.taskId;
    userIDSender = element.taskMsg.fromUser?.userId;
    userNameReceiver =
        element.taskMsg.toUser?.userCompany?.displayName ?? '';
    userNameSender =
        element.taskMsg.fromUser?.userCompany?.displayName ?? '';
    userIDReceiver = element.taskMsg.toUser?.userId;
    // controller.replyToMessage = element.taskMsg;

    update();

    if(kIsWeb){
      Get.toNamed("${AppRoutes.task_threads_web}?currentUserId=${user?.userId.toString()}&taskMsgId=${element.taskMsg.taskId.toString()}"
      );
    }else{
      Get.toNamed(AppRoutes.task_threads,
          arguments: {
            'taskMsg':  element.taskMsg, 'currentUser': user!
          });
    }
  }




  Future<void> openTaskThreadSmart({
    required BuildContext context,
    GroupTaskElement? groupElement,
  }) async {
    Get.find<SocketController>().joinTaskEmitter(taskId: groupElement?.taskMsg.taskId??0);

    update();
    if (kIsWeb) {

      Get.parameters = {
        "currentUserId": user?.userId.toString(),
        "taskMsgId": groupElement?.taskMsg.taskId.toString(),
      };
      // Load binding manually
      TaskThreadBinding().dependencies();
       await  showDialog(
        context: context,
        barrierDismissible: true,
        builder: (_) {
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 600,
                maxHeight:500,
              ),
              child: Material(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                clipBehavior: Clip.antiAlias,
                child: TaskThreadScreenWeb(),   // <- Your original Screen
              ),
            ),
          ).marginAll(20);
        },
      ).then((_) {
        Get.delete<TaskThreadController>(force: true);
      }).whenComplete((){
        final _tagTaskid = TaskPresence.activeTaskId.value;
        final _tagTask = "task_$_tagTaskid";
        if(Get.isRegistered<TaskController>(tag: _tagTask)) {
          final taskc=  Get.find<TaskController>(tag: _tagTask);
          taskc.resetPaginationForNewChat();
          taskc.hitAPIToGetTaskHistory();
        }
      });

    } else {
      // Mobile → normal navigation
      Get.toNamed(AppRoutes.task_threads,
          arguments: {
            'taskMsg':  groupElement?.taskMsg, 'currentUser': user!
          });
    }
  }


  /*Future<void> sendTaskApiCall() async {
    // Hide keyboard
    SystemChannels.textInput.invokeMethod('TextInput.hide');

    try {
      if (attachedFiles.isNotEmpty) {
        isUploading = true;
        update();

        // Build multipart files (with safe filename & contentType)
        final List<multi.MultipartFile> mediaFiles = [];
        for (final item in attachedFiles) {
          final path = _pathOf(item);
          final name = (item['name'] as String?)?.trim();
          final filename =
              (name != null && name.isNotEmpty) ? name : p.basename(path);

          final mt = _mediaTypeForPath(path);
          // If contentType is null, let Dio infer—avoids crashes on unknown types
          final mf = await multi.MultipartFile.fromFile(
            path,
            filename: filename,
            contentType: mt,
          );
          mediaFiles.add(mf);
        }

        // Build other fields
        DateTime? selectedDateTime;
        if (selectedDate != null && selectedTime != null) {
          selectedDateTime = DateTime(
            selectedDate!.year,
            selectedDate!.month,
            selectedDate!.day,
            selectedTime!.hour,
            selectedTime!.minute,
          );
        }

        final Map<String, dynamic> fields = {
          'task_media': mediaFiles,
        };

        final formData = multi.FormData.fromMap(fields);

        // Optional: log once to verify keys
        // print(formData.fields.map((e) => e.key).toList());
        // print(formData.files.map((e) => e.key).toList());

        final resp =
            await Get.find<PostApiServiceImpl>().uplaodTaskAttachmentsAPICall(
          dataBody: formData,
        );

        isUploading = false;
        update();
        var time = selectedDateTime?.toIso8601String();
        try {
          // If your upload API returns the saved files list:
          Get.find<SocketController>().sendTaskMessage(
            receiverId: user?.userCompany?.userCompanyId,
            companyId: myCompany?.companyId,
            taskTitle: titleController.text.trim(),
            taskDes: descController.text.trim(),
            taskDeadline:  time,
            attachmentsList: resp.data?.files,
          );
          _clearFields();
          Get.back();

          update();
        } catch (e) {
          print(e.toString());
        }
      } else {
        if (selectedDate != null && selectedTime != null) {
        try {
            DateTime? selectedDateTime;
            if (selectedDate != null && selectedTime != null) {
              selectedDateTime = DateTime(
                selectedDate!.year,
                selectedDate!.month,
                selectedDate!.day,
                selectedTime!.hour,
                selectedTime!.minute,
              );
            }
            var time = selectedDateTime?.toIso8601String();
            Get.find<SocketController>().sendTaskMessage(
              receiverId: user?.userCompany?.userCompanyId,
              companyId: myCompany?.companyId,
              taskTitle: titleController.text.trim(),
              taskDes: descController.text.trim(),
              taskDeadline: time,
            );
            _clearFields();
            Get.back();
            update();
          } catch (e) {
          print(e.toString());
        }
      }else{
          Get.find<SocketController>().sendTaskMessage(
            receiverId: user?.userCompany?.userCompanyId,
            companyId: myCompany?.companyId,
            taskTitle: titleController.text.trim(),
            taskDes: descController.text.trim(),
          );
          _clearFields();
          Get.back();
          update();
        }
      }
    } catch (e) {
      isUploading = false;
      update();
      errorDialog(e.toString());
    }
  }*/


  Future<void> sendTaskApiCall() async {
    // Hide keyboard
    SystemChannels.textInput.invokeMethod('TextInput.hide');

    try {
      // Build selected deadline, if any
      DateTime? selectedDateTime;
      if (selectedDate != null && selectedTime != null) {
        selectedDateTime = DateTime(
          selectedDate!.year,
          selectedDate!.month,
          selectedDate!.day,
          selectedTime!.hour,
          selectedTime!.minute,
        );
      }
      final String? isoDeadline = selectedDateTime?.toIso8601String();

      // If there are no attachments, just emit the socket event
      if (attachedFiles.isEmpty) {
        try {
          Get.find<SocketController>().sendTaskMessage(
            receiverId: user?.userCompany?.userCompanyId,
            companyId: myCompany?.companyId,
            taskTitle: titleController.text.trim(),
            taskDes: descController.text.trim(),
            taskDeadline: isoDeadline,
          );
          clearFields();
          Get.back();
          update();
        } catch (e) {
          debugPrint('sendTaskMessage (no files) error: $e');
        }
        return;
      }

      // === With attachments ===
      isUploading = true;
      update();

      final List<multi.MultipartFile> mediaFiles = [];

      for (final item in attachedFiles) {
        // expected shapes we support:
        // MOBILE image/doc: {'file': File, 'name': '...', 'type': 'image'|'doc', ...}
        // WEB image:  {'bytes': Uint8List, 'name': '...', 'type': 'image', ...}
        // WEB doc:{'platformFile': PlatformFile, 'name': '...', 'type': 'doc', ...}
        // LEGACY: {'url': File}  (your older code path)

        final String nameFromItem = (item['name'] as String?)?.trim() ?? '';
        final dynamic fileObj = item['file'];            // File? (mobile)
        final dynamic legacyUrl = item['url'];           // File? (legacy mobile key)
        final dynamic bytesObj = item['bytes'];          // Uint8List? (web images)
        final dynamic pfObj    = item['platformFile'];   // PlatformFile? (web docs)

        // Decide filename
        String filename = nameFromItem;
        if (filename.isEmpty) {
          if (pfObj != null && pfObj is PlatformFile) {
            filename = pfObj.name;
          } else if (fileObj != null && fileObj is File) {
            filename = p.basename(fileObj.path);
          } else if (legacyUrl != null && legacyUrl is File) {
            filename = p.basename(legacyUrl.path);
          } else {
            filename = 'file_${DateTime.now().millisecondsSinceEpoch}';
          }
        }
        filename = safeName(filename);
        final extis = ext(filename);
        final contentType = mediaTypeForExt(extis); // MediaType

        // Build MultipartFile depending on platform & data available
        multi.MultipartFile mf;

        if (kIsWeb) {
          // WEB: prefer in-memory bytes
          if (bytesObj != null && bytesObj is Uint8List) {
            mf = multi.MultipartFile.fromBytes(
              bytesObj,
              filename: filename,
              contentType: contentType,
            );
          } else if (pfObj != null && pfObj is PlatformFile && pfObj.bytes != null) {
            mf = multi.MultipartFile.fromBytes(
              pfObj.bytes!,
              filename: filename,
              contentType: contentType,
            );
          } else if (pfObj != null && pfObj is PlatformFile && pfObj.path != null) {
            // Some desktop/web setups might still give a path
            mf = await multi.MultipartFile.fromFile(
              pfObj.path!,
              filename: filename,
              contentType: contentType,
            );
          } else {
            // nothing usable -> skip
            debugPrint('Skipping attachment (no bytes/path on web): $filename');
            continue;
          }
        } else {
          // MOBILE / DESKTOP: prefer File path
          if (fileObj != null && fileObj is File) {
            mf = await multi.MultipartFile.fromFile(
              fileObj.path,
              filename: filename,
              contentType: contentType,
            );
          } else if (legacyUrl != null && legacyUrl is File) {
            mf = await multi.MultipartFile.fromFile(
              legacyUrl.path,
              filename: filename,
              contentType: contentType,
            );
          } else if (pfObj != null && pfObj is PlatformFile && pfObj.path != null) {
            mf = await multi.MultipartFile.fromFile(
              pfObj.path!,
              filename: filename,
              contentType: contentType,
            );
          } else if (bytesObj != null && bytesObj is Uint8List) {
            // Fallback: if you stored bytes on mobile too
            mf = multi.MultipartFile.fromBytes(
              bytesObj,
              filename: filename,
              contentType: contentType,
            );
          } else {
            debugPrint('Skipping attachment (no file/path/bytes on mobile): $filename');
            continue;
          }
        }

        mediaFiles.add(mf);
      }

      if (mediaFiles.isEmpty) {
        // nothing to upload—just send the task text
        isUploading = false;
        update();
        Get.find<SocketController>().sendTaskMessage(
          receiverId: user?.userCompany?.userCompanyId,
          companyId: myCompany?.companyId,
          taskTitle: titleController.text.trim(),
          taskDes: descController.text.trim(),
          taskDeadline: isoDeadline,
        );
        clearFields();
        Get.back();
        update();
        return;
      }

      // Build multipart payload for API that stores attachments
      final formData = multi.FormData.fromMap({
        'task_media': mediaFiles, // server expects an array field
      });

      final resp = await Get.find<PostApiServiceImpl>().uplaodTaskAttachmentsAPICall(
        dataBody: formData,
        // If your service exposes progress:
        // onSendProgress: (s, t) => setUploadProgress(s, t),
      );

      isUploading = false;
      update();

      try {
        Get.find<SocketController>().sendTaskMessage(
          receiverId: user?.userCompany?.userCompanyId,
          companyId: myCompany?.companyId,
          taskTitle: titleController.text.trim(),
          taskDes: descController.text.trim(),
          taskDeadline: isoDeadline,
          attachmentsList: resp.data?.files, // as per your API
        );
        clearFields();
        Get.back();
        update();
      } catch (e) {
        debugPrint('sendTaskMessage (with files) error: $e');
      }
    } catch (e) {
      isUploading = false;
      update();
      errorDialog(e.toString());
    }
  }

  clearFields(){
    titleController.clear();
    descController.clear();
    selectedDate=null;
    selectedTime=null;
    attachedFiles.clear();
  }

  Future<void> pickWebImagesForTask(void Function(void Function()) setStateInside) async {
    try {
      setStateInside(() => isUploadingTaskDoc = true);

      final result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        withData: true, // critical on web
        type: FileType.custom,
        allowedExtensions: const ['jpg', 'jpeg', 'png', 'webp'],
      );
      if (result == null || result.files.isEmpty) return;

      final remaining = 3 - attachedFiles.length;
      if (remaining <= 0) {
        toast("You can upload up to 3 attachments only");
        return;
      }

      final selected = result.files.take(remaining);
      for (final f in selected) {
        final Uint8List? bytes = f.bytes;
        if (bytes == null) continue;

        attachedFiles.add({
          'type': 'image',
          'name': f.name,
          'isLocal': true,
          'isDelete': false,
          // Web stores raw bytes for preview & later upload
          'bytes': bytes,
        });
      }
      update();
    } catch (e) {
      debugPrint('pick web images error: $e');
    } finally {
      setStateInside(() => isUploadingTaskDoc = false);
    }
  }

  Future<void> pickWebDocsForTask(void Function(void Function()) setStateInside) async {
    try {
      setStateInside(() => isUploadingTaskDoc = true);

      final result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        withData: true,
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
      if (result == null || result.files.isEmpty) return;

      final remaining = 3 - attachedFiles.length;
      if (remaining <= 0) {
        toast("You can upload up to 3 attachments only");
        return;
      }

      final selected = result.files.take(remaining);
      for (final f in selected) {
        attachedFiles.add({
          'type': 'doc',
          'name': f.name,
          'isLocal': true,
          'isDelete': false,
          // Web: we keep the PlatformFile for upload (has name, size, bytes)
          'bytes': f,
        });
      }
      update();
    } catch (e) {
      debugPrint('pick web docs error: $e');
    } finally {
      setStateInside(() => isUploadingTaskDoc = false);
    }
  }



  Future<void> updateTaskApiCall({
    required TaskData task,
    taskStatusId,
  }) async {
    // Hide keyboard
    SystemChannels.textInput.invokeMethod('TextInput.hide');

    try {
      // ⏰ Deadline calculate
      DateTime? selectedDateTime;
      if (selectedDate != null && selectedTime != null) {
        selectedDateTime = DateTime(
          selectedDate!.year,
          selectedDate!.month,
          selectedDate!.day,
          selectedTime!.hour,
          selectedTime!.minute,
        );
      }
      final String? time = selectedDateTime?.toIso8601String();

      // ===========================
      //   CASE 1: WITH ATTACHMENTS
      // ===========================


        if (taskStatusId != null) {
          Get.find<SocketController>().updateTaskMessage(
            taskID: task.taskId,
            taskStatusId: taskStatusId,
            receiverId: user?.userCompany?.userCompanyId,
            companyId: myCompany?.companyId,
            taskTitle: task.title,
            taskDes: task.details,
          );
          clearFields();
          update();
          return;
        } else {
          if (attachedFiles.isNotEmpty ) {
            isUploading = true;
            update();

            final List<multi.MultipartFile> mediaFiles = [];

            // 🔁 Jo bhi attachedFiles me hai (existing + new) sabko Multipart bana ke upload karenge
            for (final raw in attachedFiles) {
              final Map<String, dynamic> item =
              Map<String, dynamic>.from(raw as Map);

              final String? name = (item['name'] as String?)?.trim();
              final String filename =
              (name != null && name.isNotEmpty) ? name : 'file';

              final mt = _mediaTypeForPath(filename);
              final bool isLocal = item['isLocal'] == true;

              multi.MultipartFile? mf;

              if (isLocal) {
                // 🔹 NEW LOCAL FILE
                if (kIsWeb) {
                  // 🌐 WEB: use bytes
                  final bytes = item['bytes'];
                  if (bytes == null) {
                    // invalid local item, skip
                    continue;
                  }

                  mf = multi.MultipartFile.fromBytes(
                    (bytes as List<int>),
                    filename: filename,
                    contentType: mt,
                  );
                } else {
                  // 📱 MOBILE / DESKTOP: use File
                  final file = item['file'];
                  if (file == null) {
                    continue;
                  }

                  final String path = (file as File).path;

                  mf = await multi.MultipartFile.fromFile(
                    path,
                    filename: filename,
                    contentType: mt,
                  );
                }
              } else {
                // 🔹 EXISTING SERVER FILE → re-upload via URL
                final String? url = item['url'] as String?;
                if (url == null || url.isEmpty) {
                  continue;
                }

                try {
                  final uri = Uri.parse(url);
                  final res = await http.get(uri);

                  if (res.statusCode != 200) {
                    // download fail → skip this particular media
                    continue;
                  }

                  mf = multi.MultipartFile.fromBytes(
                    res.bodyBytes,
                    filename: filename,
                    contentType: mt,
                  );
                } catch (e) {
                  // network / parse error → skip this media
                  continue;
                }
              }

              if (mf != null) {
                mediaFiles.add(mf);
              }

            }

            // Agar kisi reason se koi bhi media valid na ban paya
            if (mediaFiles.isEmpty) {
              isUploading = false;
              update();

              // Fallback: sirf text update bhej sakti ho ya attachmentsList empty bhej do
              Get.find<SocketController>().updateTaskMessage(
                taskID: task.taskId,
                receiverId: user?.userCompany?.userCompanyId,
                companyId: myCompany?.companyId,
                taskTitle: titleController.text.trim(),
                taskDes: descController.text.trim(),
                taskDeadline: time,
                attachmentsList: [],
              );
              Get.back();
              return;
            }

            // 🔴 IMPORTANT: Yaha **saare** media (existing + new) upload ho rahe hain
            final formData = multi.FormData.fromMap({
              'task_media': mediaFiles,
            });

            final resp =
            await Get.find<PostApiServiceImpl>().uplaodTaskAttachmentsAPICall(
              dataBody: formData,
            );

            isUploading = false;
            update();

            final attachments = resp.data?.files ?? [];

            try {
              Get.find<SocketController>().updateTaskMessage(
                taskID: task.taskId,
                receiverId: user?.userCompany?.userCompanyId,
                companyId: myCompany?.companyId,
                taskTitle: titleController.text.trim(),
                taskDes: descController.text.trim(),
                taskDeadline: time,
                // 👇 Fresh full list from API
                attachmentsList: attachments,
              );
              Get.back();
              update();
            } catch (e) {
              debugPrint(e.toString());
            }

            // ===========================
            //   CASE 2: NO ATTACHMENTS
            // ===========================
          } else {


            isUploading = false;
            update();

            // Fallback: sirf text update bhej sakti ho ya attachmentsList empty bhej do
            Get.find<SocketController>().updateTaskMessage(
              taskID: task.taskId,
              receiverId: user?.userCompany?.userCompanyId,
              companyId: myCompany?.companyId,
              taskTitle: titleController.text.trim(),
              taskDes: descController.text.trim(),
              taskDeadline: time,
              attachmentsList: [],
            );
            Get.back();
            return;
          }
        }





    } catch (e) {
      isUploading = false;
      update();
      errorDialog(e.toString());
    }
  }



/*  Future<void> updateTaskApiCall({required TaskData task, taskStatusId}) async {
    // Hide keyboard
    SystemChannels.textInput.invokeMethod('TextInput.hide');

  try {
      if (attachedFiles.isNotEmpty) {
        isUploading = true;
        update();

        // Build multipart files (with safe filename & contentType)
        final List<multi.MultipartFile> mediaFiles = [];
        for (final item in attachedFiles) {
          final path = _pathOf(item);
          final name = (item['name'] as String?)?.trim();
          final filename =
              (name != null && name.isNotEmpty) ? name : p.basename(path);

          final mt = _mediaTypeForPath(path);
          // If contentType is null, let Dio infer—avoids crashes on unknown types
          final mf = await multi.MultipartFile.fromFile(
            path,
            filename: filename,
            contentType: mt,
          );
          mediaFiles.add(mf);
        }

        // Build other fields
        DateTime? selectedDateTime;
        if (selectedDate != null && selectedTime != null) {
          selectedDateTime = DateTime(
            selectedDate!.year,
            selectedDate!.month,
            selectedDate!.day,
            selectedTime!.hour,
            selectedTime!.minute,
          );
        }

        final Map<String, dynamic> fields = {
          'task_media': mediaFiles,
        };

        final formData = multi.FormData.fromMap(fields);

        // Optional: log once to verify keys
        // print(formData.fields.map((e) => e.key).toList());
        // print(formData.files.map((e) => e.key).toList());

        final resp =
            await Get.find<PostApiServiceImpl>().uplaodTaskAttachmentsAPICall(
          dataBody: formData,
        );

        isUploading = false;
        update();
        var time = selectedDateTime?.toIso8601String();
        try {
          // If your upload API returns the saved files list:
          Get.find<SocketController>().updateTaskMessage(
            taskID: task.taskId,
            receiverId: user?.userCompany?.userCompanyId,
            companyId: myCompany?.companyId,
            taskTitle: titleController.text.trim(),
            taskDes: descController.text.trim(),
            taskDeadline:  time,
            attachmentsList: resp.data?.files,
          );
          Get.back();

          update();
        } catch (e) {
          print(e.toString());
        }
      } else {
        try {
          DateTime? selectedDateTime;
          if (selectedDate != null && selectedTime != null) {
            selectedDateTime = DateTime(
              selectedDate!.year,
              selectedDate!.month,
              selectedDate!.day,
              selectedTime!.hour,
              selectedTime!.minute,
            );
          }
          var time = selectedDateTime?.toIso8601String();
          taskStatusId!=null?Get.find<SocketController>().updateTaskMessage(
            taskID: task.taskId,
            taskStatusId: taskStatusId,
            receiverId: user?.userCompany?.userCompanyId,
            companyId: myCompany?.companyId,
            taskTitle: task.title,
            taskDes: task.details,
            // taskDeadline: time,
          ):Get.find<SocketController>().updateTaskMessage(
              taskID: task.taskId,
              receiverId: user?.userCompany?.userCompanyId,
              companyId: myCompany?.companyId,
              taskTitle: titleController.text.trim(),
              taskDes: descController.text.trim(),
              taskStatusId: taskStatusId
            // taskDeadline: time,
          );
          clearFields();
          update();
        } catch (e) {
          print(e.toString());
        }
      }
    } catch (e) {
      isUploading = false;
      update();
      errorDialog(e.toString());
    }
   *//* try {
      DateTime? selectedDateTime;
      if (selectedDate != null && selectedTime != null) {
        selectedDateTime = DateTime(
          selectedDate!.year,
          selectedDate!.month,
          selectedDate!.day,
          selectedTime!.hour,
          selectedTime!.minute,
        );
      }
      var time = selectedDateTime?.toIso8601String();
      taskStatusId!=null?Get.find<SocketController>().updateTaskMessage(
          taskID: task.taskId,
          taskStatusId: taskStatusId,
          receiverId: user?.userCompany?.userCompanyId,
          companyId: myCompany?.companyId,
          taskTitle: task.title,
          taskDes: task.details,
        // taskDeadline: time,
      ):Get.find<SocketController>().updateTaskMessage(
        taskID: task.taskId,
        receiverId: user?.userCompany?.userCompanyId,
        companyId: myCompany?.companyId,
        taskTitle: titleController.text.trim(),
        taskDes: descController.text.trim(),
        taskStatusId: taskStatusId
        // taskDeadline: time,
      );
      clearFields();
      update();
    } catch (e) {
      print(e.toString());
    }*//*
  }*/


  String convertUtcToIndianTime(String utcTimeString) {
    // Parse UTC string
    DateTime utcTime = DateTime.parse(utcTimeString);

    // Always convert to IST (+5:30)
    DateTime indianTime = utcTime.add(const Duration(hours: 5, minutes: 30));

    // Format like "9:00 AM"
    return DateFormat.jm().format(indianTime);
  }

  TaskHisResModel taskHisRes = TaskHisResModel();

  List<TaskData>? taskHisList = [];
  List<GroupTaskElement> taskCategory = [];
  bool isLoading = false;
  bool isLoadings = false;
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
            !isPageLoading && hasMore) {
          // resetPaginationForNewChat();
          hitAPIToGetTaskHistory();
        }
      });
    } else {
      scrollController2.addListener(() {
        if (scrollController2.position.pixels <=
            scrollController2.position.minScrollExtent + 50 &&
            !isPageLoading&& hasMore ) {
          // resetPaginationForNewChat();
          hitAPIToGetTaskHistory();
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
    taskHisList = []; // <--- MOST IMPORTANT
    taskCategory = [];
    showPostShimmer = true;
    update();
  }

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
      taskHisList = [];
      update();
      hitAPIToGetTaskHistory(search: searchQuery.isEmpty ? null : searchQuery);
    });

  }


  Future<void> hitAPIToGetTaskHistory({int? statusId,isFilter= false,isForward= false,fromDate,toDate,String? search}) async {
    if (isPageLoading || !hasMore) return;
    if (page == 1) {
      showPostShimmer = true;
      taskCategory.clear();
      taskHisList?.clear();
    }
    isPageLoading = true;
    update();
    try {
      final value = await Get.find<PostApiServiceImpl>().getTaskHistoryApiCall(
          userComId: user?.userCompany?.userCompanyId,
          page: page,
          statusId: statusId ?? '',
          searchText: search,
          fromDate: fromDate,
          toDate: toDate
      );
      showPostShimmer = false;
      taskHisRes = value;
      final rows = value.data?.rows ?? [];
      if (rows.isNotEmpty) {
        if (page == 1) {
          taskHisList = rows;
        } else {
          taskHisList?.addAll(rows);
        }
        page++;
      } else {
        if (!isFilter) {
          // isPageLoading = false;
          hasMore = false;
        } else {
          hasMore = false;
          taskHisList = [];
          taskCategory = [];
        }
      }
      taskCategory = (taskHisList ?? []).map((item) {
        DateTime? datais;
        if (item.createdOn != null) {
          datais = DateTime.parse(item.createdOn ?? '');
        }
        return GroupTaskElement(datais ?? DateTime.now(), item);
      }).toList();

    } catch (e) {
      showPostShimmer = false;
    } finally {
      isPageLoading = false;
      update();
    }
  }



/*
  hitAPIToGetTaskHistory({int? statusId,isFilter= false,isForward= false,fromDate,toDate,String? search}) async {
    if(page==1){
      showPostShimmer = true;
      taskCategory.clear();
      taskHisList?.clear();
    }

    isPageLoading = true;
    update();
    try {
      Get.find<PostApiServiceImpl>()
          .getTaskHistoryApiCall(
          userComId: user?.userCompany?.userCompanyId,
          page: page,
          statusId: statusId ?? '',
          searchText: search,
          fromDate: fromDate,
          toDate: toDate
      )
          .then((value) async {
        showPostShimmer = false;
        taskHisRes = value;
        if (value.data?.rows != null && (value.data?.rows ?? []).isNotEmpty) {
          if (page == 1) {
            taskHisList = value.data?.rows ?? [];
          } else {
            taskHisList?.addAll(value.data?.rows ?? []);
          }
          page++;
        } else {
          if (!isFilter) {
            hasMore = false;
            isPageLoading = false;
          } else {
            isPageLoading = false;
            hasMore = false;
            taskHisList = [];
            taskCategory = [];
          }
        }

        taskCategory = (taskHisList ?? []).map((item) {
          DateTime? datais;
          if (item.createdOn != null) {
            datais = DateTime.parse(item.createdOn ?? '');
          }
          return GroupTaskElement(datais ?? DateTime.now(), item);
        }).toList();
        showPostShimmer = false;
        isPageLoading = false;
        update();
      }).onError((error, stackTrace) {
        showPostShimmer = false;
        isPageLoading = false;
        update();
      });
    }  catch (e) {
      showPostShimmer = false;
    } finally {
      isPageLoading = false;
      update();
    }
  }
*/



  timeExceed(taskDetails) {
    // Timer.periodic(const Duration(seconds: 15), (t) {
    //   final end =
    //       DateTime.fromMillisecondsSinceEpoch(taskDetails['estimatedEndTime']);
    //   if (DateTime.now().isAfter(end) && taskDetails['status'] != 'Done') {
    //     // play sound or show badge
    //     // showDeadlineExceededAlert();
    //     timer.cancel();
    //   }
    // });
  }

  final tasksFormKey = GlobalKey<FormState>();
  DateTime? newSelectedDate;
  TimeOfDay? newSelectedTime;
  DateTime? newSelectedDateTime;
  final titleController = TextEditingController();
  final descController = TextEditingController();
  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  bool isTaskMessage(String msg) {
    return msg.toLowerCase().startsWith('task:');
  }

  Map<String, dynamic>? parseTaskMessage(String msg) {
    if (!isTaskMessage(msg)) return null;
    final lines = msg.split('\n');
    final title = lines.first.replaceFirst('task:', '').trim();
    final timeLine =
        lines.last.toLowerCase().startsWith('time:') ? lines.last : null;
    final description = lines
        .sublist(1, timeLine != null ? lines.length - 1 : null)
        .join('\n')
        .trim();
    return {
      'title': title,
      'description': description,
      'time': timeLine?.replaceFirst('time:', '').trim()
    };
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

  Future<void> pickDocumentForTask(setStateInside) async {
    update();
    setStateInside(() {
      isUploadingTaskDoc = true;
    });

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
      allowMultiple: false,
    );

    if (result != null && result.files.single.path != null) {
      File file = File(result.files.single.path!);
      attachedFiles
          .add({'url': file, 'type': 'doc', 'name': result.files.single.name});
      update();
      setStateInside(() {
        isUploadingTaskDoc = false;
      });
    }
  }



  List<NavigationItem> taskItems=[];
  List<NavigationItem>? userNav=[];
  getUserNavigation(){
    userNav = getNavigation();
    update();
    userNav = (userNav??[])
        .where((nav) => nav.navigationPlace == task_details_key)
        .toList();
    taskItems =(userNav??[])
        .where((nav) => nav.navigationPlace == task_details_key && nav.isActive == 1)
        .toList()
      ..sort((a, b) => (a.sortingOrder??0).compareTo(b.sortingOrder??0));


  }






  initVideoPlayer() async {
    // videoPlayerController = VideoPlayerController.file(_file!);
    // await videoPlayerController?.initialize();
    // chewieController = ChewieController(
    //   videoPlayerController: videoPlayerController!,
    //   autoPlay: false,
    //   showControls: false,
    //   aspectRatio: MediaQuery.of(context).size.aspectRatio * 2.74,
    // );
    // setState(() {});
  }





  chooseMediaSource() async {
    var pFile;
    galleryVideo() async {
      pFile = await ImagePicker.platform.pickVideo(
          source: ImageSource.gallery,
          maxDuration: const Duration(seconds: 30));
      if (pFile != null) {
        file = File(pFile.path);
        isUploading = true;
        update();

        // await APIs.sendChatVideo(user!, File(pFile.path));
        await initVideoPlayer();
        isUploading = false;
        update();
      }
    }

    gallaryImage() async {
      // final ImagePicker picker = ImagePicker();
      //
      // // Picking multiple images
      // final List<XFile> images = await picker.pickMultiImage(imageQuality: 70);
      //
      // // uploading & sending image one by one
      // for (var i in images) {
      //   // log('Image Path: ${i.path}');
      //   setState(() => _isUploading = true);
      //   await APIs.sendChatImage(widget.user, File(i.path));
      //   setState(() => _isUploading = false);
      // }
      final ImagePicker picker = ImagePicker();

      // Picking multiple images
      final List<XFile> imas = await picker.pickMultiImage(imageQuality: 70);

      // uploading & sending image one by one

      images.addAll(imas);
    }

    cameraVideo() async {
      pFile = await ImagePicker.platform.pickVideo(
          source: ImageSource.camera, maxDuration: const Duration(seconds: 30));
      if (pFile != null) {
        file = File(pFile.path);
        isUploading = true;

        update();

        // await APIs.sendChatVideo(user!, File(pFile.path));
        await initVideoPlayer();
        isUploading = false;
        update();
      }
    }

    cameraImage() async {
      // final ImagePicker picker = ImagePicker();
      // // Pick an image
      // final XFile? image =
      //     await picker.pickImage(source: ImageSource.camera, imageQuality: 70);
      // if (image != null) {
      //   // log('Image Path: ${image.path}');
      //   setState(() => _isUploading = true);
      //
      //   await APIs.sendChatImage(widget.user, File(image.path));
      //   setState(() => _isUploading = false);
      // }

      final ImagePicker picker = ImagePicker();
      // Pick an image
      final XFile? image =
          await picker.pickImage(source: ImageSource.camera, imageQuality: 70);
      if (image != null) {
        // log('Image Path: ${image.path}');
        isUploading = true;
        update();
        // await APIs.sendChatImage(user!, File(image.path));
        isUploading = false;
        update();
      }
    }

    return showBottomSheet(
        context: Get.context!,
        builder: (_) => Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Gallery',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                  /*const SizedBox(height: 5),
                  ListTile(
                    title: const Text('Video'),
                    leading: const Icon(Icons.video_collection_rounded),
                    onTap: () async {
                      await _galleryVideo();
                      Navigator.pop(context, _file);
                    },
                    contentPadding: const EdgeInsets.all(0),
                    isThreeLine: false,
                  ),*/
                  const SizedBox(height: 5),
                  ListTile(
                    title: const Text('Image'),
                    leading: const Icon(Icons.video_collection_rounded),
                    onTap: () async {
                      await gallaryImage();
                      Navigator.pop(Get.context!, file);
                    },
                    contentPadding: const EdgeInsets.all(0),
                    isThreeLine: false,
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  const Text(
                    'Camera',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                  /* ListTile(
                    title: const Text('Video'),
                    leading: const Icon(Icons.videocam_outlined),
                    onTap: () async {
                      await _cameraVideo();
                      Navigator.pop(context, _file);
                    },
                    contentPadding: const EdgeInsets.all(0),
                    isThreeLine: false,
                  ),
                  const SizedBox(height: 5),*/
                  ListTile(
                    title: const Text('Image'),
                    leading: const Icon(Icons.image),
                    onTap: () async {
                      await cameraImage();
                      Navigator.pop(Get.context!, file);
                    },
                    contentPadding: const EdgeInsets.all(0),
                    isThreeLine: false,
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                ],
              ),
            ));
  }

  Future<void> handleForward({required TaskData taskData}) async {
    final selectedUser = await showDialog<UserDataAPI>(
      context: Get.context!,
      builder: (_) => AllUserScreenDialog(),
    );
    if (selectedUser == null) return;

    final companyId = myCompany?.companyId;
    if (companyId == null) return;

    final taskId = taskData.taskId;
    if (taskId == null) return;

    final receiverId = selectedUser.userCompany?.userCompanyId;
    if (receiverId == null) return;

    final socket = Get.find<SocketController>();

    void afterSendNavigate() {
      textController.clear();
      replyToMessage = null;

      final tagId = receiverId;
      final tag = "task_$tagId";

      if (Get.isRegistered<TaskHomeController>()) {
        Get.find<TaskHomeController>().selectedChat.value = selectedUser;
      }

      final con = Get.isRegistered<TaskController>(tag: tag)
          ? Get.find<TaskController>(tag: tag)
          : Get.put(TaskController(user: selectedUser), tag: tag);


      con.openConversation(selectedUser);
    }

    socket.forwardTaskMessage(
      taskID: taskId,
      receiverId: receiverId,
      companyId: companyId,
      tasktitle: taskData.title ?? '',
      user:
      (selectedUser.userCompany?.displayName != null)
          ? selectedUser.userCompany?.displayName ?? ''
          : selectedUser?.userName != null
          ? selectedUser?.userName ?? ''
          : selectedUser?.phone?? ''
    );

    afterSendNavigate();
  }

/*  Future<void> handleForward({required TaskData taskData}) async {
    final selectedUser = await showDialog<UserDataAPI>(
      context: Get.context!,
      builder: (_) => AllUserScreenDialog(),
    );
    if (selectedUser == null) return;
    final socket = Get.find<SocketController>();
    void _afterSendNavigate() {
      textController.clear();
      replyToMessage = null;
      final _tagid = selectedUser.userCompany?.userCompanyId;
      final _tag = "task_${_tagid ?? 'mobile'}";
      if (Get.isRegistered<TaskController>(tag: _tag)) {
        Get.find<TaskHomeController>().selectedChat.value = selectedUser;
        final con = Get.find<TaskController>(
            tag:_tag);
        con.openConversation(selectedUser);
      } else {
        Get.put(TaskController(user: selectedUser),tag: _tag);
      }
    }

    final targetUcId = selectedUser.userCompany?.userCompanyId;

    if (selectedUser == null) return;

    socket.forwardTaskMessage(
        taskID: taskData.taskId,
        receiverId: selectedUser.userCompany?.userCompanyId,
        companyId: myCompany?.companyId,
        tasktitle: taskData.title??''
    );
    _afterSendNavigate();

  }*/

  Future<void> handleForwardMobile({required TaskData taskData}) async {
    final selectedUser = await showDialog<UserDataAPI>(
      context: Get.context!,
      builder: (_) => AllUserScreenDialog(),
    );
    if (selectedUser == null) return;
    final socket = Get.find<SocketController>();
    void _afterSendNavigate() {
      textController.clear();
      replyToMessage = null;
      if (Get.isRegistered<TaskController>()) {
        Get.find<TaskHomeController>().selectedChat.value = selectedUser;
        final con = Get.find<TaskController>();
        con.openConversation(selectedUser);
      } else {
        Get.put(TaskController(user: selectedUser));
      }
    }

    final targetUcId = selectedUser.userCompany?.userCompanyId;

    if (selectedUser == null) return;

    socket.forwardTaskMessage(
        taskID: taskData.taskId,
        receiverId: selectedUser.userCompany?.userCompanyId,
        companyId: myCompany?.companyId,
        tasktitle: taskData.title??'',
        user:  (selectedUser.userCompany?.displayName != null)
            ? selectedUser.userCompany?.displayName ?? ''
            : selectedUser?.userName != null
            ? selectedUser?.userName ?? ''
            : selectedUser?.phone?? ''
    );
    _afterSendNavigate();

  }








  // Future<void> handleForward({required TaskData taskData}) async {
  //   final selectedUser = await showDialog<UserDataAPI>(
  //     context: Get.context!,
  //     builder: (_) =>  AllUserScreenDialog(users: taskData.members,),
  //   );
  //   if (selectedUser == null) return;
  //   final socket = Get.find<SocketController>();
  //
  //   socket.forwardTaskMessage(
  //       taskID: taskData.taskId,
  //       receiverId: selectedUser.userCompany?.userCompanyId,
  //   companyId: myCompany?.companyId,
  //       tasktitle: taskData.title??''
  //
  //   ).then((v)=> kIsWeb?_afterSendNavigate(selectedUser):_afterSendNavigateMobile(selectedUser));
  //
  // }
  //
  // void _afterSendNavigate(UserDataAPI selectedUser) {
  //   textController.clear();
  //   replyToMessage = null;
  //   update();
  //   final _tagTaskid = TaskPresence.activeTaskId.value;
  //   final _tagTask = "task_$_tagTaskid";
  //   // Replace current chat screen with the target chat
  //   if(Get.isRegistered<TaskController>(tag: _tagTask)&& kIsWeb) {
  //     page =1;
  //     Get.find<TaskHomeController>().selectedChat.value =selectedUser ;
  //     Get.find<TaskController>(tag: _tagTask).openConversation(selectedUser);
  //   }
  //  /* if (Get.isRegistered<TaskController>() && kIsWeb) {
  //     page =1;
  //     Get.find<TaskHomeController>().selectedChat.value =selectedUser ;
  //     Get.find<TaskController>().openConversation(selectedUser);
  //   }*/ else {
  //     if(kIsWeb){
  //       Get.to(()=>TaskScreen(taskUser: selectedUser));
  //       // Get.offNamed(
  //       //   "${AppRoutes.tasks_li_r}?userId=${selectedUser.userId.toString()}",
  //       // );
  //     }else{
  //       Get.toNamed(
  //         AppRoutes.tasks_li_r,
  //         arguments: {'user': selectedUser},
  //       );
  //       // Get.to(()=>TaskScreen(taskUser: selectedUser));
  //     }
  //   }
  // }
  //
  // void _afterSendNavigateMobile(UserDataAPI selectedUser) {
  //   textController.clear();
  //   replyToMessage = null;
  //   update();
  //   // Replace current chat screen with the target chat
  //   if(Get.isRegistered<TaskController>() && kIsWeb) {
  //     page =1;
  //     Get.find<TaskHomeController>().selectedChat.value =selectedUser ;
  //     openConversation(selectedUser);
  //   }
  //  /* if (Get.isRegistered<TaskController>() && kIsWeb) {
  //     page =1;
  //     Get.find<TaskHomeController>().selectedChat.value =selectedUser ;
  //     Get.find<TaskController>().openConversation(selectedUser);
  //   }*/ else {
  //     if(kIsWeb){
  //       Get.to(()=>TaskScreen(taskUser: selectedUser));
  //       // Get.offNamed(
  //       //   "${AppRoutes.tasks_li_r}?userId=${selectedUser.userId.toString()}",
  //       // );
  //     }else{
  //       Get.toNamed(
  //         AppRoutes.tasks_li_r,
  //         arguments: {'user': selectedUser},
  //       );
  //       // Get.to(()=>TaskScreen(taskUser: selectedUser));
  //     }
  //   }
  // }
  
  


  String formatWhen(String utcISO) {
    final t = DateTime.parse(utcISO).toLocal();
    return DateFormat('h:mm a, dd MMM').format(t); // e.g., 5:33 PM, 11 Sep
  }
  String getEstimatedTime(setStateInside) {
    /*  if (_selectedTime == null) return "";

    final now = DateTime.now();

    // You can also include selectedDate if you allow full date selection
    final selectedDateTime = DateTime(
      now.year,
      now.month,
      now.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );

    final duration = selectedDateTime.difference(now);

    if (duration.isNegative) return "⏰ Time exceeded!";

    final hrs = duration.inHours;
    final mins = duration.inMinutes.remainder(60);

    return "⏳ $hrs hrs ${mins} mins";*/

    if (selectedDate == null || selectedTime == null) return "";

    final selectedDateTime = DateTime(
      selectedDate!.year,
      selectedDate!.month,
      selectedDate!.day,
      selectedTime!.hour,
      selectedTime!.minute,
    );

    final now = DateTime.now();
    final duration = selectedDateTime.difference(now);

    if (duration.isNegative) {
      return "Oops! The selected time is in the past. Please choose a valid future time.";
    }

    final hrs = duration.inHours;
    final mins = duration.inMinutes.remainder(60);
    return "⏳ $hrs hrs $mins mins remaining";
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

  /// Core saver: downloads bytes and inserts directly into Gallery.
  /// Returns true on success.
/*  Future<bool> _saveToGalleryFromUrl(String url) async {
    if (url.isEmpty) return false;

    try {
      final ts = DateTime.now().millisecondsSinceEpoch;
      final resp = await multi.Dio().get<List<int>>(
        url,
        options: multi.Options(responseType: multi.ResponseType.bytes, receiveTimeout: const Duration(minutes: 2)),
      );

      if (resp.statusCode == 200 && resp.data != null) {
        final ext = _inferExtFromUrl(url); // .jpg/.png …
        final name = 'AccuChat_$ts$ext';

        final result = await ImageGallerySaver.saveImage(
          Uint8List.fromList(resp.data!),
          name: name,
          quality: 100,
          isReturnImagePathOfIOS: true, // gives local id/path on iOS
        );

        // image_gallery_saver returns a map like {'isSuccess': true, 'filePath': '...'}
        final ok = (result['isSuccess'] == true);
        return ok;
      }
    } catch (e) {
      // You can log e if needed
    }
    return false;
  }*/


  void _toast(String msg) {
    Dialogs.showSnackbar(Get.context!, msg);
  }
}

class GroupTaskElement implements Comparable {
  DateTime date;
  TaskData taskMsg;

  GroupTaskElement(
    this.date,
    this.taskMsg,
  );

  @override
  int compareTo(other) {
    return date.compareTo(other.date);
  }
}
