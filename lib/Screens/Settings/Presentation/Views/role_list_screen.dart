import 'package:AccuChat/Constants/colors.dart';
import 'package:AccuChat/Screens/Settings/Model/get_nav_permission_res_model.dart';
import 'package:AccuChat/routes/app_routes.dart';
import 'package:AccuChat/utils/helper_widget.dart';
import 'package:AccuChat/utils/loading_indicator.dart';
import 'package:AccuChat/utils/text_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:flutter/foundation.dart' show kIsWeb; // added for web checks

import '../Controllers/role_list_controller.dart';

class RoleListScreen extends GetView<RoleListController> {

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final bool isWide = size.width >= 1000; // responsive breakpoint
    final double maxContentWidth = 1000;   // comfy width for web

    return GetBuilder<RoleListController>(
      init: RoleListController(),
      builder: (ctrl) {
        return Scaffold(
          appBar: AppBar(
            title:  Text('All Roles',style: BalooStyles.baloosemiBoldTextStyle(),
            ),
            centerTitle: true,
            toolbarHeight: isWide ? 64 : kToolbarHeight, // a bit taller on wide screens
          ),
          body: ctrl.isLoadingRoles
              ? const Center(child: IndicatorLoading())
              : Center( // responsive wrapper begins
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: isWide ? maxContentWidth : double.infinity,
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: isWide ? 16 : 0),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: ListView.separated(
                    itemCount: ctrl.rolesList.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final role = ctrl.rolesList[index];
                      final Map<String, List<NavigationItem>> grouped = {};
                      for (var perm in role.navigationItems ?? []) {
                        grouped
                            .putIfAbsent(perm.navigationPlace!, () => [])
                            .add(perm);
                      }
                      return Slidable(
                        key: ValueKey(role.userCompanyRoleId),
                        startActionPane: ActionPane(
                          motion: const DrawerMotion(),
                          extentRatio: 0.3,
                          children: [
                            SlidableAction(
                              onPressed: (_) {
                                ctrl.editRole(role);

                              },
                              backgroundColor: Colors.white,
                              foregroundColor: appColorGreen,
                              icon: Icons.edit,
                              label: 'Edit',
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ],
                        ),
                        endActionPane: ActionPane(
                          motion: const DrawerMotion(),
                          extentRatio: 0.4,
                          children: [
                            SlidableAction(
                              onPressed: (_) {},
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.red,
                              icon: Icons.delete,
                              label: 'Delete',
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ],
                        ),
                        child: Card(
                          elevation: .5,
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12,vertical: 12),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      vGap(10),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              Container(
                                                padding: EdgeInsets.all(isWide ? 10 : 8),
                                                decoration: BoxDecoration(
                                                  color: appColorGreen.withOpacity(.1),
                                                  borderRadius: BorderRadius.circular(10),
                                                  border: Border.all(color: appColorGreen),
                                                ),

                                                child: Text(
                                                    "${(role.userRole??'').toUpperCase()}",
                                                    style: BalooStyles.baloosemiBoldTextStyle(color:appColorGreen)
                                                ),
                                              ),
                                            ],
                                          ),
                                          TextButton(onPressed: (){ctrl.editRole(role);}, child: Icon(Icons.edit_rounded,color: Colors.black87,)),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
/*
                                            Wrap(
                                              spacing: 6,
                                              runSpacing: 4,
                                              children: (role.navigationItems??[])
                                                  .map((perm) => Chip(
                                                color: MaterialStateProperty.all(appColorGreen.withOpacity(.05)),
                                                label: Text(perm.navigationItem??'',
                                                    style: BalooStyles.balooregularTextStyle()),
                                                visualDensity: VisualDensity.compact,
                                              ))
                                                  .toList(),
                                            ),
*/
                                      /*...grouped.entries.map((entry) {
                                              final place = entry.key;
                                              final items = entry.value;
                                              return Padding(
                                                padding: const EdgeInsets.only(bottom: 8),
                                                child: Column(
                                                  crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      place.toUpperCase(),
                                                      style: BalooStyles
                                                          .baloosemiBoldTextStyle(),
                                                    ),
                                                    const SizedBox(height: 4),
                                                    Wrap(
                                                      spacing: 6,
                                                      runSpacing: 4,
                                                      children: items.map((perm) {
                                                        return Chip(
                                                          backgroundColor:
                                                          appColorGreen.withOpacity(.1),
                                                          label: Text(
                                                            perm.navigationItem ?? '',
                                                            style: BalooStyles
                                                                .balooregularTextStyle(),
                                                          ),
                                                          visualDensity:
                                                          VisualDensity.compact,
                                                        );
                                                      }).toList(),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            }).toList(),*/

                                      Text(
                                          "Permissions :",
                                          style: BalooStyles.baloosemiBoldTextStyle()
                                      ),
                                      vGap(8),
                                      ...grouped.entries.map((entry) {
                                        final place = entry.key;
                                        final items = entry.value;
                                        return Container(
                                          margin: const EdgeInsets.symmetric(vertical: 5),
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

                                          // 2️⃣ Override the divider color to hide it
                                          child: Theme(
                                            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                                            child: ExpansionTile(
                                              // Remove default internal padding if you like
                                              tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                                              childrenPadding: const EdgeInsets.fromLTRB(5, 0, 5, 4),

                                              // The header
                                              title: Row(
                                                children: [
                                                  Icon(Icons.circle_rounded,color: appColorGreen,size: 12,),
                                                  hGap(5),
                                                  Expanded( // prevent overflow on web
                                                    child: Text(
                                                      place.toUpperCase(),
                                                      style: BalooStyles.baloonormalTextStyle(),
                                                      maxLines: 1,
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ],
                                              ),

                                              // Optional: change the trailing icon shape/color

                                              // The grouped chips
                                              children: [
                                                Align(
                                                  alignment: Alignment.centerLeft,
                                                  child: ConstrainedBox(
                                                    constraints: BoxConstraints(
                                                      // keep chips readable on wide and prevent super-long lines
                                                      maxWidth: isWide ? (maxContentWidth - 64) : double.infinity,
                                                    ),
                                                    child: Wrap(
                                                      spacing: 6,
                                                      runSpacing: 4,
                                                      children: items.map((perm) => Chip(
                                                        color: MaterialStateProperty.all(appColorGreen.withOpacity(.05)),
                                                        label: Text(
                                                          perm.navigationItem!,
                                                          style: BalooStyles.balooregularTextStyle(),
                                                          overflow: TextOverflow.ellipsis,
                                                        ),
                                                        visualDensity: kIsWeb ? const VisualDensity(vertical: -1, horizontal: -1) : VisualDensity.compact,
                                                      )).toList(),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => Get.toNamed(AppRoutes.create_role),
            backgroundColor: appColorGreen,
            child: const Icon(Icons.add,color: Colors.white,),
          ),
        );
      },
    );
  }
}



















// import 'package:AccuChat/Constants/colors.dart';
// import 'package:AccuChat/Screens/Settings/Model/get_nav_permission_res_model.dart';
// import 'package:AccuChat/main.dart';
// import 'package:AccuChat/routes/app_routes.dart';
// import 'package:AccuChat/utils/custom_container.dart';
// import 'package:AccuChat/utils/helper_widget.dart';
// import 'package:AccuChat/utils/loading_indicator.dart';
// import 'package:AccuChat/utils/text_style.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_slidable/flutter_slidable.dart';
// import 'package:get/get.dart';
//
// import '../Controllers/role_list_controller.dart';
//
// class RoleListScreen extends GetView<RoleListController> {
//
//
//   @override
//   Widget build(BuildContext context) {
//     return GetBuilder<RoleListController>(
//       init: RoleListController(),
//       builder: (ctrl) {
//         return Scaffold(
//           appBar: AppBar(
//             title:  Text('All Roles',style: BalooStyles.baloosemiBoldTextStyle(),
//             ),
//             centerTitle: true,
//           ),
//           body: ctrl.isLoadingRoles
//               ? const Center(child: IndicatorLoading())
//               : Padding(
//             padding: const EdgeInsets.all(16),
//             child: ListView.separated(
//               itemCount: ctrl.rolesList.length,
//               separatorBuilder: (_, __) => const SizedBox(height: 10),
//               itemBuilder: (context, index) {
//                 final role = ctrl.rolesList[index];
//                 final Map<String, List<NavigationItem>> grouped = {};
//                 for (var perm in role.navigationItems ?? []) {
//                   grouped
//                       .putIfAbsent(perm.navigationPlace!, () => [])
//                       .add(perm);
//                 }
//                 return Slidable(
//                   key: ValueKey(role.userCompanyRoleId),
//                   startActionPane: ActionPane(
//                     motion: const DrawerMotion(),
//                     extentRatio: 0.3,
//                     children: [
//                       SlidableAction(
//                         onPressed: (_) {
//                           ctrl.editRole(role);
//
//                         },
//                         backgroundColor: Colors.white,
//                         foregroundColor: appColorGreen,
//                         icon: Icons.edit,
//                         label: 'Edit',
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                     ],
//                   ),
//                   endActionPane: ActionPane(
//                     motion: const DrawerMotion(),
//                     extentRatio: 0.4,
//                     children: [
//                       SlidableAction(
//                         onPressed: (_) {},
//                         backgroundColor: Colors.white,
//                         foregroundColor: Colors.red,
//                         icon: Icons.delete,
//                         label: 'Delete',
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                     ],
//                   ),
//                   child: Card(
//                     elevation: .5,
//                    color: Colors.white,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     child: Padding(
//                       padding: const EdgeInsets.symmetric(horizontal: 12,vertical: 12),
//                       child: Row(
//                         children: [
//                           Expanded(
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 vGap(10),
//                                 Row(
//                                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                   children: [
//                                     Row(
//                                       children: [
//                                         Container(
//                                           padding: EdgeInsets.all(8),
//                                           decoration: BoxDecoration(
//                                             color: appColorGreen.withOpacity(.1),
//                                             borderRadius: BorderRadius.circular(10),
//                                             border: Border.all(color: appColorGreen),
//                                           ),
//
//                                           child: Text(
//                                             "${(role.userRole??'').toUpperCase()}",
//                                             style: BalooStyles.baloosemiBoldTextStyle(color:appColorGreen)
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                     TextButton(onPressed: (){ctrl.editRole(role);}, child: Icon(Icons.edit_rounded,color: Colors.black87,)),
//                                   ],
//                                 ),
//                                 const SizedBox(height: 8),
// /*
//                                 Wrap(
//                                   spacing: 6,
//                                   runSpacing: 4,
//                                   children: (role.navigationItems??[])
//                                       .map((perm) => Chip(
//                                     color: MaterialStateProperty.all(appColorGreen.withOpacity(.05)),
//                                     label: Text(perm.navigationItem??'',
//                                         style: BalooStyles.balooregularTextStyle()),
//                                     visualDensity: VisualDensity.compact,
//                                   ))
//                                       .toList(),
//                                 ),
// */
//                                 /*...grouped.entries.map((entry) {
//                                   final place = entry.key;
//                                   final items = entry.value;
//                                   return Padding(
//                                     padding: const EdgeInsets.only(bottom: 8),
//                                     child: Column(
//                                       crossAxisAlignment:
//                                       CrossAxisAlignment.start,
//                                       children: [
//                                         Text(
//                                           place.toUpperCase(),
//                                           style: BalooStyles
//                                               .baloosemiBoldTextStyle(),
//                                         ),
//                                         const SizedBox(height: 4),
//                                         Wrap(
//                                           spacing: 6,
//                                           runSpacing: 4,
//                                           children: items.map((perm) {
//                                             return Chip(
//                                               backgroundColor:
//                                               appColorGreen.withOpacity(.1),
//                                               label: Text(
//                                                 perm.navigationItem ?? '',
//                                                 style: BalooStyles
//                                                     .balooregularTextStyle(),
//                                               ),
//                                               visualDensity:
//                                               VisualDensity.compact,
//                                             );
//                                           }).toList(),
//                                         ),
//                                       ],
//                                     ),
//                                   );
//                                 }).toList(),*/
//
//                                 Text(
//                                     "Permissions :",
//                                     style: BalooStyles.baloosemiBoldTextStyle()
//                                 ),
//                                 vGap(8),
//                                 ...grouped.entries.map((entry) {
//                                   final place = entry.key;
//                                   final items = entry.value;
//                                   return Container(
//                                     margin: const EdgeInsets.symmetric(vertical: 5),
//                                     decoration: BoxDecoration(
//                                       color: Colors.white,
//                                       borderRadius: BorderRadius.circular(12),
//                                       boxShadow: const [
//                                         BoxShadow(
//                                           color: Colors.black12,
//                                           blurRadius: 6,
//                                           offset: Offset(0, 3),
//                                         ),
//                                       ],
//                                     ),
//
//                                     // 2️⃣ Override the divider color to hide it
//                                     child: Theme(
//                                       data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
//                                       child: ExpansionTile(
//                                         // Remove default internal padding if you like
//                                         tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
//                                         childrenPadding: const EdgeInsets.fromLTRB(5, 0, 5, 4),
//
//                                         // The header
//                                         title: Row(
//                                           children: [
//                                             Icon(Icons.circle_rounded,color: appColorGreen,size: 12,),
//                                             hGap(5),
//                                             Text(
//                                               place.toUpperCase(),
//                                               style: BalooStyles.baloonormalTextStyle(),
//                                               maxLines: 1,
//                                               overflow: TextOverflow.ellipsis,
//                                             ),
//                                           ],
//                                         ),
//
//                                         // Optional: change the trailing icon shape/color
//
//                                         // The grouped chips
//                                         children: [
//                                           Wrap(
//                                             spacing: 6,
//                                             runSpacing: 4,
//                                             children: items.map((perm) => Chip(
//                                               color: MaterialStateProperty.all(appColorGreen.withOpacity(.05)),
//                                               label: Text(perm.navigationItem!, style: BalooStyles.balooregularTextStyle()),
//                                               visualDensity: VisualDensity.compact,
//                                             )).toList(),
//                                           ),
//                                         ],
//                                       ),
//                                     ),
//                                   );
//                                 }).toList(),
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ),
//           floatingActionButton: FloatingActionButton(
//             onPressed: () => Get.toNamed(AppRoutes.createRoleRoute),
//             backgroundColor: appColorGreen,
//             child: const Icon(Icons.add,color: Colors.white,),
//           ),
//         );
//       },
//     );
//   }
// }
//
