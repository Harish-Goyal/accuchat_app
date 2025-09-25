import 'package:AccuChat/Constants/assets.dart';
import 'package:AccuChat/Constants/colors.dart';
import 'package:AccuChat/Constants/themes.dart';
import 'package:AccuChat/routes/app_routes.dart';
import 'package:AccuChat/utils/loading_indicator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:swipe_to/swipe_to.dart';
import '../../../../../../Constants/app_theme.dart';
import '../../../../../../Services/APIs/api_ends.dart';
import '../../../../../../main.dart';
import '../../../../../../utils/common_textfield.dart';
import '../../../../../../utils/custom_dialogue.dart';
import '../../../../../../utils/custom_flashbar.dart';
import '../../../../../../utils/gradient_button.dart';
import '../../../../../../utils/helper_widget.dart';
import '../../../../../../utils/networl_shimmer_image.dart';
import '../../../../../../utils/text_style.dart';
import '../../../../../Home/Presentation/Controller/company_service.dart';
import '../../../../api/apis.dart';
import '../../../../helper/dialogs.dart';
import '../../../../models/chat_user.dart';
import '../Controllers/task_home_controller.dart';
import '../Widgets/broad_cast_card.dart';
import '../Widgets/chat_group_card.dart';
import '../Widgets/chat_user_card.dart';
import '../Controllers/chat_home_controller.dart';
import 'chat_groups.dart';
import 'chats_broadcasts.dart';
import 'create_broadcast_dialog_screen.dart';

class TaskHomeScreen extends GetView<TaskHomeController> {
  TaskHomeScreen({super.key});

