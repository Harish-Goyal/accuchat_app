import 'dart:convert';
import 'package:AccuChat/Screens/Chat/screens/auth/models/get_uesr_Res_model.dart';
import 'package:AccuChat/Services/web_notication_stub.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:get/get.dart';

import '../../../routes/app_routes.dart';
import '../Screens/Chat/api/apis.dart';
import '../Screens/Chat/helper/local_notification_channel.dart';
import '../Screens/Chat/models/get_company_res_model.dart';
import '../Screens/Chat/screens/chat_tasks/Presentation/Controllers/chat_home_controller.dart';
import '../Screens/Chat/screens/chat_tasks/Presentation/Controllers/chat_screen_controller.dart';
import '../Screens/Chat/screens/chat_tasks/Presentation/Controllers/task_controller.dart';
import '../Screens/Chat/screens/chat_tasks/Presentation/Controllers/task_home_controller.dart';
import '../Screens/Home/Presentation/Controller/company_service.dart';
import '../Screens/Home/Presentation/Controller/home_controller.dart';
// ====== ONLY for non-web (server-auth on device) ======
import 'package:googleapis_auth/auth_io.dart';
import 'package:googleapis_auth/googleapis_auth.dart';

import '../Screens/Home/Presentation/Controller/socket_controller.dart';
import '../main.dart';
import '../utils/custom_flashbar.dart';
import 'APIs/post/post_api_service_impl.dart';


class NotificationServicess {
  static final NotificationServicess _instance =
  NotificationServicess._internal();

  factory NotificationServicess() => _instance;

  NotificationServicess._internal();

  // ---- Non-web (mobile/desktop) server-auth pieces ----
  static ServiceAccountCredentials? _credentials;
  static AutoRefreshingAuthClient? _client;
  static String? _projectId;

