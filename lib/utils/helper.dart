import 'package:AccuChat/utils/text_style.dart';
import 'package:AccuChat/utils/web_file_picekr.dart';
import 'package:dio/dio.dart' as dio;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http_parser/http_parser.dart';
import 'package:intl/intl.dart';
import 'package:mime/mime.dart';
import 'package:mime/mime.dart' as mime;
import 'package:path/path.dart' as p;
import '../Constants/themes.dart';
import 'helper_widget.dart';

/*
abstract class Helper {
  static String getRoomText(RoomDataFilter roomData) {
    return "${roomData.adult} ${"Adults"} ${roomData.rooms} ${"Rooms"}";
  }

  static String getDateText(DateText dateText) {
    String languageCode = Get.find<Loc>().locale.languageCode;
    return "0${dateText.startDate} ${DateFormat('MMM', languageCode).format(DateTime.now())} - 0${dateText.endDate} ${DateFormat('MMM', languageCode).format(DateTime.now().add(const Duration(days: 2)))}";
  }

  static String getLastSearchDate(DateText dateText) {
    String languageCode = Get.find<Loc>().locale.languageCode;
    return "${dateText.startDate} - ${dateText.endDate} ${DateFormat('MMM', languageCode).format(DateTime.now().add(const Duration(days: 2)))}";
  }

  static String getPeopleandChildren({adults,size,type,bedNos}) {
    return "${"Adults"} - ${adults??''} | ${"Size"} - ${size ?? ''} | ${"Type"} - ${type??''} | ${"No. of Beds"} - ${bedNos??''}";
  }

  static String getPeopleRoom({adults,bedNos}) {
    return "${"Adults"} - ${adults} | ${"No. of Beds"} - $bedNos ";
  }

  static Widget ratingStar({double rating = 0.0,itemCount,Color? color}) {
    return RatingBarIndicator(
      rating: rating,
      itemBuilder: (context, index) => Icon(
        Icons.star,
        color:color?? AppTheme.primaryColor,
      ),
      itemCount:itemCount?? 5,
      unratedColor: AppTheme.secondaryTextColor,
      itemSize: 18.0,
      direction: Axis.horizontal,
    );
  }


  static Widget writeRatingStar({double rating = 0.0,itemCount,Color? color,ValueChanged<double>? onRatingUpdate}) {
    return RatingBar.builder(
        initialRating: 0,
        itemCount: 5,
        itemBuilder: (context, index) {
      switch (index) {
        case 0:
          return Icon(
            Icons.sentiment_very_dissatisfied,
            color: AppTheme.redErrorColor,
          );
        case 1:
          return Icon(
            Icons.sentiment_dissatisfied,
            color: Colors.redAccent,
          );
        case 2:
          return Icon(
            Icons.sentiment_neutral,
            color: Colors.amber,
          );
        case 3:
          return Icon(
            Icons.sentiment_satisfied_alt_outlined,
            color: Colors.lightGreen,
          );
        case 4:
          return Icon(
            Icons.sentiment_very_satisfied,
            color: Colors.green,
          );
      }
      return Container();
      },
    onRatingUpdate:onRatingUpdate?? (rating) {
    print(rating);
    });
  }

  static Future<bool> showCommonPopup(
      String title, String descriptionText, BuildContext context,
      {bool isYesOrNoPopup = false, bool barrierDismissible = true,Widget? textWid}) async {
    bool isOkClick = false;
    return await showDialog(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (BuildContext context) => CustomDialog(
        title: title,
        description: descriptionText,
        onCloseClick: () {
          Navigator.of(context).pop();
        },

        actionButtonList: isYesOrNoPopup
            ? <Widget>[

              Column(
                children: [
                  textWid??SizedBox(),
                  Row(
                    children: [
                      Expanded(
                        child: CustomDialogActionButton(
                          buttonText: "NO",
                          color: Colors.green,
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ),
                      Expanded(
                        child: CustomDialogActionButton(
                          buttonText: "YES",
                          color: AppTheme.redErrorColor,
                          onPressed: () {
                            isOkClick = true;
                            Navigator.of(context).pop();
                          },
                        ),
                      )
                    ],
                  )
                ],

              ),


              ]
            : <Widget>[
                CustomDialogActionButton(
                  buttonText: "OK",
                  color: Colors.green,
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                )
              ],
      ),
    ).then((_) {
      return isOkClick;
    });
  }
}*/

