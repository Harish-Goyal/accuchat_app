import 'package:AccuChat/Constants/colors.dart';
import 'package:AccuChat/utils/loading_indicator.dart';
import 'package:AccuChat/utils/text_style.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../../Constants/assets.dart';
import '../../../../../../utils/networl_shimmer_image.dart';
import '../Controllers/add_broadcard_mem_controller.dart';

class AddBroadcastsMembersScreen extends GetView<AddBroadcastMemController> {


  const AddBroadcastsMembersScreen({super.key});


  @override
  Widget build(BuildContext context) {
    ThemeData themeData = Theme.of(context);
    return GetBuilder<AddBroadcastMemController>(
      builder: (controller) {
        return Scaffold(
          appBar: AppBar(      scrolledUnderElevation: 0,
              surfaceTintColor: Colors.white,title:  Text('Add Broadcasts Members',style: themeData.textTheme.titleMedium,)),
          body: _mainBody(),
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

  Widget _mainBody(){
    return controller.isLoding
        ? const IndicatorLoading()
        :controller.allUsers.isEmpty
        ? const Center(child: Text("No User Found!"))
        : ListView.builder(
      itemCount: controller.allUsers.length,
      itemBuilder: (context, index) {
        final user = controller.allUsers[index];
        final isSelected = controller.selectedUserIds.contains(user.id);
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
                style: BalooStyles.baloonormalTextStyle(),
              )),
          subtitle: Text((user.email=='null'||user.email==''||user.email==null && (user.name!='null'||user.name==''||user.name))?
          user.phone:user.email,style: BalooStyles.baloonormalTextStyle(size: 13),),
          secondary: SizedBox(
            width: 55,
            child: CustomCacheNetworkImage(
              user.image??'',radiusAll: 100,height: 75,defaultImage: userIcon,
              borderColor: greyColor,),
          ),
        );
      },
    );
  }

}
