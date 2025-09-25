import 'package:AccuChat/Constants/app_theme.dart';
import 'package:AccuChat/Constants/assets.dart';
import 'package:AccuChat/Constants/colors.dart';
import 'package:AccuChat/routes/app_routes.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../api/apis.dart';
import '../../../../helper/my_date_util.dart';
import '../../../../../../main.dart';
import '../../../../models/chat_user.dart';
import '../../../../models/message.dart';
import '../Views/chat_groups.dart';


//card to represent a single user in home screen
class ChatGroupCard extends StatefulWidget with WidgetsBindingObserver{
  final ChatGroup user;

  const ChatGroupCard({super.key, required this.user});


  @override
  State<ChatGroupCard> createState() => _ChatGroupCardState();
}

class _ChatGroupCardState extends State<ChatGroupCard> with WidgetsBindingObserver{

  Message? _message;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    //
    // switch (state) {
    //   case AppLifecycleState.resumed:
    //   // App is in the foreground
    //     APIs.updateActiveStatus(true);
    //     break;
    //   case AppLifecycleState.paused:
    //   // App is in the background
    //     APIs.updateActiveStatus(false);
    //     // APIs.updateTypingStatus(false);
    //     break;
    //   case AppLifecycleState.detached:
    //   // App is terminated
    //     APIs.updateActiveStatus(false);
    //     // APIs.updateTypingStatus(false);
    //     break;
    //   case AppLifecycleState.inactive:
    //     // APIs.updateTypingStatus(false);
    //     // This state is not commonly used for online/offline status handling
    //     break;
    //   case AppLifecycleState.hidden:
    //   // TODO: Handle this case.
    //     throw UnimplementedError();
    // }
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
    return/* Container(
      padding: EdgeInsets.zero,
      margin: EdgeInsets.symmetric(horizontal: mq.width * .04, vertical: 3),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color:  appColorGreen.withOpacity(.1)),
          color: Colors.white,
          boxShadow: [
            BoxShadow(color: appColorGreen.withOpacity(.07),blurRadius: 12)
          ]
      ),


      child: InkWell(
          onTap: () {

            APIs.updateActiveStatus(true);
            Get.toNamed(AppRoutes.GroupChatRoute,arguments: {'group': widget.user});
          },
          child: StreamBuilder(
            stream: APIs.getLastMessageGroup(widget.user),
            builder: (context, snapshot) {
              final data = snapshot.data?.docs;
              final list =
                  data?.map((e) => Message.fromJson(e.data())).toList() ?? [];
              if (list.isNotEmpty) _message = list[0];

              return ListTile(
                contentPadding: EdgeInsets.symmetric(horizontal: 10),
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(mq.height * .04),
                  child: Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        boxShadow: [BoxShadow(color: Colors.grey,blurRadius: 10,offset: Offset(3,3)),]                      ),
                    child:Icon(Icons.group,size: mq.height * .03,color: appColorGreen,),
                  ),
                ),

                //user name
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.user.name??'',style: themeData.textTheme.titleMedium,),

                    Container(
                      width: Get.width*.58,
                      child: Text(
                        _message != null
                            ? _message!.type == Type.image
                            ? 'image'
                            : _message!.type == Type.video
                            ? 'video'
                            : _message!.type == Type.doc?"Document": widget.user.lastMessage ?? ""
                            : "",

                        maxLines: 1,overflow: TextOverflow.ellipsis,
                        style: themeData.textTheme.bodySmall,
                      ),
                    )
                  ],
                ),

                trailing: (widget.user.lastMessage??'').isEmpty
                    ? null //show nothing when no message is sent
                    : _message?.read.isEmpty??true &&
                    _message?.fromId != APIs.user.uid
                    ?

                Container(
                  width: 15,
                  height: 15,
                  decoration: BoxDecoration(
                      color: Colors.greenAccent.shade400,
                      borderRadius: BorderRadius.circular(10)),
                ):

                Text(
                  MyDateUtil.getLastMessageTime(
                      context: context, time: widget.user.lastMessageTime??"0"),
                  style: const TextStyle(color: Colors.black54),
                ),

              );
            },
          )),
    );*/
    Container();
  }
}
