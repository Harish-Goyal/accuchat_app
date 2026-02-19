import 'package:AccuChat/Constants/assets.dart';
import 'package:AccuChat/Constants/colors.dart';
import 'package:AccuChat/Screens/Chat/api/apis.dart';
import 'package:AccuChat/Screens/Chat/screens/chat_tasks/Presentation/Controllers/view_profile_controller.dart';
import 'package:AccuChat/Screens/Chat/screens/chat_tasks/Presentation/Views/profile_modea_selection.dart';
import 'package:AccuChat/utils/helper_widget.dart';
import 'package:AccuChat/utils/networl_shimmer_image.dart';
import 'package:AccuChat/utils/text_style.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../../../Services/APIs/api_ends.dart';
import '../../../../../../main.dart';
import '../../../../../../routes/app_routes.dart';
import '../../../../helper/my_date_util.dart';
import '../Widgets/profile_zoom.dart';
import '../dialogs/profile_dialog.dart';

class ViewProfileScreen extends GetView<ViewProfileController> {
  const ViewProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ViewProfileController>(builder: (controller) {
      final about = controller.user?.about?.trim();


      return GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
            //app bar
            appBar: AppBar(
              title: Text(
                controller.user?.userCompany?.displayName !=null?
                        controller.user?.userCompany?.displayName ??''
                    :controller.user?.userName!=null? controller.user?.userName??'':
                        controller.user?.phone ?? '',
                style: BalooStyles.balooboldTitleTextStyle(),
              ),
              scrolledUnderElevation: 0,
              surfaceTintColor: Colors.white,
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
                          controller.formattedDate,
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
                    InkWell(
                      borderRadius: BorderRadius.circular(100),
                      onTap: () => controller.user?.userId == APIs.me.userId
                          ? Get.toNamed(AppRoutes.h_profile)
                          : controller.user?.userImage != null
                              ? Get.to(() => ProfileZoom(
                                  imagePath:
                                      "${ApiEnd.baseUrlMedia}${controller.user?.userImage ?? ''}",
                                  heroTag: "DetailedProfile"))
                              : showDialog(
                                  context: context,
                                  builder: (_) =>
                                      ProfileDialog(user: controller.user)),
                      child: CustomCacheNetworkImage(
                        "${ApiEnd.baseUrlMedia}${controller.user?.userImage ?? ''}",
                        height: 100,
                        width: 100,
                        radiusAll: 100,
                        boxFit: BoxFit.cover,
                        defaultImage: userIcon,
                        borderColor: greyText,
                      ),
                    ),
                    vGap(10),
                    Text(
                        controller.user?.email == null ||
                                controller.user?.email == ''
                            ? controller.user?.phone ?? ''
                            : controller.user?.email ?? '',
                        style: BalooStyles.baloomediumTextStyle()),
                    vGap(10),
                    Text(
                      'About:',
                      style: BalooStyles.baloosemiBoldTextStyle(),
                    ),
                    (about != null && about.isNotEmpty)? Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                              controller.user?.about ?? 'I am using Accuchat!',
                              style: BalooStyles.baloonormalTextStyle(size: 13),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis)
                          .paddingSymmetric(horizontal: 8),
                    ):Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                          'I am using Accuchat!',
                          style: BalooStyles.baloonormalTextStyle(size: 13),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis)
                          .paddingSymmetric(horizontal: 8),
                    ),
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
