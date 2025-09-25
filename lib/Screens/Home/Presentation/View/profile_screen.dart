
import 'dart:io';

import 'package:AccuChat/Constants/assets.dart';
import 'package:AccuChat/Constants/colors.dart';
import 'package:AccuChat/Screens/Home/Presentation/Controller/profile_controller.dart';
import 'package:AccuChat/Services/APIs/api_ends.dart';
import 'package:AccuChat/utils/gradient_button.dart';
import 'package:AccuChat/utils/loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../Constants/themes.dart';
import '../../../../Services/APIs/local_keys.dart';
import '../../../../routes/app_routes.dart';
import '../../../../utils/common_textfield.dart';
import '../../../../utils/custom_dialogue.dart';
import '../../../../utils/helper_widget.dart';
import '../../../../utils/networl_shimmer_image.dart';
import '../../../../utils/text_style.dart';
import '../Controller/home_controller.dart';
import 'home_screen.dart';
import '../../../Settings/Presentation/Views/settings_screen.dart';
import '../../../Chat/api/apis.dart';
import '../../../Chat/helper/dialogs.dart';
import '../../../../main.dart';
import '../../../Chat/models/chat_user.dart';
import '../../../Chat/screens/auth/Presentation/Views/login_screen.dart';

//profile screen -- to show signed in user info
class ProfileScreen extends GetView<HProfileController> {

   ProfileScreen({super.key});

  final _formKey = GlobalKey<FormState>();


  @override
  Widget build(BuildContext context) {

    return GetBuilder<HProfileController>(
      builder: (controller) {
        return GestureDetector(
          // for hiding keyboard
          onTap: () => FocusScope.of(context).unfocus(),
          child: Scaffold(
            //app bar
              appBar: AppBar(title:  Text('Profile',style: BalooStyles.balooboldTitleTextStyle(),),actions: [
                InkWell(
                    onTap: ()
                    async {
                      showDialog(
                          context: Get.context!,
                          builder: (_) => CustomDialogue(
                            title: "Logout",
                            isShowAppIcon: false,
                            content: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                vGap(20),
                                Text(
                                  "Do you really want to Logout?",
                                  style: BalooStyles.baloonormalTextStyle(),
                                  textAlign: TextAlign.center,
                                ),

                                vGap(30),

                                Row(
                                  children: [
                                    Expanded(
                                      child: GradientButton(
                                        name: "Yes",
                                        btnColor: AppTheme.redErrorColor,
                                        gradient: LinearGradient(colors: [AppTheme.redErrorColor,AppTheme.redErrorColor]),

                                        vPadding: 6,
                                        onTap: () async{
                                          logoutLocal();
                                        },
                                      ),
                                    ),
                                    hGap(15),
                                    Expanded(
                                      child: GradientButton(
                                        name: "Cancel",
                                        btnColor: Colors.black,
                                        color: Colors.black,
                                        gradient: LinearGradient(colors: [AppTheme.whiteColor,Colors.white]),
                                        vPadding: 6,
                                        onTap: () {
                                          Get.back();
                                        },
                                      ),
                                    ),
                                  ],
                                )
                                // Text(STRING_logoutHeading,style: BalooStyles.baloomediumTextStyle(),),
                              ],
                            ),
                            onOkTap: () {},
                          ));


                    },
                    child: Container(
                        padding: EdgeInsets.all(10),
                        child: Icon(Icons.logout)))
              ],),

              //body
              body:controller.isLoading?IndicatorLoading(): Form(
                key: _formKey,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: mq.width * .05),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        // for adding some space
                        SizedBox(width: mq.width, height: mq.height * .01),

                        //user profile picture
                        Stack(
                          children: [
                            //profile picture
                            controller.image != null
                                ?

                            //local image
                            Container(
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: appColorGreen,width: 1)
                              ),
                              child: ClipRRect(
                                  borderRadius:
                                  BorderRadius.circular(mq.height * .1),
                                  child: Image.file(File(controller.image??''),
                                    width: mq.height * .18,
                                    height: mq.height * .18,
                                    fit: BoxFit.cover,
                                    errorBuilder: (b,c,v){
                                      return Image.asset(userIcon,height: 40,);
                                    },
                                  )),
                            )
                                :

                            //image from server
                            CustomCacheNetworkImage(
                              // APIs.me.image??'',
                              "${ApiEnd.baseUrlMedia}${controller.profileImg}",
                              height: mq.height * .18,
                              width: mq.height * .18,
                              boxFit: BoxFit.cover,
                              radiusAll: 100,
                              defaultImage: userIcon,
                              borderColor: AppTheme.appColor,
                            ),

                            //edit image button
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: MaterialButton(
                                elevation: 1,
                                onPressed: () {
                                  _showBottomSheet();
                                },
                                shape: const CircleBorder(),
                                color: Colors.white,
                                child: const Icon(Icons.edit, color: Colors.blue),
                              ),
                            )
                          ],
                        ),

