import 'package:AccuChat/Screens/Chat/screens/chat_tasks/Presentation/Controllers/task_home_controller.dart';
import 'package:AccuChat/Screens/Home/Presentation/Controller/compnaies_controller.dart';
import 'package:AccuChat/Services/APIs/api_ends.dart';
import 'package:AccuChat/main.dart';
import 'package:AccuChat/utils/helper_widget.dart';
import 'package:AccuChat/utils/loading_indicator.dart';
import 'package:AccuChat/utils/networl_shimmer_image.dart';
import 'package:AccuChat/utils/text_style.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../Constants/assets.dart';
import '../../../../Constants/colors.dart';
import '../../../../routes/app_routes.dart';
import '../Controller/company_service.dart';
import '../Controller/home_controller.dart';
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

                    if(kIsWeb){
                      Get.toNamed(
                        "${AppRoutes.create_company}?isHome='1'",
                      );
                    }else {
                      Get.toNamed(
                          AppRoutes.create_company,
                          arguments: {'isHome': true});
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
                    child: SingleChildScrollView(
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
                          vGap(12),

                          /*FutureBuilder<List<CompanyModel>>(
                      future: APIs.fetchJoinedCompanies(),
                      initialData: controller.initData,
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) return SizedBox();
                        final companies = snapshot.data!;
                        bool isAdminOfCompany = false;

                        for (var company in companies) {
                          if (company.id == APIs.me.selectedCompany?.id) {
                            if (company.adminUserId == APIs.me.id) {
                              isAdminOfCompany = true;
                            }
                            break;
                          }
                        }

                        return companies.isNotEmpty
                            ? SizedBox(
                          height: Get.height * .7,
                          child: SingleChildScrollView(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                ...companies.map(
                                        (CompanyModel companyData)
                                    {

                                      return
                                        FutureBuilder(
                                            future: APIs.getPendingInvitationCount(
                                              companyData.id??'',
                                            ),
                                            builder: (context, snapshot) {
                                              return

                                              Stack(
                                                clipBehavior: Clip.none,
                                                children: [
                                                  ChatCard(
                                                    cardColor: companyData.id ==
                                                        APIs.me.selectedCompany?.id
                                                        ? Colors.white
                                                        : Colors.grey.shade200,
                                                    iconWidget: SizedBox(
                                                      width: 50,
                                                      child: CustomCacheNetworkImage(
                                                          radiusAll: 100,
                                                          companyData?.logoUrl ?? ''),
                                                    ),
                                                    trailWidget:
                                                    Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Text(companyData.name ?? '',style: BalooStyles.baloosemiBoldTextStyle(),maxLines: 1,overflow: TextOverflow.ellipsis,),
                                                        vGap(4),
                                                        Text("(creator: ${companyData.adminUserId == APIs.me.id ?APIs.me.phone:companyData.name})",style: BalooStyles.baloonormalTextStyle(size: 14),maxLines: 1,overflow: TextOverflow.ellipsis,),
                                                      ],
                                                    ),
                                                    title: '',
                                                    subtitleTap: (){
                                                      if(companyData.id ==
                                                          APIs.me.selectedCompany
                                                              ?.id) {
                                                        Get.toNamed(AppRoutes.companyMemberRoute,
                                                            arguments: {
                                                              'companyId': companyData
                                                                  .id ?? '',
                                                              'companyName': companyData
                                                                  .name ?? ''
                                                            });
                                                      }else{
                                                        Get.snackbar(
                                                            'Company Not Selected',
                                                            'Tap on this card to select this company to show or chat/task to that member!',
                                                            duration: Duration(seconds: 4),
                                                            backgroundColor: Colors.white.withOpacity(.9),colorText: Colors.black);
                                                      }

                                                    },
                                                    subtitle:
                                                    'members: ${companyData.members?.length ?? 0}',
                                                    onTap: () async {
                                                      await controller.changeCompany(companyData);

                                                      await APIs.getSelfInfo();
                                                      controller.update();
                                                    },
                                                  ),
                                                  companyData.id ==
                                                            APIs.me.selectedCompany
                                                                ?.id && APIs.me.role =='admin'
                                                  // companyData.adminUserId == APIs.me.id
                                                  // isAdminOfCompany
                                                      ? Positioned(
                                                    right: 15,
                                                    top: 8,
                                                    child: dynamicButton(
                                                        name: "",
                                                        onTap: () {
                                                          // controller.updateIndex(1);
                                                          // setState(() {
                                                          //   isTaskMode =false;
                                                          // });

                                                          Get.toNamed(AppRoutes.inviteMemberRoute,
                                                              arguments: {
                                                                'company': companyData,
                                                                'invitedBy': APIs.me.id,
                                                              }
                                                          );
                                                        },
                                                        isShowText: true,
                                                        isShowIconText: true,
                                                        // gradient: buttonGradient,
                                                        vPad: 5,
                                                        hPad: 0,
                                                        color: Colors.black,
                                                        iconColor: Colors.black,
                                                        leanIcon: addUserIcon)
                                                        .paddingOnly(top: 0),
                                                  )
                                                      : const SizedBox(),
                                                  Positioned(
                                                    top: -12,
                                                    right: 12,
                                                    child: Container(
                                                      padding: const EdgeInsets.all(5),
                                                      decoration: BoxDecoration(
                                                          borderRadius:
                                                          BorderRadius.circular(10),
                                                          color: companyData.createdBy ==
                                                              APIs.me.id
                                                              ? appColorGreen
                                                              .withOpacity(.1)
                                                              : appColorYellow
                                                              .withOpacity(.1)),
                                                      child: Text(
                                                        companyData.createdBy ==
                                                            APIs.me.id
                                                            ? "Creator"
                                                            : "Joined",
                                                        style: BalooStyles
                                                            .balooregularTextStyle(
                                                            color: companyData
                                                                .createdBy ==
                                                                APIs.me.id
                                                                ? appColorGreen
                                                                : appColorYellow,
                                                            size: 11),
                                                      ),
                                                    ),
                                                  ),
                                                  (companyData.createdBy == APIs.me.id && companyData.id ==
                                                      APIs.me.selectedCompany?.id)
                                                      ? Positioned(
                                                    left: -5,
                                                    top: -10,
                                                    child: InkWell(
                                                      onTap: () {

                                                        // _goToUpdate(companyData);
                                                        Get.toNamed(AppRoutes.updateCompanyRoute,
                                                        arguments:
                                                        {
                                                                    'company':
                                                                        companyData
                                                                  },);
                                                      },
                                                      child: Container(
                                                        padding:
                                                        const EdgeInsets.all(3),
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
                                                      :  SizedBox(),

                                                  (isAdminOfCompany && APIs.me.id == companyData.adminUserId)
                                                      ? Positioned(
                                                    right: 15,
                                                    bottom: 15,
                                                    child: InkWell(
                                                      onTap: () {
                                                        Get.toNamed(
                                                            AppRoutes.invitationsRoute,
                                                          arguments: {
                                                            'companyID': companyData.id??'',
                                                          }
                                                        );
                                                      },
                                                      child: Text(
                                                        "Invites(${snapshot.data??0})",
                                                        style: BalooStyles
                                                            .balooregularTextStyle(
                                                            color:
                                                            appColorGreen),
                                                      ),
                                                    ),
                                                  )
                                                      : const SizedBox(),
                                                ],
                                              ).paddingOnly(bottom: 12);
                                            }
                                        );

                                    }
                                )
                              ],
                            ).paddingSymmetric(vertical: 12, horizontal: 10),
                          ),
                        )
                            : DataNotFoundText();
                      },
                    ),
*/
                          controller.loadingCompany
                              ? const IndicatorLoading()
                              : ListView.builder(
                                  shrinkWrap: true,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 10),
                                  itemCount:
                                      controller.joinedCompaniesList.length,
                                  itemBuilder: (context, index) {
                                    final companyData =
                                        controller.joinedCompaniesList[index];
                                    return Stack(
                                      clipBehavior: Clip.none,
                                      children: [
                                        ChatCard(
                                          cardColor: companyData.companyId ==
                                                  controller
                                                      .selCompany?.companyId
                                              ? Colors.white
                                              : Colors.grey.shade200,
                                          iconWidget: SizedBox(
                                            width: 50,
                                            child: CustomCacheNetworkImage(
                                                radiusAll: 100,
                                                height:50,
                                                width: 50,
                                                '${ApiEnd.baseUrlMedia}${companyData.logo ?? ''}',
                                            boxFit: BoxFit.cover,),
                                          ),
                                          trailWidget: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                (companyData.companyName ?? '')
                                                    .toUpperCase(),
                                                style: BalooStyles
                                                    .baloosemiBoldTextStyle(),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              vGap(4),
                                              Text(
                                                "(creator: ${companyData.createdBy == controller.me?.userId ? controller.me?.phone : (companyData.companyName ?? ''.toUpperCase())})",
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
                                            // Get.toNamed(
                                            //     '${AppRoutes.companyMemberRoute}?companyId=${companyData.companyId}&companyName=${companyData.companyName ?? ''}');
                                            customLoader.show();
                                            final svc = Get.find<CompanyService>();
                                            await svc.select(companyData);
                                            customLoader.hide();
                                            controller.getCompany();
                                            controller.update();

                                              if (kIsWeb) {
                                                Get.toNamed(
                                                    '${AppRoutes.company_members}?companyId=${companyData.companyId}&companyName=${companyData.companyName ?? ''}');
                                              } else {
                                                Get.toNamed(
                                                    AppRoutes
                                                        .company_members,
                                                    arguments: {
                                                      'companyId': companyData
                                                              .companyId ??
                                                          0,
                                                      'companyName': companyData
                                                              .companyName ??
                                                          ''
                                                    });

                                              // print(companyData.companyId);
                                              // print(controller
                                              //     .selCompany?.companyId);
                                              // Get.snackbar(
                                              //     'Company Not Selected',
                                              //     'Tap on this card to select this company to show or chat/task to that member!',
                                              //     backgroundColor: Colors.white
                                              //         .withOpacity(.9),
                                              //     colorText: Colors.black);
                                            }
                                          },
                                          subtitle:
                                              'members: ${companyData.members?.length ?? 0}',
                                          onTap: () async {
                                            // await controller.changeCompany(companyData);
                                            // await APIs.getSelfInfo();
                                            customLoader.show();
                                            final svc = Get.find<CompanyService>();
                                            await svc.select(companyData);
                                            customLoader.hide();
                                            controller.getCompany();
                                            controller.update();
                                          },
                                        ),
                                        /*  companyData.companyId ==
                                                    controller.selCompany
                                                        ?.companyId &&
                                                (controller.selCompany
                                                        ?.createdBy) ==
                                                    controller.me?.userId
                                            // companyData.adminUserId == APIs.me.id
                                            // isAdminOfCompany
                                            ?*/
                                        Positioned(
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
                                                  value, companyData);
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
                                        )

                                        /*Positioned(
                                                right: 15,
                                                top: 8,
                                                child: dynamicButton(
                                                        name: "",
                                                        onTap: () {
                                                          // controller.updateIndex(1);
                                                          // setState(() {
                                                          //   isTaskMode =false;
                                                          // });
                                                          if (kIsWeb) {
                                                            Get.toNamed(
                                                                '${AppRoutes.inviteMemberRoute}?companyId=${companyData.companyId.toString()}&invitedBy=${companyData.createdBy}&companyName=${companyData.companyName}');
                                                          } else {
                                                            Get.toNamed(
                                                                AppRoutes
                                                                    .inviteMemberRoute,
                                                                arguments: {
                                                                  'companyName':
                                                                      companyData
                                                                          .companyName,
                                                                  'companyId':
                                                                      companyData
                                                                          .companyId,
                                                                  'invitedBy':
                                                                      companyData
                                                                          .createdBy,
                                                                });
                                                          }
                                                        },
                                                        isShowText: true,
                                                        isShowIconText: true,
                                                        // gradient: buttonGradient,
                                                        vPad: 5,
                                                        hPad: 0,
                                                        color: Colors.black,
                                                        iconColor: Colors.black,
                                                        leanIcon: addUserIcon)
                                                    .paddingOnly(top: 0),
                                              )*/
                                        ,
                                            Positioned(
                                          top: -12,
                                          right: 12,
                                          child: Container(
                                            padding: const EdgeInsets.all(5),
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                color: companyData.createdBy ==
                                                        controller.me?.userId
                                                    ? appColorGreen
                                                        .withOpacity(.1)
                                                    : appColorYellow
                                                        .withOpacity(.1)),
                                            child: Text(
                                              companyData.createdBy ==
                                                      controller.me?.userId
                                                  ? "Creator"
                                                  : "Joined",
                                              style: BalooStyles
                                                  .balooregularTextStyle(
                                                      color: companyData
                                                                  .createdBy ==
                                                              controller
                                                                  .me?.userId
                                                          ? appColorGreen
                                                          : appColorYellow,
                                                      size: 11),
                                            ),
                                          ),
                                        ),
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
                                    ).paddingOnly(bottom: 12);
                                  }),

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
                      ).marginSymmetric(horizontal: 15, vertical: 20),
                    ),
                  );
                })),
      );
}
