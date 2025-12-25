import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';

import '../../../Services/APIs/post/post_api_service_impl.dart';
import '../../../Services/storage_service.dart';
import '../../../main.dart';
import '../../../routes/app_routes.dart';
import '../../../utils/custom_flashbar.dart';
import '../../Home/Presentation/Controller/company_service.dart';
import '../../Home/Presentation/Controller/home_controller.dart';
import '../../Home/Presentation/Controller/socket_controller.dart';
import '../api/apis.dart';
import '../models/get_company_res_model.dart';
import '../models/invite_model.dart';
import '../screens/auth/Presentation/Views/accept_invite_screen.dart';
import '../screens/auth/models/get_uesr_Res_model.dart';
import '../screens/chat_tasks/Presentation/Controllers/chat_home_controller.dart';
import '../screens/chat_tasks/Presentation/Controllers/chat_screen_controller.dart';
import '../screens/chat_tasks/Presentation/Controllers/task_controller.dart';
import '../screens/chat_tasks/Presentation/Controllers/task_home_controller.dart';

class LocalNotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize(
      {required Function(String? payload) onSelect}) async {
    const AndroidInitializationSettings androidInit =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initSettings =
        InitializationSettings(android: androidInit);

    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        final payload = response.payload;
        onSelect(payload); // payload passed here
      },
    );

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('📬 Foreground message: ${message.notification?.title}');

      final title = message.notification?.title ?? '';
      final body = message.notification?.body ?? '';
      final data = message.data;

      final meId = APIs.me.userId?.toString().trim();
      final senderId = (data['sender_id'] ?? '').toString().trim();
      final receiverId = (data['receiver_id'] ?? '').toString().trim();

      print(
          '🔔 FCM received: sender=$senderId, receiver=$receiverId, me=$meId');
      print('🔔 Notification Data =${data}');

      // 1️⃣ Skip if self not logged in properly
      if (meId == null || meId.isEmpty) return;

      // 2️⃣ Skip if missing sender info
      if (senderId.isEmpty) return;

      // 3️⃣ Skip if message is from self OR to self
      if (senderId == meId || receiverId == meId && senderId == meId) {
        print('🔕 Skipping self-message notification');
        return;
      }

      // ✅ Safe to show notification
      final senderName = (data['sender_name'] ?? '').toString().trim();
      final messageText =
          (data['title'] ?? '').toString(); // your payload uses "title" as text
      final companyId = data['company_id'];
      final channelId = data['channel_id'] ?? '';

      LocalNotificationService.showNotification(
        title: senderName.isNotEmpty ? senderName : title,
        body: messageText,
        channelId: channelId,
        // put useful navigation data in payload (to open chat on tap)
        payload: jsonEncode({
          'type': data['type'],
          'sender_id': senderId,
          'receiver_id': receiverId,
          'company_id': companyId,
        }),
      );
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
      final data = message.data;
      String? type;
      type = data['messageType'];
      print('🔔 Notification Data onMessageOpenedApp =${message.data}');
      print('🔔 Notification tapped. Type: $type');

      UserDataAPI remoteUser = UserDataAPI();
      final normalized = Map<String, dynamic>.from(message.data);

      if(type=='CHAT_SEND'||type=='TASK_SEND'||type=='SEND_TASK_COMMENT'){
        remoteUser = UserDataAPI.fromJson(normalized);
      }

      _handleTapByType(type, remoteUser.userCompany?.companyId, user: remoteUser);
    });
  }

  static Future<void> _handleTapByType(String? type, dynamic companyId,
      {required UserDataAPI user}) async {
    if (type == 'MEMBER_INVITE_ONLINE') {
      Get.toNamed(AppRoutes.invitations_r);
      return;
    } else if (type == 'TASK_SEND') {
      if (companyId == APIs.me.userCompany?.companyId) {
        _goToTask(user);
        return;
      } else {
        getCompanyByIdApi(companyId:companyId,user: user,type: 'TASK_SEND');

      }
    } else if (type == 'CHAT_SEND') {
      if (companyId == APIs.me.userCompany?.companyId) {
        _goToChat(user);
        return;
      } else {
        getCompanyByIdApi(companyId:companyId,user: user,type: 'CHAT_SEND');
        return;
      }
    } else if (type == 'SEND_TASK_COMMENT') {
      if (companyId != APIs.me.userCompany?.userCompanyId) {
        _goToTask(user);
        return;
      } else {
        getCompanyByIdApi(companyId:companyId,user: user,type: 'SEND_TASK_COMMENT');
        return;
      }
    } else {
      Get.toNamed(AppRoutes.home);
    }
  }

  static Future<void> createAllChannels() async {
    const channels = [
      AndroidNotificationChannel(
        'chat_high', // MUST match manifest
        'Chat Notifications',
        description: 'High priority chat messages',
        importance: Importance.high,
      ),
      AndroidNotificationChannel(
        'any_channel',
        'Notification',
        description: 'You  got a Notifications from AccuChat',
        importance: Importance.high,
      ),
    ];

    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    for (final channel in channels) {
      await androidPlugin?.createNotificationChannel(channel);
    }
  }

  static Future<void> showNotification({
    required String title,
    required String body,
    String? payload, // <— allow custom payload
    String channelId = 'chat_high',
    String channelName = 'AccuChat Messages',
  }) async {
    final androidDetails = AndroidNotificationDetails(
      channelId,
      channelName,
      importance: Importance.high,
      priority: Priority.high,
      styleInformation: BigTextStyleInformation(body),
      category: AndroidNotificationCategory.message,
      ticker: 'msg',
    );
    await _plugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      NotificationDetails(android: androidDetails),
      payload: payload ?? '',
    );
  }

  static CompanyData? companyResponse = CompanyData();

  static getCompanyByIdApi({int? companyId, required UserDataAPI user,type}) async {
    customLoader.show();
    Get.find<PostApiServiceImpl>()
        .getCompanyByIdApiCall(companyId)
        .then((value) async {
      customLoader.hide();
      companyResponse = value.data;

    await _selectCompany(companyResponse,type);

      if (type=='TASK_SEND') {
        _goToTask(user);
        Get.find<TaskHomeController>().getCompany();
      } else {
        _goToChat(user);
        Get.find<ChatHomeController>().getCompany();
      }


      customLoader.hide();
    }).onError((error, stackTrace) {
      customLoader.hide();
      errorDialog(error.toString());
    }).whenComplete(() {});
  }

  static Future<void> _selectCompany(companyResponse,type) async {
    if (companyResponse == null) {
      throw Exception("Company not found");
    }
    if(Get.isRegistered<CompanyService>()) {
      final svc = CompanyService.to;
      await svc.select(companyResponse);
    }else{
      await Get.putAsync<CompanyService>(
            () async => await CompanyService().init(),
        // permanent: true,
      );
      final svc = CompanyService.to;
      await svc.select(companyResponse);
    }

    if (type=='TASK_SEND') {
      Get.find<TaskHomeController>().getCompany();
      Get.find<TaskHomeController>().update();
    } else {
      Get.find<ChatHomeController>().getCompany();
      Get.find<ChatHomeController>().update();
    }
    await APIs.refreshMe(
        companyId:
        companyResponse?.companyId ??
            0);
    Get.find<SocketController>()
        .connectUserEmitter(
        companyResponse.companyId);
  }

  static _goToChat(UserDataAPI user) {
    if (!Get.isRegistered<DashboardController>()) {
      Get.put(DashboardController());
    }
    Get.find<DashboardController>().updateIndex(0);
    Get.find<DashboardController>().getCompany();
    isTaskMode = false;
    Get.find<DashboardController>().update();
    if (kIsWeb) {
      if (!Get.isRegistered<ChatHomeController>()) {
        Get.put(ChatHomeController());
      }

      if (!Get.isRegistered<ChatScreenController>()) {
        Get.put(ChatScreenController(user: user));
      }
      final homec = Get.find<ChatHomeController>();
      final chatc = Get.find<ChatScreenController>();
      // homec.page = 1;
      // homec.hitAPIToGetRecentChats();
      chatc.replyToMessage = null;
      homec.selectedChat.value = user;
      chatc.user = homec.selectedChat.value;
      chatc.showPostShimmer = true;
      chatc.openConversation(user);
      chatc.markAllVisibleAsReadOnOpen(
          APIs.me?.userCompany?.userCompanyId,
          chatc.user?.userCompany?.userCompanyId,
          chatc.user?.userCompany?.isGroup == 1 ? 1 : 0);
      // homec.selectedChat.refresh();
      chatc.update();
    } else {
      Get.toNamed(
        AppRoutes.chats_li_r,
        arguments: {'user': user},
      );
    }
    customLoader.hide();
  }

  static _goToTask(UserDataAPI user) {
    if (!Get.isRegistered<DashboardController>()) {
      Get.put(DashboardController());
    }
    Get.find<DashboardController>().updateIndex(1);
    Get.find<DashboardController>().getCompany();
    isTaskMode = true;
    Get.find<DashboardController>().update();
    if (kIsWeb) {
      if (!Get.isRegistered<TaskHomeController>()) {
        Get.put(TaskHomeController());
      }

      if (!Get.isRegistered<TaskController>()) {
        Get.put(TaskController(user: user));
      }
      final homec = Get.find<TaskHomeController>();
      final taskC = Get.find<TaskController>();
      homec.selectedChat.value = user;
      taskC.user = homec.selectedChat.value;
      taskC.replyToMessage = null;
      taskC.showPostShimmer = true;
      taskC.openConversation(homec.selectedChat.value);
      homec.selectedChat.refresh();
      taskC.update();
    } else {
      Get.toNamed(AppRoutes.tasks_li_r, arguments: {'user': user});
    }
    customLoader.hide();
  }
}
