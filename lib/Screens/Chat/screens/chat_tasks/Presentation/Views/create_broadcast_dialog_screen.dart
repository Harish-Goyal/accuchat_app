import 'package:AccuChat/Constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../../Constants/app_theme.dart';
import '../../../../../../Constants/assets.dart';
import '../../../../../../Services/APIs/api_ends.dart';
import '../../../../../../utils/custom_dialogue.dart';
import '../../../../../../utils/networl_shimmer_image.dart';
import '../Controllers/create_broadcats_controller.dart';

class BroadcastCreateDialog extends GetView<CreateBroadcastsController> {
   BroadcastCreateDialog({super.key});

  CreateBroadcastsController broadcastsController = Get.put(CreateBroadcastsController());

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CreateBroadcastsController>(builder: (controller) {
      return AlertDialog(
        title: Text('New Broadcast', style: themeData.textTheme.titleSmall),
        insetPadding: EdgeInsets.symmetric(horizontal: 20),
        backgroundColor: Colors.white,
        content: SizedBox(
          width: double.maxFinite,
          height: Get.height * .2,
          child: Column(
            mainAxisSize: MainAxisSize.min,

            children: [
              TextField(
                controller: controller.nameController,
                decoration: const InputDecoration(
                  labelText: 'Broadcast Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
            /*  Expanded(
                child: controller.allUsers.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : ListView.builder(
                        shrinkWrap: true,
                        itemCount: controller.allUsers.length,
                        itemBuilder: (context, index) {
                          final user = controller.allUsers[index];
                          final isSelected =
                              controller.selectedUserIds.contains(user.userId);
                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: SizedBox(
                              width: 55,
                              child: CustomCacheNetworkImage(
                                "${ApiEnd.baseUrlMedia}${user.userImage ?? ''}",
                                radiusAll: 100,
                                height: 75,
                                width: 75,
                                defaultImage: userIcon,
                                borderColor: greyColor,
                              ),
                            ),
                            title: Text(
                              user.userImage == 'null' ||
                                      user.userImage == '' ||
                                      user.userImage == null
                                  ? user.phone??""
                                  : user.userName??'',
                              style: themeData.textTheme.bodyMedium,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Text(
                              (user.email == 'null' ||
                                      user.email == '' ||
                                      user.email == null &&
                                          (user.userName != 'null' ||
                                              user.userName == '' ))
                                  ? user.phone??''
                                  : user.email??'',
                              style: themeData.textTheme.bodySmall,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            trailing: isSelected
                                ? const Icon(Icons.check_circle,
                                    color: Colors.green)
                                : const Icon(Icons.radio_button_unchecked),
                            onTap: () {
                              if (isSelected) {
                                controller.selectedUserIds.remove(user.userId);
                              } else {
                                controller.selectedUserIds.add(user.userId??0);
                              }
                              controller.update();
                            },
                          );
                        },
                      ),
              ),*/
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel',
                style: themeData.textTheme.bodySmall
                    ?.copyWith(color: Colors.white)),
            style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(appColorYellow),
                padding: WidgetStateProperty.all(
                    EdgeInsets.symmetric(vertical: 3, horizontal: 15))),
          ),
          dynamicButton(
              name: "Create",
              onTap:controller.createBroadcast,
              btnColor: appColorYellow,
              isShowText: true,
              isShowIconText: true,
              gradient:
                  LinearGradient(colors: [appColorYellow, appColorYellow]),
              iconColor: Colors.white,
              leanIcon: broadcastIcon)
        ],
      );
    });
  }
}
