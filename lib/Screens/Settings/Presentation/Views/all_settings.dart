import 'package:AccuChat/Constants/assets.dart';
import 'package:AccuChat/Constants/colors.dart';
import 'package:AccuChat/Screens/Chat/api/apis.dart';
import 'package:AccuChat/Screens/Home/Presentation/Controller/home_controller.dart';
import 'package:AccuChat/Screens/Home/Presentation/Controller/profile_controller.dart';
import 'package:AccuChat/Screens/Home/Presentation/View/profile_screen.dart';
import 'package:AccuChat/Screens/Settings/Presentation/Views/static_page.dart';
import 'package:AccuChat/Services/APIs/api_ends.dart';
import 'package:AccuChat/routes/app_routes.dart';
import 'package:AccuChat/utils/backappbar.dart';
import 'package:AccuChat/utils/circleContainer.dart';
import 'package:AccuChat/utils/custom_container.dart';
import 'package:AccuChat/utils/custom_flashbar.dart';
import 'package:AccuChat/utils/helper_widget.dart';
import 'package:AccuChat/utils/text_style.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../../../../utils/hover_glass_effect_widget.dart';
import '../../../../utils/networl_shimmer_image.dart';
import '../../../Chat/screens/auth/Presentation/Views/landing_screen.dart';
import '../Controllers/all_settings_controller.dart';

class AllSettingsScreen extends GetView<AllSettingsController> {
  const AllSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final bool isWide = size.width >= 800;
    const double maxContentWidth = 550;

    return GetBuilder<AllSettingsController>(
      init: AllSettingsController(),
      builder: (controller) {
        return Scaffold(
          body: Container(
            constraints: BoxConstraints(
              maxWidth: isWide ? maxContentWidth : double.infinity,
            ),
            decoration: const BoxDecoration(
              image: DecorationImage(image: AssetImage(loginbg),fit: BoxFit.cover,opacity:kIsWeb? .5:.1)
            ),
            
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: isWide ? 16 : 0),
              child: _buildContent(context, controller, isWide),
            ),
          ),
        );
      },
    );
  }

  Future<void> openProfileDialog() async {
    final c=  Get.put(HProfileController());

    try {
      await Get.dialog(
        Dialog(
          clipBehavior: Clip.antiAlias,
          insetPadding: const EdgeInsets.all(12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: SizedBox(
            width: 600,
            height: Get.height * 0.95,
            child: ProfileScreen(),
          ),
        ),
        barrierDismissible: true,
      );
    } finally {
      if (Get.isRegistered<HProfileController>()) {
        Get.delete<HProfileController>();
      }
    }
  }

  Future<void> openPvcDialog(cnt) async {
    try {
      await Get.dialog(
        Dialog(
          clipBehavior: Clip.antiAlias,
          insetPadding: const EdgeInsets.all(12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: SizedBox(
            width: 600,
            height: Get.height * 0.95,
            child: HtmlViewer(
              htmlContent: cnt,
            ),
          ),
        ),
        barrierDismissible: true,
      );
    }catch(e){
    }
  }

  Widget _buildContent(BuildContext context, AllSettingsController controller, bool isWide) {
    return SingleChildScrollView(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            backApp(context, "Settings"),
            vGap(20,),
            HoverGlassEffect(
              // margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
              borderRadius: 12,
              hoverScale: 1.015,
              normalBlur: 1,
              hoverBlur: 10,
              /*hoverGradient: LinearGradient(colors: [
                gallwhite,
                perpleBg,
                  ]),*/
              gradient: LinearGradient(colors: [
                gallwhite,
                perpleBg,
              ]),
              child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: (){
                    if(kIsWeb && Get.width>600){
                      openProfileDialog();
                    }else{
                      Get.toNamed(AppRoutes.h_profile);
                    }
                  },
                  child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        CustomCacheNetworkImage(
                          "${ApiEnd.baseUrlMedia}${APIs.me.userImage??''}",
                          height: isWide ? 100 : 80,
                          width: isWide ? 100 : 80,
                          boxFit: BoxFit.cover,
                          defaultImage: ICON_profile,
                          radiusAll: 100,
                          borderColor: Colors.black54,
                        ),
                        hGap(isWide ? 14 : 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  CircleContainer(colorIS: Colors.greenAccent,setSize: 6,),
                                  hGap(5),
                                  Text(
                                    APIs.me.userName!=null?APIs.me.userName??'':APIs.me.userCompany?.displayName??'',
                                    style: BalooStyles.baloosemiBoldTextStyle(),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                ],
                              ),
                              vGap(4),

                              Text(
                                APIs.me.phone??'',
                                style: BalooStyles.balooregularTextStyle(),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ).paddingOnly(bottom: 4),
                              Text(
                                APIs.me.about??'',
                                style: BalooStyles.balooregularTextStyle(size: 13,color: greyText),
                                overflow: TextOverflow.ellipsis,

                                maxLines: 2,
                              ).paddingOnly(bottom: 4),
                            ],
                          ),
                        ),
                      ],
                    ),
                ),
            ).marginSymmetric(horizontal: 12,vertical: 8),
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
                if(kIsWeb && Get.width>600){
                  openProfileDialog();
                }else{
                  Get.toNamed(AppRoutes.h_profile);
                }

              },
            ),  _buildTile(
              icon: Icons.insert_invitation_outlined,
              title: 'Invitations',
              onTap: () {
                if(kIsWeb){
                  openAcceptInviteDialog();
                }else{
                  Get.toNamed(AppRoutes.accept_invite);
                }
              },
            ),  _buildTile(
              icon: Icons.privacy_tip_outlined,
              title: 'Privacy Policy',
              onTap: () {
                if(kIsWeb && Get.width>600){
                  openPvcDialog(controller.pvcContent);
                }else{
                  Get.to(() => HtmlViewer(
                    htmlContent: controller.pvcContent,
                  ));
                }


              },
            ),
            _buildTile(
              icon: Icons.info_outline,
              title: 'About Us',
              onTap: () {
                if(kIsWeb && Get.width>600){
                  openPvcDialog(controller.aboutUsContent);
                }else{
                  Get.to(() => HtmlViewer(
                    htmlContent: controller.aboutUsContent,
                  ));
                }

              },
            ),
            controller.myCompany?.createdBy == APIs.me.userId?  _buildTile(
              icon: Icons.people_outline,
              title: 'Manage Roles',
              onTap: () => Get.toNamed(AppRoutes.roles),
            ):const SizedBox(),
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
                await showResponsiveLogoutDialog(context);
              },
            ),
            const SizedBox(height: kIsWeb ? 16 : 0),
          ],
        ),
      ),
    );
  }

  Widget _buildTile(
      {required IconData icon,
        required String title,
        required VoidCallback onTap}) {
    return HoverGlassEffect(
      // margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
      borderRadius: 12,
      hoverScale: 1.015,
      normalBlur: 2,
      hoverBlur: 10,
      /*hoverGradient: LinearGradient(colors: [
        gallwhite,
        perpleBg,
      ]),*/ gradient: LinearGradient(colors: [
      whiteselected,
      gallwhite,
      ]),
      onTap: onTap,
      child: ListTile(
        enabled: false,
          dense: true,
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
          visualDensity: kIsWeb ? const VisualDensity(vertical: -1) : VisualDensity.standard,
        ),
    ).marginSymmetric(horizontal: 12,vertical: 4);
  }
}
