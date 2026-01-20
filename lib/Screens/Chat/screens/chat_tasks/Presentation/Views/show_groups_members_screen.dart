import 'package:AccuChat/Constants/assets.dart';
import 'package:AccuChat/Constants/colors.dart';
import 'package:AccuChat/Constants/themes.dart';
import 'package:AccuChat/Extension/text_field_extenstion.dart';
import 'package:AccuChat/Screens/Chat/screens/chat_tasks/Presentation/Controllers/members_gr_br_controller.dart';
import 'package:AccuChat/Services/APIs/api_ends.dart';
import 'package:AccuChat/utils/confirmation_dialog.dart';
import 'package:AccuChat/utils/helper_widget.dart';
import 'package:AccuChat/utils/networl_shimmer_image.dart';
import 'package:AccuChat/utils/text_style.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../../routes/app_routes.dart';
import '../../../../../../utils/common_textfield.dart';
import '../../../../../../utils/custom_dialogue.dart';
import '../../../../../../utils/custom_flashbar.dart';
import '../../../../api/apis.dart';

class GroupMembersScreen extends GetView<GrBrMembersController> {
  const GroupMembersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    ThemeData themeData = Theme.of(context);

    return GetBuilder<GrBrMembersController>(
      builder: (controller) {
        return Scaffold(
          appBar:_appBarWidget(),
          body: _mainBody(),
        );
      },
    );
  }

  _mainBody(){
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: kIsWeb ? 650 : double.infinity,
        ),
        child: Column(
          children: [
            const SizedBox(height: 10),
            const CircleAvatar(
              radius: 40,
              backgroundColor: Colors.white,
              backgroundImage: AssetImage(groupIcn),
            ),

            CustomTextField(
              hintText: controller.groupOrBr?.userCompany?.isGroup == 1
                  ? "Group Name"
                  : "Broadcast Name",
              labletext: "",
              readOnly:
              (controller.groupOrBr?.createdBy == APIs.me?.userCompany?.userCompanyId)
                  ? false
                  : true,
              controller: controller.groupNameController,
              onChangee: (v) {
                controller.isUpdate = true;
                controller.update();
              },
              validator: (value) {
                return value?.isEmptyField(
                    messageTitle:
                    controller.groupOrBr?.userCompany?.isGroup == 1
                        ? "Group Name"
                        : "Broadcast Name");
              },
              prefix: Icon(
                Icons.group,
                color: appColorPerple,
              ),
            ).marginSymmetric(horizontal: 20, vertical: 20),

            if (controller.isUpdate)
              dynamicButton(
                  name: "Update",
                  onTap: controller.groupNameController.text.isNotEmpty
                      ? () => controller.updateGroupBroadcastApi(
                    isGroup: controller.groupOrBr?.userCompany
                        ?.isGroup ==
                        1
                        ? 1
                        : 0,
                    isBroadcast: controller.groupOrBr?.userCompany
                        ?.isBroadcast ==
                        1
                        ? 1
                        : 0,
                  )
                      : () {
                    toast("Name cannot be empty");
                  },
                  isShowText: true,
                  isShowIconText: false,
                  gradient: buttonGradient,
                  leanIcon: chaticon),

            const SizedBox(height: 10),

            Expanded(
              child: ListView.builder(
                itemCount: controller.members.length,
                itemBuilder: (context, index) {
                  final member = controller.members[index];
                  final isAdmin = member.isAdmin == 1 ? true : false;
                  final me = APIs.me;
                  final bool isSelf =
                      member.userId == me?.userId;
                  final int? creatorUserId =
                      controller.groupOrBr?.createdBy ??
                          controller.groupOrBr?.createdBy;

                  final bool iAmCreator =
                      me?.userCompany?.userCompanyId == creatorUserId;
                  final bool targetIsCreator =
                      member.userCompany?.userCompanyId == creatorUserId;

                  final bool iAmAdmin = (me?.isAdmin ?? 0) == 1;
                  final bool targetIsAdmin = (member.isAdmin ?? 0) == 1;

                  final bool iAmMemberOnly =
                      !iAmCreator && !iAmAdmin;

                  final bool isGroup =
                      (controller.groupOrBr?.userCompany?.isGroup ?? 0) == 1;

                  final bool showMenu = !isSelf &&
                      !iAmMemberOnly &&
                      !(iAmAdmin && targetIsCreator);

                  final bool canMakeAdmin = !targetIsAdmin &&
                      (iAmCreator || iAmAdmin);

                  final bool canRemove = (iAmCreator && !isSelf) ||
                      (iAmAdmin && !targetIsCreator && !isSelf);

                  return
                    Container(
                      margin: const EdgeInsets.symmetric(
                          vertical: 6, horizontal: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: kIsWeb
                            ? [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 12,
                            spreadRadius: 1,
                            offset: const Offset(0, 4),
                          )
                        ]
                            : [],
                      ),

                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 0, horizontal: 12),
                        leading: SizedBox(
                          width: 50,
                          child: CustomCacheNetworkImage(
                            "${ApiEnd.baseUrlMedia}${member.userImage ?? ''}",
                            radiusAll: 100,
                            height: 50,
                            width: 50,
                            defaultImage: userIcon,
                            borderColor: greyColor,
                            boxFit: BoxFit.cover,
                          ),
                        ),

                        title: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              member.userCompany?.displayName!=null?
                              member.userCompany?.displayName?? '':member.userName!=null?
                              member.userName??'':member.phone??'',
                              style: BalooStyles.baloonormalTextStyle(),
                            ),
                            if (isAdmin ?? true)
                              Padding(
                                padding: const EdgeInsets.only(left: 6),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: appColorGreen,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text('admin',
                                      style: TextStyle(
                                          fontSize: 10,
                                          color: Colors.white)),
                                ),
                              ),
                          ],
                        ),
                        subtitle: Text(
                          member.phone == '' ||
                              member.phone == null
                              ? member.email ?? ''
                              : member.phone ?? '',
                          style: BalooStyles.baloonormalTextStyle(color: greyText),
                        ),
                        trailing: showMenu
                            ? PopupMenuButton<String>(
                          onSelected: (value) {
                            if (value == 'make_admin') {
                              controller.hitAPIToUpdateMember(
                                mode: "set_admin",
                                isGroup: isGroup,
                                id: member.userCompany?.userCompanyId,
                              );
                            } else if (value == 'remove') {
                              controller.hitAPIToUpdateMember(
                                mode: "remove",
                                isGroup: isGroup,
                                id: member.userCompany?.userCompanyId,
                              );
                            }
                          },
                          itemBuilder: (context) => [
                            if (canMakeAdmin)
                              PopupMenuItem(
                                value: 'make_admin',
                                child: Row(
                                  children: [
                                    Icon(Icons.circle_rounded,
                                        size: 12,
                                        color: appColorGreen),
                                    hGap(5),
                                    Text('Make Admin',
                                        style: BalooStyles.baloonormalTextStyle()),
                                  ],
                                ),
                              ),
                            if (canRemove)
                              PopupMenuItem(
                                value: 'remove',
                                child: Row(
                                  children: [
                                    Icon(Icons.remove_circle,
                                        size: 12,
                                        color: AppTheme.redErrorColor),
                                    hGap(5),
                                    Text('Remove Member',
                                        style: BalooStyles.baloonormalTextStyle()),
                                  ],
                                ),
                              ),
                          ],
                          color: Colors.white,
                          icon: const Icon(Icons.more_vert),
                        )
                            : null,
                        onTap: () {},
                      ),
                    );
                },
              ),
            )
          ],
        ),
      ),
    );
  }

  AppBar _appBarWidget(){
    return  AppBar(
      automaticallyImplyLeading: false,
      leading: IconButton(onPressed: (){
        Get.back();
      }, icon:const Icon(Icons.arrow_back)),
      title: Text(
        controller.groupOrBr?.userCompany?.isGroup == 1
            ? 'Group Members'
            : "Broadcast Members",
        style: BalooStyles.balooboldTitleTextStyle(),
      ),
      actions: [
        if (controller.groupOrBr?.createdBy ==
            APIs.me?.userCompany?.userCompanyId)
          PopupMenuButton<String>(
            color: Colors.white,
            icon: const Icon(Icons.more_vert,
                color: Colors.black87, size: 18),
            onSelected: (value) {
              if (value == 'delete') {
                showResponsiveConfirmationDialog(onConfirm:  () async {
                  controller.hitAPIToDeleteGrBr(
                    isGroup: controller.groupOrBr?.userCompany?.isGroup == 1
                        ? true
                        : false,
                  );
                },title: controller.groupOrBr?.userCompany?.isGroup == 1
                    ? 'Delete Group'
                    : "Delete Broadcast");

              } else if (value == 'add') {
                if (kIsWeb) {
                  Get.toNamed(
                    "${AppRoutes.add_group_member}?groupChatId=${controller.groupOrBr?.userId.toString()}",
                  );
                } else {
                  Get.toNamed(
                    AppRoutes.add_group_member,
                    arguments: {'groupChat': controller.groupOrBr},
                  );
                }
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    const Icon(Icons.delete_outline,
                        color: Colors.black87, size: 18),
                    hGap(5),
                    Text('Delete',
                        style: BalooStyles.baloonormalTextStyle()),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'add',
                child: Row(
                  children: [
                    const Icon(Icons.person_add_outlined,
                        color: Colors.black87, size: 18),
                    hGap(5),
                    Text('Add Member',
                        style: BalooStyles.baloonormalTextStyle()),
                  ],
                ),
              ),
            ],
          )
      ],
    );
  }

}

