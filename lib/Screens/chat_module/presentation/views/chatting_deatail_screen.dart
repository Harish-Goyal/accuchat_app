import 'package:AccuChat/Constants/colors.dart';
import 'package:AccuChat/Constants/themes.dart';
import 'package:AccuChat/Screens/chat_module/models/chat_history_model.dart';
import 'package:AccuChat/Screens/chat_module/presentation/controllers/group_member_controller.dart';
import 'package:AccuChat/Screens/chat_module/presentation/controllers/user_chat_list_controller.dart';
import 'package:AccuChat/Screens/chat_module/presentation/views/reply_message_widget.dart';
import 'package:AccuChat/Screens/chat_module/presentation/views/staggered_view.dart';
import 'package:AccuChat/Services/APIs/local_keys.dart';
import 'package:AccuChat/routes/app_routes.dart';
import 'package:AccuChat/utils/custom_flashbar.dart';
import 'package:AccuChat/utils/gradient_button.dart';
import 'package:AccuChat/utils/helper.dart';
import 'package:AccuChat/utils/text_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:get/get.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:pinch_zoom/pinch_zoom.dart';
import '../../../../Constants/assets.dart';
import '../../../../main.dart';
import '../../../../utils/common_textfield.dart';
import '../../../../utils/custom_dialogue.dart';
import '../../../../utils/custom_scaffold.dart';
import '../../../../utils/helper_widget.dart';
import '../../../../utils/networl_shimmer_image.dart';
import '../../../../utils/product_shimmer_widget.dart';
import '../controllers/chat_detail_controller.dart';
import 'package:swipe_to/swipe_to.dart';

class UserChatDetailScreen extends GetView<ChatDetailController> {
  UserChatDetailScreen({
    Key? key,
  }) : super(key: key);

