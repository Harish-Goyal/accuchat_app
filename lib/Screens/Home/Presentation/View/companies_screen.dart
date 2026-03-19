import 'package:AccuChat/Screens/Home/Presentation/Controller/compnaies_controller.dart';
import 'package:AccuChat/Screens/Home/Presentation/View/company_card.dart';
import 'package:AccuChat/Screens/Home/Presentation/View/pending_invites_animated.dart';
import 'package:AccuChat/Services/subscription/billing_controller.dart';
import 'package:AccuChat/utils/helper_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import '../../../../Constants/assets.dart';
import '../../../../Constants/colors.dart';
import '../../../../Services/APIs/api_ends.dart';
import '../../../../Services/subscription/billing_service.dart';
import '../../../../routes/app_routes.dart';
import '../../../../utils/circleContainer.dart';
import '../../../../utils/networl_shimmer_image.dart';
import '../../../../utils/product_shimmer_widget.dart';
import '../../../../utils/text_style.dart';
import 'home_screen.dart';

class CompaniesScreen extends GetView<CompaniesController> {
  const CompaniesScreen({super.key});





  @override
  Widget build(BuildContext context) => SafeArea(
        child: Scaffold(
            floatingActionButton: Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: FloatingActionButton(
                  onPressed: () {
                    if (kIsWeb) {
                      // Get.toNamed(
                      //   "${AppRoutes.create_company}?isHome='1'",
                      // );
                      final service = BillingService(
                        baseUrl: 'https://api.accuchat.example',
                        authTokenProvider: () async => '<JWT>',
                      );
                      final billingCtrl = Get.put(BillingController(service));
                      controller.onCreateCompanyPressed(billingCtrl);
                    } else {
                      final service = BillingService(
                        baseUrl: 'https://api.accuchat.example',
                        authTokenProvider: () async => '<JWT>',
                      );
                      final billingCtrl = Get.put(BillingController(service));
                      controller.onCreateCompanyPressed(billingCtrl);
                      // Get.toNamed(
                      //     AppRoutes.create_company,
                      //     arguments: {'isHome': true});
                    }
                  },
                  backgroundColor: appColorGreen,
                  child: const Icon(
                    Icons.add,
                    color: Colors.white,
                  )),
            ),
            body: GetBuilder<CompaniesController>(
                init: CompaniesController(),
                builder: (controller) {
                  return RefreshIndicator(
                    onRefresh: () async => controller.refreshCompanies(),
                    child: Container(
                      decoration: const BoxDecoration(
                        image: DecorationImage(image: AssetImage(loginbg),fit: BoxFit.cover,opacity:kIsWeb? .5:.04)
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                flex: 2,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 40,
                                      // margin: EdgeInsets.only(left: 10),
                                      decoration: BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle,boxShadow: [
                                        BoxShadow(color: greenside.withOpacity(.5),blurRadius: 5)
                                      ]
                                      ),
                                      child: controller.selCompany?.logo!=null? CustomCacheNetworkImage(
                                        "${ApiEnd.baseUrlMedia}${controller.selCompany?.logo ?? ''}",
                                        radiusAll: 100,
                                        height: 40,
                                        width: 40,
                                        borderColor: appColorYellow,
                                        defaultImage: appIcon,
                                        boxFit: BoxFit.cover,
                                        isApp: true,
                                      ):CircleAvatar(
                                        // radius: 45,
                                        backgroundColor: Colors.white,
                                        child: Text(getInitials(controller.selCompany?.companyName ?? ''),style: BalooStyles.baloosemiBoldTextStyle(color: greenside,size: 20),),
                                      ),
                                    ).paddingAll(3),
                                    Expanded(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Companies',
                                            style: BalooStyles.baloomediumTextStyle(
                                                size: 14),
                                          ).paddingOnly(left: 4, top: 4),
                                          Row(
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            mainAxisSize: MainAxisSize.min,

                                            children: [
                                              CircleContainer(colorIS: Colors.greenAccent,setSize: 5.0,),
                                              Text(
                                                (controller.selCompany?.companyName ?? ''),
                                                style: BalooStyles.baloomediumTextStyle(
                                                  color: appColorYellow,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ).paddingOnly(left: 4, top: 2),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),

                                  ],
                                ),
                              ),

                              InkWell(
                                onTap: () async {
                                  controller.refreshCompanies();
                                },
                                child: GradientContainer(
                                  color1: greenside.withOpacity(.4),
                                  color2:greenside ,
                                  child: const Icon(
                                    Icons.refresh,
                                    color: Colors.white,
                                  ),
                                ),
                              ).paddingAll(0)
                            ],
                          ),
                          shimmerEffectWidget(
                            showShimmer: controller.isLoadingInvited,
                            shimmerWidget: shimmerlistItem(
                                height: 100, horizonalPadding: 12),
                            child: AnimationLimiter(
                              child: controller.pendingInvitesList == [] ||
                                      controller.pendingInvitesList.isEmpty
                                  ? const SizedBox()
                                  : ConstrainedBox(
                                constraints: const BoxConstraints(
                                  maxWidth:
                                  kIsWeb ? 500 : double.infinity,
                                ),
                                    child: PendingInvitesCard(
                                        invitesCount:
                                            controller.pendingInvitesList.length,
                                        companyNames: controller.pendingInvitesList
                                            .map(
                                                (v) => v.company?.companyName ?? '')
                                            .toList(),
                                        onTap: () {
                                          if(kIsWeb){
                                            openAcceptInviteDialog();
                                          }else{
                                            Get.toNamed(AppRoutes.accept_invite);
                                          }
                                        },
                                      ),
                                  ),
                            ),
                          ),
                          shimmerEffectWidget(
                            showShimmer: controller.loadingCompany,
                            shimmerWidget: shimmerlistView(
                                count: 2,
                                child: shimmerlistItem(
                                    height: 80, horizonalPadding: 20)),
                            child: AnimationLimiter(
                                child: Expanded(
                              child: ListView.builder(
                                  shrinkWrap: true,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 20),
                                  itemCount:
                                      controller.joinedCompaniesList.length,
                                  itemBuilder: (context, index) {
                                    final companyData =
                                        controller.joinedCompaniesList[index];
                                    final bool isSelected =
                                        companyData.companyId ==
                                            controller.selCompany?.companyId;
                                    return Align(
                                      alignment: Alignment.centerLeft,
                                      child: SizedBox(
                                          width: kIsWeb ? 420 : double.infinity,
                                          child: CompanyCardModern(companyData: companyData, controller: controller, isLanding: false,)),
                                    );
                                  }),
                            )),
                          ),
                      
                          /*!(APIs.me.role == 'admin')
                            ? const SizedBox()
                            : */
                          /*buildCompanyMembersList(
                        APIs.me.selectedCompany?.id ?? ''),*/
                          /* Align(
                        alignment: Alignment.bottomCenter,
                        child: dynamicButton(
                            name: "Connect New Company",
                            onTap: () {
                      
                            },
                            isShowText: true,
                            isShowIconText: true,
                            gradient: buttonGradient,
                            iconColor: Colors.white,
                            leanIcon: connectedAppIcon)),*/
                        ],
                      ).marginSymmetric(horizontal: 15, vertical: 15),
                    ),
                  );
                })),
      );
}
