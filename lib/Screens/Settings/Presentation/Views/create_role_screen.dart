import 'package:AccuChat/Constants/colors.dart';
import 'package:AccuChat/Extension/text_field_extenstion.dart';
import 'package:AccuChat/utils/custom_flashbar.dart';
import 'package:AccuChat/utils/gradient_button.dart';
import 'package:AccuChat/utils/helper_widget.dart';
import 'package:AccuChat/utils/loading_indicator.dart';
import 'package:AccuChat/utils/text_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../../Constants/themes.dart';
import '../../../../utils/common_textfield.dart';
import '../../../../utils/custom_dialogue.dart';
import '../../../../utils/data_not_found.dart';
import '../Controllers/create_role_controller.dart';

class CreateRoleScreen extends StatelessWidget {
  final formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return GetBuilder<CreateRoleController>(
      init: CreateRoleController(),
      builder: (controller) {
        return Scaffold(
          appBar: AppBar(
              title: Text(
            "Create Role",
            style: BalooStyles.baloosemiBoldTextStyle(),
          )),
          body: controller.isLoadingPer
              ? const Center(child: IndicatorLoading())
              : SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                          vGap(10),
                          CustomTextField(
                            hintText: "Enter role name",
                            controller: controller.roleNameController,
                            // textInputType: TextInputType.,

                            focusNode: FocusNode(),
                            onFieldSubmitted: (String? value) {
                              // FocusScope.of(Get.context!)
                              //     .requestFocus(controller.passwordFocusNode);
                            },
                            labletext: "Role Name",

                            validator: (value) {
                              return value?.isEmptyField(messageTitle: "Role Name");
                            },
                          ),
                          vGap(20),
                          Text("Select Permission",
                              style: BalooStyles.baloonormalTextStyle()),
                          vGap(8),
                      InkWell(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (_) => StatefulBuilder(
                                builder: (context, setState) {
                                  return AlertDialog(
                                    backgroundColor: Colors.white,
                                    title: const Text('Select Permissions'),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                                    content: Column(
                                      children: [
                                        Align(
                                          alignment: Alignment.centerRight,
                                          child: TextButton.icon(
                                            onPressed: () {
                                              bool selectAll = controller.selectedPermissions.length != controller.navPermissionData.length;
                                              controller.selectedPermissions.clear();
                                              controller.selectedPermissionsIds.clear();

                                              if (selectAll) {
                                                for (var perm in controller.navPermissionData) {
                                                  controller.selectedPermissions.add(perm.navigationItem ?? '');
                                                  controller.selectedPermissionsIds.add(perm.navigationItemId ?? 0);
                                                }
                                              }

                                              setState(() {});
                                            },
                                            icon: Icon(Icons.select_all,color: appColorGreen,),
                                            label: Text(controller.selectedPermissions.length == controller.navPermissionData.length
                                                ? 'Deselect All'
                                                : 'Select All'),
                                          ),
                                        ),
                                        Expanded(
                                          child: SizedBox(
                                            width: double.maxFinite,
                                            child: controller
                                                .navPermissionData.isEmpty
                                                ? DataNotFoundText()
                                                : ListView(
                                              shrinkWrap: true,
                                              padding: EdgeInsets.symmetric(vertical: 10,horizontal: 0),
                                              children: controller
                                                  .navPermissionData
                                                  .map((perm) {
                                                return CheckboxListTile(
                                                  activeColor: appColorYellow,
                                                  contentPadding: EdgeInsets.zero,
                                                  value: controller
                                                      .selectedPermissions
                                                      .contains(
                                                      perm.navigationItem ??
                                                          ''),
                                                  title: Text(
                                                    perm.navigationItem ?? '',
                                                    style: BalooStyles
                                                        .balooregularTextStyle(),
                                                  ),
                                                  onChanged: (_) {
                                                    controller.isPerNotSelected = false;
                                                    controller.togglePermission(
                                                        perm.navigationItem ??
                                                            '');
                                                    controller.selectIds(
                                                        perm.navigationItemId ??
                                                            0);
                                                    controller.update();

                                                    setState(() {});
                                                  },
                                                );
                                              }).toList(),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Get.back(),
                                        child: const Text('Done'),
                                      ),
                                    ],
                                  );
                                }),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            border: Border.all(color:(controller.isPerNotSelected??true)?Colors.red: Colors.grey),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                controller.selectedPermissions.isEmpty
                                    ? 'Tap to select permissions'
                                    : '${controller.selectedPermissions.length} selected',
                                style: BalooStyles.balooregularTextStyle(),
                              ),
                              const Icon(Icons.arrow_drop_down,color: Colors.grey,),
                            ],
                          ),
                        ),
                      ),
                      vGap(10),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children:
                                controller.selectedPermissions.map((perm) {
                              return Chip(
                                backgroundColor: Colors.white,
                                deleteIconColor: Colors.red,
                                label: Text(
                                  perm,
                                  style: BalooStyles.balooregularTextStyle(),
                                ),
                                onDeleted: () async {
                                  showDialog(
                                      context: Get.context!,
                                      builder: (_) => CustomDialogue(
                                            title: "Delete Roles",
                                        isShowActions: false,
                                            isShowAppIcon: false,
                                            content: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                vGap(20),
                                                Text(
                                                  "Do you really want to delete this role?",
                                                  style: BalooStyles
                                                      .baloonormalTextStyle(),
                                                  textAlign: TextAlign.center,
                                                ),

                                                vGap(30),

                                                Row(
                                                  children: [
                                                    Expanded(
                                                      child: GradientButton(
                                                        name: "Yes",
                                                        btnColor: AppTheme
                                                            .redErrorColor,
                                                        gradient:
                                                            LinearGradient(
                                                                colors: [
                                                              AppTheme
                                                                  .redErrorColor,
                                                              AppTheme
                                                                  .redErrorColor
                                                            ]),
                                                        vPadding: 6,
                                                        onTap: () async {
                                                          controller
                                                              .removePermission(
                                                                  perm);
                                                        },
                                                      ),
                                                    ),
                                                    hGap(15),
                                                    Expanded(
                                                      child: GradientButton(
                                                        name: "Cancel",
                                                        btnColor:
                                                            Colors.black,
                                                        color: Colors.black,
                                                        gradient:
                                                            LinearGradient(
                                                                colors: [
                                                              AppTheme
                                                                  .whiteColor,
                                                              Colors.white
                                                            ]),
                                                        vPadding: 6,
                                                        onTap: () {
                                                          Get.back();
                                                        },
                                                      ),
                                                    ),
                                                  ],
                                                )
                                                // Text(STRING_logoutHeading,style: BalooStyles.baloomediumTextStyle(),),
                                              ],
                                            ),
                                            onOkTap: () {},
                                          ));
                                },
                              );
                            }).toList(),
                          ),


                                      /*
                                          DropdownButtonFormField<String>(
                      borderRadius: BorderRadius.circular(12),
                      dropdownColor: Colors.white,
                      value: controller.selectedPermission,
                      items: controller.permissions
                          .map((perm) => DropdownMenuItem<String>(
                        value: perm,

                        child: Text(perm,style:BalooStyles.balooregularTextStyle()).paddingOnly(left: 12),
                      ))
                          .toList(),
                      onChanged: (val) {
                        controller.selectedPermission = val;
                        controller.update();
                      },
                      decoration: InputDecoration(
                        hintText: "Choose permission",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        hintStyle:BalooStyles.baloonormalTextStyle(),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 15),
                      ),
                                          ).marginSymmetric(horizontal: 5),
                                      */


                      vGap(20),
                      GradientButton(name: "Submit", onTap: () {
                        SystemChannels.textInput.invokeMethod('TextInput.hide');
                        if(formKey.currentState!.validate()){
                          if(controller.selectedPermissions.isNotEmpty){
                            controller.createRoleApi();
                            controller.isPerNotSelected = false;
                          }else{
                            toast("Please select permission to this Role");
                            controller.isPerNotSelected = true;
                          }
                        }

                      }),
                      vGap(80)
                    ],
                  ).paddingSymmetric(horizontal: 15),
                ),
              ),
        );
      },
    );
  }
}
