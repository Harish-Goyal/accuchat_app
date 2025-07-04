// UI
import 'package:AccuChat/Constants/assets.dart';
import 'package:AccuChat/Constants/themes.dart';
import 'package:AccuChat/Screens/chat_module/presentation/controllers/group_member_controller.dart';
import 'package:AccuChat/Screens/chat_module/presentation/controllers/user_chat_list_controller.dart';
import 'package:AccuChat/routes/app_routes.dart';
import 'package:AccuChat/utils/backappbar.dart';
import 'package:AccuChat/utils/custom_container.dart';
import 'package:AccuChat/utils/custom_flashbar.dart';
import 'package:AccuChat/utils/custom_scaffold.dart';
import 'package:AccuChat/utils/gradient_button.dart';
import 'package:AccuChat/utils/helper_widget.dart';
import 'package:AccuChat/utils/loading_indicator.dart';
import 'package:AccuChat/utils/networl_shimmer_image.dart';
import 'package:AccuChat/utils/seachbar_widget.dart';
import 'package:AccuChat/utils/text_style.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:get/get.dart';

import '../../../../utils/product_shimmer_widget.dart';
import '../../models/user_chat_list_model.dart';

class AddMemberPage extends GetView<GroupController> {
  AddMemberPage({super.key});

  GroupController groupController = Get.put(GroupController());

  String groupMembersID = '';
  @override
  Widget build(BuildContext context) {


    return safeAreWidget();
  }

  safeAreWidget() {
    return MyAnnotatedRegion(
      child: GetBuilder<GroupController>(builder: (controller) {
        return CustomScaffold(
            appBar: backAppBar(title: 'Add Members'),
            extendBodyBehindAppBar: true,
            body: _mainBuild());
      }),
    );
  }

  _mainBuild() {

    List<UserChatListData> filteredUsersList =groupController.searchQuary.isEmpty?groupController.filteredUsers: (groupController.filteredUsers??[])
        .where((user) => (user.userName??'').toLowerCase().contains(groupController.searchQuary))
        .toList();
    return Column(
      children: [
        CustomSearchBarAnimated(lable: "Users", searchController: groupController.searchMemController, onChangedVal: (val){
          controller.searchQuary =val;
          controller.update();

        }).marginSymmetric(horizontal: 10),
        vGap(10),

        Expanded(
          child: shimmerEffectWidget(
            showShimmer: controller.showPostShimmer,
            shimmerWidget: shimmerlistView(child: GroupMemberShimmer()),
            child: (filteredUsersList != null &&
                filteredUsersList.length != 0)
                ? AnimationLimiter(
                    child: ListView.builder(
                      itemCount: filteredUsersList.length,
                      itemBuilder: (context, index) {
                        final member = filteredUsersList[index];
                        return CustomContainer(
                          vPadding: 6,
                          hPadding: 10,
                          childWidget: ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: CustomCacheNetworkImage(
                              width: 40,
                              height: 40,
                              radiusAll: 100,
                              borderColor: AppTheme.appColor.withOpacity(.2),
                              member.employee?.empImage ?? '',
                              defaultImage: userIcon,
                            ),
                            title: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  member?.employee?.empName ?? '',
                                  style: BalooStyles.baloomediumTextStyle(),
                                 ),
                              ],
                            ),
                            trailing: /* controller.createById.toString() ==
                          member?.user?.userId.toString()
                          ? SizedBox()
                          :*/
                                Container(
                              width: 23,
                              height: 23,
                              child: CupertinoCheckbox(
                                value: member?.isSelected,
                                side: BorderSide(color: Colors.grey.shade400),
                                activeColor: AppTheme.appColor,
                                onChanged: (value) {
                                  groupController.toggleSelectAdd(member);
                                  // if (value == true) {
                                    groupController.updateSelectedIdsAdds();
                                  // }
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
     groupController.isLoading? IndicatorLoading():  GradientButton(
            name: "Submit",
            onTap: () {
              if(groupController.selectedMemberIdsAdds.isNotEmpty){
                groupController.addRemoveGroupMemAPI(
                    memberIds: groupController.selectedMemberIdsAdds);
                groupController.selectedMemberIdsAdds = '';
                groupController.update();
                Get.back();
              }else{
                errorDialog("Please select member to add");
              }
            }).marginSymmetric(horizontal: 20, vertical: 20)
      ],
    );
  }
}
