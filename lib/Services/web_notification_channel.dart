// // lib/notifications/web_notifications.dart
// // Only call on web
// import 'dart:js_util' as js;
// import 'Services/web_notication_stub.dart'
// if (dart.library.html) 'Services/web_notofication_local.dart';
// Future<void> showWebNotification({
//   required String title,
//   required String body,
//   String tag = 'default',
//   Map<String, dynamic>? data,
// }) async {
//   final perm = await html.Notification.requestPermission();
//   if (perm != 'granted') return;
//
//   final reg = await html.window.navigator.serviceWorker?.ready;
//   if (reg != null) {
//     js.callMethod(reg, 'showNotification', [
//       title,
//       js.jsify({
//         'body': body,
//         'tag': tag,
//         'icon': '/icons/Icon-192.png',
//         'badge': '/icons/Icon-192.png',
//         'requireInteraction': true, // keep it visible
//         'data': data ?? {},
//         'renotify': true,
//       }),
//     ]);
//     return;
//   }
//
//   // Fallback if SW not ready
//   html.Notification(title, body: body);
// }