  /// Call once from main() after Firebase.initializeApp(...)
  static Future<void> init({String? webVapidPublicKey}) async {
    // WEB path: NO service-account, just listeners + (optional) token helper
    if (kIsWeb) {
      await _initWebListeners();
      return;
    }

    // ====== MOBILE / DESKTOP path (what you had) ======
    // Loads service-account from assets and prepares HTTP client to send via FCM v1
    final serviceAccountJson =
    await rootBundle.loadString('assets/service-account.json');
    final jsonMap = json.decode(serviceAccountJson);
    _projectId = jsonMap['project_id'];
    _credentials = ServiceAccountCredentials.fromJson(serviceAccountJson);

    // _client = await clientViaServiceAccount(
    //   _credentials!,
    //   ['https://www.googleapis.com/auth/firebase.messaging'],
    // );

    // Foreground notifications while app is open
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final title = message.notification?.title ?? '';
      final body = message.notification?.body ?? '';
      final type = message.data['type'];

      final data = message.data;

      final meId = APIs.me.userId?.toString().trim();
      final senderId = (data['user_id'] ?? '').toString().trim();
      final receiverId = (data['receiver_id'] ?? '').toString().trim();

      print('🔔 FCM received: sender=$senderId, receiver=$receiverId, me=$meId');

      // 1️⃣ Skip if self not logged in properly
      if (meId == null || meId.isEmpty) return;

      // 2️⃣ Skip if missing sender info
      if (senderId.isEmpty) return;

      // 3️⃣ Skip if message is from self OR to self
      if (senderId == meId && senderId == meId) {
        print('🔕 Skipping self-message notification');
        return;
      }

      // ✅ Safe to show notification
      LocalNotificationService.showNotification(
        title: title,
        body: body,
      );
    });

    // When user taps a notification
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {

      String? type;
      type = message.data['messageType'];

      print('🔔 Notification Data onMessageOpenedApp =${message.data}');
      print('🔔 Notification tapped. Type: $type');

      UserDataAPI remoteUser = UserDataAPI();
      final normalized = Map<String, dynamic>.from(message.data);

      if(type=='CHAT_SEND'||type=='TASK_SEND'||type=='SEND_TASK_COMMENT'){
        remoteUser = UserDataAPI.fromJson(normalized);
      }

      handleTapByType(type, remoteUser.userCompany?.companyId, user: remoteUser);
    });
  }

  // ---------------- WEB LISTENERS ONLY ----------------
  static Future<void> _initWebListeners() async {
    // Foreground: tab open
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final title = message.notification?.title ?? 'New message';
      final body = message.notification?.body ?? '';
      final click = message.data['click_action'];
      // Show your in-app banner/snackbar (system toast is handled by SW only in bg)
      // showBrowserNotification(title, body, clickUrl: click);
      debugPrint('📩 (WEB) Foreground: $title — $body');
    });
    // User clicked a notification (navigates via data.type)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
      String? type;
      type = message.data['messageType'];
      UserDataAPI remoteUser = UserDataAPI();
      final normalized = Map<String, dynamic>.from(message.data);
      if(type=='CHAT_SEND'||type=='TASK_SEND'||type=='SEND_TASK_COMMENT'){
        remoteUser = UserDataAPI.fromJson(normalized);
      }
      handleTapByType(type,  remoteUser.userCompany?.companyId, user: remoteUser);
    });
  }

  // Centralized navigation handler for both web/mobile
  static Future<void> handleTapByType(String? type, dynamic companyId,
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
        return;
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

  static CompanyData? companyResponse = CompanyData();

  static getCompanyByIdApi({int? companyId, required UserDataAPI user,type}) async {
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
    // controller.getCompany();
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
/*

  // ================== SENDING (Server -> Device) ==================
  // ❗ DO NOT call these from web; call from server or non-web clients only.

  static Future<void> _sendNotification({
    required String targetToken,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    if (kIsWeb) {
      debugPrint('❌ Not allowed: sending from web client. Use your server.');
      return;
    }
    if (_client == null || _projectId == null) {
      await init();
    }

    final url = Uri.parse(
        'https://fcm.googleapis.com/v1/projects/$_projectId/messages:send');
    final message = {
      "message": {
        "token": targetToken,
        "notification": {"title": title, "body": body},
        "data": data ?? {"click_action": "FLUTTER_NOTIFICATION_CLICK"}
      }
    };

    final response = await _client!.post(url, body: jsonEncode(message));
    if (response.statusCode == 200) {
      debugPrint('✅ Notification sent!');
    } else {
      debugPrint('❌ Failed to send notification: ${response.body}');
    }
  }

  // Public helpers (same API you used before)

  static Future<void> sendInvitationNotification({
    required String targetToken,
    required String inviterName,
    required String companyName,
  }) async {
    await _sendNotification(
      targetToken: targetToken,
      title: "Invitation!",
      body: "$companyName invited you.",
      data: {"type": "invite", "company": companyName},
    );
  }

  static Future<void> sendAcceptInvitationNotification({
    required String targetToken,
    required String inviterName,
    required String number,
    required String companyName,
  }) async {
    await _sendNotification(
      targetToken: targetToken,
      title: "Invitation Accepted",
      body:
          "${inviterName == '' ? number : inviterName} accepted your Invitation for $companyName.",
      data: {"type": "acceptinvite", "company": companyName},
    );
  }

  static Future<void> sendMessageNotification({
    required String targetToken,
    required String senderName,
    CompanyData? company,
    required String message,
  }) async {
    await _sendNotification(
      targetToken: targetToken,
      title: "💬 New Message from $senderName",
      body: message,
      data: {"type": "chat", "companyId": company?.companyId?.toString() ?? ''},
    );
  }

  static Future<void> sendTaskNotification({
    required String targetToken,
    required String assignerName,
    required String taskSummary,
    CompanyData? company,
  }) async {
    await _sendNotification(
      targetToken: targetToken,
      title: "📝 Task Assigned by $assignerName",
      body: taskSummary,
      data: {"type": "task", "companyId": company?.companyId?.toString() ?? ''},
    );
  }
}
*/
