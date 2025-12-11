import 'package:AccuChat/Constants/assets.dart';
import 'package:AccuChat/Constants/colors.dart';
import 'package:AccuChat/Constants/themes.dart';
import 'package:AccuChat/Screens/Chat/screens/chat_tasks/Presentation/Controllers/chat_screen_controller.dart';
import 'package:AccuChat/Screens/Chat/screens/chat_tasks/Presentation/Controllers/task_home_controller.dart';
import 'package:AccuChat/Screens/Chat/screens/chat_tasks/Presentation/Views/chat_screen.dart';
import 'package:AccuChat/routes/app_routes.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:swipe_to/swipe_to.dart';
import '../../../../../../Constants/app_theme.dart';
import '../../../../../../Services/APIs/api_ends.dart';
import '../../../../../../main.dart';
import '../../../../../../utils/common_textfield.dart';
import '../../../../../../utils/custom_dialogue.dart';
import '../../../../../../utils/custom_flashbar.dart';
import '../../../../../../utils/gradient_button.dart';
import '../../../../../../utils/helper_widget.dart';
import '../../../../../../utils/networl_shimmer_image.dart';
import '../../../../../../utils/text_style.dart';
import '../../../../../Home/Presentation/Controller/company_service.dart';
import '../../../../../Home/Presentation/Controller/socket_controller.dart';
import '../../../../../Home/Presentation/View/main_screen.dart';
import '../../../../api/apis.dart';
import '../../../../helper/dialogs.dart';
import '../../../../models/chat_user.dart';
import '../../../../models/get_company_res_model.dart';
import '../Widgets/broad_cast_card.dart';
import '../Widgets/chat_group_card.dart';
import '../Widgets/chat_user_card.dart';
import '../Controllers/chat_home_controller.dart';
import '../Widgets/chat_user_card_mobile.dart';
import 'chat_groups.dart';
import 'chat_task_shimmmer.dart';
import 'chats_broadcasts.dart';
import 'create_broadcast_dialog_screen.dart';

class ChatsHomeScreen extends GetView<ChatHomeController> {
  ChatsHomeScreen({super.key});

  ChatHomeController chatHomeController =
      Get.put<ChatHomeController>(ChatHomeController());

