import 'package:AccuChat/Constants/assets.dart';
import 'package:AccuChat/Constants/colors.dart';
import 'package:AccuChat/Constants/themes.dart';
import 'package:AccuChat/Screens/Chat/screens/chat_tasks/Presentation/Views/task_chat_screen.dart';
import 'package:AccuChat/routes/app_routes.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:swipe_to/swipe_to.dart';
import '../../../../../../Services/APIs/api_ends.dart';
import '../../../../../../main.dart';
import '../../../../../../utils/common_textfield.dart';
import '../../../../../../utils/custom_dialogue.dart';
import '../../../../../../utils/custom_flashbar.dart';
import '../../../../../../utils/gradient_button.dart';
import '../../../../../../utils/helper_widget.dart';
import '../../../../../../utils/networl_shimmer_image.dart';
import '../../../../../../utils/text_style.dart';
import '../Controllers/task_home_controller.dart';
import '../Widgets/chat_user_card.dart';
import '../Widgets/chat_user_card_mobile.dart';
import 'chat_task_shimmmer.dart';

class TaskHomeScreen extends GetView<TaskHomeController> {
  TaskHomeScreen({super.key});

  TaskHomeController taskhomec =
      Get.put<TaskHomeController>(TaskHomeController());
  @override
  Widget build(BuildContext context) {
    return GetBuilder<TaskHomeController>(
        init: TaskHomeController(),
        builder: (controller) {
          return GestureDetector(
              //for hiding keyboard when a tap is detected on screen
              onTap: () => FocusScope.of(context).unfocus(),
              child: WillPopScope(
                onWillPop: () {
                  return Future.value(true);
                },
                child: controller.isLoading
                    ? const ChatHomeShimmer(itemCount: 12)
                    : LayoutBuilder(
          builder: (context, constraints) {
          double w = constraints.maxWidth;
                        return Scaffold(
                            appBar: AppBar(
                              automaticallyImplyLeading: false,
                              backgroundColor: Colors.white, // white color
                              elevation: 1, // remove shadow
                              scrolledUnderElevation:
                                  0, // ✨ prevents color change on scroll
                              surfaceTintColor: Colors.white,
                              title:kIsWeb && w>600 ?InkWell(
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
                                            style: BalooStyles.balooboldTitleTextStyle(
                                                color: AppTheme.appColor, size: 16),
                                          ).paddingOnly(left: 4, top: 4),
                                          Text(
                                            (controller.myCompany?.companyName ?? ''),
                                            style: BalooStyles.baloomediumTextStyle(
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
                              ): Obx(() {
                                return controller.isSearching.value
                                    ? TextField(
                                  controller: controller.seacrhCon,
                                  cursorColor: appColorGreen,
                                  decoration: const InputDecoration(
                                      border: InputBorder.none,
                                      hintText: 'Search User ...',
                                      contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                                      constraints: BoxConstraints(maxHeight: 45)),
                                  autofocus: true,
                                  style: const TextStyle(fontSize: 13, letterSpacing: 0.5),
                                  onChanged: (val) {
                                    controller.searchQuery = val;
                                    controller.onSearch(val);
                                  },
                                ).marginSymmetric(vertical: 10)
                                    : InkWell(
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
                                              'Task',
                                              style: BalooStyles.balooboldTitleTextStyle(
                                                  color: AppTheme.appColor, size: 16),
                                            ).paddingOnly(left: 4, top: 4),
                                            Text(
                                              (controller.myCompany?.companyName ?? ''),
                                              style: BalooStyles.baloomediumTextStyle(
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
                                );
                              }),
                              /*title: Obx(() {
                                return controller.isSearching.value
                                    ? TextField(
                                        controller: controller.seacrhCon,
                                        cursorColor: appColorGreen,
                                        decoration: const InputDecoration(
                                            border: InputBorder.none,
                                            hintText:
                                                'Search User, Group & Collection ...',
                                            contentPadding: EdgeInsets.symmetric(
                                                vertical: 0, horizontal: 10),
                                            constraints:
                                                BoxConstraints(maxHeight: 45)),
                                        autofocus: true,
                                        style: const TextStyle(
                                            fontSize: 13, letterSpacing: 0.5),
                                        onChanged: (val) {
                                          controller.searchQuery = val;
                                          controller.onSearch(val);
                                        },
                                      ).marginSymmetric(vertical: 10)
                                    : Row(
                                        children: [
                                          SizedBox(
                                            width: 40,
                                            child: CustomCacheNetworkImage(
                                              "${ApiEnd.baseUrlMedia}${controller.myCompany?.logo ?? ''}",
                                              radiusAll: 100,
                                              height: 40,
                                              width: 40,
                                              defaultImage: appIcon,
                                              borderColor: greyText,
                                              boxFit: BoxFit.cover,
                                            ),
                                          ).paddingAll(4),
                                          Expanded(
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              mainAxisSize: MainAxisSize.min,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  "Tasks",
                                                  style: BalooStyles
                                                      .balooboldTitleTextStyle(
                                                          color: appColorYellow,
                                                          size: 16),
                                                ).paddingOnly(left: 8, top: 4),
                                                Text(
                                                  (controller
                                                          .myCompany?.companyName ??
                                                      ''),
                                                  style: BalooStyles
                                                      .baloomediumTextStyle(
                                                    color: appColorYellow,
                                                  ),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ).paddingOnly(left: 8, top: 2),
                                              ],
                                            ),
                                          ),
                                        ],
                                      );
                              }),*/
                              actions: [
                                //search user button
                                kIsWeb
                                    ? IconButton(
                                        onPressed: () {
                                          if (kIsWeb) {
                                            Get.offNamed(
                                                "${AppRoutes.all_users}?isRecent='false'");
                                          } else {
                                            Get.toNamed(AppRoutes.all_users,
                                                arguments: {"isRecent": 'false'});
                                          }
                                        },
                                        icon: Image.asset(addNewChatPng,
                                            height: 27, width: 27))
                                    : SizedBox(),
                                hGap(10),

                                  kIsWeb && w >600 ?const SizedBox(): hGap(10),
                                  kIsWeb && w > 600?const SizedBox(): Obx(() {
                                  return IconButton(
                                  onPressed: () {
                                  controller.isSearching.value = !controller.isSearching.value;
                                  controller.isSearching.refresh();
                                  if (!controller.isSearching.value) {
                                  controller.searchQuery = '';
                                  controller.onSearch('');
                                  controller.seacrhCon.clear();
                                  }
                                  // controller.update();
                                  },
                                  icon: controller.isSearching.value
                                  ? const Icon(CupertinoIcons.clear_circled_solid)
                                      : Image.asset(searchPng, height: 25, width: 25));
                                  })
                                /*Obx(() {
                                  return IconButton(
                                          onPressed: () {
                                            controller.isSearching.value =
                                                !controller.isSearching.value;
                                            controller.isSearching.refresh();

                                            if (!controller.isSearching.value) {
                                              controller.searchQuery = '';
                                              controller.onSearch('');
                                              controller.seacrhCon.clear();
                                            }
                                            // controller.update();
                                          },
                                          icon: controller.isSearching.value
                                              ? const Icon(CupertinoIcons
                                                  .clear_circled_solid)
                                              : Image.asset(searchPng,
                                                  height: 25, width: 25))
                                      .paddingOnly(top: 0, right: 0);
                                }),*/
                              ],
                            ),

                            //floating button to add new user
                            floatingActionButton: kIsWeb
                                ? const SizedBox()
                                : Padding(
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
                                        backgroundColor: appColorYellow,
                                        child: const Icon(
                                          Icons.add,
                                          color: Colors.white,
                                        )),
                                  ),

                            body: Obx(() {
                              final selected = controller.selectedChat.value;
                              return LayoutBuilder(
                                builder: (context, constraints) {
                                  double w = constraints.maxWidth;

                                  // ---------------- MOBILE ----------------
                                  if (w < 500) {
                                    return _recentTaskBody(
                                        true); // your existing list
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
                                          child: _recentTaskBody(true),
                                        ),
                                      ],
                                    );
                                  }

                                  // ---------------- WEB (Drawer + Recents + ChatScreen) ----------------

                                  return Row(
                                    children: [
                                      SizedBox(
                                          width: 320,
                                          child: _recentTaskBody(false)),
                                      Expanded(
                                        child: selected == null
                                            ? const Center(
                                                child: Text(
                                                    "Select a chat to start messaging"))
                                            : TaskScreen(
                                                taskUser: selected,
                                                showBack: false,
                                              ), // <- correct
                                      ),
                                    ],
                                  );
                                },
                              );
                            }),
                          );
                      }
                    ),
              ));
        });
  }

  Widget _recentTaskBody(bool isWebwidth) {
    return Column(
      children: [
        kIsWeb && !isWebwidth
            ? TextField(
                controller: controller.seacrhCon,
                focusNode: controller.searchFocus,
                autocorrect: true,
                cursorColor: appColorGreen,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Search User, Group & Collection ...',
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 3, horizontal: 10),
                  constraints: const BoxConstraints(maxHeight: 35),
                  suffixIcon: Obx(() {
                    return IconButton(
                        onPressed: () {
                          controller.isSearching.value =
                              !controller.isSearching.value;
                          controller.isSearching.refresh();
                          if (!controller.isSearching.value) {
                            controller.searchQuery = '';
                            controller.onSearch('');
                            controller.seacrhCon.clear();
                            controller.searchFocus.unfocus();
                          }
                        },
                        icon: controller.isSearching.value
                            ? const Icon(CupertinoIcons.clear_circled_solid)
                            : Image.asset(searchPng, height: 25, width: 25));
                  }),
                ),
                autofocus: true,
                style: const TextStyle(fontSize: 13, letterSpacing: 0.5),
                onChanged: (val) {
                  controller.searchQuery = val;
                  controller.isSearching.value = true;
                  controller.onSearch(val);
                  if (val.isEmpty) {
                    controller.isSearching.value = false;
                    controller.searchFocus.unfocus();
                  }
                },
              ).marginSymmetric(vertical: 10, horizontal: 15)
            : const SizedBox(),
        (controller.filteredList ?? []).isEmpty
            ? Center(
                child: InkWell(
                  onTap: () {
                    if (kIsWeb) {
                      Get.toNamed("${AppRoutes.all_users}?isRecent='false'");
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
                      Text('Click to Start New Task ✍️',
                              style: BalooStyles.baloosemiBoldTextStyle(
                                  color: appColorGreen))
                          .paddingAll(12),
                      vGap(12),
                      IconButton(
                          onPressed: () async =>
                              controller.hitAPIToGetRecentTasksUser(),
                          icon: Icon(
                            Icons.refresh,
                            size: 35,
                            color: appColorGreen,
                          )).paddingOnly(right: 8)
                    ],
                  ),
                ),
              )
            : Expanded(
              child: RefreshIndicator(
                  backgroundColor: Colors.white,
                  color: appColorGreen,
                  onRefresh: () async {
                    controller.resetPaginationForNewChat();
                    controller.hitAPIToGetRecentTasksUser();
                  },
                  child: Obx(() {
                    return ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: controller.filteredList.length,
                      controller: controller.scrollController,
                      itemBuilder: (context, index) {
                        final item = controller.filteredList[index];
                        return SwipeTo(
                            iconOnLeftSwipe: Icons.delete_outline,
                            iconColor: Colors.red,
                            onLeftSwipe: (detail) async {
                              final confirm = await showDialog(
                                context: context,
                                builder: (_) => AlertDialog(
                                  backgroundColor: Colors.white,
                                  title: Text(
                                      "Remove ${item.email == null || item.email == '' ? item.phone : item.email}"),
                                  content: const Text(
                                      "Are you sure you want to remove this member from recants?"),
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
                                          style:
                                              BalooStyles.baloosemiBoldTextStyle(
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
                            },
                            child: kIsWeb && !isWebwidth
                                ? ChatUserCard(user: item)
                                : ChatUserCardMobile(user: item));
                      },
                    );
                  })),
            )
      ],
    );
  }

  Widget _buildHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
    );
  }

  _groupDialogWidget() {
    return CustomDialogue(
      title: "Create Group",
      isShowActions: false,
      isShowAppIcon: false,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "Enter group name to create Group",
            style: BalooStyles.baloonormalTextStyle(),
            textAlign: TextAlign.center,
          ),
          /*    vGap(20),
            Container(
              width: Get.width,
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: 'Select Type',
                  hintText: 'Select Type',
                  hintStyle:
                  BalooStyles.baloonormalTextStyle(color: Colors.grey),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade400)),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade400)),
                  labelStyle: BalooStyles.baloonormalTextStyle(),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding:
                  const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: controller.selectedGroupType,
                    hint: Text(
                      "Select Type",
                      style: BalooStyles.baloomediumTextStyle(),
                    ),
                    items: ["Group", "Collection"]
                        .map((String type) => DropdownMenuItem<String>(
                      value: type,
                      child: SizedBox(
                          width: Get.width * .52,
                          child: Text(
                            type,
                            style: BalooStyles.baloomediumTextStyle(),
                          )),
                    ))
                        .toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        controller.selectedGroupType = newValue;
                        controller.update();
                      }
                    },
                    dropdownColor: Colors.white,
                  ),
                ),
              ),
            ),*/
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
                controller.createGroupBroadcastApi(
                    isGroup: "1", isBroadcast: '0');
              } else {
                errorDialog("Please enter group name");
              }
            },
          )
        ],
      ),
      onOkTap: () {},
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
