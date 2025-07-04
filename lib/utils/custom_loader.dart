// // Project imports:
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:loading_indicator/loading_indicator.dart';
//
// class CustomLoader {
//   static CustomLoader? _loader;
//
//   CustomLoader._createObject();
//
//   factory CustomLoader() {
//     if (_loader != null) {
//       return _loader!;
//     } else {
//       _loader = CustomLoader._createObject();
//       return _loader!;
//     }
//   }
//
//   OverlayState? _overlayState;
//   OverlayEntry? _overlayEntry;
//
//   _buildLoader() {
//     _overlayEntry = OverlayEntry(
//       builder: (context) {
//         return Stack(
//           alignment: Alignment.center,
//           children: <Widget>[
//             Container(
//               child: buildLoader(context),
//               color: Colors.black.withOpacity(.3),
//             )
//           ],
//         );
//       },
//     );
//   }
//
//   show() {
//     _overlayState = Overlay.of(Get.context!);
//     _buildLoader();
//     _overlayState!.insert(_overlayEntry!);
//   }
//
//   hide() {
//     try {
//       if (_overlayEntry != null) {
//         _overlayEntry!.remove();
//         _overlayEntry = null;
//       }
//     } catch (_) {}
//   }
//
//   buildLoader(context,{isTransparent = false}) {
//     return Center(
//       child: Container(
//         height: 50,
//         width: 50,
//         color: isTransparent ? Colors.transparent : Colors.transparent,
//         margin: const EdgeInsets.all(77),
//         child:  LoadingIndicator(
//             indicatorType: Indicator.ballRotateChase,
//             colors: [Theme.of(context).primaryColor,Theme.of(context).splashColor],
//             backgroundColor:Colors.transparent /*Theme.of(context).primaryColor*/,
//             pathBackgroundColor:Colors.transparent
//         ), //CircularProgressIndicator(),
//       ),
//     );
//   }
// }