Widget tillRowWidget({title, assetName}) {
  return Row(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Image.asset(
        assetName,
        height: 12.5,
        width: 12.5,
        color: AppTheme.appColor,
      ).paddingOnly(top: 2),
      hGap(3),
      Expanded(
        // width: Get.width*.81,
        // color: Colors.blue,
          child: Text(title, style: BalooStyles.baloonormalTextStyle())),
    ],
  );
}

String formatDateMonth(DateTime date,{String? format ="d MMM yyyy"}) {
  return DateFormat(format??'d MMM').format(date);
}

DateTime parseDate(String dateString, {String format ="yyyy-MM-dd"}) {
  final DateFormat formatter = DateFormat(format);
  return formatter.parse(dateString);
}

String formatTimeAMPM(DateTime date) {
  return DateFormat('h:mm a').format(date);  // 'h' for 12-hour format, 'a' for AM/PM
}


Widget titleRow({String? leadIcon, title, value,Color? leadColor,bool isExpanded=false,FontWeight? weight}) {
  return Row(
    // mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      isExpanded?   Row(
        children: [
          Container(
            padding: EdgeInsets.all(6),
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: leadColor?.withOpacity(.1)??Colors.grey.withOpacity(.1)
            ),
            child: Image.asset(
              leadIcon??'',
              color: leadColor??Colors.grey.shade600,
              height: 13,
            ),
          ),
          hGap(5),
          FittedBox(
            child: SizedBox(
              width: 140,
              child: Text(
                title,
                style: BalooStyles.baloonormalTextStyle(),
                overflow:TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ):Row(
        children: [
          Container(
            padding: EdgeInsets.all(6),
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: leadColor?.withOpacity(.1)??Colors.grey.withOpacity(.1)
            ),
            child: Image.asset(
              leadIcon??'',
              color: leadColor??Colors.grey.shade600,
              height: 13,
            ),
          ),
          hGap(5),
          Text(
            title,
            style: BalooStyles.baloonormalTextStyle(),
          ),
        ],
      ),
      Text(
        isExpanded? ":":"",
        style: BalooStyles.baloonormalTextStyle(),
      ),
      hGap(10),
      isExpanded?   Expanded(

        child: Text(
          value,
          style: BalooStyles.balooregularTextStyle(weight:weight?? FontWeight.w500),
        ),
      ):Text(
        value,
        style: BalooStyles.balooregularTextStyle(weight: weight??FontWeight.w500),
      ),
    ],
  );
}

String buildAbsoluteUrl(String baseUrl, String? fileName) {
  final file = (fileName ?? '').trim();
  if (file.isEmpty) return '';
  if (file.startsWith('http')) return file;
  // Ensure there’s exactly one slash
  if (baseUrl.endsWith('/') && file.startsWith('/')) {
    return baseUrl + file.substring(1);
  } else if (!baseUrl.endsWith('/') && !file.startsWith('/')) {
    return '$baseUrl/$file';
  }
  return '$baseUrl$file';
}

IconData iconForFile(String? fileName) {
  final f = (fileName ?? '').toLowerCase();
  if (f.endsWith('.pdf')) return Icons.picture_as_pdf;
  if (f.endsWith('.doc') || f.endsWith('.docx')) return Icons.description;
  if (f.endsWith('.xls') || f.endsWith('.xlsx')) return Icons.grid_on;
  if (f.endsWith('.ppt') || f.endsWith('.pptx')) return Icons.slideshow;
  if (f.endsWith('.txt')) return Icons.note;
  if (f.endsWith('.zip') || f.endsWith('.rar') || f.endsWith('.7z')) return Icons.archive;
  return Icons.insert_drive_file;
}

