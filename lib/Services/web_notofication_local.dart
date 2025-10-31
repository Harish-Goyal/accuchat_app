// import 'dart:html' as html;
//
// void showBrowserNotification(String title, String body, {String? clickUrl}) {
//   if (html.Notification.supported) {
//     html.Notification.requestPermission().then((perm) {
//       if (perm == 'granted') {
//         final n = html.Notification(title, body: body, icon: '/icons/Icon-192.png');
//         n.onClick.listen((_) {
//           if (clickUrl != null) {
//             html.window.open(clickUrl, '_self');
//           }
//         });
//       }
//     });
//   }
// }