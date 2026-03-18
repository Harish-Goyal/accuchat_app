import 'package:AccuChat/Screens/Chat/screens/auth/Presentation/Controllers/landing_screen_controller.dart';
import 'package:AccuChat/Services/APIs/local_keys.dart';
import 'package:AccuChat/main.dart';
import 'package:AccuChat/utils/helper_widget.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import '../../../../../../Constants/assets.dart';
import '../../../../../../Constants/colors.dart';
import '../../../../../../Constants/themes.dart';
import '../../../../../../Services/APIs/api_ends.dart';
import '../../../../../../Services/APIs/auth_service/auth_api_services_impl.dart';
import '../../../../../../Services/hive_boot.dart';
import '../../../../../../Services/storage_service.dart';
import '../../../../../../routes/app_routes.dart';
import '../../../../../../utils/custom_dialogue.dart';
import '../../../../../../utils/gradient_button.dart';
import '../../../../../../utils/networl_shimmer_image.dart';
import '../../../../../../utils/shares_pref_web.dart';
import '../../../../../../utils/text_style.dart';
import '../../../../../Home/Presentation/Controller/company_service.dart';
import '../../../../../Home/Presentation/View/company_card.dart';
import '../../../../../Home/Presentation/View/home_screen.dart';
import '../../../../api/apis.dart';
import '../../../../api/session_alive.dart';
import '../../../../models/get_company_res_model.dart';

class LandingPage extends GetView<LandingScreenController> {
  const LandingPage({Key? key}) : super(key: key);



  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          appBar: AppBar(      scrolledUnderElevation: 0,
            surfaceTintColor: Colors.white,
            automaticallyImplyLeading: false,
            actions: [
              InkWell(
                  onTap: ()async {
                    showResponsiveLogoutDialog(context);
                  },
                  child: Container(
                      padding: const EdgeInsets.all(10),
                      child: const Icon(Icons.logout)))
            ],
          ),
        // body
        body: GetBuilder<LandingScreenController>(
          builder: (controller) {
            return LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 600;
                return Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: isWide ? 600 : double.infinity,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            vGap(20),
                            Text(
                              'Welcome to AccuChat',
                              style: BalooStyles.balooboldTextStyle(size: 18),
                              textAlign: TextAlign.center,
                            ),
                            vGap(10),
                            Image.asset(appIcon, width: 100),
                            // SvgPicture.asset(appIcon, width: 100),
                            vGap(20),

                            if (controller.joinedCompaniesList.isNotEmpty)
                              ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: controller.joinedCompaniesList.length,
                                itemBuilder: (context, i) {
                                  final company = controller.joinedCompaniesList[i];
                                  return  Align(
                                    alignment: Alignment.center,
                                    child: SizedBox(
                                        width: kIsWeb ? 420 : double.infinity,
                                        child: CompanyCardModern(companyData: company, isLanding: true,)),
                                  );










                                },
                              )
                            else
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                child: Center(
                                  child: SizedBox(
                                    width: Get.width * .5,
                                    child: Text(
                                      "You are not connected to any company! You can create or join company.",
                                      textAlign: TextAlign.center,
                                      style: BalooStyles.balooregularTextStyle(),
                                    ),
                                  ),
                                ),
                              ),

                            vGap(40),

