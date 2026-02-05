import 'package:AccuChat/Constants/colors.dart';
import 'package:AccuChat/Constants/themes.dart';
import 'package:AccuChat/Extension/text_field_extenstion.dart';
import 'package:AccuChat/utils/custom_container.dart';
import 'package:AccuChat/utils/helper_widget.dart';
import 'package:AccuChat/utils/text_style.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../utils/common_textfield.dart';
import '../../../../utils/gradient_button.dart';
import '../Controller/invite_member_with_role_controller.dart';

class InviteUserRoleScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<InviteUserRoleController>(
      init: InviteUserRoleController(),
      builder: (controller) {
        return Scaffold(
          appBar: AppBar(      scrolledUnderElevation: 0,
            surfaceTintColor: Colors.white,
            title: Text(
              'Members',
              style: BalooStyles.baloosemiBoldTextStyle(),
            ),
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: controller.selectAllRoles,
                        child: Text('Select All'),
                      ),
                      const SizedBox(width: 12),
                      TextButton(
                        onPressed: controller.deselectAllRoles,
                        child: Text('Deselect All'),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: Get.height * .7,
                  child: ListView.builder(
                    shrinkWrap: true,
                    physics: BouncingScrollPhysics(),
                    itemCount: controller.users.length,
                    itemBuilder: (context, index) {
                      final user = controller.users[index];
                      return Row(
                        children: [
                          SizedBox(
                              width: 30,
                              child: CupertinoCheckbox(
                                  value: user.isSelected,
                                  activeColor: appColorGreen,
                                  onChanged: (v) {
                                    controller.toggleRole(user, v);
                                  })),
                          Expanded(
                            child: CustomContainer(
                              elevation: 3,
                              vPadding: 5,
                              childWidget: Padding(
                                padding: const EdgeInsets.all(14),
                                child: Form(
                                  child: Column(
                                    children: [
                                      CustomTextField(
                                        hintText: "Display Name",
                                        borderColor: greyText,
                                        labletext: "Display Name in company",
                                        controller:
                                            controller.nameControllers[index],
                                        validator: (value) =>
                                            value?.isEmptyField(
                                                messageTitle: "Display Name"),
                                        onFieldSubmitted: (_) =>
                                            FocusScope.of(context).unfocus(),
                                        onChangee: (v) {
                                          controller.updateRoleForUser(
                                              user.mobile,
                                              controller.getRoleIdForUser(
                                                      user.mobile) ??
                                                  0,
                                              controller
                                                  .nameControllers[index].text
                                                  .trim(),
                                              index);
                                        },
                                      ),
                                      vGap(12),
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              '📞 ${user.mobile}',
                                              style: BalooStyles
                                                  .balooregularTextStyle(
                                                      color: AppTheme
                                                          .secondaryTextColor),
                                            ),
                                          ),
                                          hGap(8),
                                          Expanded(
                                            child: InkWell(
                                              onTap: () {
                                                /*showDialog(
                                              context: context,
                                              builder: (_) => StatefulBuilder(
                                                  builder: (context, setState) {
                                                return AlertDialog(
                                                  backgroundColor: Colors.white,
                                                  title: Column(
                                                    children: [
                                                      Text(
                                                        'Role Assignment',
                                                        style: BalooStyles
                                                            .baloosemiBoldTextStyle(),
                                                      ),
                                                      vGap(10),
                                                      Text(
                                                        'You can assign role to this specific user buy selecting one of the role! Thanks!',
                                                        style: BalooStyles
                                                            .balooregularTextStyle(),
                                                      ),
                                                    ],
                                                  ),
                                                  contentPadding:
                                                      const EdgeInsets.symmetric(
                                                          horizontal: 12,
                                                          vertical: 40),
                                                  content: SingleChildScrollView(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment.start,
                                                      children: controller.rolesList
                                                          .map((perm) {
                                                        return InkWell(
                                                          onTap: () {
                                                            controller.updateRoleForUser(user.mobile, perm.userCompanyRoleId ?? 0,user.name,);
                                                            Get.back();

                                                          },
                                                          child: CustomContainer(
                                                            childWidget: Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceBetween,
                                                              children: [
                                                                Row(
                                                                  children: [
                                                                    Icon(
                                                                      Icons
                                                                          .circle_rounded,
                                                                      size: 10,
                                                                      color:
                                                                          appColorGreen,
                                                                    ),
                                                                    hGap(4),
                                                                    Text(
                                                                      ((perm.userRole ?? '').capitalizeFirst)??'',
                                                                      style: BalooStyles
                                                                          .balooregularTextStyle(),
                                                                      maxLines: 1,
                                                                      overflow: TextOverflow.ellipsis,
                                                                    ),
                                                                  ],
                                                                ),
                                                                const Icon(
                                                                  Icons
                                                                      .arrow_forward_ios,
                                                                  size: 15,
                                                                  color: Colors.grey,
                                                                )
                                                              ],
                                                            ),
                                                          ),
                                                        ).marginAll(5);
                                                      }).toList(),
                                                    ),
                                                  ),
                                                );
                                              }),
                                            );*/
                                              },
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 12,
                                                        vertical: 5),
                                                decoration: BoxDecoration(
                                                  border: Border.all(
                                                      color: Colors.grey),
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    /*controller.rolesList.isNotEmpty? Text(
                                                  controller.selectedRole == ''
                                                      ? controller.rolesList[0].userRole??''
                                                      : controller.selectedRole,
                                                  style: BalooStyles
                                                      .balooregularTextStyle(),
                                                ):SizedBox(),*/
                                                    Text(
                                                      controller
                                                          .getRoleNameForUser(
                                                              user.mobile),
                                                      style: BalooStyles
                                                          .balooregularTextStyle(),
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                    const Icon(
                                                      Icons.arrow_drop_down,
                                                      color: Colors.grey,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ).marginSymmetric(horizontal: 12, vertical: 8);
                    },
                  ),
                ),
                GradientButton(
                  name: "Send Invites",
                  onTap: () {
                    if (controller.users
                        .any((user) => user.isSelected ?? true)) {
                      controller.hitAPIToSendInvites();
                    }
                  },
                  gradient:
                      controller.users.any((user) => user.isSelected ?? true)
                          ? buttonGradient
                          : LinearGradient(colors: [
                              Colors.grey,
                              Colors.grey,
                            ]),
                ).marginSymmetric(horizontal: 30)
              ],
            ),
          ),
        );
      },
    );
  }
}
