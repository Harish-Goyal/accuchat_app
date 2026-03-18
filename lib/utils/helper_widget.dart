import 'package:AccuChat/Constants/colors.dart';
import 'package:AccuChat/Services/APIs/api_ends.dart';
import 'package:AccuChat/utils/text_style.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:media_scanner/media_scanner.dart';
import 'package:open_filex/open_filex.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher_string.dart';
import '../Constants/assets.dart';
import '../Constants/themes.dart';
import '../Screens/Chat/api/app_budge_controller.dart';
import '../Screens/Chat/models/all_media_res_model.dart';
import '../Screens/Chat/models/message.dart';
import 'package:dio/dio.dart';
import 'package:permission_handler/permission_handler.dart';
import '../Screens/Chat/screens/auth/Presentation/Controllers/accept_invite_controller.dart';
import '../Screens/Chat/screens/auth/Presentation/Controllers/create_company_controller.dart';
import '../Screens/Chat/screens/auth/Presentation/Views/accept_invite_screen.dart';
import '../Screens/Chat/screens/auth/Presentation/Views/create_company_screen.dart';
import '../main.dart';
import '../routes/app_routes.dart';
import 'circleContainer.dart';
import 'custom_container.dart';
import 'custom_flashbar.dart';
import 'dart:io';
import 'package:path/path.dart' as p;
import 'dart:async';
import 'dart:math' as math;
import 'package:path_provider/path_provider.dart';

import 'package:AccuChat/utils/web_download/download_factory.dart';

import 'hover_glass_effect_widget.dart';
import 'networl_shimmer_image.dart';





Future<bool> requestStoragePermission() async {
  if (Platform.isAndroid) {
    final sdkInt = (await DeviceInfoPlugin().androidInfo).version.sdkInt;

    if (sdkInt >= 33) {
      // Android 13+
      var photosPermission = await Permission.photos.status;
      if (!photosPermission.isGranted) {
        photosPermission = await Permission.photos.request();
      }
      return photosPermission.isGranted;
    } else {
      // Android 12 and below
      var storagePermission = await Permission.storage.status;
      if (!storagePermission.isGranted) {
        storagePermission = await Permission.storage.request();
      }
      return storagePermission.isGranted;
    }
  } else {
    return true;
  }
}

Future<void> showCompanyErrorDialog() async {
  await Get.dialog(
    Center(
      child: Container(
        width: 300,
        height: 300,
        child: AlertDialog(
          backgroundColor: Colors.white,
          title: const Text('Access Denied'),
          content: const Text(
              'You are not a part of this company. Please contact admin for more details.'),
          actions: [
            TextButton(
              onPressed: () {
                Get.back();
                Get.offAllNamed(AppRoutes.landing_r);
              },
              child: const Text('OK'),
            ),
          ],
        ),
      ),
    ),
    barrierDismissible: false,
  );
}

