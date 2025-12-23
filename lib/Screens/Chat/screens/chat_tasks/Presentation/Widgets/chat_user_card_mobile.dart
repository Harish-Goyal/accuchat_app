import 'package:AccuChat/Constants/colors.dart';
import 'package:AccuChat/Screens/Chat/screens/chat_tasks/Presentation/Controllers/chat_screen_controller.dart';
import 'package:AccuChat/Screens/Chat/screens/chat_tasks/Presentation/Views/chat_screen.dart';
import 'package:AccuChat/Screens/Chat/screens/chat_tasks/Presentation/Views/task_chat_screen.dart';
import 'package:AccuChat/Services/APIs/api_ends.dart';
import 'package:AccuChat/routes/app_routes.dart';
import 'package:AccuChat/utils/text_style.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../../Constants/app_theme.dart';
import '../../../../../../Constants/assets.dart';
import '../../../../../../utils/networl_shimmer_image.dart';
import '../../../../api/apis.dart';
import '../../../../helper/my_date_util.dart';
import '../../../../../../main.dart';
import '../../../auth/models/get_uesr_Res_model.dart';
import '../../../../models/recent_chat_user_res_model.dart';
import '../dialogs/profile_dialog.dart';

//card to represent a single user in home screen
class ChatUserCardMobile extends StatefulWidget with WidgetsBindingObserver {
  UserDataAPI? user;

  ChatUserCardMobile({super.key, this.user});

  @override
  State<ChatUserCardMobile> createState() => _ChatUserCardMobileState();
}

