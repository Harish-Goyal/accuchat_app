import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';

import '../../../routes/app_routes.dart';
import '../../Home/Presentation/Controller/home_controller.dart';
import '../api/apis.dart';
import '../models/invite_model.dart';
import '../screens/auth/Presentation/Views/accept_invite_screen.dart';

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
      print(
          '🔔 Notification Data =${data}');

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
      final type = data['messageType'];
      print('🔔 Notification Data onMessageOpenedApp =${message.data}');
      print('🔔 Notification tapped. Type: $type');
      if (type == 'CHAT_SEND') {

        Get.toNamed(AppRoutes.accept_invite);
      } else if (type == 'task') {
        Get.find<DashboardController>().updateIndex(1);
      } else if (type == 'chat') {
        Get.find<DashboardController>().updateIndex(0);
      }
    });
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

}
