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
import '../../../../Services/subscription/billing_service.dart';
import '../../../../routes/app_routes.dart';
import '../../../../utils/product_shimmer_widget.dart';
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
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      const Icon(
                        Icons.add,
                        color: Colors.white,
                      ),
                      Positioned(
                          top: -22,
                          right: -15,
                          // child: Image.asset(
                          child: SvgPicture.asset(
                            connectedAppIcon,
                            height: 20,
                          ))
                    ],
                  )),
            ),
            body: GetBuilder<CompaniesController>(
                init: CompaniesController(),
                builder: (controller) {
                  return RefreshIndicator(
                    onRefresh: () async => controller.refreshCompanies(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Flexible(
                              child: SectionHeader(
                                title: 'Companies',
                                icon: connectedAppIcon,
                              ),
                            ),
                            InkWell(
                              onTap: () async {
                                controller.refreshCompanies();
                              },
                              child: const Icon(
                                Icons.refresh,
                                color: Colors.black87,
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
                  );
                })),
      );
}
