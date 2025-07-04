import 'dart:io';
import 'package:AccuChat/Screens/chat_module/presentation/controllers/profile_controller.dart';
import 'package:AccuChat/Screens/chat_module/presentation/views/profile_zoom.dart';
import 'package:AccuChat/utils/backappbar.dart';
import 'package:AccuChat/utils/common_textfield.dart';
import 'package:AccuChat/utils/custom_container.dart';
import 'package:AccuChat/utils/gradient_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../Constants/assets.dart';
import '../../../../Constants/themes.dart';
import '../../../../utils/helper_widget.dart';
import '../../../../utils/networl_shimmer_image.dart';
import '../../../../utils/text_style.dart';

class UserProfileScreen extends GetView<ProfileController> {
  final String? userName;
  const UserProfileScreen({super.key, this.userName});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        // appBar: backAppBar(title: userName ?? ''),
        body: GetBuilder<ProfileController>(builder: (context) {
          return Column(
            children: [
              vGap(30),
              getProfileUI(),
              vGap(20),
              Column(
                children: [
                  CustomTextField(
                    hintText: "Username".tr,
                    controller:TextEditingController(text: "Muskan Gupta"),
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
                  vGap(20),

                  CustomTextField(
                    hintText: "Emp Code".tr,
                    controller:TextEditingController(text: "9999"),
                    // textInputType: TextInputType.,

                    focusNode: FocusNode(),
                    onFieldSubmitted: (String? value) {
                      // FocusScope.of(Get.context!)
                      //     .requestFocus(controller.passwordFocusNode);
                    },
                    labletext: "Emp Code",

                    validator: (value) {
                      // return value?.isEmptyField(messageTitle: "Username");
                    },
                  ),

                  vGap(20),

                  CustomTextField(
                    hintText: "Email".tr,
                    controller:TextEditingController(text: "muskan@accutech.com"),
                    // textInputType: TextInputType.,

                    focusNode: FocusNode(),
                    onFieldSubmitted: (String? value) {
                      // FocusScope.of(Get.context!)
                      //     .requestFocus(controller.passwordFocusNode);
                    },
                    labletext: "Email",

                    validator: (value) {
                      // return value?.isEmptyField(messageTitle: "Username");
                    },
                  ),
                ],
              ),


              Spacer(),
              GradientButton(name: "Submit", onTap: () {})
                  .marginOnly(bottom: 50, left: 20, right: 20)
            ],
          );
        }),
      ),
    );
  }

  Widget getProfileUI() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          SizedBox(
            width: Get.width * .5,
            height: 180,
            child: Stack(
              alignment: Alignment.center,
              children: <Widget>[
                Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: Colors.grey.shade400,
                        blurRadius: 8,
                        offset: const Offset(4, 4),
                      ),
                    ],
                  ),
                  child: controller.profileImg != "" &&
                          !controller.profileImg.startsWith("http")
                      ? Hero(
                          tag: "profile",
                          child: InkWell(
                            onTap: () => Get.to(() =>
                                ProfileZoom(imagePath: controller.profileImg)),
                            child: Container(
                              height: 180,
                              width: 180,
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  image: DecorationImage(
                                      image: FileImage(
                                        File(controller.profileImg),
                                      ),
                                      fit: BoxFit.cover),
                                  border: Border.all(color: Colors.white)),
                            ),
                          ),
                        )
                      : controller.profileImg.startsWith("http")
                          ? Hero(
                              tag: "profile",
                              child: InkWell(
                                onTap: () {
                                  Get.to(() => ProfileZoom(
                                      imagePath: controller.profileImg));
                                },
                                child: CustomCacheNetworkImage(
                                  controller.profileImg,
                                  height: 170,
                                  width: 170,
                                  radiusAll: 100,
                                  defaultImage: userIcon,
                                  // boxFit: BoxFit.cover,
                                ),
                              ),
                            )
                          : Container(
                              height: 120,
                              width: 120,
                              padding: const EdgeInsets.all(30),
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                  border: Border.all(color: Colors.white)),
                              child: Image.asset(
                                userIcon,
                                height: 50,
                                width: 50,
                              ),
                            ),
                ),
                Positioned(
                  bottom: 0,
                  right: 6,
                  child: CustomContainer(
                    radius: 36,
                    childWidget: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(24.0)),
                        onTap: () {
                          _showBottomSheet();
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(2.0),
                          child: Icon(
                            Icons.camera_alt,
                            color: AppTheme.appColor,
                            size: 18,
                          ),
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  void _showBottomSheet() {
    showModalBottomSheet(
        context: Get.context!,
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20), topRight: Radius.circular(20))),
        builder: (_) {
          return ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.only(top: 20, bottom: 20),
            children: [
              vGap(10),
              //pick profile picture label
              Text('Select Your Profile Picture',
                  textAlign: TextAlign.center,
                  style: BalooStyles.balooboldTitleTextStyle()),
              //for adding some space
              vGap(30),
              //buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  //pick from gallery button
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CustomContainer(
                        radius: 36,
                        color: AppTheme.appColor.withOpacity(.2),
                        childWidget: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius:
                                const BorderRadius.all(Radius.circular(24.0)),
                            onTap: () async {
                              final ImagePicker picker = ImagePicker();

                              // Pick an image
                              final XFile? image = await picker.pickImage(
                                  source: ImageSource.camera,
                                  imageQuality: 100);
                              if (image != null) {
                                // log('Image Path: ${image.path}');
                                await _cropImage(image.path);
                                controller.profileImg = image.path;

                                controller.update();

                                // for hiding bottom sheet
                                Get.back();
                              }
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Icon(
                                Icons.camera_alt,
                                color: AppTheme.appColor,
                                size: 22,
                              ),
                            ),
                          ),
                        ),
                      ),
                      vGap(10),
                      Text('Camera',
                          textAlign: TextAlign.center,
                          style: BalooStyles.baloonormalTextStyle()),
                    ],
                  ),

                  //take picture from camera button
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CustomContainer(
                        color: AppTheme.appColor.withOpacity(.2),
                        radius: 36,
                        childWidget: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius:
                                const BorderRadius.all(Radius.circular(24.0)),
                            onTap: () async {
                              final ImagePicker picker = ImagePicker();

                              // Pick an image
                              final XFile? image = await picker.pickImage(
                                  source: ImageSource.gallery,
                                  imageQuality: 100);
                              if (image != null) {
                                await _cropImage(image.path);
                                // log('Image Path: ${image.path}');
                                controller.profileImg = image.path;
                                controller.update();
                                // APIs.updateProfilePicture(File(_image!));
                                // for hiding bottom sheet
                                Get.back();
                              }
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Icon(
                                Icons.image,
                                color: AppTheme.appColor,
                                size: 22,
                              ),
                            ),
                          ),
                        ),
                      ),
                      vGap(10),
                      Text('Gallery',
                          textAlign: TextAlign.center,
                          style: BalooStyles.baloonormalTextStyle()),
                    ],
                  ),
                ],
              )
            ],
          );
        });
  }

  Future _cropImage(String pickedFile) async {
    final croppedFile = await ImageCropper().cropImage(
      sourcePath: pickedFile,
      compressFormat: ImageCompressFormat.jpg,
      compressQuality: 100,
      maxHeight: 250,
      maxWidth: 250,
      uiSettings: [
        AndroidUiSettings(
            hideBottomControls: true,
            showCropGrid: true,
            toolbarTitle: 'Cropper',
            toolbarColor: AppTheme.appColor,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.square,
            lockAspectRatio: true),
        IOSUiSettings(
          rectHeight: 100,
          rectWidth: 100,
          rectX: 100,
          rectY: 100,
          resetAspectRatioEnabled: false,
          title: 'Cropper',
          aspectRatioLockEnabled: true,
          rotateClockwiseButtonHidden: true,
          rotateButtonsHidden: true,
          resetButtonHidden: true,
        ),
      ],
    );
    if (croppedFile != null) {
      controller.profileImg = croppedFile.path ?? '';
      controller.update();
      // controller.hitApiToUpdateProfileLogo();
    }
  }
}
