import 'package:AccuChat/Constants/colors.dart';
import 'package:AccuChat/Constants/themes.dart';
import 'package:AccuChat/Screens/Chat/screens/chat_tasks/Presentation/Controllers/chat_screen_controller.dart';
import 'package:AccuChat/Services/APIs/api_ends.dart';
import 'package:AccuChat/routes/app_routes.dart';
import 'package:AccuChat/utils/helper_widget.dart';
import 'package:AccuChat/utils/text_style.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../../Constants/app_theme.dart';
import '../../../../../../Constants/assets.dart';
import '../../../../../../utils/networl_shimmer_image.dart';
import '../../../../../Home/Presentation/Controller/socket_controller.dart';
import '../../../../api/apis.dart';
import '../../../../helper/my_date_util.dart';
import '../../../../../../main.dart';
import '../../../../models/chat_user.dart';
import '../../../../models/message.dart';
import '../../../auth/models/get_uesr_Res_model.dart';
import '../../../../models/recent_chat_user_res_model.dart';
import '../dialogs/profile_dialog.dart';

//card to represent a single user in home screen
class ChatUserCard extends StatefulWidget with WidgetsBindingObserver {
  UserDataAPI? user;

  ChatUserCard({super.key, this.user});

  @override
  State<ChatUserCard> createState() => _ChatUserCardState();
}

class _ChatUserCardState extends State<ChatUserCard>
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
      margin: EdgeInsets.symmetric(horizontal: mq.width * .04, vertical: 5),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: appColorYellow.withOpacity(.1)),
          color: Colors.white,
          boxShadow: [
            BoxShadow(color: appColorYellow.withOpacity(.1), blurRadius: 8)
          ]),
      child: InkWell(
          onTap: () {
            //for navigating to chat screen
            // APIs.updateActiveStatus(true);

            if(isTaskMode) {

              if(kIsWeb){
                Get.toNamed(
                  "${AppRoutes.tasks_li_r}?userId=${widget.user?.userId?.toString()}",
                );
              }else{
                Get.toNamed(AppRoutes.tasks_li_r, arguments: {
                  'user': widget.user
                });
              }

            }else{
              if(kIsWeb){
                Get.toNamed(
                  "${AppRoutes.chats_li_r}?userId=${widget.user?.userId?.toString()}",
                );
              }else{
                Get.toNamed(AppRoutes.chats_li_r, arguments: {
                  'user': widget.user
                });
              }

            }
          },
          child:ListTile(
            //user profile picture
            contentPadding:
            const EdgeInsets.symmetric(horizontal: 10),
            leading: InkWell(
              onTap: () {
                showDialog(
                    context: context,
                    builder: (_) => ProfileDialog(user: widget.user));
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(mq.height * .04),
                child: Container(
                  padding: const EdgeInsets.all(0),
                  decoration: const BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                            color: Colors.grey,
                            blurRadius: 10,
                            offset: Offset(3, 3)),
                      ]),
                  child: CustomCacheNetworkImage(
                    radiusAll: 100,
                    "${ApiEnd.baseUrlMedia}${widget.user?.userImage??''}",
                    height: mq.height * .055,
                    width: mq.height * .055,
                    boxFit: BoxFit.cover,
                    defaultImage: widget.user?.userCompany?.isGroup==1?
                    groupIcn:
                    widget.user?.userCompany?.isBroadcast==1?
                    broadcastIcon:ICON_profile,
                  ),
                ),
              ),
            ),

            //user name
            title: Text(
              (widget.user?.userId==APIs.me.userId)?"Me":  (widget.user?.userName =='null' ||widget.user?.userName==''||widget.user?.userName==null)?widget.user?.phone??'':widget.user?.userName??'',
              style: themeData.textTheme.titleMedium,
            ),

            //last message
            subtitle: Text(
              widget.user?.lastMessage?.message??''
                  ,
              maxLines: 1,
              style: BalooStyles.balooregularTextStyle(),
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
                  ),
                ):SizedBox(),
                widget.user?.open_count!=null&&widget.user?.open_count!=0 ? Spacer():SizedBox(),
                Text(
                  MyDateUtil.getLastMessageTime(
                      context: context, time: widget.user?.lastMessage?.messageTime??''),
                  style: const TextStyle(color: Colors.black54),
                ).paddingOnly(bottom: 2),
              ],
            ),
            //message sent time

          )
      ),
    );
  }
}
