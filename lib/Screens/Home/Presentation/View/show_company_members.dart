import 'package:AccuChat/Constants/colors.dart';
import 'package:AccuChat/Screens/Chat/api/apis.dart';
import 'package:AccuChat/main.dart';
import 'package:AccuChat/utils/loading_indicator.dart';
import 'package:AccuChat/utils/text_style.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:swipe_to/swipe_to.dart';

import '../../../../utils/custom_flashbar.dart';
import '../../../../utils/data_not_found.dart';
import '../../../../utils/helper_widget.dart';
import '../../../Chat/models/chat_user.dart';
import '../../../Chat/models/company_model.dart';
import '../../../Chat/models/invite_model.dart';

class CompanyMembers extends StatefulWidget {
  @override
  _CompanyMembersState createState() => _CompanyMembersState();

  String comapnyID;
  String comapnyName;

  CompanyMembers({super.key,required this.comapnyID,required this.comapnyName});
}

class _CompanyMembersState extends State<CompanyMembers> {
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
        leadingWidth: 30,
        title: Text(
          '${widget.comapnyName} Members',
          style: BalooStyles.balooboldTitleTextStyle(),

        ),
      ),
      body: buildCompanyMembersList(),
    );
  }


  Widget buildCompanyMembersList() {
    return Container(
      height: Get.height,
      padding: EdgeInsets.symmetric(horizontal: 10),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FutureBuilder<List<ChatUser>>(
              future: APIs.getCompanyMembers2(widget.comapnyID),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const SizedBox(height: 40, child: SizedBox());
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return IndicatorLoading();
                }

                if (snapshot.hasError) {
                  return SizedBox(
                      height: 40, child: Text(snapshot.error.toString()));
                }

                final members = snapshot.data!;
                print( members.length);
                print(widget.comapnyID);
                return members.isEmpty
                    ? DataNotFoundText()
                    : FutureBuilder<List<CompanyModel>>(
                    future: APIs.fetchJoinedCompanies(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return SizedBox();
                      final companies = snapshot.data!;
                      return ListView.separated(
                        itemCount: members.length,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
                          final user = members[index];
                          return SwipeTo(
                            iconOnLeftSwipe: Icons.delete_outline,
                            iconColor: Colors.red,
                            onLeftSwipe: /*(((APIs.me.selectedCompany!.createdBy == user.id) ))
                                    ? (de) {
                                  if(user.role
                                      != 'admin') {
                                    errorDialog("Not Allowed Delete!");
                                  }else{
                                    errorDialog("You cannot delete company here!");
                                  }
                                }
                                    :*/
                                (detail) async {
                              if (APIs.me.role != 'admin') {
                                // Show message that the user is not allowed to remove members if they are not admin
                                toast(
                                  "You don't have permission to remove members.",
                                );
                                return; // Exit if the user is not an admin
                              }

                              // 2. Check if the logged-in user is trying to remove themselves
                              if (APIs.me.id == user.id) {
                                // Show message that the admin cannot remove themselves
                                toast(
                                  "You cannot remove yourself from the company.",
                                );
                                return; // Exit if the user is trying to remove themselves
                              }
                              // Step 3: Check if the logged-in user is an admin of the selected company
                              bool isAdminOfCompany = false;
                              CompanyModel selectedCompany;

                              // Check if the logged-in user is an admin of the selected company
                              for (var company in companies) {
                                if (company.id == widget.comapnyID) {
                                  selectedCompany = company;
                                  if (company.adminUserId == APIs.me.id) {
                                    isAdminOfCompany = true;
                                  }
                                  break;
                                }
                              }

                              if (!isAdminOfCompany) {
                                // Logged-in user is not an admin of the selected company
                                toast(
                                  "You must be an admin of the company to remove members.",
                                );
                                return;
                              }

                              // Step 4: If the logged-in user is an admin, ensure they are not trying to remove the company creator
                              if (APIs.me.selectedCompany?.adminUserId ==
                                  user.id) {
                                // You cannot remove the creator (admin) of the company
                                toast(
                                  "You cannot remove the company creator.",
                                );
                                return;
                              }

                              final confirm = await showDialog(
                                context: context,
                                builder: (_) => AlertDialog(
                                  backgroundColor: Colors.white,
                                  title: Text(
                                      "Remove ${user.email == 'null' || user.email == null || user.email == '' ? user.phone : user.email}"),
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
                                await APIs.removeCompanyMember(
                                    userId: user.id,
                                    companyId: widget.comapnyID,
                                    currentUserId: APIs.me.id,
                                    role: APIs.me.role);
                                setState(() {});
                              }
                            },
                            child: ListTile(
                              dense: true,
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 0),
                              leading: user.name == 'null' ||
                                  user.name == '' ||
                                  user.name == null
                                  ? CircleAvatar(
                                  radius: 15,
                                  backgroundColor:
                                  appColorGreen.withOpacity(.1),
                                  child: Icon(
                                    Icons.person,
                                    size: 15,
                                    color: appColorGreen,
                                  ))
                                  : CircleAvatar(
                                  radius: 15,
                                  backgroundColor:
                                  appColorGreen.withOpacity(.1),
                                  child: Text(user.name[0] ?? '')),
                              title: user.name == 'null' ||
                                  user.name == '' ||
                                  user.name == null
                                  ? Text(
                                user.email.isEmpty ||
                                    user.email == null ||
                                    user.email == 'null'
                                    ? user.phone
                                    : user.email,
                                style:
                                BalooStyles.balooregularTextStyle(),
                              )
                                  : Text(
                                user.name ?? '',
                                style: BalooStyles
                                    .baloosemiBoldTextStyle(),
                              ),
                              subtitle: user.name == 'null' ||
                                  user.name == '' ||
                                  user.name == null
                                  ? const SizedBox(
                                height: 0,
                              )
                                  : Text(
                                user.email.isEmpty ||
                                    user.email == null ||
                                    user.email == 'null'
                                    ? user.phone
                                    : user.email,
                                style:
                                BalooStyles.balooregularTextStyle(),
                              ),
                              trailing: (user.id == APIs.me.id && user.id != APIs.me.selectedCompany?.adminUserId)
                                  ? Text(
                                "You",
                                style: BalooStyles
                                    .baloonormalTextStyle(),
                              )
                                  :(user.id == APIs.me.selectedCompany?.adminUserId)?Text(
                                "Creator",
                                style: BalooStyles
                                    .baloonormalTextStyle(color:appColorGreen),
                              ): const SizedBox(),
                              /*trailing: IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () async {
                                final confirm = await showDialog(
                                  context: context,
                                  builder: (_) => AlertDialog(
                                    title: Text("Remove ${user.name}?"),
                                    content: Text("Are you sure you want to remove this member?"),
                                    actions: [
                                      TextButton(onPressed: () => Navigator.pop(context, false), child: Text("Cancel")),
                                      TextButton(onPressed: () => Navigator.pop(context, true), child: Text("Remove")),
                                    ],
                                  ),
                                );

                                if (confirm == true) {
                                  await APIs.removeCompanyMember(user.id, companyId);
                                }
                              },
                            ),*/
                            ),
                          );
                        },
                        separatorBuilder: (BuildContext context, int index) {
                          return divider().marginSymmetric(horizontal: 20);
                        },
                      );
                    });
              },
            ),
          ],
        ),
      ),
    );
  }
}
