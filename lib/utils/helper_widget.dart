import 'package:AccuChat/Constants/colors.dart';
import 'package:AccuChat/utils/text_style.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:media_scanner/media_scanner.dart';
import 'package:open_filex/open_filex.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher_string.dart';
import '../Constants/assets.dart';
import '../Constants/themes.dart';
import '../Screens/Chat/models/all_media_res_model.dart';
import '../Screens/Chat/models/message.dart';
import 'package:dio/dio.dart';
import 'package:permission_handler/permission_handler.dart';
import '../Screens/Chat/screens/auth/Presentation/Controllers/accept_invite_controller.dart';
import '../Screens/Chat/screens/auth/Presentation/Views/accept_invite_screen.dart';
import '../main.dart';
import '../routes/app_routes.dart';
import 'custom_flashbar.dart';
import 'dart:io';
import 'package:path/path.dart' as p;
import 'dart:async';
import 'dart:math' as math;
import 'package:path_provider/path_provider.dart';
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
    return true; // iOS not needed for saving to gallery
  }
}

void showCompanyErrorDialog() {
  Get.dialog(
    Center(
      child: Container(
        width: 300,
        height: 300,
        child: AlertDialog(
          title: Text('Access Denied'),
          content: Text('You are not a part of this company. Please contact admin for more details.'),
          actions: [
            TextButton(
              onPressed: () {
                Get.back(); // Close the dialog
                Get.offAllNamed(AppRoutes.landing_r);
              },
              child: Text('OK'),
            ),
          ],
        ),
      ),
    ),
    barrierDismissible: true,
  );
}


