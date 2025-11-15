import 'package:AccuChat/Constants/assets.dart';
import 'package:AccuChat/Constants/colors.dart';
import 'package:AccuChat/Constants/themes.dart';
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
import '../../../../api/apis.dart';
import '../../../../helper/dialogs.dart';
import '../../../../models/chat_user.dart';
import '../Widgets/broad_cast_card.dart';
import '../Widgets/chat_group_card.dart';
import '../Widgets/chat_user_card.dart';
import '../Controllers/chat_home_controller.dart';
import 'chat_groups.dart';
import 'chat_task_shimmmer.dart';
import 'chats_broadcasts.dart';
import 'create_broadcast_dialog_screen.dart';

class ChatsHomeScreen extends GetView<ChatHomeController> {
  ChatsHomeScreen({super.key});

  ChatHomeController chatHomeController =
      Get.put<ChatHomeController>(ChatHomeController());
  // 5678568900
  @override
  Widget build(BuildContext context) {
    return GetBuilder<ChatHomeController>(
        init: ChatHomeController(),
        builder: (controller) {
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
                    title: controller.isSearching
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
                        : InkWell(
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
                                                size: 18),
                                      ).paddingOnly(left: 4, top: 4),
                                      Text(
                                        (controller.myCompany?.companyName ?? '')
                                            .toUpperCase(),
                                        style: BalooStyles.baloosemiBoldTextStyle(
                                          color: appColorYellow,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ).paddingOnly(left: 4, top: 2),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                    actions: [
                      //search user button
                      IconButton(
                          onPressed: () {
                            controller.isSearching = !controller.isSearching;
                            controller.update();
                          },
                          icon: Icon(controller.isSearching
                                  ? CupertinoIcons.clear_circled_solid
                                  : Icons.search)
                              .paddingOnly(top: 0, right: 10)),

                      PopupMenuButton<String>(
                        padding: EdgeInsets.zero,
                        menuPadding: EdgeInsets.zero,
                        onSelected: (value) {
                          if (value == 'new_group') {
                            showDialog(
                                context: Get.context!,
                                builder: (_) => _groupDialogWidget());
                            // Get.dialog(
                            //   Dialog(
                            //     insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                            //     clipBehavior: Clip.antiAlias,
                            //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            //     child: _groupDialogWidget(), // from above
                            //   ),
                            //   barrierDismissible: true,
                            // );
                          } else if (value == 'new_broadcast') {
                            showDialog(
                                context: Get.context!,
                                builder: (_) => BroadcastCreateDialog());
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
                  floatingActionButton: Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: FloatingActionButton(
                        onPressed: () {
                          // _addChatUserDialog();
                          if (kIsWeb) {
                            Get.toNamed(
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
                  body:/*controller.isLoading?
                  ChatHomeShimmer(itemCount: 12):*/(!controller.isLoading||controller.filteredList!=[])
                      ? RefreshIndicator(
                          backgroundColor: Colors.white,
                          color: appColorGreen,
                          onRefresh: () async =>
                              controller.hitAPIToGetRecentChats(),
                          child: ListView.builder(
                            physics: const AlwaysScrollableScrollPhysics(),
                            itemCount: controller.filteredList.length,
                            controller: controller.scrollController,
                            itemBuilder: (context, index) {
                              final item = controller.filteredList[index];
                              return /*SwipeTo(
                                  iconOnLeftSwipe: Icons.delete_outline,
                                  iconColor: Colors.red,
                                  onLeftSwipe: (detail) async {
                                    if ((item.userCompany?.isGroup == 1) ||
                                        (item.userCompany?.isBroadcast == 1)) {
                                    } else {
                                      final confirm = await showDialog(
                                        context: context,
                                        builder: (_) => AlertDialog(
                                          backgroundColor: Colors.white,
                                          title: Text(
                                              "Remove ${item?.email == null || item?.email == '' ? item?.phone : item?.email}"),
                                          content: const Text(
                                              "Are you sure you want to remove this member from recants?"),
                                          actions: [
                                            TextButton(
                                                onPressed: () => Navigator.pop(
                                                    context, false),
                                                child: const Text("Cancel")),
                                            TextButton(
                                                onPressed: () => Navigator.pop(
                                                    context, true),
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

                                        // await APIs.deleteRecantUserAndChat(item.id);
                                        customLoader.hide();
                                        controller.update();
                                      }
                                    }
                                  },
                                  child: */ChatUserCard(user: item)
                              // )
                              ;
                            },
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
                        )),
            ),
          );
        });
  }

  Widget _buildHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(title,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
              title: Row(
                children: const [
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