  @override
  Widget build(BuildContext context) {

    return GestureDetector(
      //for hiding keyboard when a tap is detected on screen
      onTap: () => FocusScope.of(context).unfocus(),
      child: WillPopScope(
        //if search is on & back button is pressed then close search
        //or else simple close current screen on back button click
        onWillPop: () {
          // if (_isSearching) {
          //   setState(() {
          //     _isSearching = !_isSearching;
          //   });
          //   return Future.value(false);
          // } else {
          //   return Future.value(true);
          // }
          return Future.value(true);
        },
        child:/*controller.isLoading?ChatHomeShimmer(itemCount: 12):*/ Scaffold(
                //app bar
                // backgroundColor: isTaskMode?appColorYellow.withOpacity(.05):Colors.white,
                appBar: AppBar(
                  automaticallyImplyLeading: false,
                  backgroundColor: Colors.white,   // white color
                  elevation: 1,                    // remove shadow
                  scrolledUnderElevation: 0,       // ✨ prevents color change on scroll
                  surfaceTintColor: Colors.white,
                  title: Obx(
                    () {
                      if (controller.loadingCompany.value) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      return controller.isSearching.value
                          ? TextField(
                                  controller: controller.seacrhCon,
                                  cursorColor: appColorGreen,
                                  decoration: const InputDecoration(
                                      border: InputBorder.none,
                                      hintText: 'Search User, Group & Collection ...',
                                      contentPadding: EdgeInsets.symmetric(
                                          vertical: 0, horizontal: 10),
                                      constraints: BoxConstraints(maxHeight: 45)),
                                  autofocus: true,
                                  style: const TextStyle(
                                      fontSize: 13, letterSpacing: 0.5),
                                  onChanged: (val) {
                                    controller.searchQuery = val;
                                    controller.onSearch(val);
                                  },
                                ).marginSymmetric(vertical: 10)
                          :

                   /*   DropdownButtonHideUnderline(

                        child: DropdownButton<CompanyData>(
                          borderRadius: BorderRadius.circular(12),
                          value: controller.selectedCompany.value,
                          isExpanded: true,

                          icon: const Icon(Icons.arrow_drop_down),
                          dropdownColor: Colors.white,
                          items: controller.joinedCompaniesList.map((company) {
                            return DropdownMenuItem<CompanyData>(
                              value: company,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SizedBox(
                                    width: 40,
                                    child: CustomCacheNetworkImage(
                                      "${ApiEnd.baseUrlMedia}${company?.logo ?? ''}",
                                      radiusAll: 100,
                                      height: 40,
                                      width: 40,
                                      borderColor: appColorYellow,

                                      defaultImage: appIcon,
                                      boxFit: BoxFit.cover,
                                    ),
                                  ),
                                  hGap(10),
                                  Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Chats',
                                        style:
                                        BalooStyles.balooboldTitleTextStyle(
                                            color: AppTheme.appColor,
                                            size: 16),
                                      ).paddingOnly(left: 0, top: 4,bottom: 4),
                                      Text(
                                        (company?.companyName ?? '')
                                            .toUpperCase(),
                                        style: BalooStyles.baloomediumTextStyle(
                                            color: appColorYellow,
                                            size:12
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: (CompanyData? companyData) async {
                            if (companyData == null) return;

                            controller.selectedCompany.value = companyData;
                            controller.update();

                            // --- 🔥 YOUR CHANGE LOGIC ---
                            customLoader.show();

                            controller.hitAPIToGetSentInvites(
                              companyData: companyData,
                              isMember: false,
                            );

                            final svc = CompanyService.to;
                            await svc.select(companyData);

                            controller.getCompany();

                            await APIs.refreshMe(companyId: companyData?.companyId??0);

                            Get.find<SocketController>()
                                .connectUserEmitter(companyData.companyId);

                            controller.resetPaginationForNewChat();
                            controller.hitAPIToGetRecentChats();


                            // Get.find<ChatScreenController>().getArguments();
                            //
                            // if (kIsWeb) {
                            //   Get.find<ChatScreenController>().user = Get.find<ChatHomeController>().selectedChat.value;
                            //   // _initScroll();
                            // }
                            // Get.find<ChatScreenController>().onInit();

                            Get.find<ChatHomeController>().update();
                            Get.find<ChatScreenController>().update();
                            customLoader.hide();
                          },
                        ),
                      )*/

                      InkWell(
                        hoverColor: Colors.transparent,
                              onTap: () {
                                Get.toNamed(AppRoutes.all_settings);
                              },
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: 40,
                                    child: CustomCacheNetworkImage(
                                      "${ApiEnd.baseUrlMedia}${controller.myCompany?.logo ?? ''}",
                                      radiusAll: 100,
                                      height: 40,
                                      width: 40,
                                      borderColor: appColorYellow,

                                      defaultImage: appIcon,
                                      boxFit: BoxFit.cover,
                                    ),
                                  ).paddingAll(3),
                                  Expanded(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Chats',
                                          style:
                                              BalooStyles.balooboldTitleTextStyle(
                                                  color: AppTheme.appColor,
                                                  size: 16),
                                        ).paddingOnly(left: 4, top: 4),
                                        Text(
                                          (controller.myCompany?.companyName ?? '')
                                              .toUpperCase(),
                                          style: BalooStyles.baloomediumTextStyle(
                                            color: appColorYellow,
                                            size:12
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ).paddingOnly(left: 4, top: 2),
                                      ],
                                    ),
                                  ),


                                ],
                              ),
                            );
                    }
                  ),
                  actions: [
                   kIsWeb? IconButton(
                        onPressed: () {
                          if (kIsWeb) {
                            Get.offNamed(
                                "${AppRoutes.all_users}?isRecent='false'");
                          } else {
                            Get.toNamed(AppRoutes.all_users,
                                arguments: {"isRecent": 'false'});
                          }
                        },
                        icon: Image.asset(addNewChatPng,height:27,width:27)):const SizedBox(),
                    hGap(10),
                    Obx(
                       () {
                        return IconButton(
                            onPressed: () {
                              controller.isSearching.value = !controller.isSearching.value;
                              controller.isSearching.refresh();

                              if(!controller.isSearching.value){
                                controller.searchQuery = '';
                                controller.onSearch('');
                                controller.seacrhCon.clear();
                              }
                              // controller.update();
                            },
                            icon:  controller.isSearching.value?  const Icon(
                                CupertinoIcons.clear_circled_solid)
                                : Image.asset(searchPng,height:25,width:25)
                                ).paddingOnly(top: 0, right: 0);
                      }
                    ),

                    PopupMenuButton<String>(
                      padding: EdgeInsets.zero,
                      menuPadding: EdgeInsets.zero,
                      onSelected: (value) {
                        if (value == 'new_group') {
                          showDialog(
                              context: Get.context!,
                              builder: (_) => _groupDialogWidget());
                        } else if (value == 'new_broadcast') {
                          showDialog(
                              context: Get.context!,
                              builder: (_) => BroadcastCreateDialog());
                        }else if (value == 'settings') {
                            Get.toNamed(AppRoutes.all_settings);
                        }
                      },
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 'new_group',
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.group,
                                size: 17,
                                color: appColorGreen,
                              ),
                              hGap(5),
                              Text(
                                'Create Group',
                                style: themeData.textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'new_broadcast',
                          child:
                              Row(mainAxisSize: MainAxisSize.min, children: [
                            Image.asset(
                              broadcastIcon,
                              height: 15,
                              color: appColorYellow,
                            ),
                            hGap(5),
                            Text(
                              'Create Broadcast',
                              style: themeData.textTheme.bodySmall,
                            )
                          ]),
                        ),
                        PopupMenuItem(
                          value: 'settings',
                          child:
                              Row(mainAxisSize: MainAxisSize.min, children: [
                            Image.asset(
                              settingPng,
                              height: 15,
                              color: Colors.black87,
                            ),
                            hGap(5),
                            Text(
                              'Settings',
                              style: themeData.textTheme.bodySmall,
                            )
                          ]),
                        ),
                      ],
                      color: Colors.white,
                      icon: const Icon(Icons.more_vert),
                    ),
                    //more features button
                    /*IconButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => ProfileScreen(user: APIs.me)));
                    },
                    icon: const Icon(Icons.person))*/
                  ],
                ),

                //floating button to add new user
                floatingActionButton:kIsWeb?const SizedBox(): Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: FloatingActionButton(
                      onPressed: () {
                        // _addChatUserDialog();
                        if (kIsWeb) {
                          Get.offNamed(
                              "${AppRoutes.all_users}?isRecent='false'");
                        } else {
                          Get.toNamed(AppRoutes.all_users,
                              arguments: {"isRecent": 'false'});
                        }
                      },
                      backgroundColor: appColorGreen,
                      child: const Icon(
                        Icons.add,
                        color: Colors.white,
                      )),
                ),

              body: Obx(
                 () {
                   final selected = controller.selectedChat.value;
                  return LayoutBuilder(
                    builder: (context, constraints) {
                      double w = constraints.maxWidth;

                      // ---------------- MOBILE ----------------
                      if (w < 500) {
                        return _recentChatsList(controller,true,w);  // your existing list
                      }

                      // ---------------- TABLET (Drawer + Recents) ----------------
                      if (w < 600) {
                        return Row(
                          children: [
                            // SizedBox(
                            //   width: 250,
                            //   child: buildSideNav(dashboardController),   // <--- add your drawer here
                            // ),
                            Expanded(
                              child: _recentChatsList(controller,true,w),
                            ),
                          ],
                        );
                      }

                      // ---------------- WEB (Drawer + Recents + ChatScreen) ----------------

                        return Row(
                          children: [
                            SizedBox(width: 320, child: _recentChatsList(controller,false,w)),

                            Expanded(
                              child: selected == null
                                  ? const Center(child: Text("Select a chat to start messaging"))
                                  : ChatScreen(user: selected,showBack: false,),   // <- correct
                            ),
                          ],
                        );


                    },
                  );
                }
              ),


            ),
      ),
    );
  }

  Widget _recentChatsList(ChatHomeController controller,bool isWebwidth,double width) {
    return (controller.filteredList!=[])
        ? RefreshIndicator(
      backgroundColor: Colors.white,
      color: appColorGreen,
      onRefresh: () async =>
          controller.hitAPIToGetRecentChats(),
      child: Obx(
        () {
          return ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: controller.filteredList.length,
            padding: EdgeInsets.zero,
            controller: controller.scrollController,
            itemBuilder: (context, index) {
              final item = controller.filteredList[index];
              return  kIsWeb && !isWebwidth?ChatUserCard(user: item):ChatUserCardMobile(user: item);
            },
          );
        }
      ),
    )
        : Center(
      child: InkWell(
        onTap: () {
          if (kIsWeb) {
            Get.toNamed(
                "${AppRoutes.all_users}?isRecent='false'");
          } else {
            Get.toNamed(AppRoutes.all_users,
                arguments: {"isRecent": 'false'});
          }
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              emptyRecentPng,
              height: 90,
            ),
            Text('Click to Start new Chat 👋',
                style:
                BalooStyles.baloosemiBoldTextStyle(
                    color: appColorGreen))
                .paddingAll(12),

            vGap(12),
            IconButton(onPressed: () async => controller.hitAPIToGetRecentChats(), icon: Icon(Icons.refresh,size: 35,color: appColorGreen,)).paddingOnly(right: 8)

          ],
        ),
      ),
    );
  }


  Widget _buildHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
    );
  }

  Widget _groupDialogWidget() {
    // Reuse your original body so it's easy to maintain
    Widget _dialogBody() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "Enter group name to create Group",
            style: BalooStyles.baloonormalTextStyle(),
            textAlign: TextAlign.center,
          ),
          vGap(20),
          CustomTextField(
            hintText: "Group Name",
            controller: controller.groupController,
            focusNode: FocusNode(),
            onFieldSubmitted: (String? value) {
              FocusScope.of(Get.context!).unfocus();
            },
            labletext: "Group Name",
          ),
          vGap(30),
          GradientButton(
            name: "Submit",
            btnColor: AppTheme.appColor,
            vPadding: 8,
            onTap: () {
              if (controller.groupController.text.isNotEmpty) {
                controller.createGroupBroadcastApi(isGroup: "1", isBroadcast: '0');
              } else {
                errorDialog("Please enter group name");
              }
            },
          )
        ],
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;

        // Responsive target width
        double targetMaxWidth;
        if (w >= 1400) {
          targetMaxWidth = 560;       // big desktop
        } else if (w >= 900) {
          targetMaxWidth = 520;       // desktop/tablet landscape
        } else if (w >= 600) {
          targetMaxWidth = 480;       // tablet portrait
        } else {
          targetMaxWidth = w * 0.9;   // phones: take ~90% width
        }

        return Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: targetMaxWidth,
              minWidth: 280,
            ),
            child: Material( // ensure proper elevation/shape if CustomDialogue is plain
              type: MaterialType.transparency,
              child: CustomDialogue(
                title: "Create Group",
                isShowAppIcon: false,
                // In case content grows, let it scroll
                content: SingleChildScrollView(child: _dialogBody()),
                onOkTap: () {},
              ),
            ),
          ),
        );
      },
    );
  }


  // for adding new chat user
  void _addChatUserDialog() {
    String email = '';

    showDialog(
        context: Get.context!,
        builder: (_) => AlertDialog(
              contentPadding: const EdgeInsets.only(
                  left: 24, right: 24, top: 20, bottom: 10),

              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),

              //title
              title: const Row(
                children: [
                  Icon(
                    Icons.person_add,
                    color: Colors.blue,
                    size: 28,
                  ),
                  Text('  Add User')
                ],
              ),

              //content
              content: TextFormField(
                maxLines: null,
                onChanged: (value) => email = value,
                decoration: InputDecoration(
                    hintText: 'Email Id',
                    prefixIcon: const Icon(Icons.email, color: Colors.blue),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15))),
              ),

              //actions
              actions: [
                //cancel button
                MaterialButton(
                    onPressed: () {
                      //hide alert dialog
                      Get.back();
                    },
                    child: const Text('Cancel',
                        style: TextStyle(color: Colors.blue, fontSize: 16))),

                //add button
                MaterialButton(
                    onPressed: () async {
                      //hide alert dialog
                      Get.back();
                      // if (email.isNotEmpty) {
                      //   await APIs.addChatUser(email).then((value) {
                      //     if (!value) {
                      //       Dialogs.showSnackbar(
                      //           Get.context!, 'User does not Exists!');
                      //     }
                      //   });
                      // }
                    },
                    child: const Text(
                      'Add',
                      style: TextStyle(color: Colors.blue, fontSize: 16),
                    ))
              ],
            ));
  }
}