                        // for adding some space
                        /*SizedBox(height: mq.height * .04 ),
                        ChatCard(

                            iconWidget:CustomCacheNetworkImage(
                                radiusAll: 100,
                                APIs.me.selectedCompany?.logoUrl??'') ,
                            trailWidget: Text(APIs.me.selectedCompany?.name??''),
                            title: APIs.me.selectedCompany?.email??'',
                            // subtitle: 'members: ${APIs.me.selectedCompany?.members?.length??0}',
                            onTap: () {}),*/
                        SizedBox(height: mq.height * .03),
                        Column(
                          children: [
                            CustomTextField(
                              hintText: "Username".tr,
                              controller:controller.nameC,
                              // textInputType: TextInputType.,

                              focusNode: FocusNode(),
                              onFieldSubmitted: (String? value) {
                                // FocusScope.of(Get.context!)
                                //     .requestFocus(controller.passwordFocusNode);
                              },
                              labletext: "Username",

                              validator: (value) {
                                // return value?.isEmptyField(messageTitle: "Username");
                              },
                            ),
                            vGap(10),

                            CustomTextField(
                              hintText: "Phone or Email".tr,
                              controller:controller.phoneC,
                              // textInputType: TextInputType.number,
                              readOnly: true,

                              focusNode: FocusNode(),
                              onFieldSubmitted: (String? value) {
                                // FocusScope.of(Get.context!)
                                //     .requestFocus(controller.passwordFocusNode);
                              },
                              labletext: "Phone or Email",

                              validator: (value) {
                                // return value?.isEmptyField(messageTitle: "Username");
                              },
                            ),

                            /*vGap(10),

                            CustomTextField(
                              hintText: "Email".tr,
                              controller:controller.mailC,
                              readOnly:controller.user?.email==null? true:false,
                              textInputType: TextInputType.emailAddress,

                              focusNode: FocusNode(),
                              onFieldSubmitted: (String? value) {
                                // FocusScope.of(Get.context!)
                                //     .requestFocus(controller.passwordFocusNode);
                              },
                              labletext: "Email",

                              validator: (value) {
                                if((value??'').isEmpty || value == null){
                                  return null;
                                }else{
                                  return value?.isValidEmail();
                                }
                              },
                            ),*/
                            vGap(10),

                            CustomTextField(
                              hintText: "About".tr,
                              controller:controller.aboutC,
                              // textInputType: TextInputType.,
                              maxLines: 4,

                              focusNode: FocusNode(),
                              onFieldSubmitted: (String? value) {
                                // FocusScope.of(Get.context!)
                                //     .requestFocus(controller.passwordFocusNode);
                              },
                              labletext: "About",

                              validator: (value) {
                                // return value?.isEmptyField(messageTitle: "Username");
                              },
                            ),
                          ],
                        ).marginSymmetric(horizontal: 5),



                        // for adding some space
                        SizedBox(height: mq.height * .05),

                        // update profile button
                        GradientButton(name: "Update", onTap: (){


                          SystemChannels.textInput.invokeMethod('TextInput.hide');
                          if (_formKey.currentState!.validate()) {
                            _formKey.currentState!.save();
                            controller.hitAPIToUpdateUser();
                            /*APIs.updateUserInfo(
                                controller.nameC.text.trim(),
                                controller.mailC.text.trim(),
                                controller.phoneC.text.trim(),
                                controller.aboutC.text.trim()
                            ).then((value)async {
                              await APIs.getSelfInfo();
                              Get.back();
                              Get.snackbar(
                                  'Profile Updated',
                                  'Profile Updated Successfully!',
                                  backgroundColor: Colors.white.withOpacity(.9),colorText: Colors.black);
                            });*/
                          }
                        }),

