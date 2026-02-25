
import 'package:AccuChat/Constants/colors.dart';
import 'package:AccuChat/Screens/Home/Presentation/Controller/invitations_controller.dart';
import 'package:AccuChat/utils/custom_dialogue.dart';
import 'package:AccuChat/utils/data_not_found.dart';
import 'package:AccuChat/utils/text_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:get/get.dart';
import '../../../../utils/helper_widget.dart';
import '../../../../utils/product_shimmer_widget.dart';

class InvitationsScreen extends GetView<InvitationsController> {
  const InvitationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<InvitationsController>(builder: (controller) {
      return Scaffold(
        appBar: AppBar(      scrolledUnderElevation: 0,
          surfaceTintColor: Colors.white,
          title: Text(
            'Invitations',
            style: BalooStyles.balooboldTitleTextStyle(),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                controller.initData();
                // You can call the resend invite function here
              },
            )
          ],
        ),
        body: shimmerEffectWidget(
          // showShimmer:true,
          showShimmer: controller.isLoading,
          shimmerWidget: shimmerlistView(
              child: shimmerlistItem(height: 100, horizonalPadding: 20)),
          child: AnimationLimiter(
              child: controller.sentInviteList.isNotEmpty
                  ? ListView.builder(
                      shrinkWrap: true,
                      itemCount: controller.sentInviteList.length,
                      itemBuilder: (context, i) {
                        final invitation = controller.sentInviteList[i];
                        return Slidable(
                          key: ValueKey(invitation.inviteId),
                          endActionPane: ActionPane(
                            motion: const DrawerMotion(),
                            extentRatio: 0.3,
                            children: [
                              SlidableAction(
                                onPressed: (_) async {
                                  controller.hitAPIToDeleteInvitations(
                                      invitation.inviteId);
                                },
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.red,
                                icon: Icons.delete,
                                label: 'Delete',
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ],
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                                backgroundColor: appColorYellow.withOpacity(.1),
                                child: Icon(
                                  Icons.person,
                                  color: appColorYellow,
                                )),
                            title: Text(
                                invitation.contactName ?? 'AccuChat member',
                                style: BalooStyles.baloomediumTextStyle()),
                            subtitle: Text(invitation.toPhoneEmail ?? '',
                                style: BalooStyles.baloonormalTextStyle()),
                            onLongPress: () {
                              showDialog(
                                  context: context,
                                  builder: (_) => AlertDialog(
                                    backgroundColor: Colors.white,
                                        content: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              "Delete Invitations",
                                              style: BalooStyles
                                                  .baloosemiBoldTextStyle(),
                                            ),
                                            vGap(8),
                                            Text(
                                              "The invite you have sent has been deleted! click OK!",
                                              style: BalooStyles
                                                  .baloonormalTextStyle(),
                                            ),
                                            vGap(30),
                                            dynamicButton(
                                                name: "Ok",
                                                onTap: () => controller
                                                    .hitAPIToDeleteInvitations(
                                                        invitation.inviteId),
                                                isShowText: true,
                                                gradient:LinearGradient(colors: [Colors.red,Colors.red]),
                                                color: Colors.white,
                                                isShowIconText: false,
                                                leanIcon: '')
                                          ],
                                        ),
                                      ));
                            },
                          ),
                        );
                      },
                    )
                  : Center(
                      child: SizedBox(height: 150, child: DataNotFoundText(height: 150,)))),
        ),
      );
    });
  }
}
