import 'package:AccuChat/Constants/assets.dart';
import 'package:AccuChat/Constants/colors.dart';
import 'package:AccuChat/Screens/Chat/api/apis.dart';
import 'package:AccuChat/Screens/Chat/screens/chat_tasks/Presentation/Controllers/view_profile_controller.dart';
import 'package:AccuChat/Screens/Chat/screens/chat_tasks/Presentation/Views/profile_modea_selection.dart';
import 'package:AccuChat/utils/helper_widget.dart';
import 'package:AccuChat/utils/networl_shimmer_image.dart';
import 'package:AccuChat/utils/text_style.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../../Services/APIs/api_ends.dart';
import '../../../../../../main.dart';
import '../../../../../../routes/app_routes.dart';
import '../../../../helper/my_date_util.dart';
import '../../../../models/chat_user.dart';

//view profile screen -- to view profile of user
class ViewProfileScreen extends GetView<ViewProfileController> {
  const ViewProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ViewProfileController>(builder: (controller) {
      print(controller.user?.about);
      return GestureDetector(
        // for hiding keyboard
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
            //app bar
            appBar: AppBar(
              title: Text(
                controller.user?.displayName == null ||
                        controller.user?.displayName == ''
                    ? controller.user?.phone ?? ''
                    : controller.user?.displayName ?? '',
                style: BalooStyles.balooboldTitleTextStyle(),
              ),
            ),
            floatingActionButton: //user about
                Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  margin: const EdgeInsets.only(left: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Joined On: ',
                        style: BalooStyles.baloomediumTextStyle(size: 13),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                          MyDateUtil.getLastMessageTime(
                              context: context,
                              time: controller.user?.createdOn ?? '',
                              showYear: true),
                          style: BalooStyles.baloonormalTextStyle(size: 13)),
                    ],
                  ),
                ),
              ],
            ),

            //body
            body: Padding(
              padding: EdgeInsets.symmetric(horizontal: mq.width * .05),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    controller.user?.userImage != null
                        ? InkWell(
                            borderRadius: BorderRadius.circular(100),
                            onTap: () =>
                                controller.user?.userId == APIs.me.userId
                                    ? Get.toNamed(AppRoutes.h_profile)
                                    : null,
                            child: CustomCacheNetworkImage(
                              "${ApiEnd.baseUrlMedia}${controller.user?.userImage ?? ''}",
                              height: 140,
                              width: 140,
                              radiusAll: 100,
                              boxFit: BoxFit.cover,
                              defaultImage: userIcon,
                              borderColor: Colors.black,
                            ),
                          )
                        : const SizedBox(),
                    vGap(10),
                    Text(
                        controller.user?.email == null ||
                                controller.user?.email == ''
                            ? controller.user?.phone ?? ''
                            : controller.user?.email ?? '',
                        style: BalooStyles.baloomediumTextStyle()),
                    vGap(10),
                    Text(
                      'About: ',
                      style: BalooStyles.baloosemiBoldTextStyle(),
                    ),
                    controller.user?.about != null ||
                            controller.user?.about != ""
                        ? Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(controller.user?.about ?? '',
                                    style: BalooStyles.baloonormalTextStyle(
                                        size: 13),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis)
                                .paddingSymmetric(horizontal: 8),
                          )
                        : const SizedBox(),
                    vGap(15),
                    const ProfileMediaSectionGetX(baseUrl: ApiEnd.baseUrlMedia),
                  ],
                ),
              ),
            )),
      );
    });
  }
}
