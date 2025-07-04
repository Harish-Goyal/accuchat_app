import 'dart:io';
import 'package:AccuChat/Constants/assets.dart';
import 'package:AccuChat/Screens/chat_module/models/chat_history_model.dart';
import 'package:AccuChat/Screens/chat_module/models/user_chat_list_model.dart';
import 'package:AccuChat/Screens/chat_module/presentation/controllers/group_member_controller.dart';
import 'package:AccuChat/Screens/chat_module/presentation/views/chatting_deatail_screen.dart';
import 'package:AccuChat/Services/APIs/Chat_service/chat_api_servcie_impl.dart';
import 'package:AccuChat/Services/APIs/local_keys.dart';
import 'package:AccuChat/main.dart';
import 'package:AccuChat/utils/custom_flashbar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import '../../../../routes/app_routes.dart';
import 'package:dio/dio.dart' as multi;

import '../../models/chat_detail_model.dart';


class ChatDetailController extends GetxController {
  Employee? profileData;
  bool? isFromChat = false;
  String? roomId;
  var receiverIdis;
  late TextEditingController chatMessageController;
  late TextEditingController groupNameController;

  FocusNode chatFocus = FocusNode();

  late ScrollController scrollController;
  List<GroupChatElement> chatCatygory = [];

  ChatHistoryData? replyToMessage;

  List<ChatHistoryData>? chatHistory = [];
  ChatHistoryResModel chatDetailResModel = ChatHistoryResModel();
  var isGroup;
  var isCollectiond;

  bool showPostShimmer = false;
  bool isLoading = false;
  int currentPage = 1;
  int perPage = 20;

  File? attachedFile;

  String? senderId= '';
  int? useridis;
  var usernameis;
  var createdBy;

  Map<String, dynamic> jsonData ={
    "id": 1,
    "user_send_by": 101,
    "user_receive_by": 102,
    "msg": "Hey, the client meeting is at 4 PM. Are you joining?",
    "is_read": true,
    "createdAt": "2025-05-03T10:45:00Z",
    "read_on": "2025-05-03T11:00:00Z",
    "reference_id": "msg_ref_001",
    "message": {
      "id": 1,
      "user_send_by": 101,
      "user_receive_by": 102,
      "msg": "Hey, the client meeting is at 4 PM. Are you joining?",
      "is_read": true,
      "createdAt": "2025-05-03T10:45:00Z",
      "read_on": "2025-05-03T11:00:00Z",
      "reference_id": "msg_ref_001"
    },
    "sender_user": {
      "user_id": 101,
      "regd_date": "2025-01-01",
      "user_name": "Amit Sharma",
      "password": null,
      "status": 1,
      "user_role_id": 3,
      "emp_id": 501,
      "can_view_all": 1,
      "can_edit_all": 1,
      "can_add_all": 1,
      "user_abbr": "AS",
      "access_email_check_box": true,
      "can_view_client_contact": true,
      "is_group": 0,
      "is_collection": false,
      "created_on": "2025-01-01T08:00:00Z",
      "socket_id": "socket_101"
    },
    "receiver_user": {
      "user_id": 102,
      "regd_date": "2025-01-05",
      "user_name": "Priya Mehta",
      "password": null,
      "status": 1,
      "user_role_id": 2,
      "emp_id": 502,
      "can_view_all": 1,
      "can_edit_all": 0,
      "can_add_all": 1,
      "user_abbr": "PM",
      "access_email_check_box": false,
      "can_view_client_contact": true,
      "is_group": 0,
      "is_collection": false,
      "created_on": "2025-01-05T09:30:00Z",
      "socket_id": "socket_102"
    }
  };

  // ChatHistoryData? chatDetailsData;

