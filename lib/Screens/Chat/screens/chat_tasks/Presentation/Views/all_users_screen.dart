import 'package:AccuChat/Constants/assets.dart';
import 'package:AccuChat/Screens/Chat/screens/chat_tasks/Presentation/Controllers/all_user_controller.dart';
import 'package:AccuChat/Services/APIs/api_ends.dart';
import 'package:AccuChat/routes/app_routes.dart';
import 'package:AccuChat/utils/loading_indicator.dart';
import 'package:AccuChat/utils/networl_shimmer_image.dart';
import 'package:AccuChat/utils/text_style.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../../Constants/app_theme.dart';
import '../../../../../../Constants/colors.dart';
import '../../../../../../Constants/colors.dart' as AppTheme;
import '../../../../../../main.dart';
import '../../../../api/apis.dart';
import '../../../../models/chat_user.dart';
import 'chat_screen.dart';

class AllUserScreen extends GetView<AllUserController> {
  const AllUserScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: GetBuilder<AllUserController>(
        builder: (controller) {
          return Scaffold(
            appBar: AppBar(
              // automaticallyImplyLeading: false,

              title:controller.isSearching
                  ? TextField(
                controller: controller.seacrhCon,
                cursorColor: appColorGreen,
                decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Search User...',
                    contentPadding:
                    EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                    constraints: BoxConstraints(maxHeight: 45)),
                autofocus: true,
                style: const TextStyle(fontSize: 13, letterSpacing: 0.5),
                onChanged: (val) {
                  controller.searchQuery = val;
                  controller.onSearch(val);
                },
              ).marginSymmetric(vertical: 10)
                  : Text(
                'Users',
                style:BalooStyles.balooboldTitleTextStyle(),
              ),
              actions: [
                IconButton(
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
              ],
            ),
            body: ListView.builder(
              itemCount: controller.filteredList.length??0,
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              itemBuilder: (_, i) => ListTile(
                leading: SizedBox(
                  width: 55,
                  child: CustomCacheNetworkImage(
                    "${ApiEnd.baseUrlMedia}${controller.filteredList[i].userImage??''}",
                    height: 55,
                    width: 55,
                    radiusAll: 100,
                    borderColor: greyText,
                    boxFit: BoxFit.cover,
                    defaultImage: userIcon,
                  ),
                ),
                title: Text(
                  controller.filteredList[i].userId == controller.me?.userId
                      ? "Me"
                      : (controller.filteredList[i].displayName.toString() == ''||controller.filteredList[i].displayName == null)
                      ? controller.filteredList[i].phone??""
                      : controller.filteredList[i].displayName??'',
                  style: themeData.textTheme.bodySmall,
                ),
                subtitle: ((controller.filteredList[i].displayName.toString() == ''||controller.filteredList[i].displayName == null) &&
                    controller.filteredList[i].userId != controller.me?.userId)
                    ? SizedBox()
                    : Text(
                  controller.filteredList[i].email.toString() == 'null'||controller.filteredList[i].email.toString() == ''||(controller.filteredList[i].email??'').isEmpty||controller.filteredList[i].email==null
                    ? controller.filteredList[i].phone??''
                    : controller.filteredList[i].email??'',
                  style: themeData.textTheme.bodySmall
                      ?.copyWith(color: greyText),
                ),
                onTap: () {

                  if(isTaskMode)  {
                    if(kIsWeb){
                      Get.toNamed(
                        "${AppRoutes.tasks_li_r}?userId=${controller.filteredList[i].userId.toString()}",
                      );
                    }else{
                      Get.toNamed(AppRoutes.tasks_li_r,arguments:
                      {
                        'user': controller.filteredList[i]
                      }
                      );
                    }
                  }else {
                    if (kIsWeb) {
                      Get.toNamed(
                        "${AppRoutes.chats_li_r}?userId=${controller
                            .filteredList[i].userId.toString()}",
                      );
                    } else {
                      Get.toNamed(AppRoutes.chats_li_r, arguments:
                      {
                        'user': controller.filteredList[i]
                      }
                      );
                    }
                  }
                },
              ),
            ),
          );
        }
      ),
    );
  }
}
