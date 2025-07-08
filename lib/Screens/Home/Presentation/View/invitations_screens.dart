import 'package:AccuChat/Constants/colors.dart';
import 'package:AccuChat/Screens/Chat/api/apis.dart';
import 'package:AccuChat/main.dart';
import 'package:AccuChat/utils/text_style.dart';
import 'package:flutter/material.dart';
import 'package:swipe_to/swipe_to.dart';

import '../../../Chat/models/invite_model.dart';

class InvitationsScreen extends StatefulWidget {
  @override
  _InvitationsScreenState createState() => _InvitationsScreenState();

  String comapnyID;

  InvitationsScreen({super.key,required this.comapnyID});
}

class _InvitationsScreenState extends State<InvitationsScreen> {
  late Future<List<InvitationModel>> invitationsFuture;

  @override
  void initState() {
    super.initState();
    initData();
    // Assuming you have selectedCompanyId available from your APIs or state management
  }

  bool isLoading = true;
  initData() async {
    invitationsFuture = APIs.getInvitations(widget.comapnyID);
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
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
              initData();
              // You can call the resend invite function here
            },
          )
        ],
      ),
      body: FutureBuilder<List<InvitationModel>>(
        future: invitationsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }


          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No invitations found.'));
          }

          final invitations = snapshot.data!;

          return ListView.builder(
            itemCount: invitations.length,
            itemBuilder: (context, index) {
              final invitation = invitations[index];
              print('sda');
              print(invitation.name);

              return SwipeTo(
                iconOnLeftSwipe: Icons.delete_outline,
                iconColor: Colors.red,
                onLeftSwipe: (detail) async {

                  final confirm = await showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      backgroundColor: Colors.white,
                      title: Text(
                          "Remove ${invitation.name}"),
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
                    customLoader.show();
                    await APIs.deleteInvitation(invitation.id).then((v){
                      if(v){
                        customLoader.hide();
                        initData();
                      }
                    }).onError((v,e){
                      customLoader.hide();
                    });
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
                          invitation.name == '' ||
                                  invitation.name == null ||
                                  invitation.name == 'null'
                              ? invitation.email!
                              : invitation.name ?? '',
                          style: BalooStyles.baloosemiBoldTextStyle()),
                      Text(
                          invitation.email == '' ||
                                  invitation.email == null ||
                                  invitation.email == 'null'
                              ? invitation.email!
                              : invitation.email ?? '',
                          style: BalooStyles.baloosemiBoldTextStyle()),
                    ],
                  ),
                  subtitle: Text(
                      'Status: ${invitation.isAccepted ? 'Accepted' : 'Pending'}',
                      style: BalooStyles.balooregularTextStyle(
                          color: invitation.isAccepted
                              ? appColorGreen
                              : appColorYellow)),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
