import 'package:AccuChat/Constants/colors.dart';
import 'package:AccuChat/Screens/Chat/api/apis.dart';
import 'package:AccuChat/Screens/Home/Presentation/Controller/invitations_controller.dart';
import 'package:AccuChat/main.dart';
import 'package:AccuChat/utils/text_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:swipe_to/swipe_to.dart';

import '../../../Chat/models/invite_model.dart';

class InvitationsScreen extends GetView<InvitationsController> {
  const InvitationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<InvitationsController>(
      builder: (controller) {
        return Scaffold(
          appBar: AppBar(
            title: Text(
              'Invitations',
              style: BalooStyles.balooboldTitleTextStyle(),
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.refresh),
                onPressed: () {
                  controller.initData();
                  // You can call the resend invite function here
                },
              )
            ],
          ),
          body: ListView.builder(
            shrinkWrap: true,
            itemCount: controller.sentInviteList.length,
            itemBuilder: (context, i) {
              final invitation = controller.sentInviteList[i];
              return  Slidable(
                key: ValueKey(invitation.inviteId),
                endActionPane: ActionPane(
                  motion: const DrawerMotion(),
                  extentRatio: 0.3,
                  children: [
                    SlidableAction(
                      onPressed: (_)async {
                        controller.hitAPIToDeleteInvitations(invitation.inviteId);
                      },

                      backgroundColor: Colors.white,
                      foregroundColor: Colors.red,
                      icon: Icons.delete,
                      label: 'Delete',
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ],
                ),
                child: ListTile(
                  leading: CircleAvatar(
                      backgroundColor: appColorYellow.withOpacity(.1),
                      child: Icon(
                        Icons.person,
                        color: appColorYellow,
                      )),
                  title: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Text(
                      //     invitation.toPhoneEmail == '' ||
                      //         invitation.toPhoneEmail == null
                      //         ? invitation.toPhoneEmail??''
                      //         : invitation.toPhoneEmail ?? '',
                      //     style: BalooStyles.baloosemiBoldTextStyle()),
                      Text(
                          invitation.toPhoneEmail == '' ||
                              invitation.toPhoneEmail == null
                              ? invitation.toPhoneEmail??''
                              : invitation.toPhoneEmail ?? '',
                          style: BalooStyles.baloomediumTextStyle()),
                    ],
                  ),
                  subtitle: Text(
                      'Status: ${'Pending'}',
                      style: BalooStyles.balooregularTextStyle(
                          color: appColorYellow)),
                ),
              );

               /*SwipeTo(
                iconOnLeftSwipe: Icons.delete_outline,
                iconColor: Colors.red,
                onLeftSwipe: (detail) async {

                  final confirm = await showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      backgroundColor: Colors.white,
                      title: Text(
                          // "Remove ${invitation.name}"),
                          "Remove ${invitation.toPhoneEmail}"),
                      content: const Text(
                          "Are you sure you want to remove this member?"),
                      actions: [
                        TextButton(
                            onPressed: () =>
                                Navigator.pop(context, false),
                            child: const Text("Cancel")),
                        TextButton(
                            onPressed: () =>
                                Navigator.pop(context, true),
                            child: Text(
                              "Remove",
                              style: BalooStyles
                                  .baloosemiBoldTextStyle(
                                  color: Colors.red),
                            )),
                      ],
                    ),
                  );

                  if (confirm == true) {
                    // customLoader.show();
                    // await APIs.deleteInvitation(invitation.inviteId??0).then((v){
                    //   if(v){
                    //     customLoader.hide();
                    //     controller.initData();
                    //   }
                    // }).onError((v,e){
                    //   customLoader.hide();
                    // });
                  }
                },
                child: ListTile(
                  leading: CircleAvatar(
                      backgroundColor: appColorYellow.withOpacity(.1),
                      child: Icon(
                        Icons.person,
                        color: appColorYellow,
                      )),
                  title: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          invitation.toPhoneEmail == '' ||
                              invitation.toPhoneEmail == null
                              ? invitation.toPhoneEmail??''
                              : invitation.toPhoneEmail ?? '',
                          style: BalooStyles.baloosemiBoldTextStyle()),
                      Text(
                          invitation.toPhoneEmail == '' ||
                              invitation.toPhoneEmail == null
                              ? invitation.toPhoneEmail??''
                              : invitation.toPhoneEmail ?? '',
                          style: BalooStyles.baloosemiBoldTextStyle()),
                    ],
                  ),
                  subtitle: Text(
                      'Status: ${'Pending'}',
                      style: BalooStyles.balooregularTextStyle(
                          color: appColorYellow)),
                ),
              )*/
            },
          ),
        );
      }
    );
  }
}