/*class GroupMembersScreen extends StatelessWidget {

  const GroupMembersScreen({super.key});


  @override
  Widget build(BuildContext context) {


    ThemeData themeData = Theme.of(context);

    return GetBuilder<GrBrMembersController>(
      builder: (controller) {
        return Scaffold(
          appBar: AppBar(title:  Text(
            controller.groupOrBr?.userCompany?.isGroup==1?
              'Group Members':"Broadcast Members",style:BalooStyles.balooboldTitleTextStyle()),
            actions: [
              if (controller.groupOrBr?.createdBy == controller.me?.userCompany?.userCompanyId)
                PopupMenuButton<String>(
                  color: Colors.white,
                  icon:  const Icon(Icons.more_vert,color: Colors.black87,size: 18,),
                  onSelected: (value) {
                    if (value == 'delete') {
                      controller.hitAPIToDeleteGrBr(isGroup:
                      controller.groupOrBr?.userCompany?.isGroup==1?true:false,);
                    }
                    else if(value == 'add'){
                      if(kIsWeb){
                        Get.toNamed(
                          "${AppRoutes.add_group_member}?groupChatId=${controller.groupOrBr?.userId.toString()}",
                        );
                      }else{
                        Get.toNamed(
                          AppRoutes.add_group_member,
                          arguments: {'groupChat': controller.groupOrBr},
                        );
                      }
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          const Icon(Icons.delete_outline,color: Colors.black87,size: 18,),
                          hGap(5),
                           Text('Delete',style: BalooStyles.baloonormalTextStyle(),),
                        ],
                      ),
                    ),PopupMenuItem(
                      value: 'add',
                      child: Row(
                        children: [
                          const Icon(Icons.person_add_outlined,color: Colors.black87,size: 18),
                          hGap(5),
                           Text('Add Member',style: BalooStyles.baloonormalTextStyle(),),
                        ],
                      ),
                    ),
                  ],
                )
            ],),
          body: Column(
            children: [
              const SizedBox(height: 10),
              const CircleAvatar(
                radius: 40,
                backgroundColor: Colors.white,
                backgroundImage: AssetImage(groupIcn), // static image
              ),


              CustomTextField(
                hintText:controller.groupOrBr?.userCompany?.isGroup==1? "Group Name":"Broadcast Name",
                labletext: "",
                readOnly: (controller.groupOrBr?.createdBy == controller.me?.createdBy)?true:false,
                controller:controller.groupNameController,
                onChangee:(v){
                  controller.isUpdate = true;
                  controller.update();
                },
                validator: (value) {
                  return value?.isEmptyField(messageTitle:controller.groupOrBr?.userCompany?.isGroup==1?"Group Name":"Broadcast Name" );
                },
                prefix: Icon(Icons.group,color: appColorPerple,),

              ).marginSymmetric(horizontal: 20,vertical: 20),
              if (controller.isUpdate)
                dynamicButton(
                    name: "Update",
                    onTap:controller.groupNameController.text.isNotEmpty?()=> controller.updateGroupBroadcastApi(isGroup:controller.groupOrBr?.userCompany?.isGroup==1? 1:0,isBroadcast:controller.groupOrBr?.userCompany?.isBroadcast==1? 1:0):(){
                      toast("Name cannot be empty");
                    },
                    isShowText: true,
                    isShowIconText: false,
                    gradient: buttonGradient,
                    leanIcon: chaticon),
              const SizedBox(height: 10),
              Expanded(
                child: ListView.builder(
                  // padding: EdgeInsets.zero,
                  itemCount: controller.members.length,
                  itemBuilder: (context, index) {
                    final member =controller.members[index];
                    final isAdmin = member.isAdmin==1?true:false;
                    // final isSelf = user.userId == controller.me?.userId;
                    // final creator = user.userCompany?.userCompanyId == controller.me?.userCompany?.userCompanyId;
                    final me     = controller.me;

// --- role flags ---
                    final bool isSelf           = member.userId == me?.userId;

// creator ko hamesha userId se identify karo (userCompanyId se nahi)
// apne model ke field ke hisab se use karo:
                    final int? creatorUserId =
                        controller.groupOrBr?.createdBy ??
                            controller.groupOrBr?.createdBy; // jo field ho, wahi rakho

                    final bool iAmCreator       = me?.userCompany?.userCompanyId == creatorUserId;
                    final bool targetIsCreator  = member.userCompany?.userCompanyId == creatorUserId;

                    final bool iAmAdmin         = (me?.isAdmin ?? 0) == 1;               // logged-in user admin?
                    final bool targetIsAdmin    = (member.isAdmin ?? 0) == 1;            // target admin?

                    final bool iAmMemberOnly    = !iAmCreator && !iAmAdmin;              // normal member
                    final bool isGroup          = (controller.groupOrBr?.userCompany?.isGroup ?? 0) == 1;

// --- can show popup on this row? ---
// 1) member (non-admin, non-creator) => kabhi options nahi
// 2) self-row par kabhi options nahi
// 3) admin creator par act nahi kar sakta
                    final bool showMenu = !isSelf
                        && !iAmMemberOnly
                        && !(iAmAdmin && targetIsCreator);

// --- which actions inside menu? ---
// Make Admin: sirf jab target admin na ho (creator already admin hota hai),
//             aur actor (creator/admin) ho.
                    final bool canMakeAdmin = !targetIsAdmin
                        && (iAmCreator || iAmAdmin);

// Remove Member:
// - Creator: kisi ko bhi (self ko chhor kar) remove kar sakta
// - Admin: creator ko remove nahi kar sakta, baaki sab ko kar sakta (admins/members)
                    final bool canRemove = (iAmCreator && !isSelf)
                        || (iAmAdmin && !targetIsCreator && !isSelf);

                    return

                     ListTile(
                      contentPadding: const EdgeInsets.symmetric(vertical: 0,horizontal: 15),
                      leading:SizedBox(
                        width: 60,
                        child: CustomCacheNetworkImage("${ApiEnd.baseUrlMedia}${member.userImage??''}",radiusAll: 100,height: 60,width:60,defaultImage: userIcon,
                          borderColor: greyColor,
                        boxFit: BoxFit.cover,),
                      ),
                      title: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            member.displayName??'',
                            style: themeData.textTheme.bodyMedium,
                          ),
                          if (isAdmin??true)
                            Padding(
                              padding: const EdgeInsets.only(left: 6),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: appColorGreen,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text('admin',
                                    style: TextStyle(
                                        fontSize: 10, color: Colors.white)),
                              ),
                            ),
                        ],
                      ),
                      subtitle: Text(
                        member.phone==''||member.phone==null?member.email??'':member.phone??'',
                        style: themeData.textTheme.bodySmall
                            ?.copyWith(color: greyText),
                      ),
                      trailing:
                     showMenu
                        ? PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'make_admin') {
                          controller.hitAPIToUpdateMember(
                            mode: "set_admin",
                            isGroup: isGroup,
                            id: member.userCompany?.userCompanyId,
                          );
                        } else if (value == 'remove') {
                          controller.hitAPIToUpdateMember(
                            mode: "remove",
                            isGroup: isGroup,
                            id: member.userCompany?.userCompanyId,
                          );
                        }
                      },
                      itemBuilder: (context) => [
                        if (canMakeAdmin)
                          PopupMenuItem(
                            value: 'make_admin',
                            child: Row(
                              children: [
                                Icon(Icons.circle_rounded, size: 12, color: appColorGreen),
                                hGap(5),
                                Text('Make Admin', style: themeData.textTheme.bodySmall),
                              ],
                            ),
                          ),
                        if (canRemove)
                          PopupMenuItem(
                            value: 'remove',
                            child: Row(
                              children: [
                                Icon(Icons.remove_circle, size: 12, color: AppTheme.redErrorColor),
                                hGap(5),
                                Text('Remove Member', style: themeData.textTheme.bodySmall),
                              ],
                            ),
                          ),
                      ],
                      color: Colors.white,
                      icon: const Icon(Icons.more_vert),
                    )
                        : null,
                      onTap: (){

                      },
                    );
                  },
                ),
              )
            ],
          ),
        );
      }
    );
  }

}*/
