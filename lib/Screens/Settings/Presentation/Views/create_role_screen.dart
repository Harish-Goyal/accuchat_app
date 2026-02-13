import 'package:AccuChat/Constants/colors.dart';
import 'package:AccuChat/Extension/text_field_extenstion.dart';
import 'package:AccuChat/utils/custom_flashbar.dart';
import 'package:AccuChat/utils/gradient_button.dart';
import 'package:AccuChat/utils/helper_widget.dart';
import 'package:AccuChat/utils/loading_indicator.dart';
import 'package:AccuChat/utils/text_style.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../../Constants/themes.dart';
import '../../../../utils/common_textfield.dart';
import '../../../../utils/custom_dialogue.dart';
import '../../../../utils/data_not_found.dart';
import '../../Model/get_nav_permission_res_model.dart';
import '../Controllers/create_role_controller.dart';


class CreateRoleScreen extends StatelessWidget {
  final formKey = GlobalKey<FormState>();

  CreateRoleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CreateRoleController>(
      init: CreateRoleController(),
      builder: (controller) {
        return Scaffold(
          appBar: AppBar(
            scrolledUnderElevation: 0,
            surfaceTintColor: Colors.white,
            title: Text(
              "Create Role",
              style: BalooStyles.baloosemiBoldTextStyle(),
            ),
          ),
          body: controller.isLoadingPer
              ? const Center(child: IndicatorLoading())
              : LayoutBuilder(
            builder: (context, constraints) {
              final isWebWide = constraints.maxWidth >= 800;
              final maxContentWidth = isWebWide ? 650.0 : double.infinity;
              final size = MediaQuery.of(context).size;
              // final bool isWide = size.width >= 900;

              return SingleChildScrollView(
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: maxContentWidth),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: isWebWide ? 24 : 15,
                        vertical: isWebWide ? 18 : 12,
                      ),
                      child: Form(
                        key: formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            vGap(10),

                            // ✅ Role Name
                            CustomTextField(
                              hintText: "Enter role name",
                              controller: controller.roleNameController,
                              focusNode: FocusNode(),
                              onFieldSubmitted: (String? value) {},
                              labletext: "Role Name",
                              validator: (value) {
                                return value?.isEmptyField(
                                    messageTitle: "Role Name");
                              },
                            ),

                            vGap(20),

                            // ✅ Title
                            Text(
                              "Select Permission",
                              style: BalooStyles.baloonormalTextStyle(),
                            ),
                            vGap(8),

                            // ✅ Permission selector
                            InkWell(
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (_) => StatefulBuilder(
                                    builder: (ctx, setState) {
                                      final Map<String, List<NavigationItem>> grouped = {};
                                      for (var perm in controller.navPermissionData) {
                                        grouped
                                            .putIfAbsent(perm.navigationPlace!, () => [])
                                            .add(perm);
                                      }
                                      final dialogMaxWidth = isWebWide ? 700.0 : double.maxFinite;
                                      final dialogMaxHeight = isWebWide ? (size.height * 0.75) : (size.height * 0.8);
                                      return AlertDialog(
                                        backgroundColor: Colors.white,
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                                        insetPadding: EdgeInsets.symmetric(
                                          horizontal: isWebWide ? 24 : 10,
                                          vertical: isWebWide ? 24 : 15,
                                        ),
                                        title: const Text('Select Permissions'),
                                        content: SizedBox(
                                          width: dialogMaxWidth,
                                          height: dialogMaxHeight,
                                          child: ListView(
                                            shrinkWrap: true,
                                            padding: EdgeInsets.zero,
                                            children: grouped.entries.map((entry) {
                                              final place = entry.key;
                                              final items = entry.value;
                                              final allChecked = items.every((p) =>
                                                  controller.selectedPermissionsIds.contains(p.navigationItemId));
                                              return Container(
                                                margin: const EdgeInsets.symmetric(vertical: 6,horizontal: 5),
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius: BorderRadius.circular(12),
                                                  boxShadow: const [
                                                    BoxShadow(
                                                      color: Colors.black12,
                                                      blurRadius: 6,
                                                      offset: Offset(0, 3),
                                                    ),
                                                  ],
                                                ),
                                                child: Theme(
                                                  data: Theme.of(context)
                                                      .copyWith(dividerColor: Colors.transparent),
                                                  child: ExpansionTile(
                                                    tilePadding: const EdgeInsets.symmetric(
                                                        horizontal: 16, vertical: 8),
                                                    childrenPadding:
                                                    const EdgeInsets.fromLTRB(16, 0, 16, 12),
                                                    leading: Checkbox(
                                                      activeColor: appColorYellow,
                                                      value: allChecked,
                                                      onChanged: (checked) {
                                                        if (checked == true) {
                                                          for (var p in items) {
                                                            if (!controller.selectedPermissionsIds
                                                                .contains(p.navigationItemId)) {
                                                              controller.selectedPermissionsIds!
                                                                  .add(p.navigationItemId!);
                                                              controller.selectedPermissions
                                                                  .add(p.navigationItem!);
                                                            }
                                                          }
                                                        } else {
                                                          for (var p in items) {
                                                            controller.selectedPermissionsIds!
                                                                .remove(p.navigationItemId);
                                                            controller.selectedPermissions
                                                                .remove(p.navigationItem);
                                                          }
                                                        }
                                                        controller.update();
                                                        setState(() {});
                                                      },
                                                    ),
                                                    title: Row(
                                                      children: [
                                                        Expanded(
                                                          child: Text(
                                                            place.toUpperCase(),
                                                            style: BalooStyles.baloonormalTextStyle()
                                                                .copyWith(fontWeight: FontWeight.w600),
                                                            maxLines: 1,
                                                            overflow: TextOverflow.ellipsis,
                                                          ),
                                                        ),
                                                      ],
                                                    ),

                                                    children: items.map((perm) {
                                                      final checked = controller.selectedPermissionsIds
                                                          .contains(perm.navigationItemId);
                                                      return CheckboxListTile(
                                                        activeColor: appColorYellow,
                                                        value: checked,
                                                        title: Text(
                                                          perm.navigationItem ?? '',
                                                          style: BalooStyles.balooregularTextStyle(),
                                                          maxLines: 1,
                                                          overflow: TextOverflow.ellipsis,
                                                        ),
                                                        controlAffinity:
                                                        ListTileControlAffinity.leading,
                                                        visualDensity: kIsWeb
                                                            ? const VisualDensity(horizontal: -2, vertical: -2)
                                                            : VisualDensity.standard,
                                                        onChanged: (v) {
                                                          if (v == true) {
                                                            controller.selectedPermissionsIds!
                                                                .add(perm.navigationItemId!);
                                                            controller.selectedPermissions
                                                                .add(perm.navigationItem!);
                                                          } else {
                                                            controller.selectedPermissionsIds!
                                                                .remove(perm.navigationItemId);
                                                            controller.selectedPermissions
                                                                .remove(perm.navigationItem);
                                                          }
                                                          controller.update();
                                                          setState(() {});
                                                        },
                                                      );
                                                    }).toList(),
                                                  ),
                                                ),
                                              );
                                            }).toList(),
                                          ),
                                        ),
                                        actionsPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Get.back(),
                                            child: const Text('Done'),
                                          ),
                                        ],
                                      );

                                    },
                                  ),
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        controller.selectedPermissionsIds.isEmpty
                                            ? 'Tap to select permissions'
                                            : '${controller.selectedPermissionsIds.length} selected',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const Icon(Icons.arrow_drop_down),
                                  ],
                                ),
                              ),
                            ),
                           /* InkWell(
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (_) => StatefulBuilder(
                                    builder: (context, setState) {
                                      final dialogMaxWidth =
                                      MediaQuery.of(context)
                                          .size
                                          .width >=
                                          700
                                          ? 560.0
                                          : MediaQuery.of(context)
                                          .size
                                          .width *
                                          0.92;

                                      final dialogMaxHeight =
                                          MediaQuery.of(context)
                                              .size
                                              .height *
                                              0.75;

                                      return AlertDialog(
                                        backgroundColor: Colors.white,
                                        title: const Text(
                                          'Select Permissions',
                                        ),
                                        contentPadding:
                                        const EdgeInsets.symmetric(
                                            horizontal: 18,vertical: 8),
                                        content: ConstrainedBox(
                                          constraints: BoxConstraints(
                                            maxWidth: dialogMaxWidth,
                                            maxHeight: dialogMaxHeight,
                                          ),
                                          child: Column(
                                            children: [
                                              Align(
                                                alignment:
                                                Alignment.centerRight,
                                                child: TextButton.icon(
                                                  onPressed: () {
                                                    bool selectAll = controller
                                                        .selectedPermissions
                                                        .length !=
                                                        controller
                                                            .navPermissionData
                                                            .length;

                                                    controller
                                                        .selectedPermissions
                                                        .clear();
                                                    controller
                                                        .selectedPermissionsIds
                                                        .clear();

                                                    if (selectAll) {
                                                      for (var perm in controller
                                                          .navPermissionData) {
                                                        controller
                                                            .selectedPermissions
                                                            .add(perm.navigationItem ??
                                                            '');
                                                        controller
                                                            .selectedPermissionsIds
                                                            .add(perm.navigationItemId ??
                                                            0);
                                                      }
                                                    }
                                                    setState(() {});
                                                  },
                                                  icon: Icon(
                                                    Icons.select_all,
                                                    color: appColorGreen,
                                                  ),
                                                  label: Text(
                                                    controller
                                                        .selectedPermissions
                                                        .length ==
                                                        controller
                                                            .navPermissionData
                                                            .length
                                                        ? 'Deselect All'
                                                        : 'Select All',
                                                  ),
                                                ),
                                              ),

                                              // ✅ List area (scroll safe)
                                              Expanded(
                                                child: SizedBox(
                                                  width: double.maxFinite,
                                                  child: controller
                                                      .navPermissionData
                                                      .isEmpty
                                                      ? Center(
                                                    child: SizedBox(
                                                      height: 80,
                                                      width: 80,
                                                      child:
                                                      DataNotFoundText(),
                                                    ),
                                                  )
                                                      : ListView(
                                                        padding: const EdgeInsets
                                                            .symmetric(
                                                            vertical:
                                                            10,
                                                            horizontal:
                                                            0),
                                                        children: controller
                                                            .navPermissionData
                                                            .map(
                                                              (perm) {
                                                            return CheckboxListTile(
                                                              activeColor:
                                                              appColorYellow,
                                                              contentPadding:
                                                              EdgeInsets.zero,
                                                              value: controller
                                                                  .selectedPermissions
                                                                  .contains(perm.navigationItem ??
                                                                  ''),
                                                              title:
                                                              Text(
                                                                perm.navigationItem ??
                                                                    '',
                                                                style:
                                                                BalooStyles.balooregularTextStyle(),
                                                              ),
                                                              onChanged:
                                                                  (_) {
                                                                controller.isPerNotSelected =
                                                                false;
                                                                controller
                                                                    .togglePermission(
                                                                    perm.navigationItem ??
                                                                        '');
                                                                controller
                                                                    .selectIds(
                                                                    perm.navigationItemId ??
                                                                        0);
                                                                controller
                                                                    .update();
                                                                setState(
                                                                        () {});
                                                              },
                                                            );
                                                          },
                                                        ).toList(),
                                                      ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Get.back(),
                                            child: const Text('Done'),
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 12),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: (controller.isPerNotSelected ??
                                        true)
                                        ? Colors.red
                                        : Colors.grey,
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  children: [
                                    Flexible(
                                      child: Text(
                                        controller.selectedPermissions
                                            .isEmpty
                                            ? 'Tap to select permissions'
                                            : '${controller.selectedPermissions.length} selected',
                                        style: BalooStyles
                                            .balooregularTextStyle(),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const Icon(Icons.arrow_drop_down,
                                        color: Colors.grey),
                                  ],
                                ),
                              ),
                            ),*/

                            vGap(12),

                            // ✅ Chips area
                            if (controller.selectedPermissions.isNotEmpty)
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border:
                                  Border.all(color: Colors.grey.shade200),
                                ),
                                child: Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: controller.selectedPermissions
                                      .map((perm) {
                                    return Chip(
                                      backgroundColor: Colors.white,
                                      deleteIconColor: Colors.red,
                                      label: Text(
                                        perm,
                                        style: BalooStyles
                                            .balooregularTextStyle(),
                                      ),
                                      onDeleted: ()  {
                                        controller
                                            .removePermission(
                                            perm);
                                       /* showDialog(
                                          context: Get.context!,
                                          builder: (_) => CustomDialogue(
                                            title: "Delete Roles",
                                            isShowActions: false,
                                            isShowAppIcon: false,
                                            content: Column(
                                              crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                              mainAxisSize:
                                              MainAxisSize.min,
                                              children: [
                                                vGap(20),
                                                Text(
                                                  "Do you really want to delete this role?",
                                                  style: BalooStyles
                                                      .baloonormalTextStyle(),
                                                  textAlign:
                                                  TextAlign.center,
                                                ),
                                                vGap(30),
                                                Row(
                                                  children: [
                                                    Expanded(
                                                      child:
                                                      GradientButton(
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
                                                          ],
                                                        ),
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
                                                      child:
                                                      GradientButton(
                                                        name: "Cancel",
                                                        btnColor:
                                                        Colors.black,
                                                        color:
                                                        Colors.black,
                                                        gradient:
                                                        LinearGradient(
                                                          colors: [
                                                            AppTheme
                                                                .whiteColor,
                                                            Colors.white
                                                          ],
                                                        ),
                                                        vPadding: 6,
                                                        onTap: () {
                                                          Get.back();
                                                        },
                                                      ),
                                                    ),
                                                  ],
                                                )
                                              ],
                                            ),
                                            onOkTap: () {},
                                          ),
                                        );*/
                                      },
                                    );
                                  }).toList(),
                                ),
                              ),

                            vGap(20),
                            SizedBox(
                              width: double.infinity,
                              child: GradientButton(
                                name: "Submit",
                                onTap: () {
                                  SystemChannels.textInput
                                      .invokeMethod('TextInput.hide');
                                  if (formKey.currentState!.validate()) {
                                    if (controller
                                        .selectedPermissions.isNotEmpty) {
                                      controller.createRoleApi();
                                      controller.isPerNotSelected = false;
                                    } else {
                                      toast(
                                          "Please select permission to this Role");
                                      controller.isPerNotSelected = true;
                                    }
                                  }
                                },
                              ),
                            ),

                            vGap(80),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}


/*class CreateRoleScreen extends StatelessWidget {
  final formKey = GlobalKey<FormState>();

  CreateRoleScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return GetBuilder<CreateRoleController>(
      init: CreateRoleController(),
      builder: (controller) {
        return Scaffold(
          appBar: AppBar(      scrolledUnderElevation: 0,
              surfaceTintColor: Colors.white,
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
                            focusNode: FocusNode(),
                            onFieldSubmitted: (String? value) {
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
                                                ? SizedBox(
                                              height: 80,
                                                width: 80,
                                                child: DataNotFoundText())
                                                : ListView(
                                              shrinkWrap: true,
                                              padding: const EdgeInsets.symmetric(vertical: 10,horizontal: 0),
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
                                              ],
                                            ),
                                            onOkTap: () {},
                                          ));
                                },
                              );
                            }).toList(),
                          ),


                                      *//*
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
                                      *//*


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
}*/