  initData(){
    chatHistory = List.generate(10, (index) {
      final sender = SenderData(
        userId: index % 2 == 0 ? 1 : 2,
        userName: index % 2 == 0 ? 'Alice' : 'Bob',
        empId: index % 2 == 0 ? 'EMP001' : 'EMP002',
        userAbbr: index % 2 == 0 ? 'A' : 'B',
        isGroup: false,
        isCollection: false,
        status: 'active',
        userRoleId: 101,
        regdDate: '2024-01-01',
        password: '****',
        accessEmailCheckBox: true,
        canViewClientContact: true,
        createdOn: '2024-01-01',
        socketId: 'socket_${index % 2 == 0 ? 'alice' : 'bob'}',
        canViewAll: true,
        canEditAll: true,
        canAddAll: true,
      );

      final receiver = SenderData(
        userId: index % 2 == 0 ? 2 : 1,
        userName: index % 2 == 0 ? 'Bob' : 'Alice',
        empId: index % 2 == 0 ? 'EMP002' : 'EMP001',
        userAbbr: index % 2 == 0 ? 'B' : 'A',
        isGroup: false,
        isCollection: false,
        status: 'active',
        userRoleId: 102,
        regdDate: '2024-01-01',
        password: '****',
        accessEmailCheckBox: true,
        canViewClientContact: true,
        createdOn: '2024-01-01',
        socketId: 'socket_${index % 2 == 0 ? 'bob' : 'alice'}',
        canViewAll: true,
        canEditAll: true,
        canAddAll: true,
      );

      return ChatHistoryData(
        id: index + 1,
        userSendBy: sender.userId,
        userReceiveBy: receiver.userId,
        msg: 'This is message number ${index + 1}',
        isRead: index % 2 == 0,
        createdAt: DateTime.now().subtract(Duration(minutes: index * 3)).toIso8601String(),
        readOn: index % 2 == 0
            ? DateTime.now().subtract(Duration(minutes: index * 2)).toIso8601String()
            : null,
        referenceId: 'REF${1000 + index}',
        message: LastMessage(
          id: 1000 + index,
          msg: 'This is message number ${index + 1}',
          createdAt: DateTime.now().subtract(Duration(minutes: index * 3)).toIso8601String(),
          userSendBy: sender.userId,
          userReceiveBy: receiver.userId,
          isRead: index % 2 == 0,
          readOn: index % 2 == 0
              ? DateTime.now().subtract(Duration(minutes: index * 2)).toIso8601String()
              : null,
          referenceId: 'REF${1000 + index}',
        ),
        senderUser: sender,
        receiverUser: receiver,
      );
    });
    chatCatygory= (chatHistory??[]).map((item) {
      DateTime? datais;
      if(item.createdAt!=null){
        datais = DateTime.parse(item.createdAt??'');
      }
      return GroupChatElement(datais??DateTime.now(), item);
    }).toList();
  }


  @override
  void onInit() {
    initData();
    scrollController = ScrollController();


    profileData = Get.arguments?[RoutesArgument.employeeProfile];
    isFromChat = Get.arguments?[RoutesArgument.isFromChatKey];
    roomId = Get.arguments?[RoutesArgument.roomIdKey];
    // receiverIdis = Get.arguments?[RoutesArgument.receiverKey];
    // if(Get.arguments!=null) {
      // senderId = Get.arguments?[RoutesArgument.senderKey];
      receiverIdis = Get.arguments?[RoutesArgument.receiverKey];
      profileData = Get.arguments?[RoutesArgument.employeeProfile];
    useridis = Get.arguments?[RoutesArgument.userIdKey];
    usernameis = Get.arguments?[RoutesArgument.userKey];
    createdBy = Get.arguments?[RoutesArgument.createdByKey];
    // }
    isGroup =Get.arguments?[RoutesArgument.groupKey];
    isCollectiond =Get.arguments?[RoutesArgument.collectionKeyKey];
    chatMessageController = TextEditingController();
    groupNameController = TextEditingController(text: usernameis);

    if(isConnected){
      // chatHistoryApiCall();
    }

    if(!isConnected){
      // getOfflineHistory();
    }
    super.onInit();
  }


  getOfflineHistory()async{

      chatHistory = await getChatHistory();
      chatCatygory= (chatHistory??[]).map((item) {
        DateTime? datais;
        if(item.createdAt!=null){
          datais = DateTime.parse(item.createdAt??'');
        }
        return GroupChatElement(datais??DateTime.now(), item);
      }).toList();
      update();
  }

