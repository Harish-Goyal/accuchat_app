import 'package:AccuChat/Constants/colors.dart';
import 'package:AccuChat/utils/text_style.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:media_scanner/media_scanner.dart';
import 'package:shimmer/shimmer.dart';
import '../Constants/assets.dart';
import '../Constants/themes.dart';
import '../Screens/Chat/models/message.dart';
import 'package:dio/dio.dart';
import 'package:permission_handler/permission_handler.dart';
import 'custom_flashbar.dart';
import 'dart:io';



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

Future<void> saveImageToDownloads(String imageUrl) async {
  try {
    final granted = await requestStoragePermission();

    if (!granted) {
      print('❌ Storage permission denied');
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
    print('❌ Error: $e');
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


Future<void> saveImageToGallery(String imageUrl) async {
  // Step 1: Request storage permission
  final permission = await requestStoragePermission();
  if (!permission) {
    print("❌ Storage permission denied");
    return;
  }

  // Step 2: Define gallery directory
  final directory = Directory('/storage/emulated/0/Pictures/AccuChat');
  if (!await directory.exists()) {
    await directory.create(recursive: true);
  }

  // Step 3: Define full file path
  final timestamp = DateTime.now().millisecondsSinceEpoch;
  final filePath = '${directory.path}/accu_image_$timestamp.jpg';

  // Step 4: Download the image using Dio
  try {
    final response = await Dio().download(imageUrl, filePath);
    if (response.statusCode == 200) {
      print("✅ Image downloaded to $filePath");

      // Step 5: Trigger media scan to show in Gallery
      await MediaScanner.loadMedia(path: filePath);

      toast("✅ Image Saved!");
    } else {
      toast("❌ Failed to download image");
    }
  } catch (e) {
    print("❌ Error saving image: $e");
  }
}


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




bool isTaskExpired(String startTime, String estimate) {
  final start = DateTime.parse(startTime);
  final estimateDuration = estimate.toLowerCase().contains('hr')
      ? int.tryParse(estimate.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0
      : 0;
  final deadline = start.add(Duration(hours: estimateDuration));
  return DateTime.now().isAfter(deadline);
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



