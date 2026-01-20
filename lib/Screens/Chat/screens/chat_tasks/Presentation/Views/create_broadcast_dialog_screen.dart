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

  final CreateBroadcastsController broadcastsController =
  Get.put(CreateBroadcastsController());

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CreateBroadcastsController>(builder: (controller) {
      return LayoutBuilder(
        builder: (context, constraints) {
          final w = constraints.maxWidth;

          double maxW;
          EdgeInsets inset;
          if (w >= 1400) {
            maxW = 640; // large desktop
            inset = const EdgeInsets.symmetric(horizontal: 48, vertical: 28);
          } else if (w >= 900) {
            maxW = 580; // desktop / tablet landscape
            inset = const EdgeInsets.symmetric(horizontal: 40, vertical: 24);
          } else if (w >= 600) {
            maxW = 520; // tablet portrait
            inset = const EdgeInsets.symmetric(horizontal: 24, vertical: 20);
          } else {
            maxW = w * 0.96; // phones
            inset = const EdgeInsets.symmetric(horizontal: 8, vertical: 12);
          }

          return Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxW, minWidth: 280),
              child: AlertDialog(
                alignment: Alignment.center,
                insetPadding: inset,
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                title: Text(
                  'New Broadcast',
                  style: themeData.textTheme.titleSmall,
                ),
                content: SingleChildScrollView(
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
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: ButtonStyle(
                      backgroundColor:
                      MaterialStateProperty.all(appColorYellow),
                      padding: WidgetStateProperty.all(
                        const EdgeInsets.symmetric(
                          vertical: 6,
                          horizontal: 16,
                        ),
                      ),
                      shape: WidgetStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    child: Text(
                      'Cancel',
                      style: themeData.textTheme.bodySmall
                          ?.copyWith(color: Colors.white),
                    ),
                  ),
                  dynamicButton(
                    name: "Create",
                    onTap: controller.createBroadcast,
                    btnColor: appColorYellow,
                    isShowText: true,
                    isShowIconText: true,
                    gradient: LinearGradient(
                      colors: [appColorYellow, appColorYellow],
                    ),
                    iconColor: Colors.white,
                    leanIcon: broadcastIcon,
                  ),
                ],
              ),
            ),
          );
        },
      );
    });
  }
}






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