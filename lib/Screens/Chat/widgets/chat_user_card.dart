import 'package:AccuChat/Constants/colors.dart';
import 'package:AccuChat/Constants/themes.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../Constants/app_theme.dart';
import '../../../Constants/assets.dart';
import '../../../utils/networl_shimmer_image.dart';
import '../api/apis.dart';
import '../helper/my_date_util.dart';
import '../../../main.dart';
import '../models/chat_user.dart';
import '../models/message.dart';
import '../screens/chat_screen.dart';
import 'dialogs/profile_dialog.dart';

//card to represent a single user in home screen
class ChatUserCard extends StatefulWidget with WidgetsBindingObserver {
  final ChatUser user;

  const ChatUserCard({super.key, required this.user});

  @override
  State<ChatUserCard> createState() => _ChatUserCardState();
}

class _ChatUserCardState extends State<ChatUserCard>
    with WidgetsBindingObserver {
  //last message info (if null --> no message)
  Message? _message;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {

    switch (state) {
      case AppLifecycleState.resumed:
        // App is in the foreground
        APIs.updateActiveStatus(true);
        break;
      case AppLifecycleState.paused:
        // App is in the background
        APIs.updateActiveStatus(false);
        APIs.updateTypingStatus(false);
        break;
      case AppLifecycleState.detached:
        // App is terminated
        APIs.updateActiveStatus(false);
        APIs.updateTypingStatus(false);
        break;
      case AppLifecycleState.inactive:
        APIs.updateTypingStatus(false);
        // This state is not commonly used for online/offline status handling
        break;
      case AppLifecycleState.hidden:
        // TODO: Handle this case.
        throw UnimplementedError();
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
            APIs.updateActiveStatus(true);
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => ChatScreen(user: widget.user)));
          },
          child: isTaskMode
              ? StreamBuilder(
                  stream: APIs.getTaskLastMessage(widget.user),
                  builder: (context, snapshot) {
                    final data = snapshot.data?.docs;
                    final list =
                        data?.map((e) => Message.fromJson(e.data())).toList() ??
                            [];
                    if (list.isNotEmpty) {
                      _message = list[0];
                    }

                    return ListTile(
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
                              widget.user.image,
                              height: mq.height * .055,
                              width: mq.height * .055,
                              boxFit: BoxFit.cover,
                              defaultImage: ICON_profile,
                            ),

                          ),
                        ),
                      ),

                      //user name
                      title: Text(
                        (_message?.fromId==APIs.me.id && _message?.toId==_message?.fromId)?"Me":  (widget.user.name =='null' ||widget.user.name==''||widget.user.name==null)?widget.user.phone:widget.user.name,
                        style: themeData.textTheme.titleMedium,
                      ),

                      //last message
                      subtitle: Text(
                        _message != null?
                                     (isTaskMode)
                                        ? _message!.taskDetails?.description ??
                                            ""
                                        : _message!.msg
                            : "",
                        maxLines: 1,
                        style: Theme.of(context).textTheme.bodySmall,
                        overflow: TextOverflow.ellipsis,
                      ),

                      //last message time
                      trailing: _message == null
                          ? null
                          : _message!.read.isEmpty &&
                                  _message!.fromId != APIs.user.uid
                              ?
                              //show for unread message
                              Container(
                                  width: 15,
                                  height: 15,
                                  decoration: BoxDecoration(
                                      color: Colors.greenAccent.shade400,
                                      borderRadius: BorderRadius.circular(10)),
                              )
                          :
                              //message sent time
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                mainAxisSize: MainAxisSize.min,
                                children: [

                                 isTaskMode?FutureBuilder<int>(
                                    future: APIs.getPendingTaskCount(widget.user.id),
                                    builder: (context, snapshot) {
                                      if (!snapshot.hasData || snapshot.data == 0) return const SizedBox();

                                      return Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          color: AppTheme.redErrorColor,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Text(
                                          '${snapshot.data}',
                                          style: const TextStyle(color: Colors.white, fontSize: 12),
                                        ),
                                      );
                                    },
                                  ):const SizedBox(),
                                 Text(
                                     MyDateUtil.getLastMessageTime(
                                         context: context, time: _message!.sent),
                                     style: const TextStyle(color: Colors.black54),
                                 ),
                                ],
                              ),
                    );
                  },
                )
              : StreamBuilder(
                  stream: APIs.getChatLastMessage(widget.user),
                  builder: (context, snapshot) {
                    final data = snapshot.data?.docs;
                    final list =
                        data?.map((e) => Message.fromJson(e.data())).toList() ??
                            [];
                    if (list.isNotEmpty) _message = list[0];

                    return ListTile(
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
                              widget.user.image,
                              height: mq.height * .055,
                              width: mq.height * .055,
                              boxFit: BoxFit.cover,
                              defaultImage: ICON_profile,
                            ),
                          ),
                        ),
                      ),

                      //user name
                      title: Text(
                       (_message?.fromId==APIs.me.id && _message?.toId==_message?.fromId)?"Me":  (widget.user.name =='null' ||widget.user.name==''||widget.user.name==null)?widget.user.phone:widget.user.name??'',
                        style: themeData.textTheme.titleMedium,
                      ),

                      //last message
                      subtitle: Text(
                        _message != null
                            ? _message!.type == Type.image
                                ? 'image'
                                : _message!.type == Type.video
                                    ? 'video'
                                        : _message!.type == Type.doc?"Document": _message!.msg
                            : "",
                        maxLines: 1,
                        style: Theme.of(context).textTheme.bodySmall,
                        overflow: TextOverflow.ellipsis,
                      ),

                      //last message time
                      trailing: _message == null
                          ? null
                          : (_message?.read.isEmpty??true) &&
                          (_message?.fromId??'') != APIs.user.uid
                              ?
                              //show for unread message
                              Container(
                                  width: 15,
                                  height: 15,
                                  decoration: BoxDecoration(
                                      color: Colors.greenAccent.shade400,
                                      borderRadius: BorderRadius.circular(10)),
                                )
                              :
                              //message sent time
                              Text(
                                  MyDateUtil.getLastMessageTime(
                                      context: context, time: _message!.sent),
                                  style: const TextStyle(color: Colors.black54),
                                ),
                    );
                  },
                )),
    );
  }
}