Future<dio.MultipartFile> pickedToMultipart(PickedFileData f) async {
  final mime = lookupMimeType(f.name, headerBytes: f.bytes) ?? 'application/octet-stream';
  final mediaType = MediaType.parse(mime); // e.g. image/jpeg, application/pdf
  return dio.MultipartFile.fromBytes(
    f.bytes,
    filename: f.name,
    contentType: mediaType,
  );
}

String ext(String pathOrName) {
  final ext = p.extension(pathOrName).toLowerCase();
  return ext.startsWith('.') ? ext.substring(1) : ext; // 'jpg'
}

MediaType mediaTypeForExt(String ext) {
  // try package:mime first (optional)
  final guessed = mime.lookupMimeType('x.$ext'); // trick to use ext
  if (guessed != null && guessed.contains('/')) {
    final parts = guessed.split('/');
    return MediaType(parts.first, parts.last);
  }

  // fallback mapping
  switch (ext) {
    case 'jpg':
    case 'jpeg':
      return MediaType('image', 'jpeg');
    case 'png':
      return MediaType('image', 'png');
    case 'webp':
      return MediaType('image', 'webp');
    case 'pdf':
      return MediaType('application', 'pdf');
    case 'doc':
      return MediaType('application', 'msword');
    case 'docx':
      return MediaType('application', 'vnd.openxmlformats-officedocument.wordprocessingml.document');
    case 'xls':
      return MediaType('application', 'vnd.ms-excel');
    case 'xlsx':
      return MediaType('application', 'vnd.openxmlformats-officedocument.spreadsheetml.sheet');
    case 'ppt':
      return MediaType('application', 'vnd.ms-powerpoint');
    case 'pptx':
      return MediaType('application', 'vnd.openxmlformats-officedocument.presentationml.presentation');
    case 'csv':
      return MediaType('text', 'csv');
    case 'txt':
      return MediaType('text', 'plain');
    case 'json':
      return MediaType('application', 'json');
    case 'xml':
      return MediaType('application', 'xml');
    case 'zip':
      return MediaType('application', 'zip');
    case 'rar':
      return MediaType('application', 'x-rar-compressed');
    default:
      return MediaType('application', 'octet-stream');
  }
}

String safeName(String name) {
  // remove odd chars that may break multipart on some backends/CDNs
  return name.replaceAll(RegExp(r'[^\w\.\-\(\) ]+'), '_');
}


enum TimeFilter { today, thisWeek, thisMonth }

// 2) Helper to build a [from, to) range in LOCAL time, then convert to UTC ISO
class DateRange {
  final DateTime fromUtc;
  final DateTime toUtc;
  DateRange(this.fromUtc, this.toUtc);
}

DateRange rangeFor(TimeFilter f, {DateTime? nowLocal}) {
  final now = nowLocal ?? DateTime.now(); // Asia/Kolkata on user device
  final startOfToday = DateTime(now.year, now.month, now.day);

  if (f == TimeFilter.today) {
    final fromLocal = startOfToday;
    final toLocal = fromLocal.add(const Duration(days: 1));
    return DateRange(fromLocal.toUtc(), toLocal.toUtc());
  }

  if (f == TimeFilter.thisWeek) {
    // ISO week (Mon–Sun). For Sun-start weeks, change weekday math.
    final int weekday = startOfToday.weekday; // Mon=1 ... Sun=7
    final fromLocal = startOfToday.subtract(Duration(days: weekday - 1)); // Monday 00:00
    final toLocal = fromLocal.add(const Duration(days: 7));               // next Monday 00:00
    return DateRange(fromLocal.toUtc(), toLocal.toUtc());
  }

  // thisMonth
  final fromLocal = DateTime(now.year, now.month, 1);
  final toLocal = DateTime(now.year, now.month + 1, 1);
  return DateRange(fromLocal.toUtc(), toLocal.toUtc());
}

String friendlyDate(DateTime dt) {
  final now = DateTime.now();
  final diff = now.difference(dt).inDays;
  if (diff == 0) return 'today';
  if (diff == 1) return 'yesterday';
  return '${diff} days ago';
}