  // Set the reply message
  void setReplyMessage(ChatHistoryData? message) {
    replyToMessage = message;
    update();
  }

  // Clear the reply message
  void clearReplyMessage() {
    replyToMessage = null;
    update();
  }

  var totalGroupMember;


  chatHistoryApiCall(){
      showPostShimmer = true;
      var reqData = multi.FormData.fromMap({
        // "auth_key": ApiEnd.authKEy,
        // "user_id": storage.read(userId),
        "sender_id": storage.read(userId),
        "receiver_id": receiverIdis??'',
        "is_group":  isGroup.toString()=="1"?"1":isCollectiond.toString()=="1"? "0":"2",
      });
      Get.find<ChatApiServiceImpl>().getUserChatHistoryApi(dataBody: reqData).then((value) {
        customLoader.hide();
        showPostShimmer = false;
        chatDetailResModel = value;
        chatHistory = chatDetailResModel.body??[];
        saveChatHistory(chatHistory??[]);
        chatCatygory= (chatHistory??[]).map((item){
          DateTime? datais;
          if(item.createdAt!=null){
            datais = DateTime.parse(item.createdAt??'');
          }
          return GroupChatElement(datais??DateTime.now(), item);
        }).toList();
        update();
      }).onError((error, stackTrace) {
        showPostShimmer = false;
        update();
        getOfflineHistory();
        errorDialog(error.toString());
      }).whenComplete((){
      });

  }

  deleteGroupApiCall(){
    customLoader.show();
      var reqData = multi.FormData.fromMap({
        // "auth_key": ApiEnd.authKEy,
        "user_id": storage.read(userId),
        "id": useridis,
        "is_group": isGroup.toString()=="1"?"1":"0",
      });

      Get.find<ChatApiServiceImpl>().deleteGroupOrMemberApi(dataBody: reqData).then((value) {
        customLoader.hide();
        Get.back();
        Get.back();
        toast("Group deleted permanently");
        update();
      }).onError((error, stackTrace) {
        customLoader.hide();
        update();
        errorDialog(error.toString());
      });

  }


  hitApiToEditGroup(groupId,usesName) {

    customLoader.show();
    var reqData = multi.FormData.fromMap({
      // "auth_key": ApiEnd.authKEy,
      "user_id": storage.read(userId),
      "id":groupId,
      "is_group":isGroup.toString()=="1"?"1":"0",
      "user_name":usesName
    });

    Get.find<ChatApiServiceImpl>()
        .editGroupMembersApi(dataBody: reqData)
        .then((value)  {
      Get.back();
      Get.back();
      // groupNameController.clear();
      customLoader.hide();
        }).onError((error, stackTrace) {
      Get.back();
      customLoader.hide();
      errorDialog(error.toString());
    });
  }





  var selectedChatId;


  Future<List<ChatHistoryData>> getChatHistory() async{
    try {
      if (!Hive.isBoxOpen("chatHistory")) {
        Hive.openBox<ChatHistoryData>('chatHistory');
      }

      final chatHistoryBox = Hive.box<ChatHistoryData>('chatHistory');

      final chatMessages = chatHistoryBox.values
          .where((message) => message.userReceiveBy== useridis)
          .toList();
      return chatMessages;
    } catch (e) {
      debugPrint('Error retrieving chat history: $e');
      return [];
    }
  }


  Future<void> saveChatHistory(List<ChatHistoryData> chatMessages) async {
    try {
      if (!Hive.isBoxOpen("chatHistory")) {
        await Hive.openBox<ChatHistoryData>('chatHistory');
      }

      final chatHistoryBox = Hive.box<ChatHistoryData>('chatHistory');

      // Clear previous messages for this user
      await chatHistoryBox.delete(useridis.toString());
      // chatHistoryBox.clear();


      // Save chat history for this user
      for (var message in chatMessages) {
        await chatHistoryBox.put('${useridis}_${message.createdAt}', message);
      }
    } catch (e) {
      debugPrint('Error saving chat history: $e');
    }
  }







  @override
  void onClose() {
    // if ((isFromChat ?? false) != true)
    //   Get.find<SocketController>().leaveChatEmitter();
    //
    //
    // super.onClose();
  }
}