Future<void> openAcceptInviteDialog() async {
  final c=  Get.put(AcceptInviteController());

  try {
    await Get.dialog(
      Dialog(
        clipBehavior: Clip.antiAlias,
        insetPadding: const EdgeInsets.all(12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: SizedBox(
          width: kIsWeb ? 450: Get.width * .9,
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



Future<void> saveImageToDownloads(String imageUrl) async {
  try {
    final granted = await requestStoragePermission();

    if (!granted) {
      errorDialog('❌ Storage permission denied');
      return;
    }

    final saveDir = Directory('/storage/emulated/0/Pictures/AccuChat'); // or DCIM
    if (!await saveDir.exists()) {
      await saveDir.create(recursive: true);
    }

    final filePath = '${saveDir.path}/accu_image_${DateTime.now().millisecondsSinceEpoch}.jpg';


    final String fileName = 'accu_image_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final response = await Dio().download(
      imageUrl,
      filePath,
      // options: Options(responseType: ResponseType.bytes),
    );

    if (response.statusCode == 200) {
      // ✅ Trigger media scan
      await MediaScanner.loadMedia(path: filePath);

      toast( "✅ Saved to Gallery");
    } else {
      toast( "❌ Failed to download image");
    }

    /*if (response.statusCode == 200) {
      print('✅ Image saved at: $fileName');
      toast("✅ Image saved!");
    } else {
      toast('❌ Failed to download image');
    }*/
  } catch (e) {

  }
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
  return (url)
      .split('/')
      .last
      .replaceAll(RegExp(r'^DOC_\d+_'), '');
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

LinearGradient headerGradient = LinearGradient(
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

Widget getAppLogo({Color? color,height}) {
  return Image.asset(
   appIcon,
    width: 110,
    height: 55,
  );
}
bool isTaskTimeExceeded(TaskDetails task) {
  if (task.estimatedTime.isEmpty) return false;
  DateTime now = DateTime.now();

  final estimatedDateTime = DateTime.fromMillisecondsSinceEpoch(int.parse(task.estimatedTime));
  if (estimatedDateTime == null) return false;

  return DateTime(now.year,now.month,now.day,now.hour,now.minute
  ).isAfter(estimatedDateTime);
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


String formatTaskTime(String timestamp,sentTime) {
  var dateString;
  final sent = DateTime.fromMillisecondsSinceEpoch(int.parse(sentTime));
  dateString = "${sent.day} ${monthName(sent.month)}";
  if (timestamp.isEmpty) return "";
  if (timestamp=='0') return "• $dateString";


  final targetTime = DateTime.fromMillisecondsSinceEpoch(int.tryParse(timestamp) ?? 0);
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
  if(timestamp=="0"){
    return "• $dateString";
  }else{
    return "$hrs hrs $mins mins • $dateString";
  }
}
String monthName(int month) {
  const months = [
    '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];
  return months[month];
}
String extractFileName(String fullName) {
  final parts = fullName.split('_');
  if (parts.length >= 3) {
    // Join everything after 'DOC' and timestamp
    return parts.sublist(2).join('_');
  }
  return fullName; // fallback
}


String extractFileNameFromUrl(String url) {
  try {
    // Extract the last segment after the last `/`
    Uri uri = Uri.parse(url);
    String path = uri.path; // e.g., /v0/b/.../o/media%2Ftasks%2FDOC_1749_name.pdf
    String lastSegment = path.split('/').last; // media%2Ftasks%2FDOC_...

    // Decode URL-encoded parts like %2F to /
    String decoded = Uri.decodeComponent(lastSegment); // media/tasks/DOC_...

    // Extract just the file name
    final segments = decoded.split('/');
    return segments.isNotEmpty ? segments.last : decoded;
  } catch (e) {
    debugPrint("⚠️ Failed to extract file name: $e");
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
      ext.endsWith('.doc') || ext.endsWith('.docx') ||
      ext.endsWith('.xls') || ext.endsWith('.xlsx') ||
      ext.endsWith('.ppt') || ext.endsWith('.pptx') ||
      ext.endsWith('.csv') || ext.endsWith('.txt');
}

bool isImageOrVideo(Items m) {
  final code = (m.mediaType?.code ?? '').toUpperCase();
  if (code == 'IMG' || code == 'IMAGE' || code == 'PHOTO' || code == 'VID' || code == 'VIDEO') return true;
  final ext = (m.fileName ?? '').toLowerCase();
  return ext.endsWith('.jpg') || ext.endsWith('.jpeg') ||
      ext.endsWith('.png') || ext.endsWith('.gif') ||
      ext.endsWith('.webp') || ext.endsWith('.mp4') ||
      ext.endsWith('.mov') || ext.endsWith('.m4v') || ext.endsWith('.avi');
}

bool isDocument(String orignalMsg) {
  final ext = (orignalMsg ?? '').toLowerCase();
  return ext.endsWith('.pdf') ||
      ext.endsWith('.doc') || ext.endsWith('.docx') ||
      ext.endsWith('.xls') || ext.endsWith('.xlsx') ||
      ext.endsWith('.ppt') || ext.endsWith('.pptx') ||
      ext.endsWith('.csv') || ext.endsWith('.txt');
}

bool isImageVideo(String orignalMsg) {
  final ext = (orignalMsg ?? '').toLowerCase();
  return ext.endsWith('.jpg') || ext.endsWith('.jpeg') ||
      ext.endsWith('.png') || ext.endsWith('.gif') ||
      ext.endsWith('.webp') || ext.endsWith('.mp4') ||
      ext.endsWith('.mov') || ext.endsWith('.m4v') || ext.endsWith('.avi');
}

String buildFileUrl(String path) {
  const baseUrl = "https://api.accuchat.in"; // or from config
  if (path.startsWith("http")) return path;
  return "$baseUrl$path";
}


Widget IconButtonWidget(image,{bool isIcon =false}){
  return Container(
    padding: const EdgeInsets.all(5),
    margin: const EdgeInsets.all(5),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color:appColorGreen.withOpacity(.3),),
      color: appColorGreen.withOpacity(.1),
    ),
    child:!isIcon? Image.asset(
      image,
      height: 20,
      color: appColorGreen,
    ):Icon(image,size: 20,color: appColorGreen,),
  );
}