  TaskHomeController taskhomec =
  Get.put<TaskHomeController>(TaskHomeController());
  @override
  Widget build(BuildContext context) {
    return GetBuilder<TaskHomeController>(
        init: TaskHomeController(),
        builder: (controller) {
          return GestureDetector(
            //for hiding keyboard when a tap is detected on screen
            onTap: () => FocusScope.of(context).unfocus(),
            child: WillPopScope(
              //if search is on & back button is pressed then close search
              //or else simple close current screen on back button click
              onWillPop: () {
                // if (_isSearching) {
                //   setState(() {
                //     _isSearching = !_isSearching;
                //   });
                //   return Future.value(false);
                // } else {
                //   return Future.value(true);
                // }
                return Future.value(true);
              },
              child: Scaffold(
                //app bar
                // backgroundColor: isTaskMode?appColorYellow.withOpacity(.05):Colors.white,
                  appBar: AppBar(
                    automaticallyImplyLeading: false,
                    title: controller.isSearching
                        ? TextField(
                      controller: controller.seacrhCon,
                      cursorColor: appColorGreen,
                      decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Search User, Group & Collection ...',
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
                        : Row(
                          children: [

                            SizedBox(
                              width: 45,
                              child: CustomCacheNetworkImage(
                                "${ApiEnd.baseUrlMedia}${controller.myCompany?.logo ?? ''}",

                                radiusAll:100,
                                height: 45,
                                defaultImage: appIcon,
                                boxFit: BoxFit.cover,
                              ),
                            ).paddingAll(4),
                            Column(
                                                  mainAxisAlignment: MainAxisAlignment.end,
                                                  mainAxisSize: MainAxisSize.min,
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                            Text(
                             "Tasks",
                              style: BalooStyles.balooboldTitleTextStyle(
                                  color:appColorYellow,size: 18),
                            ).paddingOnly(left: 8, top: 4),
                            Text(
                              controller.myCompany?.companyName??'',
                              style: BalooStyles.baloosemiBoldTextStyle(
                                color: appColorYellow,),
                            ).paddingOnly(left: 8, top: 2),


                                                  ],
                                                ),
                          ],
                        ),
                    actions: [
                      //search user button
                      IconButton(
                          onPressed: () {

                            controller.isSearching = !controller.isSearching;
                            controller.update();
                          },
                          icon: Icon(controller.isSearching
                              ? CupertinoIcons.clear_circled_solid
                              : Icons.search)
                              .paddingOnly(top: 0, right: 10)),


                    ],
                  ),

                  //floating button to add new user
                  floatingActionButton: Padding(
                    padding:  const EdgeInsets.only(bottom: 10),
                    child: FloatingActionButton(
                        onPressed: () {
                          // _addChatUserDialog();
                          if(kIsWeb){
                            Get.toNamed("${AppRoutes.all_users}?isRecent='false'");
                          }else{
                            Get.toNamed(AppRoutes.all_users,
                                arguments: {"isRecent": 'false'});
                          }
                        },
                        backgroundColor:appColorYellow,
                        child: const Icon(
                          Icons.add,
                          color: Colors.white,
                        )),
                  ),


                  body:
                 (controller.filteredList??[]).isEmpty?InkWell(
                   onTap: (){
                     if(kIsWeb){
                       Get.toNamed("${AppRoutes.all_users}?isRecent='false'");
                     }else{
                       Get.toNamed(AppRoutes.all_users,
                           arguments: {"isRecent": 'false'});
                     }
                   },
                   child: Center(
                       child: Column(
                         mainAxisAlignment: MainAxisAlignment.center,
                         children: [
                           Image.asset(emptyRecentPng,height: 90,),
                           Text('Click to Start New Task ✍️',
                               style: BalooStyles.baloosemiBoldTextStyle(color: appColorGreen)).paddingAll(12),
                         ],
                       )),
                 ) : RefreshIndicator(
          backgroundColor: Colors.white,
          color: appColorGreen,
          onRefresh: () async => controller.hitAPIToGetRecentTasksUser(),
          child: ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: controller.filteredList.length,
                    controller: controller.scrollController,
                    itemBuilder: (context, index) {
                      final item = controller.filteredList[index];
                      return  SwipeTo(
                          iconOnLeftSwipe: Icons.delete_outline,
                          iconColor: Colors.red,
                          onLeftSwipe: (detail)async {
                            final confirm = await showDialog(
                              context: context,
                              builder: (_) => AlertDialog(
                                backgroundColor: Colors.white,
                                title: Text(
                                    "Remove ${ item.email == null || item.email == '' ? item.phone : item?.email}"),
                                content: const Text(
                                    "Are you sure you want to remove this member from recants?"),
                                actions: [
                                  TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, false),
                                      child: const Text("Cancel")),
                                  TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, true),
                                      child: Text(
                                        "Remove",
                                        style: BalooStyles
                                            .baloosemiBoldTextStyle(
                                            color: Colors.red),
                                      )),
                                ],
                              ),
                            );

                            if (confirm == true) {
                              customLoader.show();

                              // await APIs.deleteRecantUserAndChat(item.id);
                              customLoader.hide();
                              controller.update();

                            }
                          },
                          child:
                          ChatUserCard(user: item)
                      );
                    },
                  )
              ),
            ),
          ));
        }
    );
  }

  Widget _buildHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
    );
  }




  _groupDialogWidget() {
    return CustomDialogue(
      title: "Create Group",
      isShowAppIcon: false,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "Enter group name to create Group",
            style: BalooStyles.baloonormalTextStyle(),
            textAlign: TextAlign.center,
          ),
          /*    vGap(20),
            Container(
              width: Get.width,
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: 'Select Type',
                  hintText: 'Select Type',
                  hintStyle:
                  BalooStyles.baloonormalTextStyle(color: Colors.grey),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade400)),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade400)),
                  labelStyle: BalooStyles.baloonormalTextStyle(),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding:
                  const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: controller.selectedGroupType,
                    hint: Text(
                      "Select Type",
                      style: BalooStyles.baloomediumTextStyle(),
                    ),
                    items: ["Group", "Collection"]
                        .map((String type) => DropdownMenuItem<String>(
                      value: type,
                      child: SizedBox(
                          width: Get.width * .52,
                          child: Text(
                            type,
                            style: BalooStyles.baloomediumTextStyle(),
                          )),
                    ))
                        .toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        controller.selectedGroupType = newValue;
                        controller.update();
                      }
                    },
                    dropdownColor: Colors.white,
                  ),
                ),
              ),
            ),*/
          vGap(20),
          CustomTextField(
            hintText: "Group Name",
            controller: controller.groupController,
            focusNode: FocusNode(),
            onFieldSubmitted: (String? value) {
              FocusScope.of(Get.context!).unfocus();
            },
            labletext: "Group Name",
          ),
          vGap(30),
          GradientButton(
            name: "Submit",
            btnColor: AppTheme.appColor,
            vPadding: 8,
            onTap: () {
              if (controller.groupController.text.isNotEmpty) {
                controller.createGroupBroadcastApi(isGroup: "1",isBroadcast: '0');
              } else {
                errorDialog("Please enter group name");
              }
            },
          )
        ],
      ),
      onOkTap: () {},
    );
  }

  // for adding new chat user
  void _addChatUserDialog() {
    String email = '';

    showDialog(
        context: Get.context!,
        builder: (_) => AlertDialog(
          contentPadding: const EdgeInsets.only(
              left: 24, right: 24, top: 20, bottom: 10),

          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20)),

          //title
          title: const Row(
            children: [
              Icon(
                Icons.person_add,
                color: Colors.blue,
                size: 28,
              ),
              Text('  Add User')
            ],
          ),

          //content
          content: TextFormField(
            maxLines: null,
            onChanged: (value) => email = value,
            decoration: InputDecoration(
                hintText: 'Email Id',
                prefixIcon: const Icon(Icons.email, color: Colors.blue),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15))),
          ),

          //actions
          actions: [
            //cancel button
            MaterialButton(
                onPressed: () {
                  //hide alert dialog
                  Get.back();
                },
                child: const Text('Cancel',
                    style: TextStyle(color: Colors.blue, fontSize: 16))),

            //add button
            MaterialButton(
                onPressed: () async {
                  //hide alert dialog
                  Get.back();
                  // if (email.isNotEmpty) {
                  //   await APIs.addChatUser(email).then((value) {
                  //     if (!value) {
                  //       Dialogs.showSnackbar(
                  //           Get.context!, 'User does not Exists!');
                  //     }
                  //   });
                  // }
                },
                child: const Text(
                  'Add',
                  style: TextStyle(color: Colors.blue, fontSize: 16),
                ))
          ],
        ));
  }
}
