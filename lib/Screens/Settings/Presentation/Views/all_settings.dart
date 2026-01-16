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
import 'package:flutter/foundation.dart' show kIsWeb; // added for web checks
import '../../../../Constants/themes.dart';
import '../../../../Services/APIs/local_keys.dart';
import '../../../../utils/custom_dialogue.dart';
import '../../../../utils/gradient_button.dart';
import '../../../../utils/networl_shimmer_image.dart';
import '../../../Chat/screens/auth/Presentation/Views/landing_screen.dart';
import '../Controllers/all_settings_controller.dart';

class AllSettingsScreen extends GetView<AllSettingsController> {
  // HProfileController profileController = Get.put(HProfileController());
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final bool isWide = size.width >= 900; // responsive breakpoint
    final double maxContentWidth = 900; // keeps content nicely centered on web

    return GetBuilder<AllSettingsController>(
      init: AllSettingsController(),
      builder: (controller) {
        return Scaffold(
          appBar: AppBar(
            title:  Text('Settings',style: BalooStyles.balooboldTitleTextStyle(),),
            // Slightly increase toolbar height on very wide web to breathe
            toolbarHeight: isWide ? 64 : kToolbarHeight,
          ),
          // ====== Responsive wrapper starts here (keeps your original ListView unchanged inside) ======
          body: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: isWide ? maxContentWidth : double.infinity,
              ),
              child: Padding(
                // add gentle horizontal padding on wide screens
                padding: EdgeInsets.symmetric(horizontal: isWide ? 16 : 0),
                child: _buildContent(context, controller, isWide),
              ),
            ),
          ),
          // ====== Responsive wrapper ends here ======
        );
      },
    );
  }

  // Pulled your original ListView into a method so we can keep it intact and just wrap it responsively.
  Widget _buildContent(BuildContext context, AllSettingsController controller, bool isWide) {
    return ListView(
      children: [
        InkWell(
          onTap: (){
            try {
              Get.back();
              final con = Get.find<DashboardController>();
              con.updateIndex(2);
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
                  // APIs.me.selectedCompany?.logoUrl ?? '',
                  "${ApiEnd.baseUrlMedia}${controller.myCompany?.logo??''}",
                  height: isWide ? 64 : 50,           // responsive: slightly larger on web
                  width: isWide ? 64 : 50,
                  boxFit: BoxFit.cover,
                  radiusAll: 100,
                  borderColor: Colors.black54,
                ),
                hGap(isWide ? 14 : 10),
                Expanded( // responsive: allow long names/emails to wrap nicely
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        // APIs.me.selectedCompany?.name ?? '',
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
        /* _buildTile(
          icon: Icons.person,
          title: 'Profile',
          onTap: () => Get.toNamed(AppRoutes.hProfileRoute),
        ),*/

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
       kIsWeb?SizedBox(): _buildTile(
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
        // Add some bottom space on web so last tile isn't glued to the bottom
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
      // compact a bit on web; keeps mobile feel on phones
      visualDensity: kIsWeb ? const VisualDensity(vertical: -1) : VisualDensity.standard,
    );
  }
}













// import 'package:AccuChat/Screens/Home/Presentation/Controller/profile_controller.dart';
// import 'package:AccuChat/Screens/Settings/Presentation/Views/static_page.dart';
// import 'package:AccuChat/Services/APIs/api_ends.dart';
// import 'package:AccuChat/routes/app_routes.dart';
// import 'package:AccuChat/utils/custom_container.dart';
// import 'package:AccuChat/utils/custom_flashbar.dart';
// import 'package:AccuChat/utils/helper_widget.dart';
// import 'package:AccuChat/utils/text_style.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import '../../../../Constants/themes.dart';
// import '../../../../utils/custom_dialogue.dart';
// import '../../../../utils/gradient_button.dart';
// import '../../../../utils/networl_shimmer_image.dart';
// import '../../../Chat/api/apis.dart';
// import '../Controllers/all_settings_controller.dart';
//
// class AllSettingsScreen extends GetView<AllSettingsController> {
//   // HProfileController profileController = Get.put(HProfileController());
//   @override
//   Widget build(BuildContext context) {
//     return GetBuilder<AllSettingsController>(
//       init: AllSettingsController(),
//       builder: (controller) {
//         return Scaffold(
//           appBar: AppBar(
//             title: const Text('Settings'),
//           ),
//           body: ListView(
//             children: [
//               CustomContainer(
//                 elevation: 1,
//                 childWidget: Row(
//                   children: [
//                     CustomCacheNetworkImage(
//                       // APIs.me.selectedCompany?.logoUrl ?? '',
//                       "${ApiEnd.baseUrlMedia}${controller.myCompany?.logo??''}",
//                       height: 50,
//                       width: 50,
//                       boxFit: BoxFit.cover,
//                       radiusAll: 100,
//                       borderColor: Colors.black54,
//                     ),
//                     hGap(10),
//                     Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           // APIs.me.selectedCompany?.name ?? '',
//                           (controller.myCompany?.companyName??"").toUpperCase(),
//                           style: BalooStyles.baloosemiBoldTextStyle(),
//                         ),
//                         vGap(4),
//                        Text(
//                          controller.myCompany?.email==null?
//                          controller.myCompany?.phone??"": controller.myCompany?.email??'',
//                             style: BalooStyles.balooregularTextStyle(),),
//                       ],
//                     ),
//                   ],
//                 ),
//               ).marginSymmetric(horizontal: 12,vertical: 12),
//              /* _buildTile(
//                 icon: Icons.person,
//                 title: 'Profile',
//                 onTap: () => Get.toNamed(AppRoutes.hProfileRoute),
//               ),*/
//
//               controller.settingsItems.isEmpty?Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 15.0,vertical: 8),
//                 child: Text("Loading..."),
//               ):SizedBox(),
//               ...controller.settingsItems.map((nav) {
//                 return ListTile(
//                   leading: Icon(controller.iconForSetting(nav), size: 20),
//                   title: Text(nav.navigationItem??'',
//                       style: BalooStyles.baloonormalTextStyle()),
//                   trailing: Icon(Icons.arrow_forward_ios, size: 15, color: Colors.grey),
//                   onTap: controller.onTapForSetting(nav, controller),
//                 );
//               }).toList(),
//               _buildTile(
//                 icon: Icons.privacy_tip_outlined,
//                 title: 'Privacy Policy',
//                 onTap: () {
//                   Get.to(() => HtmlViewer(
//                         htmlContent: controller.pvcContent,
//                       ));
//                 },
//               ),
//               _buildTile(
//                 icon: Icons.info_outline,
//                 title: 'About Us',
//                 onTap: () {
//                   Get.to(() => HtmlViewer(
//                         htmlContent: controller.aboutUsContent,
//                       ));
//                 },
//               ),
//              /* _buildTile(
//                 icon: Icons.people_outline,
//                 title: 'Manage Roles',
//                 onTap: () => Get.toNamed(AppRoutes.roleListRoute),
//               ),*/
//               _buildTile(
//                   icon: Icons.support_agent,
//                   title: 'Support',
//                   onTap: () {
//                     toast('Under Development!');
//                   }),
//               divider().paddingSymmetric(vertical: 12),
//               _buildTile(
//                 icon: Icons.settings,
//                 title: 'App Settings',
//                 onTap: () => controller.openAppSettingsPage(),
//               ),
//
//
//               /*_buildTile(
//                 icon: Icons.logout,
//                 title: 'Logout',
//                 onTap: () async {
//                   showDialog(
//                       context: Get.context!,
//                       builder: (_) => CustomDialogue(
//                             title: "Logout",
//                             isShowAppIcon: false,
//                             content: Column(
//                               crossAxisAlignment: CrossAxisAlignment.center,
//                               mainAxisSize: MainAxisSize.min,
//                               children: [
//                                 vGap(20),
//                                 Text(
//                                   "Do you really want to Logout?",
//                                   style: BalooStyles.baloonormalTextStyle(),
//                                   textAlign: TextAlign.center,
//                                 ),
//
//                                 vGap(30),
//                                 Row(
//                                   children: [
//                                     Expanded(
//                                       child: GradientButton(
//                                         name: "Yes",
//                                         btnColor: AppTheme.redErrorColor,
//                                         gradient: LinearGradient(colors: [
//                                           AppTheme.redErrorColor,
//                                           AppTheme.redErrorColor
//                                         ]),
//                                         vPadding: 6,
//                                         onTap: () async {
//                                           await profileController.signOutUser();
//                                         },
//                                       ),
//                                     ),
//                                     hGap(15),
//                                     Expanded(
//                                       child: GradientButton(
//                                         name: "Cancel",
//                                         btnColor: Colors.black,
//                                         color: Colors.black,
//                                         gradient: LinearGradient(colors: [
//                                           AppTheme.whiteColor,
//                                           Colors.white
//                                         ]),
//                                         vPadding: 6,
//                                         onTap: () {
//                                           Get.back();
//                                         },
//                                       ),
//                                     ),
//                                   ],
//                                 )
//                               ],
//                             ),
//                             onOkTap: () {},
//                           ));
//                 },
//               ),*/
//             ],
//           ),
//         );
//       },
//     );
//   }
//
//   Widget _buildTile(
//       {required IconData icon,
//       required String title,
//       required VoidCallback onTap}) {
//     return ListTile(
//       leading: Icon(
//         icon,
//         size: 18,
//       ),
//       title: Text(
//         title,
//         style: BalooStyles.baloonormalTextStyle(),
//       ),
//       trailing: const Icon(
//         Icons.arrow_forward_ios,
//         size: 15,
//         color: Colors.grey,
//       ),
//       onTap: onTap,
//     );
//   }
// }
