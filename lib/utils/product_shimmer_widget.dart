
import 'dart:math';

import 'package:AccuChat/Screens/Chat/models/chat_history_response_model.dart';
import 'package:AccuChat/utils/text_style.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../Constants/assets.dart';
import '../Constants/colors.dart';
import '../Constants/themes.dart';
import 'helper_widget.dart';
import 'networl_shimmer_image.dart';

Widget shimmerlistView(
    {required Widget child, Axis scrollDirection = Axis.vertical,int count = 15}) {
  return ListView.builder(
    shrinkWrap: true,
    scrollDirection: scrollDirection,
    itemCount: count,
    padding: EdgeInsets.symmetric(vertical: 0, horizontal: 2),
    physics: NeverScrollableScrollPhysics(),
    itemBuilder: (BuildContext context, int index) {
      return child;
    },
  );
}

Widget shimmerGridlistView(
    {required Widget child,
    Axis scrollDirection = Axis.vertical,
    int length = 10}) {
  return GridView.builder(
    padding: EdgeInsets.symmetric(vertical: 5),
    shrinkWrap: true,
    physics: NeverScrollableScrollPhysics(),
    itemCount: length,
    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
        childAspectRatio: 1.1),
    itemBuilder: (BuildContext context, int index) {
      return child;
    },
  );
}

Widget shimmerlistItem(
    {double? height, double? horizonalPadding, double radius = 10}) {
  return Container(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(
        width: 1, //                   <--- border width here
      ),
      // color: Colors.black,
    ),
    padding: EdgeInsets.symmetric(
        vertical: 20, horizontal: horizonalPadding ?? 5),
    margin: EdgeInsets.symmetric(
        vertical: 20, horizontal: horizonalPadding ?? 5),
    height: height ?? 150,
    width: Get.width,
    child: Row(
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: Image.asset(
              appIcon,
              height: height ?? 150,
              width: 100,
            ),
          ),
        ),
        Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Flexible(
                  child: Container(
                    color: black,
                    height: 10,
                    width: Get.width,
                  ),
                ),
                vGap(10),
                Flexible(
                  child: Container(
                    color: black,
                    height: 10,
                    width: 100,
                  ),
                ),
                vGap(10),
                Flexible(
                  child: Container(
                    color: black,
                    height: 10,
                    width: Get.width,
                  ),
                ),
              ],
            ))
      ],
    ),
  );
}

class ShimmerGridImage extends StatelessWidget {
  const ShimmerGridImage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.asset(appIcon,
          fit: BoxFit.fill,
        ));
  }
}


class ShimmerPostViewWidget extends StatelessWidget {
  ShimmerPostViewWidget({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
        // color: Colors.grey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            vGap(4),
            postPageViewWidget(context),
            vGap(10),
            _bottomIconRowWidget(context),
            vGap(15),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: _commentWidget(),
            ),
            vGap(10),
            _timeAgo(),
            vGap(20),
          ],
        ));
  }



  Widget postPageViewWidget(context) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.bottomCenter,
      children: [
        Container(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
            child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset(
                  appIcon,
                  width: Get.width,
                  height: 180,
                  fit: BoxFit.fill,
                )),
          ),
        ),
        Positioned(bottom: 50, left: 30, child: _pageCountWidget()),
      ],
    );
  }

  Widget _pageCountWidget() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30), color: colorGrey),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text("0",
              textAlign: TextAlign.center,
              style: BalooStyles.baloonormalTextStyle(
                color: Colors.white,
              )),
          Text("/",
              textAlign: TextAlign.center,
              style: BalooStyles.baloonormalTextStyle(
                color: Colors.white,
              )),
          Text("0",
              textAlign: TextAlign.center,
              style:BalooStyles.baloonormalTextStyle(
                color: Colors.white,
              )),
        ],
      ),
    );
  }

  Widget _bottomIconRowWidget(
    context,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              _iconWithCount(context, icon: heartIcon, count: "12"),
              hGap(15),
              _iconWithCount(context, icon: msgChatIcon, count: "14",
                  onIconTap: () {

              }),
            ],
          ),
          _iconWithCount(context,
              icon: shareIcon, count: "20", onIconTap: () {})
        ],
      ),
    );
  }

  Widget _iconWithCount(context, {icon, count, onIconTap}) {
    return InkWell(
      onTap: onIconTap,
      child: Row(
        children: [
          Image.asset(
            icon,
            height: Get.height * .027,
            width: Get.height* .027,
          ),
          hGap(8),
          Text(count,
              textAlign: TextAlign.center,
              style: BalooStyles.baloonormalTextStyle(
                color: Colors.black,
              )),
        ],
      ),
    );
  }

  Widget _commentWidget() {
    return Row(
      children: [
        Text("Ava Sadie  ",
            style:BalooStyles.balooboldTextStyle(
              color: Colors.black,
            )),
        Text("",
            style: BalooStyles.balooboldTextStyle(
              color: Colors.black,
            )),
      ],
    );
  }

  Widget _timeAgo() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: Text("17 hours ago",
          textAlign: TextAlign.center,
          style: BalooStyles.baloonormalTextStyle(
            color: Colors.black,
          )),
    );
  }
}
// CommentShimmer
class CommentShimmer extends StatelessWidget {
  const CommentShimmer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
            padding: const EdgeInsets.only(right: 10.0),
            child:
            ClipRRect(
              borderRadius: BorderRadius.circular(40),
              child: Image.asset(appIcon,
                width: 40,
                height: 40,
              ),
            )

        ),
        hGap(10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
                text: TextSpan(
                  text:  "AccuChat ",
                  style:BalooStyles.balooboldTextStyle(
                    color: Colors.black,
                  ),
                  children: <TextSpan>[
                    TextSpan(
                        text:  'AccuChat',
                        style: BalooStyles.baloonormalTextStyle(
                          color: Colors.black,
                        )),
                  ],
                ),
              ),
              Text(
                "Just Now",
                style: BalooStyles.baloonormalTextStyle(color: Colors.grey),
              ),
            ],
          ),
        )
      ],
    ).marginOnly(bottom: 20, left: 20);
  }
}

