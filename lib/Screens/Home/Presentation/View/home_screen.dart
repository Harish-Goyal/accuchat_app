import 'package:AccuChat/Constants/assets.dart';
import 'package:AccuChat/Constants/themes.dart';
import 'package:AccuChat/Screens/Chat/screens/profile_screen.dart';
import 'package:AccuChat/Screens/Home/Presentation/Controller/home_controller.dart';
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
import '../../../Chat/api/apis.dart';
import '../../../Chat/models/chat_user.dart';
import '../../../Chat/widgets/chat_group_card.dart';
import '../../../Chat/widgets/chat_user_card.dart';
import 'invite_member.dart';
class HomeScreen extends StatefulWidget {
  HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DashboardController controller = Get.find();

  DateTime? currentBackPressTime;

  Future<bool> onWillPop() {
    DateTime now = DateTime.now();
    if (currentBackPressTime == null ||
        now.difference(currentBackPressTime??DateTime.now()) > Duration(seconds: 2)) {
      currentBackPressTime = now;
      toast( "Press again to exit the app!");
      return Future.value(false);
    }
    return Future.value(true);
  }




  @override
  Widget build(BuildContext context) {
    return WillPopScope( onWillPop: onWillPop,
      child: Scaffold(
        body: GetBuilder<DashboardController>(
            builder: (controller) {
              return  SafeArea(
                child: Padding(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 15.0),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        vGap(0),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: InkWell(
                                onTap: (){
                                  Get.to(()=>ProfileScreen(user: APIs.me));
                                },
                                child: Row(
                                  children: [

                                    SizedBox(
                                      width:mq.height * .06,
                                      child: CustomCacheNetworkImage(

                                        APIs.me.image,defaultImage: userIcon,
                                        radiusAll: mq.height * .25,
                                        height: 50,
                                        boxFit: BoxFit.cover,
                                      ),
                                    ).paddingAll(4),
                                    const SizedBox(width: 8),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Hello, ${APIs.me.name!='null'?APIs.me.name:'AccuChat User'}!',
                                          style: BalooStyles.balooboldTextStyle(size: 15),
                                        ),
                                        vGap(5),
                                        Text(
                                          'Welcome back to AccuChat',
                                          style: BalooStyles.balooregularTextStyle(),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            CustomCacheNetworkImage(
                              height: 50,
                              width:  50,
                              boxFit: BoxFit.cover,
                              radiusAll: 100,
                              APIs.me.selectedCompany?.logoUrl??"",
                              defaultImage:appIcon,
                              borderColor: greyColor,
                            ),
                          ],
                        ),
                        vGap(30),
                        // Chats Section
                        Row(
                          children: [
                            InkWell(
                              onTap: controller.refreshChats,
                              child: const SectionHeader(
                                title: 'Recents ',
                                icon: chaticon,
                                // coloricon: Colors.blue,
                              ).paddingSymmetric(vertical: 4,),
                            ),
                            InkWell(
                              onTap: (){
                                controller.updateIndex(1);
                                setState(() {
                                  isTaskMode =false;
                                });
                              },
                                child: Text("Chats",style: BalooStyles.baloosemiBoldTextStyle(),)),
                            InkWell(
                              onTap: (){
                                controller.updateIndex(2);
                                setState(() {
                                  isTaskMode =true;
                                });
                              },
                              child: Text(" /Tasks",style: BalooStyles.baloosemiBoldTextStyle())),
                          ],
                        ),
                        vGap(10),
                        RefreshIndicator(
                          onRefresh: controller.refreshChats,
                          child: SizedBox(
                            height: Get.height*.5,
                            child: FutureBuilder<List<Map<String, dynamic>>>(
                              future: controller.futureChats,
                              initialData: controller.initData,
                              builder: (context, snapshot) {
                                if (snapshot.connectionState == ConnectionState.waiting) {
                                  return const Center(child: IndicatorLoading());
                                }

                                final chats = snapshot.data ?? [];
                                controller.length = chats.length;



                                if (chats.isEmpty) {
                                  return const Center(child: Text("No recent chats"));
                                }

                                return ListView.builder(
                                  padding: EdgeInsets.zero,
                                  itemCount: chats.length,
                                  itemBuilder: (context, index) {
                                    // final chat = chats[index];
                                    // final ChatUser user = chat['user'];
                                    // final msg = chat['lastMessage'];

                                    final chat = chats[index];
                                    final msg = chat['lastMessage'];

                                    if (chat['type'] == 'user') {
                                      final ChatUser user = chat['user'];
                                      // return ListTile(
                                      //   title: Text(user.name),
                                      //   subtitle: Text(msg.msg, maxLines: 1),
                                      //   onTap: () => Navigator.push(
                                      //     context,
                                      //     MaterialPageRoute(builder: (_) => ChatScreen(user: user)),
                                      //   ),
                                      // );
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
                        ),
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
                            *//*APIs.me?.role.toString()=='admin'?
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
                            ):SizedBox(),*//*
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
                                  *//*Get.dialog(
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
                                  );*//*
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
            }
        ),
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
  final VoidCallback onTap;
  final VoidCallback? subtitleTap;
  Color? cardColor;
  final Widget? trailWidget;

   ChatCard(
      { this.leadIcon,
        required this.title,
        this.trailWidget,
        this.cardColor,
        this.iconWidget,
        required this.subtitle,
        this.subtitleTap,
        required this.onTap
      });

  @override
  Widget build(BuildContext context) {
    return CustomContainer(
      vPadding: 8,
      hPadding: 10,
      color: cardColor??Colors.white,
      childWidget: ListTile(
        leading: iconWidget??Image.asset(
          leadIcon??'',
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
          onTap: subtitleTap ??(){},
          child: Text(
            subtitle,
            style: BalooStyles.baloonormalTextStyle(),
          )
        ).paddingOnly(top: 8,right: 5,bottom: 5,left: 5),
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