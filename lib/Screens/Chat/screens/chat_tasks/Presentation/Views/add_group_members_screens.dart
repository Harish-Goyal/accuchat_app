import 'package:AccuChat/Constants/colors.dart';
import 'package:AccuChat/Services/APIs/api_ends.dart';
import 'package:AccuChat/utils/custom_flashbar.dart';
import 'package:AccuChat/utils/loading_indicator.dart';
import 'package:AccuChat/utils/text_style.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../../Constants/assets.dart';
import '../../../../../../main.dart';
import '../../../../../../utils/networl_shimmer_image.dart';
import '../../../../api/apis.dart';
import '../../../../models/chat_user.dart';
import '../Controllers/add_group_mem_controller.dart';

class AddGroupMembersScreen extends GetView<AddGroupMemController> {

  const AddGroupMembersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    ThemeData themeData  = Theme.of(context);
    return GetBuilder<AddGroupMemController>(
        init: AddGroupMemController()
          ..setData(
            all: controller.allUsersList,       // supply your data
            group: controller.members, // supply your data
            current: controller.myCompany?.userCompanies?.userCompanyId,              // logged in user's uc_id
          ),
      builder: (controller) {
        return Scaffold(
          appBar: AppBar(title:  Text(
          controller.group?.userCompany?.isGroup==1?  'Add Group Members':
          'Add Broadcast Members',style: themeData.textTheme.titleMedium,)),
          body:controller.isLoading?const IndicatorLoading(): controller.allUsersList.isEmpty
              ?   Center(child: Text("No User Found!",style: BalooStyles.baloomediumTextStyle(),))
              : ListView.builder(
            itemCount: controller.allUsersList.length,
            itemBuilder: (context, index) {
              final user = controller.allUsersList[index];
              final isSelected = controller.selectedUserIds.contains(user.userCompany?.userCompanyId);
              // final isAdmin = controller.adminIds.contains(user.userId);
              final isMe = controller.me?.userId == user.userId;
              return CheckboxListTile(
                value: isSelected,
                checkColor: Colors.white,
                activeColor: appColorGreen,
                onChanged: (selected) {

                    if (selected == true) {
                      controller.selectedUserIds.add(user.userCompany?.userCompanyId??0);
                    } else {
                      controller.selectedUserIds.remove(user.userCompany?.userCompanyId??0);
                    }
                    controller.update();
                },
                title: SizedBox(
                    width: Get.width*.4,
                    child:user.userName==''||user.userName==null?Text(user.isAdmin==1?'Company':"Member",maxLines: 1,overflow: TextOverflow.ellipsis,style: themeData.textTheme.titleMedium,):
                    Text(user.userName??'User',maxLines: 1,overflow: TextOverflow.ellipsis,style: themeData.textTheme.titleMedium,)),
                subtitle: Text(user.email==null?user.phone??'': user.email??'',style: themeData.textTheme.bodySmall),

                secondary: SizedBox(
                  width: mq.height * .055,
                  child: CustomCacheNetworkImage(
                    radiusAll: 100,
                    "${ApiEnd.baseUrlMedia}${user.userImage??""}",
                    height: mq.height * .055,
                    width: mq.height * .055,
                    boxFit: BoxFit.cover,
                    defaultImage: ICON_profile,
                  ),
                ),
              );
            },
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed:controller.selectedUserIds.isNotEmpty? (){
              controller.hitAPIToAddMember(isGroup: controller.group?.userCompany?.isGroup==1?true:false);
            }:(){
              toast("No user selected!");
            },
            label:  Text('Add Members',style: themeData.textTheme.titleSmall?.copyWith(color: Colors.white),),
            icon: const Icon(Icons.group_add,color: Colors.white,),
            backgroundColor: appColorGreen,
          ),
        );
      }
    );
  }
}