  var userIDSender;
  var userNameSender;
  var userIDReceiver;
  var userNameReceiver;
  var refIdis;
  var msgis;


  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        // if (Navigator.canPop(context)) {
        //  Get.back();
        // } else {
        //   Get.offAndToNamed(AppRoutes.mainScreen);
        // }
        //
        return Future.value(false);
      },
      child: MyAnnotatedRegion(
        child: GetBuilder<ChatDetailController>(builder: (controller) {
          return CustomScaffold(appBar: _appBar(), body: _mainBuild());
        }),
      ),
    );
  }

  _appBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(120),
      child: SafeArea(
        child: Row(
          children: [
            InkWell(
                child: Icon(
                  Icons.arrow_back_ios,
                  color: blackColor,
                  size: 20,
                ),
                onTap: () {
                  Get.back();
                }),
            Expanded(
                child: InkWell(
              onTap: () {
                // Get.offAndToNamed(AppRoutes.userProfileScreen, arguments: {
                //   RoutesArgument.userIdKey: controller.profileData?.sId
                // });
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  CustomCacheNetworkImage(
                    controller.profileData?.empImage ?? "",
                    height: 45,
                    width: 45,
                    boxFit: BoxFit.cover,
                    radiusAll: 100,
                    borderColor: AppTheme.appColor.withOpacity(.1),
                    defaultImage:
                        (controller.isGroup ?? 0) == 1 ? groupIcon : (controller.isCollectiond ?? 0) == 1 ?  collectionChat :userIcon,
                  ).marginOnly(right: 15),
                  InkWell(
                    onTap: () {
                      Get.toNamed(AppRoutes.groupMember, arguments: {
                        "created_by_id": controller.createdBy,
                        "group_id": controller.useridis,
                        "is_group": controller.isGroup,
                        "groupName": controller.usernameis
                      });
                    },
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          controller.profileData?.empName ??
                              controller.usernameis??'',
                          style: BalooStyles.balooboldTextStyle(
                              color: Colors.black, size: 17),
                        ),
                        vGap(3),
                        controller.createdBy == null
                            ? SizedBox()
                            : Text(
                          // ${groupController.membersList?.length??0}
                                "Members",
                                style: BalooStyles.balooboldTextStyle(
                                    color: greyText, size: 14),
                              ),
                      ],
                    ),
                  ),
                ],
              ),
            )),
            controller.createdBy.toString()==storage.read(userId).toString()?
            PopupMenuButton<String>(
              color: Colors.white,
              icon: Icon(
                Icons.more_vert,
                color: blackColor,
              ),
              onSelected: (value) {
                if (value == 'edit') {
                  showDialog(
                      context: Get.context!,
                      builder: (_) => CustomDialogue(
                            title: "Edit Group Name",
                            isShowAppIcon: false,
                            content: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  "You can edit the group name, enter the group name",
                                  style: BalooStyles.baloonormalTextStyle(),
                                  textAlign: TextAlign.center,
                                ),
                                vGap(20),
                                CustomTextField(
                                  hintText: "Group Name".tr,
                                  controller: controller.groupNameController,

                                  // textInputType: TextInputType.,

                                  focusNode: FocusNode(),
                                  onFieldSubmitted: (String? value) {
                                    FocusScope.of(Get.context!).unfocus();
                                  },
                                  labletext: "Group Name",
                                ),

                                vGap(30),

                                GradientButton(
                                  name: "Update",
                                  btnColor: AppTheme.appColor,
                                  vPadding: 6,
                                  onTap: () {
                                    if (controller
                                        .groupNameController.text.isNotEmpty) {

                                      controller.hitApiToEditGroup(controller.useridis,controller
                                          .groupNameController.text);
                                    } else {
                                      errorDialog("Please enter group name");
                                    }
                                  },
                                )
                                // Text(STRING_logoutHeading,style: BalooStyles.baloomediumTextStyle(),),
                              ],
                            ),
                            onOkTap: () {},
                          ));
                } else if (value == 'delete') {
                  showDialog(
                      context: Get.context!,
                      builder: (_) => CustomDialogue(
                            title: "Delete Group",
                            isShowAppIcon: false,
                            content: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  controller.usernameis,
                                  style: BalooStyles.balooboldTitleTextStyle(),
                                  textAlign: TextAlign.center,
                                ),
                                vGap(20),
                                Text(
                                  "Do you really want to delete this group permanently?",
                                  style: BalooStyles.baloonormalTextStyle(),
                                  textAlign: TextAlign.center,
                                ),

                                vGap(30),

                                GradientButton(
                                  name: "Yes",
                                  btnColor: AppTheme.redErrorColor,
                                  vPadding: 6,
                                  onTap: () {
                                    controller.deleteGroupApiCall();
                                  },
                                )
                                // Text(STRING_logoutHeading,style: BalooStyles.baloomediumTextStyle(),),
                              ],
                            ),
                            onOkTap: () {},
                          ));
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'edit',
                  child: ListTile(
                    leading: Icon(
                      Icons.edit,
                      color: Colors.black,
                      size: 20,
                    ),
                    title: Text(
                      'Edit Group',
                      style: BalooStyles.baloomediumTextStyle(),
                    ),
                  ),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: ListTile(
                    leading: Icon(
                      Icons.delete,
                      color: AppTheme.redErrorColor,
                      size: 20,
                    ),
                    title: Text('Delete Group',
                        style: BalooStyles.baloomediumTextStyle()),
                  ),
                ),
              ],
            ):SizedBox(),
          ],
        ).marginSymmetric(horizontal: 15, vertical: 10),
      ),
    );
  }

  Widget _mainBuild() {
    final ImagePicker _picker = ImagePicker();
    return Column(
      children: [
        // Chat message list builder (fills remaining space)
        Expanded(child: chatMessageBuilder()),

        // Reply widget (conditionally displayed)
        if (controller.replyToMessage != null)
          Transform.translate(
            offset: Offset(0, 40),
            child: ReplyMessageWidget(
              isCancel: true,
              message: msgis,
              sentByMe:
                  storage.read(userId).toString() == userIDSender.toString()
                      ? true
                      : false,
              empIdsender: userIDSender,
              empIdreceiver: userIDReceiver,
              empName:userIDSender.toString()  == storage.read(userId).toString()
    ?userNameSender
        : userNameReceiver,
              onCancelReply: () {
                controller.replyToMessage = null;
                refIdis = null;
                controller.update();
              },
            ),
          ),

        // Message input field (at the bottom)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
          margin: const EdgeInsets.only(bottom: 8),
          width: Get.width,
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(10),
              topRight: Radius.circular(10),
            ),
            color: Colors.transparent,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Input field
              Expanded(
                child: CustomTextField(
                  hintText: "Your Message",
                  controller: controller.chatMessageController,
                  focusNode: controller.chatFocus,
                  borderColor: Colors.grey.shade300,
                  suffix: InkWell(
                    onTap: () {
                      // Add attachment functionality here
                    },
                    child: Container(
                      width: 30,
                      height: 30,
                    ),
                  ),
                ),
              ),
              hGap(8),

              // Send button
              InkWell(
                onTap: () {
                  if (controller.chatMessageController.text.isNotEmpty) {
                    Get.find<SocketController>().sendMessage(
                      receiverId: controller?.receiverIdis.toString() ?? "",
                      message: controller.chatMessageController.text.trim(),
                      senderId: storage.read(userId),
                      refId: refIdis,
                      isGroup: controller.isGroup.toString()=="1"?"1":controller.isCollectiond.toString()=="1"?"0":"2"
                    );
                    controller.chatMessageController.clear();
                    controller.clearReplyMessage();
                    controller.update();
                  }
                },
                child: sendIconWidget().paddingOnly(top: 20),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /* Widget _mainBuild() {
    final ImagePicker _picker = ImagePicker();
    return Stack(
      children: [
        chatMessageBuilder(),
        controller.replyToMessage != null
            ? Positioned(

              child: ReplyMessageWidget(message:msgis,empName: controller.profileData?.empImage ?? "",
                      onCancelReply: (){
                        controller.replyToMessage = null;
                        controller.update();
                      },),
            )
            : SizedBox(),
        vGap(10),
        Container(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
              width: Get.width,
              decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(10)),
                  color: Colors.transparent),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                      child: CustomTextField(
                    hintText: "Your Message",
                    controller: controller.chatMessageController,
                    borderColor: Colors.grey.shade300,

                    suffix: InkWell(
                      onTap: () {
                        */ /* chatImageVideoPickerAccountDialog(
                            onGallery: () async {
                          Get.back();

                          addMultiImage();
                        }, onCameraTap: () async {
                          Get.back();
                          final AssetEntity? entity = await CameraPicker.pickFromCamera(
                            Get.context!,
                            // locale:  TranslationService.fallbackLocale,
                            pickerConfig: const CameraPickerConfig(
                                imageFormatGroup: ImageFormatGroup.yuv420,
                                enableAudio: true,
                                enableTapRecording: true,
                                enableRecording: true,
                                maximumRecordingDuration: Duration(seconds: 30)
                            ),
                          );

                          controller.attachedFile =await  entity?.file;
                          controller.chatAttachmentAPI();

                        },


                        );*/ /*
                      },
                      child: Container(
                        width: 30,
                        height: 30,
                        // padding: const EdgeInsets.all(15),
                        // child: Image.asset(
                        //   attachIcon,
                        // ),
                      ),
                    ),
                  )),
                  hGap(15),
                  InkWell(
                    onTap: () {

                    // var datais =  (controller.chatHistory).map((item) {
                    //       refIdis =item.id??'';
                    //       // print("refIdis");
                    //       // print(refIdis);
                    //       return refIdis;
                    //   });

                    if(controller.chatMessageController.text.isNotEmpty) {
                      Get.find<SocketController>().sendMessage(
                          receiverId: controller?.receiverIdis.toString() ?? "",
                          message: controller.chatMessageController.text.trim(),
                          senderId: storage.read(userId),
                          refId: refIdis);
                      controller.chatMessageController.clear();
                      // Get.find<SocketController>().allListerer();

                      controller.update();
                    }
                    },
                    child: sendIconWidget().paddingOnly(top: 20),
                  )
                ],
              ),
            ))
      ],
    );
  }*/

  addMultiImage() async {
    // final List<AssetEntity>? result = await AssetPicker.pickAssets(Get.context!,
    //     pickerConfig: AssetPickerConfig(
    //       maxAssets: 1,
    //       themeColor: appColor,
    //     ));
    // if ((result ?? []).length != 0) {
    //   controller.attachedFile = await result?[0].file;
    //   controller.chatAttachmentAPI();
    // }
  }

  Widget sendIconWidget() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 2,horizontal: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: AppTheme.primaryTextColor
      ),
      child: Image.asset(
        sendIcon,
        height: Get.height * .05,
        width: Get.width * .06,
      ),
    );
  }

  Widget chatMessageBuilder() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        vGap(10),
        Expanded(
          child: shimmerEffectWidget(
            showShimmer: controller.showPostShimmer,
            shimmerWidget: shimmerlistView(
                child: ChatHistoryShimmer(
              chatData: controller.chatHistory![0]!,
            )),
            child: AnimationLimiter(child: groupListView()),
          ),
        ),
        // vGap(80)
      ],
    );
  }