//
// Widget companyCard(){
//   return Align(
//     alignment: Alignment.centerLeft,
//     child: ConstrainedBox(
//       constraints: const BoxConstraints(
//         maxWidth: kIsWeb ? 500 : double.infinity,
//       ),
//       child: Stack(
//         clipBehavior: Clip.none,
//         children: [
//           // 🔥 MAIN CARD
//           InkWell(
//             borderRadius: BorderRadius.circular(14),
//             onTap: () => _onTapCompany(companyData),
//             child: Container(
//               margin: const EdgeInsets.only(bottom: 12),
//               padding: const EdgeInsets.all(12),
//               decoration: BoxDecoration(
//                 color: companyData.companyId ==
//                     controller.selCompany?.companyId
//                     ? Colors.white
//                     : Colors.grey.shade100,
//                 borderRadius: BorderRadius.circular(14),
//                 border: Border.all(
//                   color: companyData.companyId ==
//                       controller.selCompany?.companyId
//                       ? appColorPerple.withOpacity(.2)
//                       : Colors.grey.shade200,
//                 ),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black.withOpacity(.04),
//                     blurRadius: 6,
//                     offset: const Offset(0, 3),
//                   ),
//                 ],
//               ),
//
//               // 🔥 CONTENT
//               child: Row(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // 🟣 LOGO / AVATAR
//                   Container(
//                     decoration: BoxDecoration(
//                       shape: BoxShape.circle,
//                       border: Border.all(color: greyText),
//                     ),
//                     child: companyData.logo != null
//                         ? CustomCacheNetworkImage(
//                       "${ApiEnd.baseUrlMedia}${companyData.logo ?? ''}",
//                       radiusAll: 100,
//                       height: 45,
//                       width: 45,
//                       borderColor: appColorYellow,
//                       defaultImage: appIcon,
//                       boxFit: BoxFit.cover,
//                       isApp: true,
//                     )
//                         : CircleAvatar(
//                       backgroundColor: Colors.white,
//                       radius: 22,
//                       child: Text(
//                         getInitials(companyData.companyName ?? ''),
//                         style: BalooStyles.baloosemiBoldTextStyle(
//                             color: greenside, size: 18),
//                       ),
//                     ),
//                   ),
//
//                   const SizedBox(width: 10),
//
//                   // 🔥 TEXT CONTENT
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         // NAME + STATUS
//                         Row(
//                           children: [
//                             if (companyData.companyId ==
//                                 controller.selCompany?.companyId)
//                               CircleContainer(
//                                 setSize: 6,
//                                 colorIS: Colors.greenAccent,
//                               ).paddingOnly(right: 4),
//
//                             Expanded(
//                               child: Text(
//                                 companyData.companyName ?? '',
//                                 style: BalooStyles.baloosemiBoldTextStyle(),
//                                 maxLines: 1,
//                                 overflow: TextOverflow.ellipsis,
//                               ),
//                             ),
//                           ],
//                         ),
//
//                         vGap(4),
//
//                         // CREATOR
//                         Text(
//                           "Creator: ${companyData.createdBy == APIs.me.userId ? APIs.me.phone : (companyData.companyName ?? '')}",
//                           style:
//                           BalooStyles.baloonormalTextStyle(size: 13),
//                           maxLines: 1,
//                           overflow: TextOverflow.ellipsis,
//                         ),
//
//                         vGap(4),
//
//                         // MEMBERS
//                         GestureDetector(
//                           onTap: () => _onSubtitleTap(companyData),
//                           child: Text(
//                             'Members: ${companyData.members?.length ?? 0}',
//                             style: BalooStyles.baloonormalTextStyle(
//                                 size: 13, color: Colors.blue),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//
//           // 🔥 TOP RIGHT MENU
//           Positioned(
//             top: 8,
//             right: 5,
//             child: Builder(
//               builder: (context) {
//                 final bool isSelected =
//                     companyData.companyId ==
//                         controller.selCompany?.companyId;
//                 final bool isCreator =
//                     companyData.createdBy == APIs.me?.userId;
//
//                 if (!isSelected) return const SizedBox();
//
//                 return PopupMenuButton<String>(
//                   color: Colors.white,
//                   icon: const Icon(Icons.more_vert,
//                       color: Colors.black87),
//                   onSelected: (value) => controller.companyNavigation(
//                       value, companyData, () async {
//                     if (kIsWeb) {
//                       await openMemberDialog(companyData);
//                     } else {
//                       await Get.toNamed(
//                         AppRoutes.company_members,
//                         arguments: {
//                           'companyId': companyData.companyId ?? 0,
//                           'companyName':
//                           companyData.companyName ?? '',
//                         },
//                       );
//                     }
//                   }),
//                   itemBuilder: (context) {
//                     final items = <PopupMenuEntry<String>>[];
//
//                     if (isCreator) {
//                       items.addAll([
//                         const PopupMenuItem(
//                           value: 'Invite',
//                           child: Row(children: [
//                             Icon(Icons.person_add_alt, size: 15),
//                             SizedBox(width: 4),
//                             Text('Invite Member'),
//                           ]),
//                         ),
//                         const PopupMenuItem(
//                           value: 'Pending',
//                           child: Row(children: [
//                             Icon(Icons.pending_outlined, size: 15),
//                             SizedBox(width: 4),
//                             Text('Pending Invites'),
//                           ]),
//                         ),
//                         const PopupMenuItem(
//                           value: 'Update',
//                           child: Row(children: [
//                             Icon(Icons.edit_outlined, size: 15),
//                             SizedBox(width: 4),
//                             Text('Update Company'),
//                           ]),
//                         ),
//                         PopupMenuItem(
//                           value: 'Delete',
//                           child: Row(children: [
//                             Icon(Icons.delete_outline,
//                                 size: 15,
//                                 color: AppTheme.redErrorColor),
//                             const SizedBox(width: 4),
//                             const Text('Delete Company'),
//                           ]),
//                         ),
//                       ]);
//                     }
//
//                     items.add(const PopupMenuItem(
//                       value: 'All',
//                       child: Row(children: [
//                         Icon(Icons.people, size: 15),
//                         SizedBox(width: 4),
//                         Text('All Members'),
//                       ]),
//                     ));
//
//                     return items;
//                   },
//                 );
//               },
//             ),
//           ),
//
//           // 🔥 BADGE (Creator / Joined)
//           Positioned(
//             top: -18,
//             right: 10,
//             child: Container(
//               padding: const EdgeInsets.all(6),
//               decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(30),
//                 color: companyData.createdBy == APIs.me.userId
//                     ? appColorGreen.withOpacity(.1)
//                     : appColorYellow.withOpacity(.1),
//               ),
//               child: Text(
//                 companyData.createdBy == APIs.me.userId
//                     ? "Creator"
//                     : "Joined",
//                 style: BalooStyles.baloosemiBoldTextStyle(
//                   color: companyData.createdBy == APIs.me.userId
//                       ? appColorGreen
//                       : appColorYellow,
//                   size: 12,
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     ),
//   );
// }

