import 'package:AccuChat/Constants/assets.dart';
import 'package:AccuChat/Constants/themes.dart';
import 'package:AccuChat/Screens/Home/Presentation/View/profile_screen.dart';
import 'package:AccuChat/Screens/Home/Presentation/Controller/home_controller.dart';
import 'package:AccuChat/Services/APIs/api_ends.dart';
import 'package:AccuChat/routes/app_routes.dart';
import 'package:AccuChat/utils/custom_container.dart';
import 'package:AccuChat/utils/helper_widget.dart';
import 'package:AccuChat/utils/loading_indicator.dart';
import 'package:AccuChat/utils/networl_shimmer_image.dart';
import 'package:AccuChat/utils/text_style.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../Constants/colors.dart';
import '../../../../main.dart';
import '../../../../utils/custom_dialogue.dart';
import '../../../../utils/custom_flashbar.dart';
import '../../../../utils/data_not_found.dart';
import '../../../Chat/api/apis.dart';
import '../../../Chat/models/chat_user.dart';
import '../../../Chat/screens/auth/Presentation/Controllers/accept_invite_controller.dart';
import '../../../Chat/screens/chat_tasks/Presentation/Widgets/chat_group_card.dart';
import '../../../Chat/screens/chat_tasks/Presentation/Widgets/chat_user_card.dart';
import 'invite_member.dart';

class HomeScreen extends GetView<DashboardController> {
  HomeScreen({super.key});