/*  listView() {
    return ListView.builder(
        controller: controller.scrollController,
        reverse: true,
        itemCount: controller.chatHistory.length ?? 0,
        itemBuilder: (context, index) {

          String formatatedTime = '';
          if(controller.chatHistory.isNotEmpty) {
            DateTime dateTime = DateTime.parse(
                controller.chatHistory[index].createdAt ?? '');
            formatatedTime= formatTimeAMPM(dateTime);
          }

          return StaggeredAnimationListItem(
            index: index,
            child: _chatMessageTile(
                data: controller.chatHistory[index],
                sentByMe: (controller.chatHistory[index].userSendBy==1?true : false),formatedTime: formatatedTime),
          );
        });
  }*/

  //TODO here group view is managed

  groupListView() {
    return GroupedListView<GroupChatElement, DateTime>(
        shrinkWrap: false,
        padding: const EdgeInsets.only(bottom: 30),
        controller: controller.scrollController,
        elements: controller.chatCatygory,
        order: GroupedListOrder.DESC,
        reverse: true,
        floatingHeader: true,
        useStickyGroupSeparators: true,
        groupBy: (GroupChatElement element) => DateTime(
              element.date.year,
              element.date.month,
              element.date.day,
            ),
        groupHeaderBuilder: _createGroupHeader,
        indexedItemBuilder:
            (BuildContext context, GroupChatElement element, int index) {
          String formatatedTime = '';
          if (element.chatMessageItems.createdAt != null) {
            // Example UTC time as a string
            var timeString = element.chatMessageItems.createdAt ?? ''; // ISO format


            DateTime istTime=  DateTime.parse(timeString);

            formatatedTime = formatTimeAMPM(istTime);
          }

          var userid = storage.read(userId);
          return StaggeredAnimationListItem(
            index: index,
            child: SwipeTo(
              onRightSwipe: (detail) {
                // Set the message being replied to
                refIdis = element.chatMessageItems.id;
                userIDSender = element.chatMessageItems.userSendBy.toString();
                userNameReceiver = element.chatMessageItems.receiverUser?.userAbbr??'';
                userNameSender = element.chatMessageItems.senderUser?.userAbbr??'';
                userIDReceiver =
                    element.chatMessageItems.userReceiveBy.toString();
                msgis = element.chatMessageItems.msg;



                controller.setReplyMessage(controller.chatHistory?[index]);
                FocusScope.of(Get.context!).requestFocus(controller.chatFocus);
                // Get.find<SocketController>().sendMessage( senderId: controller.chatHistory[index]?.userSendBy, receiverId: controller.chatHistory[index]?.userReceiveBy, message: controller,refId: message?.referenceId);
                controller.update();
              },
              child: _chatMessageTile(
                  data: element.chatMessageItems,
                  sentByMe: (userid.toString() ==
                          element.chatMessageItems.userSendBy.toString()
                      ? true
                      : false),
                  formatedTime: formatatedTime),
            ),
          );
        });
  }

  Widget _createGroupHeader(GroupChatElement element) {
    return Container(
      color: Colors.transparent,
      child: Row(
        children: [
          const Expanded(
            child: Divider(
              thickness: 2,
            ),
          ),
          Text(DateFormat.yMMMd().format(element.date)),
          const Expanded(
            child: Divider(
              thickness: 2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _chatMessageTile(
      {required ChatHistoryData data, required bool sentByMe, formatedTime}) {
    return Column(
      crossAxisAlignment:
          sentByMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        vGap(3),
        data.referenceId != null
            ? ReplyMessageWidget(
                isCancel: false,
                sentByMe: sentByMe,
                empIdsender: data.senderUser?.userId.toString(),
                chatdata: data,
                empIdreceiver: data.receiverUser?.userId.toString(),
                empName: data.senderUser?.userId.toString()  == storage.read(userId).toString()
                    ?data.senderUser?.userAbbr??''
                    : data.receiverUser?.userAbbr??'',
                message: data.message?.msg ?? '').marginOnly(top: 4,bottom: 4)
            : SizedBox(),
        Container(
          alignment: sentByMe ? Alignment.centerRight : Alignment.centerLeft,
          padding: EdgeInsets.only(
              top: 4, left: (sentByMe ? 0 : 14), right: (sentByMe ? 15 : 0)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment:
                sentByMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              

              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: (data.msg ?? "").isNotEmpty ? 12 : 15,
                  vertical: (data.msg ?? "").isNotEmpty ? 12 : 15,
                ),
                margin: sentByMe
                    ? const EdgeInsets.only(left: 30)
                    : const EdgeInsets.only(right: 30),
                decoration: BoxDecoration(
                    color: sentByMe ? appColor.withOpacity(.2) : greyColor,
                    borderRadius: sentByMe
                        ? const BorderRadius.only(
                            topLeft: Radius.circular(15),
                            topRight: Radius.circular(15),
                            bottomLeft: Radius.circular(15))
                        : const BorderRadius.only(
                            topLeft: Radius.circular(15),
                            topRight: Radius.circular(15),
                            bottomRight: Radius.circular(15))),
                child: messageTypeView(data, sentByMe: sentByMe),
              ).marginOnly(left: (0), top: 0),
            ],
          ),
        ),
        vGap(3),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              formatedTime ?? '',
              textAlign: TextAlign.start,
              style: BalooStyles.baloonormalTextStyle(
                  color: Colors.grey, size: 15),
            ).marginOnly(left: 15, right: 15),
          ],
        ),
      ],
    );
  }