bool looksLikeCode(String text) {
  final t = text.trim();
  if (t.isEmpty) return false;

  // Markdown fenced code
  if (t.startsWith("```") && t.endsWith("```")) return true;

  // multi-line + indentation
  final lines = t.split('\n');
  final multiLine = lines.length >= 3;
  final indentedLines =
      lines.where((l) => l.startsWith('  ') || l.startsWith('\t')).length;

  // common code tokens
  final hasTokens = RegExp(
          r'\b(class|import|return|final|var|const|void|function|def|if|else|for|while|public|private)\b')
      .hasMatch(t);

  final hasSymbols = RegExp(r'[{};=<>\[\]()]').hasMatch(t);
  final hasArrow = t.contains("=>");
  final hasColonIndent = RegExp(r':\s*$').hasMatch(lines.last);

  return (multiLine && (indentedLines >= 1 || hasSymbols)) ||
      hasTokens ||
      hasArrow ||
      hasColonIndent;
}

Future<void> openAcceptInviteDialog() async {
  final c = Get.put(AcceptInviteController());

  try {
    await Get.dialog(
      Dialog(
        clipBehavior: Clip.antiAlias,
        insetPadding: const EdgeInsets.all(12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: SizedBox(
          width: kIsWeb ? 450 : Get.width * .9,
          height: Get.height * 0.6,
          child: const AcceptInvitationScreen(),
        ),
      ),
      barrierDismissible: true,
    );
  } finally {
    if (Get.isRegistered<AcceptInviteController>()) {
      Get.delete<AcceptInviteController>();
    }
  }
}

Future<void> openCreateCompanyDialog(bool isHome) async {
  final c = Get.put(CreateCompanyController(isHome: isHome));

  try {
    await Get.dialog(
      Dialog(
        clipBehavior: Clip.antiAlias,
        insetPadding: const EdgeInsets.all(12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: SizedBox(
          width: kIsWeb ? 600 : Get.width * .9,
          height: Get.height * 0.95,
          child: const CreateCompanyScreen(),
        ),
      ),
      barrierDismissible: true,
    );
  } finally {
    if (Get.isRegistered<CreateCompanyController>()) {
      Get.delete<CreateCompanyController>();
    }
  }
}

Future<void> saveImageToDownloads(String imageUrl) async {
  try {
    final granted = await requestStoragePermission();

    if (!granted) {
      errorDialog('❌ Storage permission denied');
      return;
    }

    final saveDir =
        Directory('/storage/emulated/0/Pictures/AccuChat'); // or DCIM
    if (!await saveDir.exists()) {
      await saveDir.create(recursive: true);
    }

    final filePath =
        '${saveDir.path}/accu_image_${DateTime.now().millisecondsSinceEpoch}.jpg';

    final String fileName =
        'accu_image_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final response = await Dio().download(
      imageUrl,
      filePath,
      // options: Options(responseType: ResponseType.bytes),
    );

    if (response.statusCode == 200) {
      // ✅ Trigger media scan
      await MediaScanner.loadMedia(path: filePath);

      toast("✅ Saved to Gallery");
    } else {
      toast("❌ Failed to download image");
    }

    /*if (response.statusCode == 200) {
      print('✅ Image saved at: $fileName');
      toast("✅ Image saved!");
    } else {
      toast('❌ Failed to download image');
    }*/
  } catch (e) {}
}

Widget hGap(double width) {
  return SizedBox(width: width);
}

Widget vGap(double height) {
  return SizedBox(height: height);
}

Widget divider({Color? color, thikness}) {
  return Divider(
    thickness: thikness ?? .5,
    color: color ?? Colors.grey.shade300,
    height: 8,
  );
}

String getFileNameFromUrl(String url) {
  return (url).split('/').last.replaceAll(RegExp(r'^DOC_\d+_'), '');
}

// Future<void> saveImageToGallery(String imageUrl) async {
//   // Step 1: Request storage permission
//   final permission = await requestStoragePermission();
//   if (!permission) {
//     errorDialog("❌ Storage permission denied");
//     return;
//   }
//
//   // Step 2: Define gallery directory
//   final directory = Directory('/storage/emulated/0/Pictures/AccuChat');
//   if (!await directory.exists()) {
//     await directory.create(recursive: true);
//   }
//
//   // Step 3: Define full file path
//   final timestamp = DateTime.now().millisecondsSinceEpoch;
//   final filePath = '${directory.path}/accu_image_$timestamp.jpg';
//
//   // Step 4: Download the image using Dio
//   try {
//     final response = await Dio().download(imageUrl, filePath);
//     if (response.statusCode == 200) {
//       // Step 5: Trigger media scan to show in Gallery
//       await MediaScanner.loadMedia(path: filePath);
//
//       toast("✅ Image Saved!");
//     } else {
//       toast("❌ Failed to download image");
//     }
//   } catch (e) {
//   }
//
// }

String formatDate(String date) {
  if (date == '') {
    return "";
  } else {
    // return DateFormat('MM-dd-yy').format(DateTime.parse(date));
    return "12.2.2013";
  }
}

String parseTimestamp(dynamic value) {
  if (value is Timestamp) return value.millisecondsSinceEpoch.toString();
  if (value is int) return value.toString();
  if (value is String) return value;
  return '0';
}

BoxDecoration containerDecoration() {
  return BoxDecoration(
      borderRadius: BorderRadius.circular(12),
      color: Colors.white,
      boxShadow: [BoxShadow(color: Colors.grey.shade300, blurRadius: 8)],
      border: Border.all(color: Colors.deepOrange.withOpacity(.3)));
}

Widget shimmerEffectWidget(
    {required Widget child, Widget? shimmerWidget, bool showShimmer = true}) {
  return showShimmer
      ? Shimmer.fromColors(
          baseColor: Colors.grey.withOpacity(0.2),
          highlightColor: Colors.black12,
          child: shimmerWidget ?? child)
      : child;
}

LinearGradient homeLinearGradient = const LinearGradient(
    colors: [
      Colors.white30,
      Colors.white60,
      Colors.white,
      Colors.white,
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomCenter,
    stops: [0, 0.33, 0.78, 1]);

class MyAnnotatedRegion extends StatelessWidget {
  Widget child;
  bool? isDark;
  MyAnnotatedRegion({Key? key, required this.child, this.isDark})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark.copyWith(
            statusBarColor: AppTheme.whiteColor,
            statusBarIconBrightness: Brightness.dark),
        child: Container(color: Colors.white, child: child));
  }
}