                            SizedBox(
                              width:500,
                              child: Row(
                                children: [
                                  Expanded(
                                    child: dynamicButton(
                                      name: "Create Company",
                                      onTap: () {
                                       /* if (APIs.me.selectedCompany?.allowedCompany == 0) {
                                          toast("You are not allowed to create company more than 1! Contact Organization!");
                                        } else {
                                          Get.toNamed(AppRoutes.createCompanyRoute, arguments: {'isHome': false});
                                        }*/
                                        if(kIsWeb){
                                          openCreateCompanyDialog(false);
                                          // Get.toNamed(
                                          //   "${AppRoutes.create_company}?isHome=${0}",
                                          // );
                                        }else {
                                          Get.toNamed(
                                              AppRoutes.create_company,
                                              arguments: {'isHome': '0'});
                                        }
                                      },
                                      isShowText: true,
                                      isShowIconText: false,
                                      gradient: buttonGradient,
                                      leanIcon: 'assets/images/google.png',
                                    ),
                                  ),
                                  hGap(12),
                                  Expanded(
                                    child: dynamicButton(
                                      name: "Join Company",
                                      onTap: () async {
                                        /* await APIs.handleJoinCompany(
                                          context: context,
                                          emailOrPhone: APIs.me.phone == 'null'
                                              ? APIs.me.email
                                              : APIs.me.phone,
                                        );*/
                                        //TODO

                                        var mob = StorageService.getMobile();
                                        controller.hitAPIToGetPendingInvites(mob,context);
                                      },
                                      isShowText: true,
                                      isShowIconText: false,
                                      gradient: buttonGradient,
                                      leanIcon: 'assets/images/google.png',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            vGap(40),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),


         /* body:GetBuilder<LandingScreenController>(
              builder: (controller) {
                return Column(
                  children: [
                    vGap(15),
                    Text('Welcome to AccuChat',style: BalooStyles.balooboldTextStyle(size: 16),),
                    Image.asset(
                      appIcon,
                      width: 100,
                    ),

                    Expanded(
                      child: Container(
                        height: Get.height*.5,
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              ListView.builder(
                                shrinkWrap: true,
                                itemCount: controller.joinedCompaniesList.length,
                                itemBuilder: (context, i) {
                                  final company = controller.joinedCompaniesList[i];
                                  return controller.joinedCompaniesList.isNotEmpty? Column(
                                    children: [
                                      Column(
                                        children: [
                                          InkWell(
                                            onTap: () async{
                                              //TODO
                                              // await controller.selectCompany(companies);
                                              *//* Navigator.pushReplacement(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (_) => AccuChatDashboard()));*//*

                                              Get.toNamed(AppRoutes.home);
                                            },
                                            child: ChatCard(
                                              iconWidget: SizedBox(
                                                width: 50,
                                                child: CustomCacheNetworkImage(
                                                    radiusAll: 100,
                                                    company.logo ?? ''),
                                              ),
                                              title: company.companyName??'',
                                              subtitle:
                                              'Tap to enter this company',
                                              onTap: () async{
                                                Get.toNamed(AppRoutes.home);
                                              },),
                                          )


                                        ],
                                      ),
                                    ],
                                  ):Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      vGap(10),

                                      Center(child: SizedBox(
                                          width: Get.width*.7,
                                          child:  Text("You are not connected to any company! You can create or join company",textAlign: TextAlign.center,
                                            style: BalooStyles.balooregularTextStyle(),))),
                                    ],
                                  );
                                },
                              )
                            ],
                          ).marginSymmetric(horizontal: 15),
                        ),
                      ),
                    ),

                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: dynamicButton(
                                  name: "Create Company",
                                  onTap: () {
                                    if(APIs.me.selectedCompany?.allowedCompany==0)
                                    {
                                      toast("You are not allowed to create company more than 1! Contact Organization!");
                                    }
                                    else{
                                      Get.toNamed(AppRoutes.createCompanyRoute,arguments: {'isHome': false});
                                    }
                                  },
                                  isShowText: true,
                                  isShowIconText: false,
                                  gradient: buttonGradient,
                                  leanIcon: 'assets/images/google.png'),
                            ),
                          ],
                        ).marginSymmetric(horizontal: Get.height * .03),
                        vGap(20),
                        Row(
                          children: [
                            Expanded(
                              child: dynamicButton(
                                  name: "Join Company",
                                  onTap: () async{
                                    // Get.to(() => JoinCompanyScreen(
                                    //   type: 'join',

                                    // ));
                                    await APIs.handleJoinCompany(context:context, emailOrPhone:APIs.me.phone=='null'?APIs.me.email:APIs.me.phone);

                                  },
                                  isShowText: true,
                                  isShowIconText: false,
                                  gradient: buttonGradient,
                                  leanIcon: 'assets/images/google.png'),
                            ),
                          ],
                        ).marginSymmetric(horizontal: Get.height * .03),




                      ],
                    ).marginSymmetric(horizontal: 15),
                  ],
                );
              }
          )*/

      ),



    );
  }




}
Future<void> showResponsiveLogoutDialog(ctx) async {
  final size = MediaQuery.of(ctx).size;
  double targetWidth;
  if (size.width >= 1280) {
    targetWidth = size.width * 0.25; // desktop
  } else if (size.width >= 992) {
    targetWidth = size.width * 0.35; // laptop / large tablet
  } else if (size.width >= 768) {
    targetWidth = size.width * 0.5; // tablet
  } else {
    targetWidth = size.width * 0.85; // phones / small windows
  }

  targetWidth = targetWidth.clamp(360.0, 560.0);

  final maxHeight = size.height * 0.90;

  await Get.dialog(
    // Keeps dialog within safe areas and nicely centered
    SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: targetWidth,
            maxHeight: maxHeight,
          ),
          child: Material(
            color: Colors.transparent,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: SingleChildScrollView(
                // 👇 Your dialog code is untouched and placed as-is
                child: CustomDialogue(
                  title: "Logout",
                  isShowActions: false,
                  isShowAppIcon: false,
                  content: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      vGap(20),
                      Text(
                        "Do you really want to Logout?",
                        style: BalooStyles.baloonormalTextStyle(),
                        textAlign: TextAlign.center,
                      ),
                      vGap(30),
                      Row(
                        children: [
                          Expanded(
                            child: GradientButton(
                              name: "Yes",
                              btnColor: AppTheme.redErrorColor,
                              gradient: LinearGradient(
                                colors: [AppTheme.redErrorColor, AppTheme.redErrorColor],
                              ),
                              vPadding: 6,
                              onTap: () async {
                                imageCache.clear();
                                imageCache.clearLiveImages();
                                // logoutLocal();
                                hitAPIToDeletePushToken();
                              },
                            ),
                          ),
                          hGap(15),
                          Expanded(
                            child: GradientButton(
                              name: "Cancel",
                              btnColor: Colors.black,
                              color: Colors.black,
                              gradient: LinearGradient(
                                colors: [AppTheme.whiteColor, AppTheme.whiteColor],
                              ),
                              vPadding: 6,
                              onTap: () {
                                Get.back();
                              },
                            ),
                          ),
                        ],
                      ),
                      // Text(STRING_logoutHeading,style: BalooStyles.baloomediumTextStyle(),),
                    ],
                  ),
                  onOkTap: () {},
                ),
              ),
            ),
          ),
        ),
      ),
    ),
    barrierColor: Colors.black54, // nice dim on web
    name: 'logout_dialog',
  );
}