/*
  storyChatView({required ChatMessageItems data, required bool sentByMe}) {
    return InkWell(
      onTap: () {
        // controller.hitStoryAPI(data.storyId,
        //     onSuccess: (ChatStoryDataModal value) {
        //   Get.toNamed(AppRoutes.storyChatPageView,
        //       arguments: {RoutesArgument.chatUserItemKey: value});
        // });
        // // Get.toNamed(AppRoutes.storyChatPageView,
        // //
        // // arguments: {
        // //   RoutesArgument.chatUserItemKey:ChatStoryDataModal(storyLink: data.storyLink)
        // // }
        // // );
      },
      child: Container(
        height: 30,
        width: 30,
        margin: const EdgeInsets.only(bottom: 5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
        ),
        child: CustomCacheNetworkImage(
          data.storyThumbnail ?? data?.storyLink ?? "",
          height: 70,
          width: 40,
          radiusAll: 5,
        ),
      ),
    );
  }*/



  messageTypeView(ChatHistoryData data, {required bool sentByMe}) {
    /* switch (data.messageType) {
    case "video":
      {
        return InkWell(
            onTap: () {
              // Get.dialog(
              //   // videoPlayerLayout(data.message ?? ""),
              //   // barrierDismissible: false,
              // );
            },
            child: Stack(
              children: [
                messageImageView(data?.messageThumbnail, sentByMe: sentByMe),
                Positioned(
                  right: (Get.width / 2) - 60,
                  top: 80,
                  child: Container(
                      height: 60,
                      width: 60,
                      padding: const EdgeInsets.all(20),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          color: appColor.withOpacity(0.0),
                          border: Border.all(
                            width: 1, //
                          ),
                          shape: BoxShape.circle),
                      child: const Icon(
                        Icons.play_arrow,
                        color: Colors.black,
                        size: 20,
                      )),
                )
              ],
            ));
      }

    case "image":
      {
        return InkWell(
          onTap: () {
            // showImageViewer(
            //     Get.context!,
            //     imageShow(url:  data.message??"",
            //     // height: Get.height,
            //     //   width: Get.width
            //     ),
            //     swipeDismissible: true,
            //     doubleTapZoomable: true);
            Get.dialog(
              ImageView(imageurl: data.message ?? ""),
              barrierDismissible: false,
            );
          },
          child: messageImageView(data?.message, sentByMe: sentByMe),
        );
      }

    default:
      {
        return Stack(
          children: [
            Text(data.message ?? '',
                textAlign: TextAlign.start,
                style: BalooStyles.baloonormalTextStyle(
                  color: Colors.black87,
                  size: 15,
                ),
                overflow: TextOverflow.visible),
          ],
        );
      }
  }*/
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          controller.isGroup.toString()=="1"?

          Text("${data.senderUser?.userAbbr} :" ?? '',
              textAlign: TextAlign.start,
              style: BalooStyles.baloosemiBoldTextStyle(
                color: Colors.black54,
                size: 15,
              ),
              overflow: TextOverflow.visible).marginOnly(
              left: sentByMe?0:10,right: sentByMe?10:0,
            bottom: 3
          ):SizedBox(),
          Text(data.msg ?? '',
              textAlign: TextAlign.start,
              style: BalooStyles.baloonormalTextStyle(
                color: Colors.black87,
                size: 15,
              ),
              overflow: TextOverflow.visible),
        ],
      ),
    );
  }

}