Widget backIcon({Function()? onBack}) {
  return InkWell(
      onTap: onBack ?? () => Get.back(),
      child: const Icon(
        Icons.arrow_back,
        color: Colors.white,
        size: 25,
      ));
}

LinearGradient headerGradient = const LinearGradient(
  colors: [
    Colors.purple,
    Colors.white,
  ],
  begin: Alignment.centerLeft,
  end: Alignment.centerRight,
  stops: [1, 0],
);

Widget statusTile(title,
    {Color? coloris,
    Color? textColor,
    Function()? onStatusTap,
    double? widthis}) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    width: widthis,
    decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: coloris,
        border: Border.all(color: coloris ?? appColor, width: .5)),
    child: InkWell(
      onTap: onStatusTap ?? () {},
      child: Text(
        title,
        style: BalooStyles.baloonormalTextStyle(
          color: textColor,
          weight: FontWeight.w500,
          size: 13.5,
        ),
        textAlign: TextAlign.center,
        overflow: TextOverflow.ellipsis,
      ),
    ),
  );
}

Widget goToWidget(title, color, {count}) {
  return HoverGlassEffect(
    margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
    padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 0),
    borderRadius: 40,
    hoverScale: 1.015,
    normalBlur: 3,
    hoverBlur: 10,
    borderColor: greenside.withOpacity(.1),
    hoverBorderColor:greenside.withOpacity(.55)
        ,
    child: CustomContainer(
        vPadding: 0,
        hPadding: 10,
        elevation: 0,
        color: whiteselected,
        sColor: Colors.grey.shade300,
        childWidget: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: BalooStyles.baloonormalTextStyle(size: 12),
            ),
            hGap(2),
           isTaskMode? _budgeWidget():Container(
               padding: const EdgeInsets.all(4),
               decoration: BoxDecoration(
                   color: greenside.withOpacity(.1),
                   shape: BoxShape.circle

               ),
               child: SvgPicture.asset(bellSvg,color: greenside,height: 15,)),
          ],
        )),
  );
}

