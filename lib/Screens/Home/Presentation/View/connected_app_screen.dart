import 'package:AccuChat/Constants/themes.dart';
import 'package:AccuChat/Screens/Chat/api/apis.dart';
import 'package:AccuChat/Screens/Chat/screens/auth/landing_screen.dart';
import 'package:AccuChat/Screens/Home/Presentation/Controller/home_controller.dart';
import 'package:AccuChat/Screens/Home/Presentation/View/invitations_screens.dart';
import 'package:AccuChat/Screens/Home/Presentation/View/invite_member.dart';
import 'package:AccuChat/Screens/Home/Presentation/View/show_company_members.dart';
import 'package:AccuChat/Screens/Home/Presentation/View/update_company_screen.dart';
import 'package:AccuChat/main.dart';
import 'package:AccuChat/utils/data_not_found.dart';
import 'package:AccuChat/utils/helper_widget.dart';
import 'package:AccuChat/utils/loading_indicator.dart';
import 'package:AccuChat/utils/networl_shimmer_image.dart';
import 'package:AccuChat/utils/text_style.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:swipe_to/swipe_to.dart';

import '../../../../Constants/assets.dart';

import '../../../../Constants/colors.dart';
import '../../../../routes/app_routes.dart';
import '../../../../utils/custom_dialogue.dart';
import '../../../../utils/custom_flashbar.dart';
import '../../../Chat/models/chat_user.dart';
import '../../../Chat/models/company_model.dart';
import '../../../Chat/screens/auth/create_company_screen.dart';
import '../../../Chat/screens/auth/join_company_screen.dart';
import 'home_screen.dart';
import 'main_screen.dart';

class ConnectedAppsScreen extends StatefulWidget {
  @override
  State<ConnectedAppsScreen> createState() => _ConnectedAppsScreenState();
}

class _ConnectedAppsScreenState extends State<ConnectedAppsScreen> {
  DashboardController homeController = Get.put(DashboardController());

  int? inviteCount;

  void _refreshCompanies() async {
    initData = await APIs.fetchJoinedCompanies();

    if(mounted) {
      setState(() {});
      homeController.update();
    }

  }

  void _goToUpdate(companyData) async {
    bool isDeleted = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => UpdateCompanyScreen(
                company: companyData,
              )),
    );

    if (isDeleted) {
      _refreshCompanies(); // Refresh the Home Page if the company is deleted
    }
  }

  var initData;

  @override
  void initState() {
    _refreshCompanies();
    super.initState();
  }



  @override
  Widget build(BuildContext context) => SafeArea(
        child: Scaffold(
            floatingActionButton: Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: FloatingActionButton(
                  onPressed: () {
                    Get.to(() => CreateCompanyScreen(
                      isHome: true,
                    ));
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

                          child: Image.asset(connectedAppIcon,height: 20,))
                    ],
                  )),
            ),
            body: RefreshIndicator(
          onRefresh: () async => _refreshCompanies(),
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
                        _refreshCompanies();
                      },
                      child: const Icon(Icons.refresh,color: Colors.black87,),
                    ).paddingAll(0)
                  ],
                ),
                vGap(12),


                FutureBuilder<List<CompanyModel>>(
                  future: APIs.fetchJoinedCompanies(),
                  initialData: initData,
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
                                  return Stack(
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
                                                Get.to(()=>CompanyMembers(comapnyID: companyData.id ?? '', comapnyName: companyData.name ?? ''));
                                              },
                                              subtitle:
                                                  'members: ${companyData.members?.length ?? 0}',
                                              onTap: () async {
                                                customLoader.show();
                                                final userDoc = FirebaseFirestore
                                                    .instance
                                                    .collection('users')
                                                    .doc(APIs.me.id);
                                                await userDoc.update({
                                                  // 'company': FieldValue.arrayUnion([company.toJson()]),
                                                  'selectedCompany':
                                                      companyData.toJson(),
                                                });


                                                APIs.me.selectedCompany =
                                                    companyData;

                                                if(APIs.me.selectedCompany?.adminUserId==APIs.me.id){
                                                  await userDoc.update({
                                                    'role': 'admin',
                                                  });
                                                }else{
                                                  await userDoc.update({
                                                    'role': 'member',
                                                  });
                                                }
                                                customLoader.hide();
                                                setState(() {});
                                              },
                                            ),
                                            /*companyData.id ==
                                                        APIs.me.selectedCompany
                                                            ?.id*/
                                            companyData.adminUserId == APIs.me.id
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
                                                              Get.to(() =>
                                                                  InviteMembersScreen(
                                                                    company: companyData,
                                                                    invitedBy:
                                                                        APIs.me.id,
                                                                  ));
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
                                                        Get.to(() => UpdateCompanyScreen(
                                                              company:
                                                              companyData,
                                                            ));
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
                                                        Get.to(() =>
                                                            InvitationsScreen(comapnyID: companyData.id??'',));
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

                // ListView.builder(
                //   shrinkWrap: true,
                //   padding: EdgeInsets.symmetric(vertical: 10),
                //   physics: NeverScrollableScrollPhysics(),
                //   itemCount: APIs.me.company?.length,
                //   itemBuilder: (context, index) => Stack(
                //     children: [
                //       Container(
                //         padding: EdgeInsets.all(1),
                //         decoration: BoxDecoration(
                //             borderRadius: BorderRadius.circular(12),
                //             border: Border.all(
                //                 color: APIs.me.company?[index].id ==
                //                         APIs.me.selectedCompany?.id
                //                     ? appColorGreen
                //                     : Colors.transparent)),
                //         child: ChatCard(
                //             iconWidget: CustomCacheNetworkImage(
                //                 radiusAll: 100,
                //                 APIs.me.selectedCompany?.logoUrl ?? ''),
                //             trailWidget:
                //                 Text(APIs.me.selectedCompany?.name ?? ''),
                //             title: APIs.me.selectedCompany?.email ?? '',
                //             subtitle:
                //                 'members: ${APIs.me.selectedCompany?.members?.length ?? 0}',
                //             onTap: () {}),
                //       ),
                //       TextButton(
                //           onPressed: () {}, child: Text('Update',style:BalooStyles.baloosemiBoldTextStyle(color: appColorGreen),))
                //     ],
                //   ),
                // ),
                //   }

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
        )),
      );

}