// ImageProvider imageShow({String? url,double? height,double? width}){
//   return Image.network(url??"",
//     loadingBuilder:  (_, __,___) {
//       return shimmerEffectWidget(
//         showShimmer: true,
//         child: Container(
//             width: double.infinity,
//             height: height,
//             alignment: Alignment.center,
//             child: Image.asset(
//                appIcon,
//               height: width,
//               width: height,
//
//               fit:  BoxFit.cover
//                 ,
//             )),
//       );
//     },
//     errorBuilder: (context, exception, stackTrace) {
//       return Container(
//           width: width,
//           height: height,
//           alignment: Alignment.center,
//           child: Image.asset(
//             appIcon,
//             width: width,
//             height: height,
//
//             fit:  BoxFit.cover
//             ,
//           ));
//     },
//
//     // errorBuilder: ,
//
//   )
//       .image;
// }

messageImageView(String? imageUrl, {required bool sentByMe}) {
  return ClipRRect(
    borderRadius: sentByMe
        ? const BorderRadius.only(
            topLeft: Radius.circular(15),
            topRight: Radius.circular(15),
            bottomLeft: Radius.circular(15))
        : const BorderRadius.only(
            topLeft: Radius.circular(15),
            topRight: Radius.circular(15),
            bottomRight: Radius.circular(15)),
    child: CustomCacheNetworkImage(
      imageUrl ?? "",
      width: Get.width,
      height: 200,
      boxFit: BoxFit.cover,
    ),
  );
}

class GroupChatElement implements Comparable {
  DateTime date;
  ChatHistoryData chatMessageItems;

  GroupChatElement(
    this.date,
    this.chatMessageItems,
  );

  @override
  int compareTo(other) {
    return date.compareTo(other.date);
  }
}

class ImageView extends StatelessWidget {
  String? imageurl;
  ImageView({Key? key, this.imageurl}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          height: Get.height,
          width: Get.width,
          child: PinchZoom(
            // resetDuration: const Duration(milliseconds: 100),
            maxScale: 2.5,
            onZoomStart: () {},
            onZoomEnd: () {},
            child: Container(
              color: Colors.black,
              height: Get.height,
              width: Get.width,
              child: CustomCacheNetworkImage(
                imageurl ?? "",
                withBaseUrl: false,
                width: Get.width,
                height: 235,
                boxFit: BoxFit.contain,
              ),
            ),
          ),
        ),
        Positioned(
          right: 30,
          top: 30,
          child: InkWell(
              onTap: () {
                Get.back();
              },
              child: const Icon(
                Icons.close,
                color: Colors.white,
                size: 30,
              )),
        )
      ],
    );
  }
}
