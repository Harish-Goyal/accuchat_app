import 'package:AccuChat/Constants/colors.dart';
import 'package:AccuChat/Screens/Home/Presentation/Controller/home_controller.dart';
import 'package:AccuChat/Screens/Settings/Presentation/Views/static_page.dart';
import 'package:AccuChat/Services/APIs/api_ends.dart';
import 'package:AccuChat/routes/app_routes.dart';
import 'package:AccuChat/utils/custom_container.dart';
import 'package:AccuChat/utils/custom_flashbar.dart';
import 'package:AccuChat/utils/helper_widget.dart';
import 'package:AccuChat/utils/text_style.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../../../../utils/networl_shimmer_image.dart';
import '../../../Chat/screens/auth/Presentation/Views/landing_screen.dart';
import '../Controllers/all_settings_controller.dart';

class AllSettingsScreen extends GetView<AllSettingsController> {
  const AllSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final bool isWide = size.width >= 900;
    const double maxContentWidth = 900;

    return GetBuilder<AllSettingsController>(
      init: AllSettingsController(),
      builder: (controller) {
        return Scaffold(
          appBar: AppBar(      scrolledUnderElevation: 0,
            surfaceTintColor: Colors.white,
            title:  Text('Settings',style: BalooStyles.balooboldTitleTextStyle(),),
            toolbarHeight: isWide ? 64 : kToolbarHeight,
          ),
          body: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: isWide ? maxContentWidth : double.infinity,
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: isWide ? 16 : 0),
                child: _buildContent(context, controller, isWide),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildContent(BuildContext context, AllSettingsController controller, bool isWide) {
    return ListView(
      children: [
        InkWell(
          onTap: (){
            try {
              Get.back();
              final con = Get.find<DashboardController>();
              con.updateIndex(3);
              con.update();
            }catch(v){
              print(v);
            }
          },
          child: CustomContainer(
            elevation: 1,
            childWidget: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CustomCacheNetworkImage(
                  "${ApiEnd.baseUrlMedia}${controller.myCompany?.logo??''}",
                  height: isWide ? 64 : 50,
                  width: isWide ? 64 : 50,
                  boxFit: BoxFit.cover,
                  radiusAll: 100,
                  borderColor: Colors.black54,
                ),
                hGap(isWide ? 14 : 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        controller.myCompany?.companyName??"",
                        style: BalooStyles.baloosemiBoldTextStyle(),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      vGap(4),
                      Text(
                        controller.myCompany?.phone!=null?
                        controller.myCompany?.phone??"": controller.myCompany?.email??'',
                        style: BalooStyles.balooregularTextStyle(),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      vGap(4),
                      Text(
                        "You are now connected to ${controller.myCompany?.companyName??""}",
                        style: BalooStyles.balooregularTextStyle(color: appColorGreen,size: 12),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 4,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ).marginSymmetric(horizontal: 12,vertical: 12),
        ),
        controller.isLoading?const Padding(
          padding: EdgeInsets.symmetric(horizontal: 15.0,vertical: 8),
          child: Text("Loading..."),
        ):const SizedBox(),
       /* ...(controller.settingsItems??[]).map((nav) {
          return ListTile(
            leading: Icon(controller.iconForSetting(nav), size: isWide ? 22 : 20),
            title: Text(nav.navigationItem??'',
                style: BalooStyles.baloonormalTextStyle()),
            trailing: Icon(Icons.arrow_forward_ios, size: isWide ? 16 : 15, color: Colors.grey),
            onTap: controller.onTapForSetting(nav, controller),
            // responsive: slightly tighter density on web to fit more items
            visualDensity: kIsWeb ? const VisualDensity(vertical: -1) : VisualDensity.standard,
          );
        }).toList(),*/
        _buildTile(
          icon: Icons.person_3_outlined,
          title: 'Profile',
          onTap: () {
            Get.toNamed(AppRoutes.h_profile);
          },
        ),  _buildTile(
          icon: Icons.insert_invitation_outlined,
          title: 'Invitations',
          onTap: () {
            Get.toNamed(AppRoutes.accept_invite);
          },
        ),  _buildTile(
          icon: Icons.privacy_tip_outlined,
          title: 'Privacy Policy',
          onTap: () {
            Get.to(() => HtmlViewer(
              htmlContent: controller.pvcContent,
            ));
          },
        ),
        _buildTile(
          icon: Icons.info_outline,
          title: 'About Us',
          onTap: () {
            Get.to(() => HtmlViewer(
              htmlContent: controller.aboutUsContent,
            ));
          },
        ),
        /* _buildTile(
          icon: Icons.people_outline,
          title: 'Manage Roles',
          onTap: () => Get.toNamed(AppRoutes.roleListRoute),
        ),*/
        _buildTile(
            icon: Icons.support_agent,
            title: 'Support',
            onTap: () {
              toast('Under Development!');
            }),
        divider().paddingSymmetric(vertical: 12),
       kIsWeb?const SizedBox(): _buildTile(
          icon: Icons.settings,
          title: 'App Settings',
          onTap: () => controller.openAppSettingsPage(),
        ),

        _buildTile(
          icon: Icons.logout,
          title: 'Logout',
          onTap: () async {
            showResponsiveLogoutDialog();
          },
        ),
        const SizedBox(height: kIsWeb ? 16 : 0),
      ],
    );
  }

  Widget _buildTile(
      {required IconData icon,
        required String title,
        required VoidCallback onTap}) {
    return ListTile(
      leading: Icon(
        icon,
        size: 18,
      ),
      title: Text(
        title,
        style: BalooStyles.baloonormalTextStyle(),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 15,
        color: Colors.grey,
      ),
      onTap: onTap,
      visualDensity: kIsWeb ? const VisualDensity(vertical: -1) : VisualDensity.standard,
    );
  }
}
