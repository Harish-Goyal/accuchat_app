import 'package:AccuChat/utils/text_style.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

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
