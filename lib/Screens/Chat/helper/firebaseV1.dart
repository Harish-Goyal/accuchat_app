import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;
import 'package:googleapis_auth/googleapis_auth.dart';

Future<void> sendFcmPushV1({
  required String title,
  required String body,
  required String targetToken,
}) async {
  final serviceAccountJson = await rootBundle.loadString('assets/service-account.json');
  final accountCredentials = ServiceAccountCredentials.fromJson(serviceAccountJson);

  final scopes = ['https://www.googleapis.com/auth/firebase.messaging'];

  final client = await clientViaServiceAccount(accountCredentials, scopes);
  final Map<String, dynamic> jsonMap = json.decode(serviceAccountJson);
  final projectId = jsonMap['project_id'];


  final url = Uri.parse('https://fcm.googleapis.com/v1/projects/$projectId/messages:send');

  final message = {
    "message": {
      "token": targetToken,
      "notification": {
        "title": title,
        "body": body,
      },
      "data": {
        "click_action": "FLUTTER_NOTIFICATION_CLICK"
      }
    }
  };

  final response = await client.post(url, body: jsonEncode(message));

  if (response.statusCode == 200) {
    debugPrint('✅ FCM v1 Notification sent!');
  } else {
    debugPrint('❌ Failed to send FCM v1 notification: ${response.body}');
  }

  client.close();
}
