import 'package:AccuChat/Screens/Chat/screens/auth/Presentation/Controllers/accept_invite_controller.dart';
import 'package:AccuChat/Services/APIs/api_ends.dart';
import 'package:AccuChat/utils/data_not_found.dart';
import 'package:AccuChat/utils/text_style.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../../Constants/colors.dart';
import '../../../../../../utils/custom_container.dart';
import '../../../../../../utils/custom_dialogue.dart';
import '../../../../../../utils/helper_widget.dart';
import '../../../../../../utils/networl_shimmer_image.dart';

class AcceptInvitationScreen extends GetView<AcceptInviteController> {
  const AcceptInvitationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(      scrolledUnderElevation: 0,
          surfaceTintColor: Colors.white,title: Text("Pending Invitations", style: BalooStyles.balooboldTitleTextStyle())),
      body: GetBuilder<AcceptInviteController>(
        builder: (controller) {
          return controller.pendingInvitesList.isEmpty?Center(

              child: SizedBox(
                  height: Get.height*.6,
                  width:  Get.width * 0.8,
                  child: DataNotFoundText())):
          ListView.builder(
            shrinkWrap: true,
            itemCount: controller.pendingInvitesList.length,
            itemBuilder: (context, i) {
              final invites = controller.pendingInvitesList[i];

              return CustomContainer(
                color: Colors.white,
                vPadding: 15,
                childWidget: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                        width:50,
                        child:

                        CustomCacheNetworkImage(
                          "${ApiEnd.baseUrlMedia}${invites.company?.logo ?? ''}",
                          height: 50,
                          width: 50,

                          boxFit: BoxFit.cover,
                          radiusAll: 100,
                          borderColor: greyText,
                        )),
                    hGap(10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Invited via, ",
                            style: BalooStyles.balooregularTextStyle(),
                          ),
                          vGap(4),
                          Text(
                            (invites.company?.companyName ?? ''),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: BalooStyles.baloosemiBoldTextStyle(),
                          ),
                        ],
                      ),
                    ),
                    dynamicButton(
                      btnColor: appColorGreen,
                      onTap: () async=>  controller.hitAPIToAcceptInvite(invites.inviteId,invites.company?.companyId),
                      gradient: buttonGradient,
                      vPad: 8,
                      name: "Accept",
                      isShowText: true,
                      isShowIconText: false,
                      leanIcon: null,
                    ).paddingSymmetric(vertical: 8)
                  ],
                ),
              ).paddingSymmetric(horizontal: 15, vertical: 12);
            },
          );
        }
      ),
    );
  }

}
