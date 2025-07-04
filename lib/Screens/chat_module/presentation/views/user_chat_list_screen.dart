import 'package:AccuChat/Constants/colors.dart';
import 'package:AccuChat/Constants/themes.dart';
import 'package:AccuChat/Screens/chat_module/models/user_chat_list_model.dart';
import 'package:AccuChat/Screens/chat_module/presentation/views/staggered_view.dart';
import 'package:AccuChat/utils/text_style.dart';
import 'package:animated_search_bar/animated_search_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:get/get.dart';

import '../../../../Constants/assets.dart';
import '../../../../Services/APIs/local_keys.dart';
import '../../../../main.dart';
import '../../../../routes/app_routes.dart';
import '../../../../utils/backappbar.dart';
import '../../../../utils/common_textfield.dart';
import '../../../../utils/custom_dialogue.dart';
import '../../../../utils/custom_flashbar.dart';
import '../../../../utils/custom_scaffold.dart';
import '../../../../utils/gradient_button.dart';
import '../../../../utils/helper_widget.dart';
import '../../../../utils/networl_shimmer_image.dart';
import '../../../../utils/product_shimmer_widget.dart';
import '../../../../utils/seachbar_widget.dart';
import '../../models/chat_detail_model.dart';
import '../controllers/user_chat_list_controller.dart';

class UserChatListScreen extends GetView<UserChatListController> {
  const UserChatListScreen({
    Key? key,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return safeAreWidget();
  }

  safeAreWidget() {
    return GetBuilder<UserChatListController>(builder: (controller) {
      return CustomScaffold(
        extendBodyBehindAppBar: true,
        body: _mainBuild(),
        floatingActionButton: FloatingActionButton(
          elevation: 10,
          onPressed: () {
            showDialog(
                context: Get.context!, builder: (_) => _groupDialogWidget());
          },
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
              bottomLeft: Radius.circular(12),
              bottomRight: Radius.circular(12),
            ),
          ),
          backgroundColor: AppTheme.appColor,
          hoverColor: Colors.green,
          tooltip: 'Create Group',
          child: const Icon(
            Icons.add,
            color: Colors.white,
            size: 25,
          ),
        ),
      );
    });
  }

