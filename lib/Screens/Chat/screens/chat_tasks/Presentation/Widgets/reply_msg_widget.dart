import 'package:AccuChat/Constants/colors.dart';
import 'package:AccuChat/Constants/themes.dart';
import 'package:AccuChat/Screens/Chat/models/chat_history_response_model.dart';
import 'package:AccuChat/Services/APIs/api_ends.dart';
import 'package:AccuChat/Services/APIs/local_keys.dart';
import 'package:AccuChat/main.dart';
import 'package:AccuChat/utils/helper_widget.dart';
import 'package:AccuChat/utils/networl_shimmer_image.dart';
import 'package:AccuChat/utils/text_style.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../api/apis.dart';
import '../Controllers/chat_screen_controller.dart';

class ReplyMessageWidget extends StatelessWidget {
  final String? message;
  final String? orignalMsg;
  final String? empName;
  final String? empIdsender;
  final String? empIdreceiver;
  ChatHisList? chatdata;
  bool? isCancel = false;
  bool? sentByMe = false;
  final VoidCallback? onCancelReply;
  ReplyMessageWidget({
    @required this.message,
    @required this.orignalMsg,
    this.onCancelReply,
    this.empIdsender,
    this.chatdata,
    this.empIdreceiver,
    this.empName,
    this.sentByMe,
    this.isCancel,
    Key? key,
  }) : super(key: key);

  bool isDoc() {
    final ext =(orignalMsg??'').toLowerCase();
    return ext.endsWith('.pdf') ||
        ext.endsWith('.doc') || ext.endsWith('.docx') ||
        ext.endsWith('.xls') || ext.endsWith('.xlsx') ||
        ext.endsWith('.ppt') || ext.endsWith('.pptx') ||
        ext.endsWith('.csv') || ext.endsWith('.txt');
  }

  bool isImageOrVideo() {
    final ext = (orignalMsg ?? '').toLowerCase();
    return ext.endsWith('.jpg') || ext.endsWith('.jpeg') ||
        ext.endsWith('.png') || ext.endsWith('.gif') ||
        ext.endsWith('.webp') || ext.endsWith('.mp4') ||
        ext.endsWith('.mov') || ext.endsWith('.m4v') || ext.endsWith('.avi');
  }

  @override
  Widget build(BuildContext context) {
    bool isSendByME = APIs.me.userId.toString() == empIdsender ? true : false;
    return IntrinsicHeight(
      child: Container(
        // alignment: isSendByME &&!isCancel!?Alignment.centerRight:Alignment.centerLeft,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: isSendByME && !isCancel!
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            Container(
              width: 4,
              margin: EdgeInsets.symmetric(vertical: 6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: greyText),
                color: AppTheme.appColor,
              ),
            ),
            const SizedBox(width: 2),
            isCancel!
                ? Expanded(child: buildReplyMessage(isSendByME))
                : Flexible(child: buildReplyMessage(isSendByME)),
          ],
        ).marginOnly(
          right: isCancel! ? 35 : 15,
          left: isCancel! ? 10 : 15,
        ),
      ),
    );
  }
  Widget buildReplyMessage(isSendByME) {
    return InkWell(
      onTap:(){
        // final replyToId = chatdata?.replyToId;
        // if (replyToId != null) {
        //   Get.find<ChatScreenController>().scrollToChatId(replyToId);
        // }
      },
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: greyText),
            color:Colors.grey.shade100),
        child: Column(
          crossAxisAlignment:isSendByME && !isCancel! ?CrossAxisAlignment.start:CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,

          children: [
            Row(
              mainAxisAlignment:MainAxisAlignment.start,
              mainAxisSize: isCancel! ? MainAxisSize.max: MainAxisSize.min,
              children: [
               /* isCancel! ?     Expanded(
                  child:chatdata?.isGroupChat==1? Text(
                    (chatdata?.fromUser?.userCompany?.displayName!=null?
                    chatdata?.fromUser?.userCompany?.displayName??'':chatdata?.fromUser?.phone??''),
                    style: BalooStyles.baloonormalTextStyle(color: appColorYellow),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    textAlign: TextAlign.start,
                  ).paddingOnly(left: 8,right: 8):Text(
                    isSendByME?(chatdata?.fromUser?.userCompany?.displayName!=null?
                    chatdata?.fromUser?.userCompany?.displayName??'':chatdata?.fromUser?.phone??''):(chatdata?.toUser?.userCompany?.displayName!=null?chatdata?.toUser?.userCompany?.displayName??'':chatdata?.toUser?.phone??''),
                    style: BalooStyles.baloonormalTextStyle(color: appColorYellow),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    textAlign: TextAlign.start,
                  ).paddingOnly(left: 8,right: 8),
                ):*/ Flexible(
                  child: Text(
        chatdata?.replyToName??'',
                    style: BalooStyles.baloonormalTextStyle(color: appColorYellow),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    textAlign: TextAlign.start,
                  ).paddingOnly(left: 8,right: 8)),


                isCancel!

                    ?
                GestureDetector(
                  onTap: onCancelReply,
                  child: Icon(
                    Icons.cancel_outlined,
                    size: 18,
                    color: AppTheme.redErrorColor,
                  ).paddingAll(2),
                )
                    : const SizedBox()
              ],
            ).paddingSymmetric(horizontal: 5,vertical: 3),

           !isImageOrVideo()?  Container(
              // width: Get.width * .78,
                child: Text(
                  orignalMsg?? '',
                  style: BalooStyles.baloonormalTextStyle(color: greyText ,size: 15),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ).marginOnly(left: 13, bottom: 4, right: 15)):
           Container(
             // color: Colors.red,
             width: 70,
             margin: EdgeInsets.only(left: 8,bottom: 8,right: 8),
             child: CustomCacheNetworkImage("${ApiEnd.baseUrlMedia}${orignalMsg??''}",
               width: 60,
               height: 60,
             radiusAll: 8,
               boxFit: BoxFit.cover,
               borderColor: greyColor,
             ),
           ),
          ],
        ),
      ),
    );
  }
}