  AcceptInviteController acceptInviteController = Get.put(AcceptInviteController());
  @override
  Widget build(BuildContext context) {
    Get.lazyPut(() => DashboardController(), fenix: true);
    return WillPopScope(
      onWillPop: controller.onWillPop,
      child: Scaffold(
        body: GetBuilder<DashboardController>(
            builder: (controller) {
              return SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 15.0),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: InkWell(
                                onTap: () {
                                  Get.toNamed(AppRoutes.all_settings);
                                },
                                child: Row(
                                  children: [
                                    SizedBox(
                                      width: mq.height * .06,
                                      child: CustomCacheNetworkImage(
                                        "${ApiEnd.baseUrlMedia}${controller.userData.userImage??''}",
                                        defaultImage: userIcon,
                                        radiusAll: mq.height * .25,
                                        height: 50,
                                        boxFit: BoxFit.cover,
                                        borderColor: greyText,
                                      ),
                                    ).paddingAll(4),
                                    const SizedBox(width: 8),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Hello, ${controller.userData?.userCompany?.displayName != null ?controller.userData?.userCompany?.displayName : 'AccuChat User'}!',

                                          style: BalooStyles.baloosemiBoldTextStyle(
                                              ),
                                        ),
                                        vGap(5),
                                        Text(
                                          'Welcome back to AccuChat',
                                          style: BalooStyles
                                              .balooregularTextStyle(),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            hGap(20),
                            CustomCacheNetworkImage(
                              height: 50,
                              width: 50,
                              boxFit: BoxFit.cover,
                              radiusAll: 100,
                              // APIs.me.selectedCompany?.logoUrl ?? "",
                              "${ApiEnd.baseUrlMedia}${controller.myCompany?.logo??''}"
                              ,
                              defaultImage: appIcon,
                              borderColor: greyColor,
                            ),
                          ],
                        ),
                        vGap(15),
                        // Chats Section

                        GetBuilder<AcceptInviteController>(
                            builder: (controller) {
                              return controller.pendingInvitesList.isEmpty?Center(
                                  child: SizedBox()):
                              SizedBox(
                                height: Get.height*.2,
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: controller.pendingInvitesList.length,
                                  itemBuilder: (context, i) {
                                    final invites = controller.pendingInvitesList[i];

                                    return SizedBox(
                                      // height: MediaQuery.of(context).size.height * 0.8,
                                      child: CustomContainer(
                                        color: Colors.white,
                                        vPadding: 15,
                                        childWidget: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            SizedBox(
                                                width:50,
                                                child:

                                                CustomCacheNetworkImage(
                                                  invites.company?.logo ?? '',
                                                  height: 50,
                                                  width: 50,
                                                  boxFit: BoxFit.cover,
                                                  radiusAll: 100,
                                                  borderColor: greyText,
                                                )),
                                            hGap(10),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    "Invited via, ",
                                                    style: BalooStyles.balooregularTextStyle(),
                                                  ),
                                                  vGap(4),
                                                  Text(
                                                    (invites.company?.companyName ?? '').toUpperCase(),
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                    style: BalooStyles.baloosemiBoldTextStyle(),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            dynamicButton(
                                              btnColor: appColorGreen,
                                              onTap: () async=>  controller.hitAPIToAcceptInvite(invites.inviteId,invites.company?.companyId),
                                              gradient: buttonGradient,
                                              vPad: 8,
                                              name: "Accept",
                                              isShowText: true,
                                              isShowIconText: false,
                                              leanIcon: null,
                                            ).paddingSymmetric(vertical: 8)
                                          ],
                                        ),
                                      ).paddingSymmetric(horizontal: 15, vertical: 12),
                                    );
                                  },
                                ),
                              );
                            }
                        ),

                        Row(
                          children: [
                            InkWell(
                              onTap: controller.refreshChats,
                              child: const SectionHeader(
                                title: 'Recents ',
                                icon: chaticon,
                              ).paddingSymmetric(
                                vertical: 4,
                              ),
                            ),
                            InkWell(
                                onTap: () {
                                  controller.updateIndex(0);
                                  isTaskMode = false;
                                  controller.update();
                                },
                                child: Text(
                                  "Chats",
                                  style: BalooStyles.baloosemiBoldTextStyle(),
                                )),
                            InkWell(
                                onTap: () {
                                  controller.updateIndex(1);

                                  isTaskMode = true;
                                  controller.update();
                                },
                                child: Text(" /Tasks",
                                    style:
                                        BalooStyles.baloosemiBoldTextStyle())),
                          ],
                        ),
                        vGap(10),
                       //TODO
                       /* RefreshIndicator(
                          onRefresh: controller.refreshChats,
                          child: SizedBox(
                            height: Get.height * .5,
                            child: FutureBuilder<List<Map<String, dynamic>>>(
                              future: controller.futureChats,
                              initialData: controller.initData,
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Center(
                                      child: IndicatorLoading());
                                }

                                final chats = snapshot.data ?? [];
                                controller.length = chats.length;

                                if (chats.isEmpty) {
                                  return const Center(
                                      child: Text("No recent chats"));
                                }

                                return ListView.builder(
                                  padding: EdgeInsets.zero,
                                  itemCount: chats.length,
                                  itemBuilder: (context, index) {
                                    final chat = chats[index];
                                    final msg = chat['lastMessage'];
                                    if (chat['type'] == 'user') {
                                      final ChatUser user = chat['user'];

                                      return ChatUserCard(user: user);
                                    } else if (chat['type'] == 'group') {
                                      final ChatGroup group = chat['group'];
                                      return ChatGroupCard(user: group);
                                    }
                                  },
                                );
                              },
                            ),
                          ),
                        ),*/
                        // vGap(25),
                        /*  Row(
                          children: [

                            (controller.initData !=null)?SizedBox():  Expanded(
                              child: dynamicButton(
                                  name: "Start Chatting",
                                  onTap: () {
                                    controller.updateIndex(1);
                                    setState(() {
                                      isTaskMode =false;
                                    });
                                  },
                                  isShowText: true,
                                  isShowIconText: true,
                                  gradient: buttonGradient,

                                  leanIcon: chaticon).paddingOnly(top: 20),
                            ),
                            // APIs.me?.role.toString()=='admin'?   hGap(20):SizedBox(),
                            */ /*APIs.me?.role.toString()=='admin'?
                            Expanded(
                              child: dynamicButton(
                                  name: "Add Member",
                                  onTap: () {
                                    // controller.updateIndex(1);
                                    // setState(() {
                                    //   isTaskMode =false;
                                    // });
                                    Get.to(()=>InviteMembersScreen(company: APIs.me.company, invitedBy: APIs.me.id,));
                                  },
                                  isShowText: true,
                                  isShowIconText: true,
                                  gradient: buttonGradient,
                                  iconColor: Colors.white,
                                  leanIcon: addUserIcon).paddingOnly(top: 20),
                            ):SizedBox(),*/ /*
                          ],
                        ),*/

                        /* const SizedBox(height: 40),
                        // Connected Apps Section
                        const SectionHeader(
                          title: 'Connected Apps',
                          icon: connectedAppIcon,
                        ),
                        FutureBuilder<CompanyModel?>(
                          future: APIs.getUserCompany(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return CircularProgressIndicator();
                            } else if (!snapshot.hasData || snapshot.data == null) {
                              return Text("No company found.");
                            } else {
                              final company = snapshot.data!;
                              return  ChatCard(
                                      leadIcon: connectedAppIcon,
                                      trailWidget: Text(company.name??''),
                                      title: company.email??'',
                                      subtitle: 'members: ${company.members.length}',
                                      onTap: () {});
                            }
                          },
                        ),
                        vGap(25),
                        Align(
                            alignment: Alignment.center,
                            child:  dynamicButton(
                                name: "Connect New App",
                                onTap:  () {
                                  errorDialog("Under Development");
                                  */ /*Get.dialog(
                                    AlertDialog(
                                      title: const Text('Connect New App'),
                                      content: TextField(
                                        decoration: const InputDecoration(hintText: 'Enter App Code'),
                                        onSubmitted: (value) {
                                          controller.connectApp(value);
                                          Get.back();
                                        },
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Get.back(),
                                          child: const Text('Cancel'),
                                        ),
                                      ],
                                    ),
                                  );*/ /*
                                },
                                isShowText: true,
                                isShowIconText: true,
                                gradient: buttonGradient,
                                iconColor: Colors.white,
                                leanIcon: connectedAppIcon)
                        ),*/
                      ],
                    ),
                  ),
                ),
              );
            }),
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  final String title;
  final String icon;
  final Color? coloricon;

  const SectionHeader(
      {super.key, required this.title, required this.icon, this.coloricon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Image.asset(
          icon,
          height: 25,
          color: coloricon ?? null,
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: BalooStyles.balooboldTitleTextStyle(),
        ),
      ],
    );
  }
}

class ChatCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? leadIcon;
  Widget? iconWidget;
  bool isSelected;
  final VoidCallback onTap;
  final VoidCallback? subtitleTap;
  Color? cardColor;
  Color? brcolor;
  final Widget? trailWidget;

  ChatCard(
      {this.leadIcon,
      required this.title,
      this.trailWidget,
      this.cardColor,
      this.iconWidget,
      this.isSelected = false,
      this.brcolor,
      required this.subtitle,
      this.subtitleTap,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 250),
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? brcolor??Colors.transparent : Colors.grey.shade200,
          width: isSelected ? 2 : 1,
        ),
        boxShadow: isSelected
            ? [
          BoxShadow(
            color: Colors.deepPurple.withOpacity(0.12),
            blurRadius: 12,
            offset: Offset(0, 4),
          )
        ]
            : [],
        color: isSelected
            ? brcolor?.withOpacity(0.03)
            : Colors.grey.shade100,
      ),


      child: ListTile(
        horizontalTitleGap: 8,

        // dense: true,
        minLeadingWidth: 55,
        minTileHeight: 60,


        leading: iconWidget ??
            Image.asset(
              leadIcon ?? '',
              height: 18,
            ),
        // trailing: trailWidget??SizedBox(),
        title: title == ""
            ? Align(alignment: Alignment.centerLeft, child: trailWidget)
            : Text(
                title,
                style: BalooStyles.baloosemiBoldTextStyle(),
              ),
        subtitle: InkWell(
            onTap: subtitleTap ?? () {},
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 4),
              width: 100,
              child: Text(
                subtitle,
                style: BalooStyles.baloonormalTextStyle(
                    underLineNeeded: true,
                    color: Colors.blueAccent,
                    deccolor: Colors.blueAccent),
              ),
            )),
        contentPadding: EdgeInsets.zero,
        onTap: onTap,


      ),
    ).marginOnly(bottom: 8, left: 8, right: 8);
  }
}

class AddButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  const AddButton(
      {required this.label, required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        // minimumSize: Size(double.infinity, 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 4,
      ),
    );
  }
}
