// UI
import 'package:AccuChat/Constants/assets.dart';
import 'package:AccuChat/Constants/colors.dart';
import 'package:AccuChat/Constants/themes.dart';
import 'package:AccuChat/Screens/chat_module/presentation/controllers/group_member_controller.dart';
import 'package:AccuChat/Services/APIs/local_keys.dart';
import 'package:AccuChat/main.dart';
import 'package:AccuChat/routes/app_routes.dart';
import 'package:AccuChat/utils/backappbar.dart';
import 'package:AccuChat/utils/custom_container.dart';
import 'package:AccuChat/utils/custom_flashbar.dart';
import 'package:AccuChat/utils/custom_scaffold.dart';
import 'package:AccuChat/utils/helper_widget.dart';
import 'package:AccuChat/utils/loading_indicator.dart';
import 'package:AccuChat/utils/networl_shimmer_image.dart';
import 'package:AccuChat/utils/text_style.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:get/get.dart';

import '../../../../utils/gradient_button.dart';
import '../../../../utils/product_shimmer_widget.dart';

class GroupMembersPage extends GetView<GroupController> {
  GroupMembersPage({super.key});



  @override
  Widget build(BuildContext context) {
    return safeAreWidget();
  }

  safeAreWidget() {
    return MyAnnotatedRegion(
      child: GetBuilder<GroupController>(builder: (controller) {
        return CustomScaffold(
            appBar: backAppBar(centertitle: false,title: controller.groupName ?? 'Group Members',actionss:
            [
              storage.read(userId).toString()==
                  controller.createById.toString()?   InkWell(
                onTap: (){


                  Get.toNamed(AppRoutes.addMemberPage,arguments: {"MemberList": controller.membersList});
                },
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 8,horizontal: 12),

                  child:  Text(
                    "Add Member",
                    style: BalooStyles.baloomediumTextStyle(color: AppTheme.appColor),
                  ),
                ),
              ):SizedBox(),
            ]),
            extendBodyBehindAppBar: true,
            body: _mainBuild());
      }),
    );
  }

  _mainBuild() {
    return Column(
      children: [
        Expanded(
          child: shimmerEffectWidget(
            showShimmer: controller.showPostShimmer,
            shimmerWidget: shimmerlistView(child: GroupMemberShimmer()),
            child: (controller.membersList != null &&
                    controller.membersList?.length != 0)
                ? AnimationLimiter(
                    child: ListView.builder(
                      itemCount: controller.membersList?.length,
                      itemBuilder: (context, index) {
                        final member = controller.membersList?[index];
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (member?.user?.userId.toString() != null) {
                            controller.groupMembersID =  member?.user?.userId.toString()??'';
                            controller.update();
                          }
                        });

                        // controller.update();
                        return CustomContainer(
                          vPadding: 6,
                          hPadding: 10,
                          // margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                          // elevation: 4,
                          // shape: RoundedRectangleBorder(
                          //   borderRadius: BorderRadius.circular(12),
                          // ),
                          childWidget: ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: SizedBox(
                              width: 40,
                              child: CustomCacheNetworkImage(
                                width: 40,
                                height: 40,
                                radiusAll: 100,
                                borderColor: AppTheme.appColor.withOpacity(.2),
                                member?.user?.empImage ?? '',
                                defaultImage: userIcon,
                              ),
                            ),
                            title: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  member?.user?.userName ?? '',
                                  style: BalooStyles.baloomediumTextStyle(),
                                ),
                                controller.createById.toString() ==
                                        member?.user?.userId.toString()
                                    ? Text(
                                        " (Admin)",
                                        style: BalooStyles.baloomediumTextStyle(
                                            color: Colors.green),
                                      )
                                    : SizedBox(),
                              ],
                            ),
                            trailing: controller.createById.toString() ==
                                    member?.user?.userId.toString()
                                ? SizedBox()
                                : Container(
                                    width: 23,
                                    height: 23,
                                    decoration: BoxDecoration(
                                        color: storage.read(userId).toString()==controller.createById.toString()
                                            ? null
                                            : Colors.grey.shade400,
                                        borderRadius: BorderRadius.circular(5)),
                                    child: CupertinoCheckbox(
                                      value: member?.isSelectedmember,
                                      side: BorderSide(color: Colors.grey.shade400),
                                      activeColor: storage.read(userId).toString()==controller.createById.toString()
                                          ? AppTheme.appColor
                                          : Colors.grey.shade400,
                                      onChanged: (value) {
                                        if (storage.read(userId).toString()==controller.createById.toString()) {

                                          // member?.isSelectedmember = !member.isSelectedmember;

                                          controller.toggleSelect(member);
                                          controller.isSubmit=true;
                                          controller.update();

                                            controller.updateSelectedIds();
                                        }
                                      },
                                    ),
                                  ),
                          ),
                        ).marginSymmetric(vertical: 6, horizontal: 15);
                      },
                    ),
                  )
                : Container(),
          ),
        ),

        controller.isLoading? IndicatorLoading():
        controller.createById.toString() ==
           storage.read(userId).toString()?
        GradientButton(
            name: "Submit",
            btnColor: controller.isSubmit?AppTheme.appColor:greyColor,
            onTap: () {
             var allSelectedIds= controller.selectedMemberIds.split(",");
              if(allSelectedIds.length ==controller.membersList?.length){
                toast("All Set");

              }else{
                controller.addRemoveGroupMemAPI(
                    memberIds: controller.selectedMemberIds );
              }



            }).marginSymmetric(horizontal: 20, vertical: 20):SizedBox()

      ],
    );
  }
}