/*  Widget safeAreWidget1() {
    return GetBuilder<UserChatListController>(builder: (controller) {
      return SafeArea(
          child: CustomScaffold(
          body: _mainBuild(),

      ));
    });
  }*/

  _groupDialogWidget() {
    return GetBuilder<UserChatListController>(builder: (controller) {
      return CustomDialogue(
        title: "Create ${controller.selectedGroupType}",
        isShowAppIcon: false,
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Enter ${controller.selectedGroupType?.toLowerCase()} name to create ${controller.selectedGroupType?.toLowerCase()}",
              style: BalooStyles.baloonormalTextStyle(),
              textAlign: TextAlign.center,
            ),
            vGap(20),
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
            ),
            vGap(20),
            CustomTextField(
              hintText: "${controller.selectedGroupType} Name",
              controller: controller.groupController,
              focusNode: FocusNode(),
              onFieldSubmitted: (String? value) {
                FocusScope.of(Get.context!).unfocus();
              },
              labletext: "${controller.selectedGroupType} Name",
            ),
            vGap(30),
            GradientButton(
              name: "Submit",
              btnColor: AppTheme.appColor,
              vPadding: 8,
              onTap: () {
                if (controller.groupController.text.isNotEmpty) {
                  controller.createGroupApi(
                      controller.selectedGroupType == "Group" ? "1" : "0");
                } else {
                  errorDialog("Please enter group name");
                }
              },
            )
          ],
        ),
        onOkTap: () {},
      );
    });
  }

  Widget _mainBuild() {
    // SocketController socketController=  Get.find<SocketController>();
    return SingleChildScrollView(
      controller: controller.scrollController,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
         /* vGap(8),
          Image.asset(
            appIcon,
            height: 15,
          ).paddingSymmetric(horizontal: 15),*/

          vGap(10),
          CustomSearchBarAnimated(
            lable: "Chats",
            searchController: controller.searchUserConroller,
            onChangedVal: (value) {
              controller.searchText = value;
              controller.update();
              // controller.hitApiToGetChatList(searchtext: controller.searchText);
            },
          ).marginSymmetric(horizontal: 15),
          _listView(),
        ],
      ),
    );
  }

  Widget listItemView(
      {required UserChatListData? item, Function()? onChatTap}) {
    String lastMessageTime = item?.lastMessage?.createdAt ?? '';
    String timeAgo = controller.getTimeAgo(lastMessageTime);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.all(Radius.circular(100)),
          child: InkWell(
            borderRadius: BorderRadius.circular(100),
            onTap: () {
              Get.toNamed(AppRoutes.profile);
            },
            child: CustomCacheNetworkImage(
              "http://192.168.1.112:3000/img/users${item?.employee?.empImage ?? ''}",
              height: 45,
              width: 45,
              boxFit: BoxFit.cover,
              radiusAll: 100,
              borderColor: AppTheme.appColor.withOpacity(.1),
              defaultImage: item?.isGroup == 1
                  ? groupIcon
                  : item?.isCollection == 1
                      ? collectionChat
                      : userIcon,
            ),
          ).marginOnly(right: 8),
        ),
        Expanded(
            child: Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              InkWell(
                onTap: onChatTap,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                        child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item?.userName ?? "",
                          style: BalooStyles.baloomediumTextStyle(),
                        ),
                        vGap(5),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            /*  if ((item?.isMedia ?? false))
                          Image.asset(
                            appIcon,
                            height: 15,
                            width: 15,
                          ),*/
                            Expanded(
                              child: Text(
                                  /*(item?.isMedia ?? false)
                                  ? ""
                                  :*/
                                  item?.lastMessage?.msg ?? "message",
                                  maxLines: 1,
                                  style: BalooStyles.baloonormalTextStyle(
                                      weight: /*(item?.isMedia ?? false)
                                      ? FontWeight.w500
                                      : */
                                          FontWeight.w400,
                                      color: /* (item?.isMedia ?? false)
                                      ? Colors.black
                                      :*/
                                          Colors.black54)),
                            ),
                          ],
                        ),
                      ],
                    )),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          item?.lastMessage?.createdAt ==
                                  "0000-00-00T00:00:00.000Z"
                              ? ""
                              : timeAgo,
                          style: BalooStyles.baloonormalTextStyle(
                              color: Colors.black54),
                        ),
                        if ((item?.unreadMessageCount ?? 0) != 0)
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                                shape: BoxShape.circle, color: appColor),
                            child: Text(
                              "${item?.unreadMessageCount}",
                              style: BalooStyles.baloonormalTextStyle(
                                  color: whiteColor),
                            ),
                          )
                      ],
                    )
                  ],
                ),
              ),
              Divider(
                thickness: 2,
                color: Colors.grey.shade200,
              ).paddingSymmetric(vertical: 3)
            ],
          ),
        )),
      ],
    );
  }

  _listView() {
    return shimmerEffectWidget(
      showShimmer: controller.showPostShimmer,
      shimmerWidget: shimmerlistView(child: ChatUserListShimmer()),
      child: (controller.chatList != null && controller.chatList?.length != 0)
          ? AnimationLimiter(
              child: ListView.separated(
                  physics: const NeverScrollableScrollPhysics(),
                  separatorBuilder: ((context, index) {
                    return Container();
                  }),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  shrinkWrap: true,
                  itemCount: controller.chatList?.length ?? 0,
                  itemBuilder: ((context, index) {
                    UserChatListData? item = controller.chatList?[index];
                    return StaggeredAnimationListItem(
                      index: index,
                      child: item?.isCollection == 1 &&
                              storage.read(userId).toString() !=
                                  item?.createdBy.toString()
                          ? SizedBox()
                          : listItemView(
                              item: item,
                              onChatTap: () {
                                controller.isGoChatScreen = true;
                                Get.toNamed(AppRoutes.chatDetail, arguments: {
                                  RoutesArgument.isFromChatKey: true,
                                  RoutesArgument.senderKey:
                                      item?.lastMessage?.userSendBy,
                                  RoutesArgument.receiverKey: item?.userId,
                                  RoutesArgument.employeeProfile:
                                      item?.employee,
                                  RoutesArgument.groupKey: item?.isGroup,
                                  RoutesArgument.collectionKeyKey:
                                      item?.isCollection,
                                  RoutesArgument.userIdKey: item?.userId,
                                  RoutesArgument.userKey: item?.userName,
                                  RoutesArgument.createdByKey: item?.createdBy,
                                })?.then((value) {
                                  controller.currentPage = 1;
                                  // controller.getChatList = [];
                                  if (isConnected) {
                                    // controller.hitApiToGetChatList();
                                  }
                                });
                              }),
                    );
                  })),
            )
          : Container(),
    );
  }
}

/*

class SocketChatView extends GetView<SocketController> {
  Widget child;
  SocketChatView({Key? key,required this.child}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return   GetBuilder<SocketController>(builder: (controller) {
      return child;});
  }
}

*/
