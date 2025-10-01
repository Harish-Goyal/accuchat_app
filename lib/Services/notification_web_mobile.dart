import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:get/get.dart';

import '../../../routes/app_routes.dart';
import '../Screens/Chat/api/apis.dart';
import '../Screens/Chat/helper/local_notification_channel.dart';
import '../Screens/Chat/models/get_company_res_model.dart';
import '../Screens/Home/Presentation/Controller/home_controller.dart';
// ====== ONLY for non-web (server-auth on device) ======
import 'package:googleapis_auth/auth_io.dart';
import 'package:googleapis_auth/googleapis_auth.dart';


class NotificationServicess {
  static final NotificationServicess _instance = NotificationServicess._internal();
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
      // Optional: if you want to ensure token now (you already do in _initWebPush)
      // if (webVapidPublicKey != null) {
      //   final token = await FirebaseMessaging.instance.getToken(vapidKey: webVapidPublicKey);
      //   debugPrint('✅ Web FCM Token (NotificationService): $token');
      // }
      return;
    }

    // ====== MOBILE / DESKTOP path (what you had) ======
    // Loads service-account from assets and prepares HTTP client to send via FCM v1
    final serviceAccountJson = await rootBundle.loadString('assets/service-account.json');
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
      final body  = message.notification?.body ?? '';
      LocalNotificationService.showInviteNotification(title: title, body: body);
    });

    // When user taps a notification
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
      _handleTapByType(message.data['type'], message.data['companyId']);
    });
  }

  // ---------------- WEB LISTENERS ONLY ----------------
  static Future<void> _initWebListeners() async {
    // Foreground: tab open
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final title = message.notification?.title ?? 'New message';
      final body  = message.notification?.body ?? '';
      // Show your in-app banner/snackbar (system toast is handled by SW only in bg)
      LocalNotificationService.showInviteNotification(title: title, body: body);
      debugPrint('📩 (WEB) Foreground: $title — $body');
    });

    // User clicked a notification (navigates via data.type)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
      _handleTapByType(message.data['type'], message.data['companyId']);
    });
  }

  // Centralized navigation handler for both web/mobile
  static Future<void> _handleTapByType(String? type, dynamic companyId) async {
    if (type == 'invite') {
      Get.toNamed(AppRoutes.home);
      return;
    }
    if (type == 'task') {
      Get.find<DashboardController>().updateIndex(1);
      if (companyId != APIs.me.userCompany?.userCompanyId) {
        await APIs.getSelfInfo();
      }
      return;
    }
    if (type == 'chat') {
      Get.find<DashboardController>().updateIndex(0);
      if (companyId != APIs.me.userCompany?.userCompanyId) {
        await APIs.getSelfInfo();
      }
      return;
    }
  }

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

    final url = Uri.parse('https://fcm.googleapis.com/v1/projects/$_projectId/messages:send');
    final message = {
      "message": {
        "token": targetToken,
        "notification": { "title": title, "body": body },
        "data": data ?? { "click_action": "FLUTTER_NOTIFICATION_CLICK" }
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
      data: { "type": "invite", "company": companyName },
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
      body: "${inviterName==''?number:inviterName} accepted your Invitation for $companyName.",
      data: { "type": "acceptinvite", "company": companyName },
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
      data: { "type": "chat", "companyId": company?.companyId?.toString() ?? '' },
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
      data: { "type": "task", "companyId": company?.companyId?.toString() ?? '' },
    );
  }
}