                        SettingsScreen(),
                        /*!(APIs.me.role=='admin')? */
                        TextButton(child: Text("Delete Account",
                          style: BalooStyles.baloomediumTextStyle(color: AppTheme.redErrorColor),), onPressed: ()async{
                          await showDeleteAccountDialog(context,Get.find<DashboardController>().user?.userId??0);

                        })/*:SizedBox()*/
                      ],
                    ),
                  ),
                ),
              )),
        );
      }
    );
  }

   Future<void> showDeleteAccountDialog(BuildContext context, int userId) async {
     final shouldDelete = await showDialog<bool>(
       context: context,
       builder: (context) => AlertDialog(
         backgroundColor: Colors.white,
         actionsAlignment: MainAxisAlignment.center,
         title:  Text('Delete Account',style:BalooStyles.balooboldTitleTextStyle(color: AppTheme.redErrorColor),),
         content: Column(
           mainAxisSize: MainAxisSize.min,
           crossAxisAlignment: CrossAxisAlignment.center,
           children: [
             Text(
               'Are you sure you want to permanently delete your account?',
               style: BalooStyles.balooregularTextStyle(),

             ),
             vGap(15),

             Text(
               'All your messages, group participation, and data will be deleted and cannot be recovered.'
               ,style: BalooStyles.baloomediumTextStyle(color: AppTheme.redErrorColor),
             ),
           ],
         ),
         actions: [
           TextButton(
             onPressed: () => Navigator.pop(context, false),
             child:  Text('Cancel',style:BalooStyles.baloomediumTextStyle(),),
           ),
           ElevatedButton(
             style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
             onPressed: () => Navigator.pop(context, true),
             child: const Text('Delete'),
           ),
         ],
       ),
     );

     if (shouldDelete == true) {
       controller.hitAPIToDeleteAccount();

     }
   }


   // bottom sheet for picking a profile picture for user
  void _showBottomSheet() {
    showModalBottomSheet(
        context: Get.context!,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20), topRight: Radius.circular(20))),
        builder: (_) {
          return ListView(
            shrinkWrap: true,
            padding:
            EdgeInsets.only(top: mq.height * .03, bottom: mq.height * .05),
            children: [
              //pick profile picture label
              const Text('Pick Profile Picture',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500)),

              //for adding some space
              SizedBox(height: mq.height * .02),

              //buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  //pick from gallery button
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          shape: const CircleBorder(),
                          fixedSize: Size(mq.width * .3, mq.height * .15)),
                      onPressed: () async {
                        final ImagePicker picker = ImagePicker();

                        // Pick an image
                        final XFile? image = await picker.pickImage(
                            source: ImageSource.gallery, imageQuality: 80);
                        if (image != null) {
                          // log('Image Path: ${image.path}');

                          controller.image = image.path;
                            controller.update();

                          // await APIs.updateProfilePicture(File(controller.image!)).then((v)=>Get.back());
                          // for hiding bottom sheet
                          Get.back();
                        }
                      },
                      child: Image.asset('assets/images/add_image.png')),

                  //take picture from camera button
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          shape: const CircleBorder(),
                          fixedSize: Size(mq.width * .3, mq.height * .15)),
                      onPressed: () async {
                        final ImagePicker picker = ImagePicker();

                        // Pick an image
                        final XFile? image = await picker.pickImage(
                            source: ImageSource.camera, imageQuality: 80);
                        if (image != null) {
                          // log('Image Path: ${image.path}');

                          controller.image = image.path;
                          controller.update();

                          // await APIs.updateProfilePicture(File(controller.image!)).then((v)=>Get.back());
                          // for hiding bottom sheet
                          Get.back();
                        }
                      },
                      child: Image.asset('assets/images/camera.png')),
                ],
              )
            ],
          );
        });
  }

}
