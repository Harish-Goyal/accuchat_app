import 'package:AccuChat/Screens/Chat/screens/chat_tasks/Presentation/Controllers/task_home_controller.dart';
import 'package:AccuChat/Screens/Home/Presentation/Controller/compnaies_controller.dart';
import 'package:AccuChat/Screens/Home/Presentation/View/pending_invites_animated.dart';
import 'package:AccuChat/Services/APIs/api_ends.dart';
import 'package:AccuChat/Services/subscription/billing_controller.dart';
import 'package:AccuChat/main.dart';
import 'package:AccuChat/utils/helper_widget.dart';
import 'package:AccuChat/utils/loading_indicator.dart';
import 'package:AccuChat/utils/networl_shimmer_image.dart';
import 'package:AccuChat/utils/text_style.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:get/get.dart';
import '../../../../Constants/assets.dart';
import '../../../../Constants/colors.dart';
import '../../../../Services/subscription/billing_service.dart';
import '../../../../routes/app_routes.dart';
import '../../../../utils/product_shimmer_widget.dart';
import '../../../Chat/api/apis.dart';
import '../../../Chat/screens/chat_tasks/Presentation/Controllers/chat_home_controller.dart';
import '../../../Chat/screens/chat_tasks/Presentation/Controllers/chat_screen_controller.dart';
import '../../../Chat/screens/chat_tasks/Presentation/Controllers/task_controller.dart';
import '../Controller/company_service.dart';
import '../Controller/home_controller.dart';
import '../Controller/socket_controller.dart';
import 'home_screen.dart';