_budgeWidget(){
  return Obx(() {
    final unread = AppBadgeController.to.chatUnread.value;
    return Stack(
      clipBehavior: Clip.none,
      children: [
       Container(
           padding: const EdgeInsets.all(4),
           decoration: BoxDecoration(
               color: greenside.withOpacity(.1),
               shape: BoxShape.circle

           ),
           child:SvgPicture.asset(bellSvg,color: greenside,height: 15,)),
       if (unread > 0)
          Positioned(
            right: -6,
            top: -9,
            child: Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: greenside,
                shape: BoxShape.circle

              ),
              constraints: const BoxConstraints(
                minWidth: 15,
                minHeight: 15,
              ),
              child: Text(
                unread > 99 ? "99+" : unread.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          )
      ],
    );
  });
}

Widget getAppLogo({Color? color, height}) {
  // return SvgPicture.asset(
  return Image.asset(
    appIcon,
    width: 110,
    height: 55,
  );
}

bool isTaskTimeExceeded(TaskDetails task) {
  if (task.estimatedTime.isEmpty) return false;
  DateTime now = DateTime.now();

  final estimatedDateTime =
      DateTime.fromMillisecondsSinceEpoch(int.parse(task.estimatedTime));
  if (estimatedDateTime == null) return false;

  return DateTime(now.year, now.month, now.day, now.hour, now.minute)
      .isAfter(estimatedDateTime);
}

/// Estimate label between createdOn and deadlineOn.
/// - If same calendar day: "Xh Ym"
/// - Else: "Xd"
/// - Uses local time for day comparison.
/// - Returns "Expired" if deadline < created.
String estimateLabel({
  required String createdIso,
  required String deadlineIso,
}) {
  final created = DateTime.parse(createdIso).toLocal();
  final deadline = DateTime.parse(deadlineIso).toLocal();

  if (deadline.isBefore(created)) return "Expired";

  // Date-only (midnight) to compare calendar days
  final cDay = DateTime(created.year, created.month, created.day);
  final dDay = DateTime(deadline.year, deadline.month, deadline.day);

  if (cDay == dDay) {
    final diff = deadline.difference(created);
    final h = diff.inHours;
    final m = diff.inMinutes % 60;
    if (h <= 0 && m <= 0) return "0m";
    if (h > 0 && m > 0) return "${h}h ${m}m";
    if (h > 0) return "${h}h";
    return "${m}m";
  } else {
    final days = dDay.difference(cDay).inDays; // whole days
    return "${days}d";
  }
}

String formatTaskTime(String timestamp, sentTime) {
  var dateString;
  final sent = DateTime.fromMillisecondsSinceEpoch(int.parse(sentTime));
  dateString = "${sent.day} ${monthName(sent.month)}";
  if (timestamp.isEmpty) return "";
  if (timestamp == '0') return "• $dateString";

  final targetTime =
      DateTime.fromMillisecondsSinceEpoch(int.tryParse(timestamp) ?? 0);
  final now = DateTime.now();
  final duration = targetTime.difference(sent);
  final remainingDuration = targetTime.difference(now);

  if (remainingDuration.isNegative) return "⏰ Time exceeded";

  final hrs = duration.inHours;
  final hrsR = duration.inHours;
  final mins = duration.inMinutes.remainder(60);
  final minsR = duration.inMinutes.remainder(60);

  dateString = "${targetTime.day} ${monthName(targetTime.month)}";
  final remaining = "${targetTime.day} ${monthName(targetTime.month)}";
  if (timestamp == "0") {
    return "• $dateString";
  } else {
    return "$hrs hrs $mins mins • $dateString";
  }
}

String monthName(int month) {
  const months = [
    '',
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec'
  ];
  return months[month];
}

String extractFileName(String fullName) {
  final parts = fullName.split('_');
  if (parts.length >= 3) {
    return parts.sublist(2).join('_');
  }
  return fullName;
}

String extractFileNameFromUrl(String url) {
  try {
    Uri uri = Uri.parse(url);
    String path =
        uri.path;
    String lastSegment = path.split('/').last;

    String decoded = Uri.decodeComponent(lastSegment);

    final segments = decoded.split('/');
    return segments.isNotEmpty ? segments.last : decoded;
  } catch (e) {
    return "Unknown File";
  }
}

