import 'package:AccuChat/Constants/assets.dart';
import 'package:AccuChat/Constants/colors.dart';
import 'package:AccuChat/Screens/Chat/api/apis.dart';
import 'package:AccuChat/Screens/Chat/screens/chat_tasks/Presentation/Controllers/view_profile_controller.dart';
import 'package:AccuChat/Screens/Chat/screens/chat_tasks/Presentation/Views/profile_modea_selection.dart';
import 'package:AccuChat/utils/backappbar.dart';
import 'package:AccuChat/utils/helper_widget.dart';
import 'package:AccuChat/utils/networl_shimmer_image.dart';
import 'package:AccuChat/utils/text_style.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../../../Services/APIs/api_ends.dart';
import '../../../../../../main.dart';
import '../../../../../../routes/app_routes.dart';
import '../../../../../../utils/hover_glass_effect_widget.dart';
import '../../../../helper/my_date_util.dart';
import '../Widgets/profile_zoom.dart';
import '../dialogs/profile_dialog.dart';

class ViewProfileScreen extends GetView<ViewProfileController> {
  const ViewProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ViewProfileController>(builder: (controller) {
      final about = controller.user?.about?.trim();
      final usern = (controller.user?.userCompany?.displayName != null)
          ? controller.user?.userCompany?.displayName ?? ''
          :controller.user?.userName!=null?controller.user?.userName ?? '':controller.user?.phone ?? '';

      return GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
            //app bar

            floatingActionButton: //user about
                Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
               GradientContainer(
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
            body: Container(
              height: Get.height,
              width: Get.width,
              padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 0),
              decoration: BoxDecoration(
                image: DecorationImage(image: AssetImage(darkbg),fit: BoxFit.cover)
              ),
              child: SingleChildScrollView(
                child: Column(
                  // crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    vGap(10),
                    Row(
                      children: [
                        Expanded(
                          child: backApp(context, controller.user?.userCompany?.displayName !=null?
                          controller.user?.userCompany?.displayName ??''
                              :controller.user?.userName!=null? controller.user?.userName??'':
                          controller.user?.phone ?? ''),
                        ),
                      ],
                    ),
                    vGap(12),

                    Stack(
                      clipBehavior: Clip.none,
                      alignment: Alignment.topCenter,
                      children: [
                        Center(
                          child: GradientContainer(
                            radius: 20,
                            width: 800,
                            padding: 15,

                            child: Column(
                              children: [

                                vGap(20),
                                Text(
                                    controller.user?.email == null ||
                                        controller.user?.email == ''
                                        ? controller.user?.phone ?? ''
                                        : controller.user?.email ?? '',
                                    style: BalooStyles.baloomediumTextStyle()),
                                vGap(3),
                                Text(
                                  'About:',
                                  style: BalooStyles.baloosemiBoldTextStyle(),
                                ),
                                vGap(3),
                                (about != null && about.isNotEmpty)? Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                      controller.user?.about ?? 'I am using Accuchat!',
                                      style: BalooStyles.baloonormalTextStyle(size: 13,color: darkGreyColor),
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis)
                                      .paddingSymmetric(horizontal: 8),
                                ):Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade50,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                      'I am using Accuchat!',
                                      style: BalooStyles.baloonormalTextStyle(size: 13,color: darkGreyColor),
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis)
                                      .paddingSymmetric(horizontal: 8),
                                ),
                              ],
                            ),
                          ),
                        ),

                        Positioned(
                          top: -45,
                          child: HoverGlassEffect(
                            borderRadius: 100,
                            hoverScale: 1.04,
                            normalBlur: 3,
                            hoverBlur: 10,
                            child: InkWell(
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
                              child:
                              controller.user?.userImage!=null? CustomCacheNetworkImage(
                                "${ApiEnd.baseUrlMedia}${controller.user?.userImage ?? ''}",
                                height: 80,
                                width: 80,
                                radiusAll: 100,
                                boxFit: BoxFit.cover,
                                defaultImage: ICON_profile,
                                borderColor: Colors.white,
                                borderWidth: 2,
                              ):GradientContainer(
                                radius: 100,
                                height: 80,
                                width: 80,
                                padding: 0,
                                // color1: greenside.withOpacity(.2),
                                // color2: greenside.withOpacity(.2),
                                child: Center(child: Text(getInitials(usern),style: BalooStyles.baloosemiBoldTextStyle(color: perplebr,size: 50),)),
                              ),

                            ),
                          ),
                        ),
                      ],
                    ),

                    vGap(8),
                SizedBox(
                  width: 900,child: const ProfileMediaSectionGetX(baseUrl: ApiEnd.baseUrlMedia)),
                  ],
                ),
              ),
            )),
      );
    });
  }
}
