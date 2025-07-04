// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
//
// import '../constants/text_style.dart';
// import '../constants/themes.dart';
//
// class ThankYouDialog extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return AlertDialog(
//       title: Center(
//         child: Text(
//           'Thank You!',
//           style: BalooStyles.baloonormalTextStyle(size: 22),
//         ),
//       ),
//       content: Column(
//         mainAxisSize: MainAxisSize.min,
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           // Image.asset(Localfiles.thumpUp,height: 70,),
//
//           SizedBox(height: 10),
//           Text(
//             'Thank you for sharing your feedback!',
//             style: BalooStyles.baloomediumTextStyle(),
//             textAlign: TextAlign.center,
//           ),
//
//           SizedBox(height: 10),
//           Text(
//             'Your input is invaluable to us and helps us improve. We look forward to serving you again in the future. @checkinmyhotel.com',
//             style:  BalooStyles.baloonormalTextStyle(),
//             textAlign: TextAlign.center,
//           ),
//
//
//         ],
//       ),
//       actions: [
//         TextButton(
//           onPressed: () {
//             Get.back();// Close the dialog
//           },
//           child: Text(
//             'OK',
//             style:  BalooStyles.baloonormalTextStyle(size: 18,color: AppTheme.primaryColor),
//           ),
//         ),
//       ],
//     );
//   }
// }
//
// // Usage in a widget
// void showThankYouDialog(BuildContext context) {
//   showDialog(
//     context: context,
//     builder: (BuildContext context) {
//       return ThankYouDialog();
//     },
//   );
// }
