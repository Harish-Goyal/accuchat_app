import 'package:AccuChat/Constants/colors.dart';
import 'package:AccuChat/Constants/themes.dart';
import 'package:AccuChat/Services/APIs/local_keys.dart';
import 'package:AccuChat/main.dart';
import 'package:AccuChat/utils/helper_widget.dart';
import 'package:AccuChat/utils/text_style.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../models/chat_history_model.dart';

class ReplyMessageWidget extends StatelessWidget {
  final String? message;
  final String? empName;
  final String? empIdsender;
  final String? empIdreceiver;
  ChatHistoryData? chatdata;
  bool? isCancel = false;
  bool? sentByMe = false;
  final VoidCallback? onCancelReply;
  ReplyMessageWidget({
    @required this.message,
    this.onCancelReply,
    this.empIdsender,
    this.chatdata,
    this.empIdreceiver,
    this.empName,
    this.sentByMe,
    this.isCancel,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isSendByME =   storage.read(userId) ==
        empIdsender
        ? true
        : false;
  return IntrinsicHeight(
    child: Container(
      // alignment: isSendByME &&!isCancel!?Alignment.centerRight:Alignment.centerLeft,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment:isSendByME &&!isCancel!?CrossAxisAlignment.end: CrossAxisAlignment.start,
        children: [
          Container(
            width: 4,
            margin: EdgeInsets.symmetric(vertical: 6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: appColor.withOpacity(.4)),
              color: AppTheme.appColor,
            ),
          ),
          const SizedBox(width: 2),
          isCancel!?   Expanded(child: buildReplyMessage(isSendByME)):
          Flexible(child: buildReplyMessage(isSendByME)),
        ],
      ).marginOnly(
        right: isCancel! ? 35 : 15,
        left: isCancel! ? 10 : 15,
      ) ,
    ),
  );

  }
  Widget buildReplyMessage(isSendByME) {
  var empId=  storage.read(userId)== empIdsender.toString()?empIdsender.toString():
    empIdreceiver;

  String replySender = empIdsender.toString() == storage.read(userId).toString()
      ?"You"
      : chatdata?.receiverUser?.userAbbr??'';

    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: appColor.withOpacity(.4)),
          color: AppTheme.appColor.withOpacity(.05)),
      child: Column(
        crossAxisAlignment:isSendByME && !isCancel! ?CrossAxisAlignment.start:CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 3),
          Row(
            mainAxisAlignment:MainAxisAlignment.start,
            mainAxisSize: isCancel! ? MainAxisSize.max: MainAxisSize.min,
            children: [
              isCancel! ?     Expanded(
                child: Text(
                  empName??'',
                  style: BalooStyles.baloonormalTextStyle(color: AppTheme.appColor.withOpacity(.7)),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  textAlign: TextAlign.start,
                ).paddingOnly(left: 8,right: 8),
              ): Flexible(
                child: Text(
                  empName??'',
                  style: BalooStyles.baloonormalTextStyle(color: AppTheme.appColor),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  textAlign: TextAlign.start,
                ).paddingOnly(left: 8,right: 8),
              ),

              isCancel!

                  ?
              GestureDetector(
                onTap: onCancelReply,
                child: Icon(
                  Icons.cancel_outlined,
                  size: 18,
                  color: AppTheme.redErrorColor,
                ).paddingAll(3),
              )
                  : const SizedBox()
            ],
          ).paddingSymmetric(horizontal: 5),
          const SizedBox(height: 4),

          SizedBox(
            // width: Get.width * .78,
              child: Text(
                message ?? '',
                style: BalooStyles.baloonormalTextStyle(color: Colors.black54 ,size: 15),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ).marginOnly(left: 13, bottom: 4, right: 15)),
        ],
      ),
    );
  }
}
