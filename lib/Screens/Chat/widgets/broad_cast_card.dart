import 'package:AccuChat/Constants/assets.dart';
import 'package:AccuChat/Constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import '../../../Constants/app_theme.dart';
import '../../../main.dart';
import '../api/apis.dart';
import '../helper/my_date_util.dart';
import '../models/chat_user.dart';
import '../models/message.dart';
import '../screens/chats_broadcasts.dart';

class BroadcastCard extends StatefulWidget {
  final BroadcastChat chat;

   BroadcastCard({super.key, required this.chat});

  @override
  State<BroadcastCard> createState() => _BroadcastCardState();
}

class _BroadcastCardState extends State<BroadcastCard> {
  Message? _message;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: APIs.getBroadcastLastMessage(widget.chat),
        builder: (context, snapshot) {
          final data = snapshot.data?.docs;
          final list =
              data?.map((e) => Message.fromJson(e.data())).toList() ??
                  [];
          if (list.isNotEmpty) _message = list[0];
          return Container(
            padding: EdgeInsets.zero,
            margin: EdgeInsets.symmetric(horizontal: mq.width * .04, vertical: 3),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: appColorPerple.withOpacity(.1)),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(color: appColorPerple.withOpacity(.07), blurRadius: 12)
                ]),
            child: ListTile(
              contentPadding: EdgeInsets.symmetric(horizontal: 10),
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(mq.height * .04),
                child: Container(
                  padding: EdgeInsets.all(10),
                  decoration:
                      BoxDecoration(color: Colors.grey.shade100, boxShadow: [
                    BoxShadow(
                        color: Colors.grey, blurRadius: 10, offset: Offset(3, 3)),
                  ]),
                  child: Image.asset(
                    broadcastIcon,
                    height: mq.height * .03,
                    color: appColorPerple,
                  ),
                ),
              ),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.chat.name ?? '',
                    style: themeData.textTheme.titleMedium,
                  ),
                  Container(
                    width: Get.width * .58,
                    child: Text(

                      _message != null
                          ?_message!.type == Type.image
                          ? 'image'
                          : _message!.type == Type.video
                          ? 'video'
                          : _message!.type == Type.doc?"Document": widget.chat.lastMessage ?? ''
                          : "",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: themeData.textTheme.bodySmall
                          ?.copyWith(color: Colors.black),
                    ),
                  )
                ],
              ),
              trailing: Text(
                MyDateUtil.getLastMessageTime(
                  context: context,
                  time: widget.chat.lastMessageTime ?? '0',
                ),
                style: const TextStyle(color: Colors.black54),
              ),
              onTap: () {
                Get.to(() => BroadcastChatScreen(
                      chat: widget.chat,
                    ));
              },
            ));
      }
    );
  }
}
