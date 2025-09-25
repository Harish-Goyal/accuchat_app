import 'package:AccuChat/utils/loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/foundation.dart' show kIsWeb; // added for web checks
import '../../../../utils/common_textfield.dart';
import '../../../../utils/gradient_button.dart';
import '../../../../utils/helper_widget.dart';
import '../../../../utils/text_style.dart';
import '../../../../Constants/colors.dart';
import '../../Model/get_nav_permission_res_model.dart';
import '../Controllers/edit_role_controller.dart';

class EditRoleScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final bool isWide = size.width >= 900; // responsive breakpoint
    final double maxContentWidth = 900;    // comfy page width for web

    return GetBuilder<EditRoleController>(
      init: EditRoleController(),
      builder: (ctrl) {
        return Scaffold(
          appBar: AppBar(
            title: Text('Edit Role', style: BalooStyles.baloosemiBoldTextStyle()),
            toolbarHeight: isWide ? 64 : kToolbarHeight, // a bit taller on wide screens
          ),
          body: ctrl.isLoading
              ? const Center(child: CircularProgressIndicator())
              : Center( // responsive shell
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: isWide ? maxContentWidth : double.infinity,
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: isWide ? 16 : 0),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              vGap(10),
                              CustomTextField(
                                hintText: 'Enter role name',
                                controller: ctrl.roleNameController,
                                labletext: 'Role Name',
                              ),
                              vGap(20),
                              Text('Select Permissions', style: BalooStyles.baloonormalTextStyle()),
                              vGap(8),

                              InkWell(
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    builder: (_) => StatefulBuilder(
                                      builder: (ctx, setState) {

                                        final Map<String, List<NavigationItem>> grouped = {};
                                        for (var perm in ctrl.navPermissionData) {
                                          grouped
                                              .putIfAbsent(perm.navigationPlace!, () => [])
                                              .add(perm);
                                        }

                                        // responsive dialog sizing
                                        final dialogMaxWidth = isWide ? 700.0 : double.maxFinite;
                                        final dialogMaxHeight = isWide ? (size.height * 0.75) : (size.height * 0.8);

                                        return AlertDialog(
                                          backgroundColor: Colors.white,

                                          contentPadding: EdgeInsets.symmetric(horizontal: 10),
                                          insetPadding: EdgeInsets.symmetric(
                                            horizontal: isWide ? 24 : 10,
                                            vertical: isWide ? 24 : 15,
                                          ),
                                          title: const Text('Select Permissions'),
                                          content: SizedBox(
                                            width: dialogMaxWidth,
                                            height: dialogMaxHeight, // allow scrolling area on web
                                            child: Scrollbar(
                                              thumbVisibility: kIsWeb, // visible scrollbar on web
                                              child: ListView(
                                                shrinkWrap: true,
                                                padding: EdgeInsets.zero,
                                                children: grouped.entries.map((entry) {
                                                  final place = entry.key;
                                                  final items = entry.value;
                                                  // 2️⃣ Is every child in this group currently selected?
                                                  final allChecked = items.every((p) =>
                                                      ctrl.selectedPermissionsIds.contains(p.navigationItemId));

                                                  return Container(
                                                    margin: const EdgeInsets.symmetric(vertical: 6,horizontal: 5),
                                                    decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      borderRadius: BorderRadius.circular(12),
                                                      boxShadow: [
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

                                                        // 3️⃣ Group-checkbox in the header
                                                        leading: Checkbox(
                                                          activeColor: appColorYellow,
                                                          value: allChecked,
                                                          onChanged: (checked) {
                                                            if (checked == true) {
                                                              // select all in group
                                                              for (var p in items) {
                                                                if (!ctrl.selectedPermissionsIds
                                                                    .contains(p.navigationItemId)) {
                                                                  ctrl.selectedPermissionsIds!
                                                                      .add(p.navigationItemId!);
                                                                  ctrl.selectedPermissions
                                                                      .add(p.navigationItem!);
                                                                }
                                                              }
                                                            } else {
                                                              // deselect all in group
                                                              for (var p in items) {
                                                                ctrl.selectedPermissionsIds!
                                                                    .remove(p.navigationItemId);
                                                                ctrl.selectedPermissions
                                                                    .remove(p.navigationItem);
                                                              }
                                                            }
                                                            ctrl.update();
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

                                                        // 4️⃣ Individual checkboxes
                                                        children: items.map((perm) {
                                                          final checked = ctrl.selectedPermissionsIds
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
                                                                ctrl.selectedPermissionsIds!
                                                                    .add(perm.navigationItemId!);
                                                                ctrl.selectedPermissions
                                                                    .add(perm.navigationItem!);
                                                              } else {
                                                                ctrl.selectedPermissionsIds!
                                                                    .remove(perm.navigationItemId);
                                                                ctrl.selectedPermissions
                                                                    .remove(perm.navigationItem);
                                                              }
                                                              ctrl.update();
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
                                          ),
                                          actionsPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                          actions: [
                                            TextButton(
                                              onPressed: () => Get.back(),
                                              child: const Text('Done'),
                                            ),
                                          ],
                                        );
                                        /*  return AlertDialog(
                                                backgroundColor: Colors.white,
                                                title: const Text('Select Permissions'),
                                                content: SizedBox(
                                                  width: double.maxFinite,
                                                  child:ctrl.isLoadingPer?const IndicatorLoading(): ListView(
                                                    shrinkWrap: true,
                                                    children: ctrl.navPermissionData.map((perm) {
                                                      return CheckboxListTile(
                                                        activeColor: appColorYellow,
                                                        // value: ctrl.selectedPermissions.contains(perm),
                                                        value: ctrl.selectedIds?.contains(perm.navigationItemId),
                                                        title: Text(perm.navigationItem??'', style: BalooStyles.balooregularTextStyle()),
                                                        onChanged: (v) {
                                                          ctrl.togglePermission(perm.navigationItem??'');
                                                          ctrl.selectIds(perm.navigationItemId??'');
                                                          setState(() {});
                                                          if(v==true) {
                                                            ctrl.selectedIds?.add(
                                                                perm.navigationItemId ?? 0);
                                                            ctrl.permissions.add(perm);

                                                          }else {
                                                            ctrl.selectedIds?.remove(perm.navigationItemId ?? 0);
                                                            ctrl.permissions.removeWhere((p) => p.navigationItemId == perm.navigationItemId);
                                                          }
                                                        },
                                                      );
                                                    }).toList(),
                                                  ),
                                                ),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () => Get.back(),
                                                    child: const Text('Done'),
                                                  ),
                                                ],
                                              );*/
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
                                          ctrl.selectedPermissionsIds.isEmpty
                                              ? 'Tap to select permissions'
                                              : '${ctrl.selectedPermissionsIds.length} selected',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const Icon(Icons.arrow_drop_down),
                                    ],
                                  ),
                                ),
                              ),
/*
                                    vGap(8),
                                    if (ctrl.selectedPermissionsIds.isEmpty)
                                      Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 12),
                                        child: Text(
                                          'No permissions selected yet',
                                          style: BalooStyles.balooregularTextStyle().copyWith(color: Colors.grey),
                                        ),
                                      )
                                    else
                                      ...ctrl.groupedSelected.entries.map((entry) {
                                        final place = entry.key;
                                        final items = entry.value;
                                        return ExpansionTile(
                                          tilePadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
                                          title: Text(
                                            place.toUpperCase(),
                                            style: BalooStyles.baloosemiBoldTextStyle(),
                                          ),
                                          childrenPadding: const EdgeInsets.only(left: 16, bottom: 8),
                                          children: items.map((perm) {
                                            return ListTile(
                                              dense: true,
                                              contentPadding: EdgeInsets.zero,
                                              title: Text(
                                                perm.navigationItem ?? '',
                                                style: BalooStyles.balooregularTextStyle(),
                                              ),
                                            );
                                          }).toList(),
                                        );
                                      }).toList(),
*/
                              /*   Wrap(
                                      spacing: 8,
                                      runSpacing: 8,
                                      children: ctrl.selectedPermissions.map((perm) {
                                        return Chip(
                                          backgroundColor: Colors.white,
                                          deleteIconColor: appColorYellow,
                                          label: Text(perm, style: BalooStyles.balooregularTextStyle()),
                                          onDeleted: () => ctrl.removePermission(perm),
                                        );
                                      }).toList(),
                                    ),*/
                            ],
                          ),
                        ),
                      ),
                      GradientButton(name: 'Update', onTap: ctrl.updateRoleApi),
                      vGap(40),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}





/*
varrr(){
  // … inside your EditRoleScreen, in place of the current ListView:
  InkWell(
    onTap: () {
      showDialog(
        context: context,
        builder: (_) => StatefulBuilder(
          builder: (ctx, setState) {
            if (ctrl.isLoadingPer) {
              return const AlertDialog(
                content: SizedBox(
                  height: 100,
                  child: Center(child: IndicatorLoading()),
                ),
              );
            }

            // 1️⃣ Grouping
            final Map<String, List<NavigationItem>> grouped = {};
            for (var perm in ctrl.navPermissionData) {
              grouped
                  .putIfAbsent(perm.navigationPlace!, () => [])
                  .add(perm);
            }

            return AlertDialog(
              backgroundColor: Colors.white,
              title: const Text('Select Permissions'),
              content: SizedBox(
                width: double.maxFinite,
                child: ListView(
                  shrinkWrap: true,
                  children: grouped.entries.map((entry) {
                    final place = entry.key;
                    final items = entry.value;
                    // 2️⃣ Is every child in this group currently selected?
                    final allChecked = items.every((p) =>
                        ctrl.selectedPermissionsIds.contains(p.navigationItemId));

                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
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

                          // 3️⃣ Group-checkbox in the header
                          leading: Checkbox(
                            activeColor: appColorYellow,
                            value: allChecked,
                            onChanged: (checked) {
                              if (checked == true) {
                                // select all in group
                                for (var p in items) {
                                  if (!ctrl.selectedPermissionsIds
                                      .contains(p.navigationItemId)) {
                                    ctrl.selectedPermissionsIds!
                                        .add(p.navigationItemId!);
                                    ctrl.selectedPermissions
                                        .add(p.navigationItem!);
                                  }
                                }
                              } else {
                                // deselect all in group
                                for (var p in items) {
                                  ctrl.selectedPermissionsIds!
                                      .remove(p.navigationItemId);
                                  ctrl.selectedPermissions
                                      .remove(p.navigationItem);
                                }
                              }
                              setState(() {});
                            },
                          ),
                          title: Text(
                            place.toUpperCase(),
                            style: BalooStyles.baloonormalTextStyle()
                                .copyWith(fontWeight: FontWeight.w600),
                          ),

                          // 4️⃣ Individual checkboxes
                          children: items.map((perm) {
                            final checked = ctrl.selectedPermissionsIds
                                .contains(perm.navigationItemId);
                            return CheckboxListTile(
                              activeColor: appColorYellow,
                              value: checked,
                              title: Text(
                                perm.navigationItem ?? '',
                                style: BalooStyles.balooregularTextStyle(),
                              ),
                              controlAffinity:
                              ListTileControlAffinity.leading,
                              onChanged: (v) {
                                if (v == true) {
                                  ctrl.selectedPermissionsIds!
                                      .add(perm.navigationItemId!);
                                  ctrl.selectedPermissions
                                      .add(perm.navigationItem!);
                                } else {
                                  ctrl.selectedPermissionsIds!
                                      .remove(perm.navigationItemId);
                                  ctrl.selectedPermissions
                                      .remove(perm.navigationItem);
                                }
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
      // … your existing closed‐state UI here …
    ),
  ),

}*/
