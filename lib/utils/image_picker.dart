// import 'dart:io';
// import 'package:file_picker/file_picker.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:image_picker/image_picker.dart';
//
// import '../navigation/navigation.dart';
// import 'google_font_text_style.dart';
// import 'helper_widget.dart';
// class ImgPicker {
//   static chooseImage(context) {
//     var path;
//     cameraImage() async {
//       final file = await ImagePicker()
//           .pickImage(source: ImageSource.camera, imageQuality: 100);
//       if (file != null) {
//         path = File(file.path);
//         Get.back(result: path);
//       }
//     }
//
//     galleryImages() async {
//       final file = await ImagePicker()
//           .pickImage(source: ImageSource.gallery, imageQuality: 100);
//       if (file != null) {
//         path = File(file.path);
//         Get.back(result: path);
//       }
//     }
//
//     document() async {
//       FilePickerResult? result = await FilePicker.platform.pickFiles(
//           type: FileType.custom,
//           allowedExtensions: ['pdf', 'doc'],
//           allowMultiple: false);
//       if (result != null) {
//         List<File> files = result.paths.map((path) => File(path!)).toList();
//         path = File(files[0].path);
//         Get.back(result: files[0]);
//       }
//     }
//
//     return showDialog(
//         context: context,
//         builder: (_) => AlertDialog(
//               titlePadding: const EdgeInsets.all(0),
//               title: Container(
//                 width: MediaQuery.of(context).size.width,
//                 color: Colors.white,
//                 padding:
//                     const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
//                 child: const Text("Choose Document",
//                     style: TextStyle(color: Colors.black)),
//               ),
//               content: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   ListTile(
//                     title: Text(
//                       'Gallery',
//                       style: BalooStyles.balooboldTextStyle(),
//                     ),
//                     leading: const Icon(
//                       Icons.image_outlined,
//                       color: Colors.deepOrange,
//                     ),
//                     onTap: () async {
//                       await galleryImages();
//                     },
//                     contentPadding: const EdgeInsets.all(0),
//                     isThreeLine: false,
//                   ),
//                   ListTile(
//                     title:
//                         Text('Camera', style: BalooStyles.balooboldTextStyle()),
//                     leading: const Icon(
//                       Icons.camera,
//                       color: Colors.deepOrange,
//                     ),
//                     onTap: () async {
//                       await cameraImage();
//                     },
//                     contentPadding: const EdgeInsets.all(0),
//                     isThreeLine: false,
//                   ),
//                   ListTile(
//                     title: Text('Document',
//                         style: BalooStyles.balooboldTextStyle()),
//                     leading: const Icon(
//                       Icons.picture_as_pdf_outlined,
//                       color: Colors.deepOrange,
//                     ),
//                     onTap: () async {
//                       await document();
//                     },
//                     contentPadding: const EdgeInsets.all(0),
//                     isThreeLine: false,
//                   ),
//                 ],
//               ),
//             ));
//   }
// }
//
// class ImgPickerBottom {
//   // static DashboardController controller = Get.put<DashboardController>(DashboardController())
//   static chooseImage(context) {
//     File filepath;
//     cameraImage() async {
//       final file = await ImagePicker()
//           .pickImage(source: ImageSource.camera, imageQuality: 100);
//       if (file != null) {
//         filepath = File(file.path);
//       }
//     }
//
//     galleryImages() async {
//       final file = await ImagePicker()
//           .pickImage(source: ImageSource.gallery, imageQuality: 100);
//       if (file != null) {
//         filepath = File(file.path);
//       }
//     }
//
//     document() async {
//       FilePickerResult? result = await FilePicker.platform.pickFiles(
//           type: FileType.custom,
//           allowedExtensions: ['pdf', 'doc'],
//           allowMultiple: false);
//       if (result != null) {
//         List<File> files = result.paths.map((path) => File(path!)).toList();
//         filepath = File(files[0].path);
//         // Get.toNamed(AppRoutes.uploadDocumenth, arguments: {"path": files[0]});
//       }
//     }
//
//     return Get.bottomSheet(
//       Container(
//         width: MediaQuery.of(context).size.width,
//         color: Colors.white,
//         padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             vGap(20),
//             Text("Choose Document",
//                 style: BalooStyles.balooboldTextStyle(size: 18)),
//             ListTile(
//               title: Text(
//                 'Gallery',
//                 style: BalooStyles.balooboldTextStyle(),
//               ),
//               leading: const Icon(
//                 Icons.image_outlined,
//                 color: Colors.deepOrange,
//               ),
//               onTap: () async {
//                 await galleryImages();
//               },
//               contentPadding: const EdgeInsets.all(0),
//               isThreeLine: false,
//             ),
//             ListTile(
//               title: Text('Camera', style: BalooStyles.balooboldTextStyle()),
//               leading: const Icon(
//                 Icons.camera,
//                 color: Colors.deepOrange,
//               ),
//               onTap: () async {
//                 await cameraImage();
//               },
//               contentPadding: const EdgeInsets.all(0),
//               isThreeLine: false,
//             ),
//             ListTile(
//               title: Text('Document', style: BalooStyles.balooboldTextStyle()),
//               leading: const Icon(
//                 Icons.picture_as_pdf_outlined,
//                 color: Colors.deepOrange,
//               ),
//               onTap: () async {
//                 await document();
//               },
//               contentPadding: const EdgeInsets.all(0),
//               isThreeLine: false,
//             ),
//           ],
//         ),
//       ),
//       isScrollControlled: true,
//     );
//   }
// }