class CompaniesScreen extends GetView<CompaniesController> {
  CompaniesScreen({super.key});
  final dash = Get.put(DashboardController());

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
                          child: Image.asset(
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
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Flexible(
                              child: SectionHeader(
                                title: 'Your Companies',
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
                                : PendingInvitesCard(
                                    invitesCount:
                                        controller.pendingInvitesList.length,
                                    companyNames: controller.pendingInvitesList
                                        .map(
                                            (v) => v.company?.companyName ?? '')
                                        .toList(),
                                    onTap: () {
                                      Get.toNamed(AppRoutes.accept_invite);
                                    },
                                  ),
                          ),
                        ),
                        shimmerEffectWidget(
                          showShimmer: controller.loadingCompany,

                          // showShimmer: true,
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
                                          controller
                                              .selCompany?.companyId;
                                  return Center(
                                      child: ConstrainedBox(
                                      constraints: BoxConstraints(
                                      maxWidth: kIsWeb ? 600 : double.infinity,
                                  ),
                                    child: Stack(
                                      clipBehavior: Clip.none,
                                      children: [
                                        ChatCard(
                                          cardColor: companyData.companyId ==
                                                  controller.selCompany?.companyId
                                              ? Colors.white
                                              : Colors.grey.shade200,
                                          isSelected: companyData.companyId ==
                                              controller
                                                  .selCompany?.companyId,
                                          brcolor: companyData.companyId ==
                                              controller.selCompany?.companyId
                                              ? appColorPerple.withOpacity(.2)
                                              : Colors.grey.shade200,
                                          iconWidget: Container(
                                            decoration:BoxDecoration(
                                              shape: BoxShape.circle,
                                              border: Border.all(color: greyText)
                                            ) ,
                                            child: CustomCacheNetworkImage(
                                              radiusAll: 100,
                                              height: 50,
                                              width: 50,
                                              // borderColor: greyText,
                                              '${ApiEnd.baseUrlMedia}${companyData.logo ?? ''}',
                                              boxFit: BoxFit.cover,
                                              defaultImage: appIcon,
                                            ),
                                          ).paddingOnly(left: 6),
                                          trailWidget: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                children: [
                                    /*
                                                  companyData.companyId ==
                                                      controller
                                                          .selCompany?.companyId?Image.asset(pinnedPng,height: 18,width: 15,):SizedBox(),
                                    */
                                                  Expanded(
                                                    child: Text(
                                                      (companyData.companyName ?? '')
                                                          .toUpperCase(),
                                                      style: BalooStyles.baloosemiBoldTextStyle(),
                                                      maxLines: 1,
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              vGap(4),
                                              Text(
                                                "Creator: ${companyData.createdBy == controller.me?.userId ? controller.me?.phone : (companyData.companyName ?? ''.toUpperCase())}",
                                                style: BalooStyles
                                                    .baloonormalTextStyle(
                                                        size: 14),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                          ),
                                          title: '',
                                          subtitleTap: () async {
                                            customLoader.show();
                                            // Get.find<SocketController>().initial();
                                            final svc = CompanyService.to;
                                            await svc.select(companyData);
                                            controller.getCompany();
                                            await APIs.refreshMe(
                                                companyId:controller.selCompany?.companyId??0);
                                            Get.find<SocketController>().connectUserEmitter(companyData.companyId);
                                            controller.update();
                                            customLoader.hide();
                                            if (kIsWeb) {
                                              Get.toNamed(
                                                  '${AppRoutes.company_members}?companyId=${companyData.companyId}&companyName=${companyData.companyName ?? ''}');
                                            } else {
                                              Get.toNamed(
                                                  AppRoutes.company_members,
                                                  arguments: {
                                                    'companyId':
                                                        companyData.companyId ??
                                                            0,
                                                    'companyName':
                                                        companyData.companyName ??
                                                            ''
                                                  });
                                            }
                                          },
                                          subtitle:
                                              'members: ${companyData.members?.length ?? 0}',
                                          onTap: () async {
                                            customLoader.show();
                                            // Get.find<SocketController>().initial();
                                            final svc = CompanyService.to;
                                            await svc.select(companyData);
                                            controller.getCompany();
                                            await APIs.refreshMe(
                                                companyId: controller.selCompany?.companyId??0);
                                            Get.find<SocketController>().connectUserEmitter(companyData.companyId);


                                            customLoader.hide();
                                            controller.update();
                                          },
                                        ),
                                        Positioned(
                                          top: 8,
                                          right: 5,
                                          child: Builder(
                                            builder: (context) {
                                              final bool isSelected =
                                                  companyData.companyId ==
                                                      controller
                                                          .selCompany?.companyId;
                                              final bool isCreator =
                                                  companyData.createdBy ==
                                                      controller.me?.userId;

                                              // Hide the 3-dot entirely if not the selected company
                                              if (!isSelected)
                                                return const SizedBox.shrink();

                                              // Show 3-dot; items depend on role
                                              return PopupMenuButton<String>(
                                                color: Colors.white,
                                                icon: const Icon(Icons.more_vert,
                                                    color: Colors.black87),
                                                onSelected: (value) =>
                                                    controller.companyNavigation(
                                                        value, companyData),
                                                itemBuilder: (context) {
                                                  final List<
                                                          PopupMenuEntry<String>>
                                                      items = [];

                                                  if (isCreator) {
                                                    // Invite (creator + mobile only)

                                                      items.add(
                                                        const PopupMenuItem(
                                                          value: 'Invite',
                                                          child: Row(children: [
                                                            Icon(
                                                                Icons
                                                                    .person_add_alt,
                                                                size: 15,
                                                                color: Colors
                                                                    .black87),
                                                            SizedBox(width: 4),
                                                            Text('Invite Member'),
                                                          ]),
                                                        ),
                                                      );


                                                    // Pending (creator)
                                                    items.add(
                                                      const PopupMenuItem(
                                                        value: 'Pending',
                                                        child: Row(children: [
                                                          Icon(
                                                              Icons
                                                                  .pending_outlined,
                                                              size: 15,
                                                              color:
                                                                  Colors.black87),
                                                          SizedBox(width: 4),
                                                          Text('Pending Invites'),
                                                        ]),
                                                      ),
                                                    );

                                                    // Update (creator)
                                                    items.add(
                                                      const PopupMenuItem(
                                                        value: 'Update',
                                                        child: Row(children: [
                                                          Icon(
                                                              Icons.edit_outlined,
                                                              size: 15,
                                                              color:
                                                                  Colors.black87),
                                                          SizedBox(width: 4),
                                                          Text('Update Company'),
                                                        ]),
                                                      ),
                                                    );
                                                  }

                                                  // All Members (everyone)
                                                  items.add(
                                                    const PopupMenuItem(
                                                      value: 'All',
                                                      child: Row(children: [
                                                        Icon(Icons.people,
                                                            size: 15,
                                                            color:
                                                                Colors.black87),
                                                        SizedBox(width: 4),
                                                        Text('All Members'),
                                                      ]),
                                                    ),
                                                  );

                                                  return items;
                                                },
                                              );
                                            },
                                          ),
                                        ),

                                        companyData.companyId ==
                                            controller
                                                .selCompany?.companyId?   Positioned(
                                          top: 4,
                                          left: 4,
                                          // right: 0,
                                          child:Transform.scale(
                                            scale: 1.2,
                                            child: CupertinoCheckbox(
                                              activeColor: appColorGreen,
                                                value: companyData.companyId ==
                                                controller
                                                    .selCompany?.companyId, onChanged: (v){}),
                                          )
                                        ):const SizedBox(),

                                        /*   Positioned(
                                              top: 8,
                                              right: 5,
                                              child: PopupMenuButton<String>(
                                                color: Colors.white,
                                                icon: const Icon(
                                                  Icons.more_vert,
                                                  color: Colors.black87,
                                                ),
                                                onSelected: (value) {
                                                  controller.companyNavigation(
                                                      value,companyData);
                                                },
                                                itemBuilder: (context) => [
                                                  PopupMenuItem(
                                                      value: 'Invite',
                                                      child:
                                                      // companyData.adminUserId == APIs.me.id
                                                      // isAdminOfCompany
                                                      Row(
                                                        children: [
                                                          const Icon(Icons.person_add_alt,size: 15,color: Colors.black87,),
                                                          hGap(4),
                                                          const Text('Invite Member'),
                                                        ],
                                                      )),
                                                  PopupMenuItem(
                                                      value: 'Pending',
                                                      child:
                                                      Row(
                                                        children: [
                                                          const Icon(Icons.pending_outlined,size: 15,color: Colors.black87,),
                                                          hGap(4),
                                                          const Text('Pending Invites') ],
                                                      )),
                                                  PopupMenuItem(
                                                      value: 'Update',
                                                      child:Row(
                                                        children: [
                                                          const Icon(Icons.edit_outlined,size: 15,color: Colors.black87),
                                                          hGap(4),
                                                          const Text('Update Company')],
                                                      )),
                                                  PopupMenuItem(
                                                      value: 'All',
                                                      child:Row(
                                                          children: [
                                                            const Icon(Icons.people,size: 15,color: Colors.black87),
                                                            hGap(4),
                                                            const Text('All Members')])),
                                                ],
                                              ),
                                            )*/

                                        Positioned(
                                          top: -18,
                                          right: 10,
                                          child: Container(
                                            padding: const EdgeInsets.all(6),
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    const BorderRadius.only(topRight: Radius.circular(30),
                                                        topLeft: Radius.circular(30),bottomRight: Radius.circular(30)),
                                                color: companyData.createdBy ==
                                                        controller.me?.userId
                                                    ? appColorGreen
                                                        .withOpacity(.1)
                                                    : appColorYellow
                                                        .withOpacity(.1),
                                              border: Border.all(color:appColorPerple.withOpacity(.1) )
                                            ),
                                            child: Text(
                                              companyData.createdBy ==
                                                      controller.me?.userId
                                                  ? "Creator"
                                                  : "Joined",
                                              style: BalooStyles
                                                  .baloosemiBoldTextStyle(
                                                      color:
                                                          companyData.createdBy ==
                                                                  controller
                                                                      .me?.userId
                                                              ? appColorGreen
                                                              : appColorYellow,
                                                      size: 12),
                                            ),
                                          ),
                                        ),

                                        (companyData.createdBy ==
                                            controller.me?.userId &&companyData.companyId ==
                                            controller
                                                .selCompany?.companyId ) ?
                                        (controller.sentInviteList.isNotEmpty ||controller.sentInviteList.length!=0 )?
                                        Positioned(
                                          bottom: 20,
                                          right: 20,
                                          child: InkWell(
                                            onTap: (){
                                              controller.companyNavigation(
                                                  "Pending", companyData);
                                            },
                                            child: Container(
                                              padding: const EdgeInsets.all(6),
                                              decoration: BoxDecoration(
                                                  shape:BoxShape.circle,
                                                  color:appColorPerple
                                                          .withOpacity(.1),
                                              border: Border.all(color: appColorPerple)),
                                              child: Text(
                                                "${controller.sentInviteList.length}",
                                                style: BalooStyles
                                                    .baloosemiBoldTextStyle(
                                                        color:appColorPerple,),
                                              ),
                                            ),
                                          ),
                                        ):const SizedBox():const SizedBox(),
                                        /*
                                          (companyData.createdBy ==
                                                      controller.me?.userId &&
                                                  companyData.companyId ==
                                                      controller
                                                          .selCompany?.companyId)
                                              ? Positioned(
                                                  left: -5,
                                                  top: -10,
                                                  child: InkWell(
                                                    onTap: () {
                                                      // _goToUpdate(companyData);
                                                      Get.toNamed(
                                                        AppRoutes
                                                            .updateCompanyRoute,
                                                        arguments: {
                                                          'company': companyData
                                                        },
                                                      );
                                                    },
                                                    child: Container(
                                                      padding:
                                                          const EdgeInsets.all(6),
                                                      margin:
                                                          const EdgeInsets.all(3),
                                                      decoration: BoxDecoration(
                                                          shape: BoxShape.circle,
                                                          color: appColorGreen
                                                              .withOpacity(.1)),
                                                      child: Icon(
                                                        Icons.edit_outlined,
                                                        color: appColorGreen,
                                                      ),
                                                    ),
                                                  ),
                                                )
                                              : SizedBox(),
                                                    //TODO
                                          (controller.selCompany?.createdBy ==
                                                  companyData.createdBy)
                                              ? (controller.sentInviteList
                                                              ?.length ??
                                                          0) >
                                                      0
                                                  ? Positioned(
                                                      right: 15,
                                                      bottom: 15,
                                                      child: InkWell(
                                                        onTap: () {
                                                          Get.toNamed(
                                                              AppRoutes
                                                                  .invitationsRoute,
                                                              arguments: {
                                                                'companyID':
                                                                    companyData
                                                                            .companyId ??
                                                                        '',
                                                                'inviteList':
                                                                    controller
                                                                            .sentInviteList ??
                                                                        [],
                                                              });
                                                        },
                                                        child: Text(
                                                          "Invites(${controller.sentInviteList?.length})",
                                                          style: BalooStyles
                                                              .balooregularTextStyle(
                                                                  color:
                                                                      appColorGreen),
                                                        ),
                                                      ),
                                                    )
                                                  : SizedBox()
                                              : const SizedBox(),*/
                                      ],
                                    ).paddingOnly(bottom: 12),
                                      )  );
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