class _ChatUserCardMobileState extends State<ChatUserCardMobile>
    with WidgetsBindingObserver {
  //last message info (if null --> no message)
  RecentChatUserList? _message;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {

    switch (state) {
      case AppLifecycleState.resumed:
      // App is in the foreground
      // APIs.updateActiveStatus(true);
        break;
      case AppLifecycleState.paused:
      // App is in the background
      // APIs.updateActiveStatus(false);
      // APIs.updateTypingStatus(false);
        break;
      case AppLifecycleState.detached:
      // App is terminated
      // APIs.updateActiveStatus(false);
      // APIs.updateTypingStatus(false);
        break;
      case AppLifecycleState.inactive:
      // APIs.updateTypingStatus(false);
      // This state is not commonly used for online/offline status handling
        break;
      case AppLifecycleState.hidden:
      // TODO: Handle this case.
      // throw UnimplementedError();
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.zero,
      margin: EdgeInsets.symmetric(horizontal: mq.width * .04, vertical: 0),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color:isTaskMode? appColorYellow.withOpacity(.06):appColorGreen.withOpacity(.04)),
          color: Colors.white,
          boxShadow: [
            BoxShadow(color:isTaskMode? appColorYellow.withOpacity(.06):appColorGreen.withOpacity(.04), blurRadius: 8)
          ]),
      child: InkWell(
          onTap: () {
            //for navigating to chat screen
            // APIs.updateActiveStatus(true);
            if(isTaskMode) {
              Get.toNamed(AppRoutes.tasks_li_r,arguments: {'user':widget.user});
            }else{
              // Get.find<ChatScreenController>().openConversation(widget.user);
                Get.toNamed(AppRoutes.chats_li_r,arguments: {'user':widget.user});
            }
          },
          child:/*ListTile(
            //user profile picture

            contentPadding:
            const EdgeInsets.symmetric(horizontal: 10),
            leading: InkWell(
              onTap: () {
                showDialog(
                    context: context,
                    builder: (_) => ProfileDialog(user: widget.user));
              },
              child: CustomCacheNetworkImage(
                radiusAll: 100,
                "${ApiEnd.baseUrlMedia}${widget.user?.userImage??''}",
                height: mq.height * .06,
                width: mq.height * .06,
                boxFit: BoxFit.cover,
                borderColor: greyText,
                defaultImage: widget.user?.userCompany?.isGroup==1?
                groupIcn:
                widget.user?.userCompany?.isBroadcast==1?
                broadcastIcon:ICON_profile,
              ),
            ),

            //user name
            title:(widget.user?.userCompany?.isGroup==1|| widget.user?.userCompany?.isBroadcast==1)? Text(
              (widget.user?.userId==APIs.me.userId)?"Me":  (widget.user?.userName==''||widget.user?.userName==null)?widget.user?.phone??'':widget.user?.userName??'',
              style: BalooStyles.baloonormalTextStyle(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ):Text(
              (widget.user?.userId==APIs.me.userId)?"Me":  (widget.user?.displayName==''||widget.user?.displayName==null)?widget.user?.phone??'':widget.user?.displayName??'',
              style: BalooStyles.baloonormalTextStyle(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),

            //last message
            subtitle: Text(
              widget.user?.lastMessage?.message??''
              ,
              maxLines: 1,
              style: BalooStyles.balooregularTextStyle(color: greyText,size: 13),
              overflow: TextOverflow.ellipsis,
            ),

            trailing: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment:MainAxisAlignment.center,
              children: [
                widget.user?.pendingCount!=null&&widget.user?.pendingCount!=0  ? CircleAvatar(
                  radius: 10,
                  backgroundColor: Colors.greenAccent.shade400,
                  child: Text(
                    "${widget.user?.pendingCount}",
                    style: BalooStyles.baloonormalTextStyle(color: Colors.white),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ):SizedBox(),
                widget.user?.open_count!=null&&widget.user?.open_count!=0 ? Spacer():SizedBox(),
                Text(
                  MyDateUtil.getLastMessageTime(
                      context: context, time: widget.user?.lastMessage?.messageTime??''),
                  style: const TextStyle(color: Colors.black54),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ).paddingOnly(bottom: 2),
              ],
            ),
            //message sent time

          )*/ListTile(
            contentPadding:
            const EdgeInsets.symmetric(horizontal: 10),
              leading: InkWell(
                onTap: () {
                  showDialog(
                      context: context,
                      builder: (_) => ProfileDialog(user: widget.user));
                },
                child: CustomCacheNetworkImage(
                  radiusAll: 100,
                  "${ApiEnd.baseUrlMedia}${widget.user?.userImage??''}",
                  height: mq.height * .06,
                  width: mq.height * .06,
                  boxFit: BoxFit.cover,
                  borderColor: greyText,
                  defaultImage: widget.user?.userCompany?.isGroup==1?
                  groupIcn:
                  widget.user?.userCompany?.isBroadcast==1?
                  broadcastIcon:ICON_profile,
                ),
              ),

              //user name
              title:(widget.user?.userCompany?.isGroup==1|| widget.user?.userCompany?.isBroadcast==1)? Text(
                (widget.user?.userId==APIs.me.userId)?"Me":  (widget.user?.userName==''||widget.user?.userName==null)?widget.user?.phone??'':widget.user?.userName??'',
                style: BalooStyles.baloonormalTextStyle(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ):Text(
                (widget.user?.userId==APIs.me.userId)?"Me":  (widget.user?.displayName==''||widget.user?.displayName==null)?widget.user?.phone??'':widget.user?.displayName??'',
                style: BalooStyles.baloonormalTextStyle(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),

              //last message
              subtitle: Text(
                widget.user?.lastMessage?.message??'',
                maxLines: 1,
                style: BalooStyles.balooregularTextStyle(color: greyText,size: 13),
                overflow: TextOverflow.ellipsis,
              ),

              trailing: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment:MainAxisAlignment.center,
                children: [
                  !isTaskMode?  ( widget.user?.pendingCount!=null&&widget.user?.pendingCount!=0  ? CircleAvatar(
                    radius: 10,
                    backgroundColor: Colors.greenAccent.shade400,
                    child: Text(
                      "${widget.user?.pendingCount}",
                      style: BalooStyles.baloonormalTextStyle(color: Colors.white,size: 12),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ):SizedBox()) /*: widget.user?.open_count!=null&&widget.user?.open_count!=0  ? CircleAvatar(
                    radius: 10,
                    backgroundColor: Colors.greenAccent.shade400,
                    child: Text(
                      "${widget.user?.open_count}",
                      style: BalooStyles.baloonormalTextStyle(color: Colors.white,size: 12),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  )*/:SizedBox(),
                  widget.user?.pendingCount!=null&&widget.user?.pendingCount!=0 ? Spacer():SizedBox(),
                  widget.user?.open_count!=null&&widget.user?.open_count!=0 ? Spacer():SizedBox(),
                  Text(
                    MyDateUtil.getLastMessageTime(
                        context: context, time: widget.user?.lastMessage?.messageTime??''),
                    style: const TextStyle(color: Colors.black54),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ).paddingOnly(bottom: 2),
                ],
              ),
              //message sent time

            ),

      ),
    );
  }
}
