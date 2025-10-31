import 'package:AccuChat/Constants/app_theme.dart';
import 'package:AccuChat/Constants/assets.dart';
import 'package:AccuChat/Screens/Chat/screens/chat_tasks/Presentation/Controllers/all_user_controller.dart';
import 'package:AccuChat/Services/APIs/api_ends.dart';
import 'package:AccuChat/utils/networl_shimmer_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../../Constants/colors.dart';
import '../../../../api/apis.dart';
import '../../../../models/chat_user.dart';
import '../Views/chat_screen.dart';

class AllUserScreenDialog extends GetView<AllUserController> {
  const AllUserScreenDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AllUserController>(
        init: AllUserController(),
        builder: (controller) {
          final listToShow = controller.searchQuery.isEmpty
              ? controller.userList
              : controller.filteredList;
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.white,
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    controller.isSearching
                        ? Expanded(
                            flex: 4,
                            child: TextField(
                              controller: controller.seacrhCon,
                              cursorColor: appColorGreen,
                              decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  hintText: 'Search User...',
                                  contentPadding: EdgeInsets.symmetric(
                                      vertical: 0, horizontal: 10),
                                  constraints: BoxConstraints(maxHeight: 45)),
                              autofocus: true,
                              style: const TextStyle(
                                  fontSize: 13, letterSpacing: 0.5),
                              onChanged: (val) {
                                controller.searchQuery = val;
                                controller.onSearch(val);
                              },
                            ).marginSymmetric(vertical: 10),
                          )
                        : Expanded(
                            flex: 4,
                            child: Text(
                              'Forwarded to',
                              style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18),
                            ).paddingOnly(left: 8, top: 10),
                          ),
                    Expanded(
                      child: IconButton(
                          onPressed: () {
                            controller.isSearching = !controller.isSearching;
                            controller.update();
                          },
                          icon: Icon(
                            controller.isSearching
                                ? CupertinoIcons.clear_circled_solid
                                : Icons.search,
                            color: colorGrey,
                          ).paddingOnly(top: 10, right: 10)),
                    ),
                  ],
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: listToShow.length,
                    itemBuilder: (_, i) => ListTile(
                      leading: SizedBox(
                        width: 50,
                        child: CustomCacheNetworkImage(
                          "${ApiEnd.baseUrlMedia}${listToShow[i].userImage ?? ''}",
                          height: 50,
                          width: 50,
                          radiusAll: 100,
                          boxFit: BoxFit.cover,
                          defaultImage:listToShow[i].userCompany?.isGroup==1?groupIcn:
                          listToShow[i].userCompany?.isBroadcast==1?
                              broadcastIcon
                          :userIcon,
                        ),
                      ),
                      title:
                      listToShow[i].displayName!=null?  Text(
                         listToShow[i].displayName ?? '',

                        style: themeData.textTheme.bodySmall,
                      ):Text(
                        listToShow[i].email != null
                            ? listToShow[i].email ?? ''
                            : listToShow[i].phone ?? '',
                        style: themeData.textTheme.bodySmall
                            ?.copyWith(color: Colors.black87),
                      ),
                      subtitle:listToShow[i].displayName!=null||listToShow[i].displayName!=""? Text(
                        listToShow[i].email != null
                            ? listToShow[i].email ?? ''
                            : listToShow[i].phone ?? '',
                        style: themeData.textTheme.bodySmall
                            ?.copyWith(color: greyText),
                      ):SizedBox(),
                      onTap: () {
                        /* Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ChatScreen(user: listToShow[i]),
                              ),
                            );
        */
                        Navigator.pop(context, listToShow[i]);
                      },
                    ),
                  ),
                )
              ],
            ).paddingAll(15),
          );
        });
  }
}