class ChatUserListShimmer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile Picture Placeholder
          Container(
              width: 50.0,
              height: 50.0,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25.0),
              ),
            ),
          const SizedBox(width: 16.0),
          // Text placeholders
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // User name placeholder
                 Container(
                    width: double.infinity,
                    height: 15.0,
                    margin: EdgeInsets.only(right: 15),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8.0),
                  )
                ),
                const SizedBox(height: 8.0),
                // Last message placeholder
                 Container(
                    width: MediaQuery.of(context).size.width * 0.6,
                    height: 10.0,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),

              ],
            ),
          ),
        ],
      ),
    );
  }
}


class ChatHistoryShimmer extends StatelessWidget {
   ChatHistoryShimmer({Key? key,required this.chatData}) : super(key: key);
  ChatHisList chatData;
  bool getRandomBool() {
    Random random = Random();
    return random.nextBool();
  }

  @override
  Widget build(BuildContext context) {
    bool isSendbme = getRandomBool();
    return Column(
      crossAxisAlignment:
      isSendbme? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        vGap(3),
        Container(
          alignment: isSendbme? Alignment.centerRight : Alignment.centerLeft,
          padding: EdgeInsets.only(
              top: 4, left: (isSendbme ? 0 : 0), right: (isSendbme ? 20 : 0)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment:
            isSendbme ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: ("").isNotEmpty ? 12 : 15,
                  vertical: ("").isNotEmpty ? 12 : 15,
                ),
                margin: isSendbme
                    ? const EdgeInsets.only(left: 30)
                    : const EdgeInsets.only(right: 30),
                decoration: BoxDecoration(
                    color: isSendbme ? Colors.black :greyText,
                    borderRadius: isSendbme
                        ? const BorderRadius.only(
                        topLeft: Radius.circular(15),
                        topRight: Radius.circular(15),
                        bottomLeft: Radius.circular(15))
                        : const BorderRadius.only(
                        topLeft: Radius.circular(15),
                        topRight: Radius.circular(15),
                        bottomRight: Radius.circular(15))),
                child: _messageTypeView(chatData, sentByMe: isSendbme),
              ).marginOnly(left: (0), top: 0),
            ],
          ),
        ),
        vGap(3),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "pm",
              textAlign: TextAlign.start,
              style: BalooStyles.baloonormalTextStyle(
                  color: Colors.grey, size: 15),
            ).marginOnly(left: 0, right: 15),
          ],
        ),
      ],
    ).marginOnly(bottom: 20, left: 20);
  }

   _messageTypeView(ChatHisList data, {required bool sentByMe}) {
     return Container(
       padding: EdgeInsets.symmetric(horizontal: 20),

       child: Text(data.message ?? '',
           textAlign: TextAlign.start,
           style: BalooStyles.baloonormalTextStyle(
             color: Colors.black87,
             size: 15,
           ),
           overflow: TextOverflow.visible),
     );
   }
}



class GroupMemberShimmer extends StatelessWidget {
  GroupMemberShimmer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,

      leading: SizedBox(
        width: 40,
        child: CustomCacheNetworkImage(
          width: 40,
          height: 40,
          radiusAll: 100,
          borderColor: AppTheme.appColor.withOpacity(.2),

          "",defaultImage: userIcon,
        ),
      ),
      title: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.symmetric(vertical: 5,horizontal: 7),

              child: Text("XXXXXXXXXX",style: BalooStyles.baloonormalTextStyle(color: Colors.black),)),
          vGap(5),
          Text("*******",style: BalooStyles.baloonormalTextStyle(color: Colors.black),)
        ],
      ),
      trailing: Container(
        width: 40,
        height: 40,
        child: CupertinoCheckbox(
          value:false,
          inactiveColor: Colors.black,

          onChanged: (value) {
            // controller.toggleSelect(member);
          },
        ),
      ),
    ).marginSymmetric(horizontal: 15,vertical: 3);
  }
}