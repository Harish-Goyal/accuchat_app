import 'package:AccuChat/Constants/colors.dart';
import 'package:AccuChat/utils/loading_indicator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../../Constants/assets.dart';
import '../../../../../../utils/networl_shimmer_image.dart';
import '../../../../api/apis.dart';
import '../../../../models/chat_user.dart';
import '../Controllers/add_broadcard_mem_controller.dart';

class AddBroadcastsMembersScreen extends GetView<AddBroadcastMemController> {


  const AddBroadcastsMembersScreen({super.key});


  @override
  Widget build(BuildContext context) {
    ThemeData themeData = Theme.of(context);
    return GetBuilder<AddBroadcastMemController>(
      builder: (controller) {
        return Scaffold(
          appBar: AppBar(title:  Text('Add Broadcasts Members',style: themeData.textTheme.titleMedium,)),
          body: controller.isLoding
              ? const IndicatorLoading()
              :controller.allUsers.isEmpty
              ? const Center(child: Text("No User Found!"))
              : ListView.builder(
            itemCount: controller.allUsers.length,
            itemBuilder: (context, index) {
              final user = controller.allUsers[index];
              final isSelected = controller.selectedUserIds.contains(user.id);
              final isAdmin = controller.adminIds.contains(user.id);
              final isMe = controller.currentUserId == user.id;
              return CheckboxListTile(
                value: isSelected,
                checkColor: Colors.white,
                activeColor: appColorPerple,
                onChanged: (selected) {
                    if (selected == true) {
                      controller.selectedUserIds.add(user.id);
                    } else {
                      controller.selectedUserIds.remove(user.id);
                    }
                    controller.update();
                },
                title: SizedBox(
                    width: Get.width * .4,
                    child: Text(
                      user.name=='null'||user.name==''||user.name==null?
                      user.phone:user.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: themeData.textTheme.titleMedium,
                    )),
                subtitle: Text((user.email=='null'||user.email==''||user.email==null && (user.name!='null'||user.name==''||user.name))?
                user.phone:user.email,style: themeData.textTheme.bodySmall,),
                secondary: SizedBox(
                  width: 55,
                  child: CustomCacheNetworkImage(
                    user.image??'',radiusAll: 100,height: 75,defaultImage: userIcon,
                    borderColor: greyColor,),
                ),
              );
            },
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () {
              // controller.selectedUserIds.isEmpty
              //     ? null
              //     : APIs.addMemberToBroadcast(controller.chat?.id??'', controller.selectedUserIds);
            },
            label: Text(
              'Add Members',
              style: themeData.textTheme.titleSmall?.copyWith(color: Colors.white),
            ),
            icon: const Icon(
              Icons.group_add,
              color: Colors.white,
            ),
            backgroundColor: appColorPerple,
          ),
        );
      }
    );
  }

}