Color getTaskStatusColor(String? status) {
  switch (status) {
    case 'Pending':
      return Colors.blue;
    case 'Running':
      return appColorPerple;
    case 'Done':
      return appColorYellow;
    case 'Cancelled':
      return AppTheme.redErrorColor;
    case 'Completed':
      return appColorGreen;
    default:
      return appColorGreen; // default for any unrecognized status
  }
}

String convertUtcToIndianTime(String utcTimeString) {
  // Parse UTC string
  DateTime utcTime = DateTime.parse(utcTimeString);

  // Always convert to IST (+5:30)
  DateTime indianTime = utcTime.add(const Duration(hours: 5, minutes: 30));

  // Format like "9:00 AM"
  return DateFormat.jm().format(indianTime);
}

bool isTaskExpired(String startTime, String estimate) {
  final start = DateTime.parse(startTime);
  final estimateDuration = estimate.toLowerCase().contains('hr')
      ? int.tryParse(estimate.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0
      : 0;
  final deadline = start.add(Duration(hours: estimateDuration));
  return DateTime.now().isAfter(deadline);
}

bool isDownloadOnlyFile(String url) {
  final fileName = url.split('/').last.split('?').first.toLowerCase();
  final ext = fileName.contains('.') ? fileName.split('.').last : '';
  return ['html', 'js', 'php', 'css', 'jsx', 'HTML', 'JS', 'PHP', 'CSS', 'JSX']
      .contains(ext);
}

Future<void> openDocumentFromUrl(String url) async {
  customLoader.show();

  try {
    final fileName = url.split('/').last.split('?').first;
    final lowerUrl = url.toLowerCase();

    final shouldDownloadOnly = lowerUrl.endsWith('.html') ||
        lowerUrl.endsWith('.js') ||
        lowerUrl.endsWith('.php') ||
        lowerUrl.contains('.html?') ||
        lowerUrl.contains('.js?') ||
        lowerUrl.contains('.php?');

    if (kIsWeb) {
      customLoader.hide();

      if (shouldDownloadOnly) {
        await downloadFileOnWeb(url, fileName);
      } else {
        final ok = await launchUrlString(
          url,
          mode: LaunchMode.externalApplication,
        );
        if (!ok) throw 'Could not open $url';
      }
      return;
    }

    final dir = await getTemporaryDirectory();
    final filePath = '${dir.path}/$fileName';

    await Dio().download(url, filePath);

    customLoader.hide();

    if (!shouldDownloadOnly) {
      await OpenFilex.open(filePath);
    }
  } catch (e) {
    customLoader.hide();
    // debugPrint('openDocumentFromUrl error: $e');
  }
}

/*
Future<void> openDocumentFromUrl(String url) async {
  customLoader.show();
  if (kIsWeb) {
    // Web: just open in a new tab (downloads or previews based on file type/server headers)
    customLoader.hide();
    final ok = await launchUrlString(
      url,
      mode: LaunchMode.externalApplication, // opens new tab
    );
    if (!ok) throw 'Could not open $url';
    return;
  }
  try {
    final dir = await getTemporaryDirectory();
    final fileName = url.split('/').last.split('?').first;
    final filePath = '${dir.path}/$fileName';

    // Download using Dio
    await Dio().download(url, filePath);
    customLoader.hide();
    await OpenFilex.open(filePath);
  } catch (e) {
    customLoader.hide();
  }
}
*/

/*Future<void> saveImageWithGallerySaver(String imageUrl) async {
  final status = await requestStoragePermission();
  if (!status) {
    print("❌ Permission denied");
    return;
  }

  final success = await GallerySaver.saveImage(imageUrl);
  if (success == true) {
    toast("✅ Image saved to gallery!");
  } else {
    toast("❌ Failed to save image");
  }
}*/

bool isDoc(Items m) {
  final code = (m.mediaType?.code ?? '').toUpperCase();
  if (code == 'DOC') return true;
  final ext = (m.fileName ?? '').toLowerCase();
  return ext.endsWith('.pdf') ||
      ext.endsWith('.doc') ||
      ext.endsWith('.docx') ||
      ext.endsWith('.xls') ||
      ext.endsWith('.xlsx') ||
      ext.endsWith('.ppt') ||
      ext.endsWith('.pptx') ||
      ext.endsWith('.php') ||
      ext.endsWith('.css') ||
      ext.endsWith('.html') ||
      ext.endsWith('.js') ||
      ext.endsWith('.csv') ||
      ext.endsWith('.txt');
}

bool isImageOrVideo(Items m) {
  final code = (m.mediaType?.code ?? '').toUpperCase();
  if (code == 'IMG' ||
      code == 'IMAGE' ||
      code == 'PHOTO' ||
      code == 'VID' ||
      code == 'VIDEO') return true;
  final ext = (m.fileName ?? '').toLowerCase();
  return ext.endsWith('.jpg') ||
      ext.endsWith('.jpeg') ||
      ext.endsWith('.png') ||
      ext.endsWith('.gif') ||
      ext.endsWith('.webp') ||
      ext.endsWith('.mp4') ||
      ext.endsWith('.mov') ||
      ext.endsWith('.m4v') ||
      ext.endsWith('.avi');
}

bool isDocument(String orignalMsg) {
  final ext = (orignalMsg ?? '').toLowerCase();
  return ext.endsWith('.pdf') ||
      ext.endsWith('.doc') ||
      ext.endsWith('.docx') ||
      ext.endsWith('.xls') ||
      ext.endsWith('.xlsx') ||
      ext.endsWith('.ppt') ||
      ext.endsWith('.pptx') ||
      ext.endsWith('.php') ||
      ext.endsWith('.css') ||
      ext.endsWith('.html') ||
      ext.endsWith('.js') ||
      ext.endsWith('.csv') ||
      ext.endsWith('.txt');
}

bool isImageVideo(String orignalMsg) {
  final ext = (orignalMsg ?? '').toLowerCase();
  return ext.endsWith('.jpg') ||
      ext.endsWith('.jpeg') ||
      ext.endsWith('.png') ||
      ext.endsWith('.gif') ||
      ext.endsWith('.webp') ||
      ext.endsWith('.mp4') ||
      ext.endsWith('.mov') ||
      ext.endsWith('.m4v') ||
      ext.endsWith('.avi');
}

String buildFileUrl(String path) {
  if (path.startsWith("http")) return path;
  return "${ApiEnd.baseUrl}$path";
}

Future<bool?> showPastedImagePreviewDialog(
  XFile file, {
  Uint8List? webBytes,
}) {
  final captionController = TextEditingController();
  final dialogFocusNode = FocusNode();

  return Get.dialog<bool>(
    Dialog(
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Focus(
        focusNode: dialogFocusNode,
        autofocus: true,
        onKeyEvent: (node, event) {
          if (!kIsWeb) return KeyEventResult.ignored;
          if (event is! KeyDownEvent) return KeyEventResult.ignored;

          if (event.logicalKey == LogicalKeyboardKey.enter) {
            final keys = HardwareKeyboard.instance.logicalKeysPressed;
            final shiftPressed = keys.contains(LogicalKeyboardKey.shiftLeft) ||
                keys.contains(LogicalKeyboardKey.shiftRight);

            if (shiftPressed) return KeyEventResult.ignored;

            Get.back(result: true);
            return KeyEventResult.handled;
          }

          if (event.logicalKey == LogicalKeyboardKey.escape) {
            Get.back(result: false);
            return KeyEventResult.handled;
          }

          return KeyEventResult.ignored;
        },
        child: LayoutBuilder(
          builder: (context, constraints) {
            final maxH = MediaQuery.of(context).size.height * 0.85;
            final maxW = 560.0;

            return ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: maxH,
                maxWidth: maxW,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 14, 8, 10),
                    child: Row(
                      children: [
                        const Expanded(
                          child: Text(
                            "Preview",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => Get.back(result: false),
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: AspectRatio(
                              aspectRatio: 16 / 10,
                              child: Container(
                                color: Colors.black12,
                                alignment: Alignment.center,
                                child: _buildPreviewImage(file,
                                    webBytes: webBytes),
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),
                        ],
                      ),
                    ),
                  ),
                  const Divider(height: 1),
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () => Get.back(result: false),
                            child: const Text("Cancel"),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Get.back(result: true);
                            },
                            icon: const Icon(Icons.send),
                            label: const Text("Send"),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    ),
    barrierDismissible: true,
  ).whenComplete(() {
    captionController.dispose();
    dialogFocusNode.dispose();
  });
}

/*Future<bool?> showPastedImagePreviewDialog(
    XFile file, {
      Uint8List? webBytes,
    }) {
  final captionController = TextEditingController();

  return Get.dialog<bool>(
    Dialog(
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final maxH = MediaQuery.of(context).size.height * 0.85;
          final maxW = 560.0;

          return ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: maxH,
              maxWidth: maxW,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 8, 10),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Text(
                          "Preview",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Get.back(result: false),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                ),

                const Divider(height: 1),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: AspectRatio(
                            aspectRatio: 16 / 10,
                            child: Container(
                              color: Colors.black12,
                              alignment: Alignment.center,
                              child: _buildPreviewImage(file, webBytes: webBytes),
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                      ],
                    ),
                  ),
                ),

                const Divider(height: 1),

                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => Get.back(result: false),
                          child: const Text("Cancel"),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Get.back(result: true);
                          },
                          icon: const Icon(Icons.send),
                          label: const Text("Send"),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    ),
    barrierDismissible: true,
  ).whenComplete(() => captionController.dispose());
}*/

Widget _buildPreviewImage(XFile file, {Uint8List? webBytes}) {
  if (kIsWeb) {
    if (webBytes != null) {
      return Image.memory(
        webBytes,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => const Text("Couldn’t load preview"),
      );
    }

    return FutureBuilder<Uint8List>(
      future: file.readAsBytes(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }

        if (!snapshot.hasData || snapshot.data == null) {
          return const Text("Couldn’t load preview");
        }

        return Image.memory(
          snapshot.data!,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => const Text("Couldn’t load preview"),
        );
      },
    );
  }

  return Image.file(
    File(file.path),
    fit: BoxFit.contain,
    errorBuilder: (_, __, ___) => const Text("Couldn’t load preview"),
  );
}

/*Future<bool?> showPastedImagePreviewDialog(XFile file) {
  final captionController = TextEditingController();

  return Get.dialog<bool>(
    Dialog(
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final maxH = MediaQuery.of(context).size.height * 0.85;
          final maxW = 560.0;

          return ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: maxH,
              maxWidth: maxW,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.max, // IMPORTANT
              children: [
                // Header (fixed)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 8, 10),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Text(
                          "Preview",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Get.back(result: false),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                ),

                const Divider(height: 1),

                // Body (scrollable if needed)
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Image Preview (keeps good height, no overflow)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: AspectRatio(
                            aspectRatio: 16 / 10,
                            child: Container(
                              color: Colors.black12,
                              alignment: Alignment.center,
                              child: kIsWeb
                                  ? CustomCacheNetworkImage(
                                radiusAll: 10,
                                borderColor: greyText,
                                boxFit: BoxFit.contain,
                                file.path,
                              )
                                  : Image.file(
                                File(file.path),
                                fit: BoxFit.contain,
                                errorBuilder: (_, __, ___) =>
                                const Text("Couldn’t load preview"),
                              ),
                            ),
                          ),
                        ),

                        */ /*  const SizedBox(height: 12),

                          // Caption (optional)
                          TextField(
                            controller: captionController,
                            minLines: 1,
                            maxLines: 3,
                            decoration: InputDecoration(
                              hintText: "Add a caption… (optional)",
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 10),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
*/ /*
                        const SizedBox(height: 14),
                      ],
                    ),
                  ),
                ),

                const Divider(height: 1),

                // Bottom actions (fixed)
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [

                      Expanded(
                          child: TextButton(onPressed: () => Get.back(result: false), child: const Text("Cancel"))

                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Get.back(result: true);
                          },
                          icon: const Icon(Icons.send),
                          label: const Text("Send"),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    ),
    barrierDismissible: true,
  ).whenComplete(() => captionController.dispose());
}*/

String getInitials(String name) {
  if (name.trim().isEmpty) return "";

  List<String> parts = name.trim().split(RegExp(r'\s+'));

  if (parts.length == 1) {
    return parts[0][0].toUpperCase();
  } else {
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }
}

Widget GradientContainer({
  required Widget child,
  double padding = 8.0,
  double radius = 100.0,
  Color? color1,
  Color? color2,
}) {
  return Container(
    padding: EdgeInsets.all(padding),
    decoration: BoxDecoration(
      gradient: LinearGradient(colors: [
      color1??  gallwhite,
        color2?? perpleBg,
      ]),
      boxShadow: [BoxShadow(color: perpleBg, blurRadius: 8)],
      borderRadius: BorderRadius.circular(radius),
    ),
    child: child,
  );
}

Widget IconButtonWidget(image, {bool isIcon = false}) {
  return Container(
    padding: const EdgeInsets.all(5),
    margin: const EdgeInsets.all(5),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(8),
      border: Border.all(
        color: perplebr,
      ),
      color: perpleBg.withOpacity(.5),
    ),
    // child:!isIcon? Image.asset(
    child: !isIcon
        ? SvgPicture.asset(
            image,
            height: 20,
            color: perplebr,
          )
        : Icon(image, size: 20),
  );
}
