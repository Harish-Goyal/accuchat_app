import 'dart:io';

import 'package:AccuChat/Components/custom_loader.dart';
import 'package:AccuChat/Constants/assets.dart';
import 'package:AccuChat/Extension/text_field_extenstion.dart';
import 'package:AccuChat/Screens/Chat/models/company_model.dart';
import 'package:AccuChat/Screens/Home/Presentation/View/invite_member.dart';
import 'package:AccuChat/routes/app_routes.dart';
import 'package:AccuChat/utils/custom_flashbar.dart';
import 'package:AccuChat/utils/gradient_button.dart';
import 'package:AccuChat/utils/helper_widget.dart';
import 'package:AccuChat/utils/networl_shimmer_image.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../Constants/colors.dart';
import '../../../../Constants/themes.dart' show AppTheme;
import '../../../../Services/APIs/api_ends.dart';
import '../../../../main.dart';
import '../../../../utils/common_textfield.dart';
import '../../../../utils/custom_container.dart';
import '../../../../utils/custom_dialogue.dart';
import '../../../../utils/text_style.dart';
import '../../../../utils/web_file_picekr.dart';
import '../../../Chat/api/apis.dart';
import '../../../Chat/screens/auth/Presentation/Views/landing_screen.dart';
import '../Controller/update_comapny_controller.dart';

import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb; // for minor web guards

class UpdateCompanyScreen extends GetView<UpdateCompanyController> {
  UpdateCompanyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<UpdateCompanyController>(builder: (controller) {
      return Scaffold(
        backgroundColor: const Color(0xFFF6F7F9),
        appBar: AppBar(
          title: Text(
            "Update Company",
            style: BalooStyles.balooboldTitleTextStyle(),
          ),
          centerTitle: true,
          elevation: 0,
        ),
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 900;
              final fieldWidth = isWide ? 420.0 : double.infinity;
              final cardMargin = EdgeInsets.symmetric(
                horizontal: isWide ? 32 : 16,
                vertical: isWide ? 24 : 12,
              );
              final cardPadding = EdgeInsets.all(isWide ? 28 : 18);
              final avatarSize = isWide ? 140.0 : 120.0;

              return Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1100),
                  child: Card(
                    margin: cardMargin,
                    color: Colors.white,
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: cardPadding,
                      child: SingleChildScrollView(
                        child: Form(
                          key: controller.formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Header
                              Text(
                                "Company Details",
                                style: BalooStyles.balooboldTitleTextStyle(),
                              ),
                              vGap(4),
                              Text(
                                "Update your company profile and contact info.",
                                style: BalooStyles.baloonormalTextStyle(
                                  color: Colors.black54,
                                ),
                              ),
                              vGap(isWide ? 24 : 16),

                              // Responsive layout: Row on wide, Column on narrow
                              isWide
                                  ? Row(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: [
                                  // Left: Logo block
                                  SizedBox(
                                    width: 300,
                                    child: _LogoPickerBlock(
                                      controller: controller,
                                      avatarSize: avatarSize,
                                      onEditTap: _showBottomSheet,
                                    ),
                                  ),
                                  const SizedBox(width: 24),

                                  // Right: Form fields as a two-column Wrap
                                  Expanded(
                                    child: Wrap(
                                      spacing: 18,
                                      runSpacing: 18,
                                      children: [
                                        SizedBox(
                                          width: fieldWidth,
                                          child: CustomTextField(
                                            hintText: "Company Name",
                                            labletext: "Company Name",
                                            controller: controller
                                                .nameController,
                                            focusNode:
                                            controller.nameFocus,
                                            validator: (value) => value
                                                ?.isEmptyField(
                                                messageTitle:
                                                "Company Name"),
                                            onFieldSubmitted: (_) =>
                                                FocusScope.of(context)
                                                    .requestFocus(controller
                                                    .emailFocus),
                                          ),
                                        ),
                                        SizedBox(
                                          width: fieldWidth,
                                          child: CustomTextField(
                                            hintText: "Email (optional)",
                                            labletext: "Email",
                                            controller: controller
                                                .emailController,
                                            focusNode:
                                            controller.emailFocus,
                                            onFieldSubmitted: (_) =>
                                                FocusScope.of(context)
                                                    .requestFocus(controller
                                                    .phoneFocus),
                                          ),
                                        ),
                                        SizedBox(
                                          width: fieldWidth,
                                          child: CustomTextField(
                                            hintText: "Phone (optional)",
                                            labletext: "Phone",
                                            controller: controller
                                                .phoneController,
                                            focusNode:
                                            controller.phoneFocus,
                                            onFieldSubmitted: (_) =>
                                                FocusScope.of(context)
                                                    .requestFocus(controller
                                                    .addressFocus),
                                          ),
                                        ),
                                        SizedBox(
                                          width: fieldWidth,
                                          child: CustomTextField(
                                            hintText:
                                            "Company Address (optional)",
                                            labletext: "Address",
                                            controller: controller
                                                .addressController,
                                            focusNode:
                                            controller.addressFocus,
                                            onFieldSubmitted: (_) =>
                                                FocusScope.of(context)
                                                    .requestFocus(controller
                                                    .websiteFocus),
                                          ),
                                        ),
                                        SizedBox(
                                          width: fieldWidth,
                                          child: CustomTextField(
                                            hintText: "Website (optional)",
                                            labletext: "Website",
                                            controller: controller
                                                .websiteController,
                                            focusNode:
                                            controller.websiteFocus,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              )
                                  : Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.center,
                                children: [
                                  // Top: Logo block
                                  _LogoPickerBlock(
                                    controller: controller,
                                    avatarSize: avatarSize,
                                    onEditTap: _showBottomSheet,
                                  ),
                                  vGap(18),

                                  // Fields stack full width
                                  CustomTextField(
                                    hintText: "Company Name",
                                    labletext: "Company Name",
                                    controller:
                                    controller.nameController,
                                    focusNode: controller.nameFocus,
                                    validator: (value) => value
                                        ?.isEmptyField(
                                        messageTitle:
                                        "Company Name"),
                                    onFieldSubmitted: (_) =>
                                        FocusScope.of(context)
                                            .requestFocus(controller
                                            .emailFocus),
                                  ),
                                  vGap(18),
                                  CustomTextField(
                                    hintText: "Email (optional)",
                                    labletext: "Email",
                                    controller:
                                    controller.emailController,
                                    focusNode: controller.emailFocus,
                                    onFieldSubmitted: (_) =>
                                        FocusScope.of(context)
                                            .requestFocus(controller
                                            .phoneFocus),
                                  ),
                                  vGap(18),
                                  CustomTextField(
                                    hintText: "Phone (optional)",
                                    labletext: "Phone",
                                    controller:
                                    controller.phoneController,
                                    focusNode: controller.phoneFocus,
                                    onFieldSubmitted: (_) =>
                                        FocusScope.of(context)
                                            .requestFocus(controller
                                            .addressFocus),
                                  ),
                                  vGap(18),
                                  CustomTextField(
                                    hintText:
                                    "Company Address (optional)",
                                    labletext: "Address",
                                    controller:
                                    controller.addressController,
                                    focusNode: controller.addressFocus,
                                    onFieldSubmitted: (_) =>
                                        FocusScope.of(context)
                                            .requestFocus(controller
                                            .websiteFocus),
                                  ),
                                  vGap(18),
                                  CustomTextField(
                                    hintText: "Website (optional)",
                                    labletext: "Website",
                                    controller:
                                    controller.websiteController,
                                    focusNode: controller.websiteFocus,
                                  ),
                                ],
                              ),

                              vGap(isWide ? 28 : 22),

                              // Actions row
                              isWide?  Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Expanded(
                                    child: OutlinedButton(
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: AppTheme.redErrorColor,
                                        side: BorderSide(
                                            color: AppTheme.redErrorColor),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        padding: EdgeInsets.symmetric(vertical: 8)
                                      ),
                                      onPressed: () async {
                                        await controller.deleteCompany(context);
                                      },
                                      child: Text(
                                        "Delete Company",
                                        style: BalooStyles.baloomediumTextStyle(
                                          color: AppTheme.redErrorColor,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 30),
                                  Expanded(
                                    child: GradientButton(
                                      onTap: () async {
                                        controller.updateCompanyApi(
                                          companyId: controller
                                              .companyResponse?.companyId,
                                        );
                                      },
                                      name: "Update Company",
                                    ),
                                  ),
                                ],
                              ):

                              Column(
                                children: [
                                  GradientButton(
                                    onTap: () async {
                                      controller.updateCompanyApi(
                                        companyId: controller
                                            .companyResponse?.companyId,
                                      );
                                    },
                                    name: "Update Company",
                                  ),vGap(25),
                                  TextButton(
                                    onPressed: ()async{
                                      await controller.deleteCompany(context);
                                    }, child:Text(
                                    "Delete Company",
                                    style: BalooStyles.baloomediumTextStyle(
                                      color: AppTheme.redErrorColor,
                                    ),
                                  ),
                                  ),
                                ],
                              ),

                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      );
    });
  }

  void _showBottomSheet() {
    showModalBottomSheet(
        context: Get.context!,
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20), topRight: Radius.circular(20))),
        builder: (_) {
          return SafeArea(
            child: ListView(
              shrinkWrap: true,
              padding: const EdgeInsets.only(top: 20, bottom: 20),
              children: [
                vGap(10),
                //pick profile picture label
                Text('Select Your Company Logo',
                    textAlign: TextAlign.center,
                    style: BalooStyles.balooboldTitleTextStyle()),
                //for adding some space
                vGap(30),
                //buttons
              kIsWeb?Column(
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

                          pickImageSingleWeb();


                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Icon(
                            Icons.file_copy_outlined,
                            color: AppTheme.appColor,
                            size: 22,
                          ),
                        ),
                      ),
                    ),
                  ),
                  vGap(10),
                  Text('File',
                      textAlign: TextAlign.center,
                      style: BalooStyles.baloonormalTextStyle()),
                ],
              ):  Row(
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
                                    await _cropImage(image.path);
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
            ),
          );
        });
  }

  Future<void> pickImageSingleWeb() async {
    if (!UniversalPicker.isWeb) {
      controller.lastMessage = 'Web-only picker. Mobile flow untouched.';
      controller.update();
      return;
    }
    final img = await UniversalPicker.pickImageSingleWeb();
    if (img != null) {
      controller.filecompanyWeb = img;
      print("controller.filecompanyLogoUrl");
      print(controller.filecompanyWeb);
      Get.back();

    } else {
      controller.filecompanyWeb = null;
      controller.lastMessage = 'No image selected';
    }
    controller.update();
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

      // customLoader.show();


      controller.filecompanyLogoUrl = croppedFile.path ?? '';
      controller.update();

      // await APIs.updateCompanyLogo(File(controller.filecompanyLogoUrl??''));
      // customLoader.hide();
      // Get.back();

    }
  }
}

/// Small, reusable block for the logo + edit button.
/// Keeps your original logic but makes it consistent & web-safe visually.
class _LogoPickerBlock extends StatelessWidget {
  const _LogoPickerBlock({
    required this.controller,
    required this.avatarSize,
    required this.onEditTap,
  });

  final UpdateCompanyController controller;
  final double avatarSize;
  final VoidCallback onEditTap;

  @override
  Widget build(BuildContext context) {
    final border = Border.all(color: appColorGreen, width: 1);
    final hasSelLogo =
    (controller.companyLogoUrl != null && (controller.companyLogoUrl ?? '').isNotEmpty);
    final hasLocalLogo = (controller.filecompanyLogoUrl?.isNotEmpty ?? false);
    final hasWebLocalLogo = (controller.filecompanyWeb!=null);
    final fallbackUrl = controller.companyLogoUrl ?? '';

    Widget image;
    if (hasLocalLogo && !kIsWeb) {
      // NOTE: For web you may later switch to Image.memory with bytes.
      image = ClipRRect(
        borderRadius: BorderRadius.circular(avatarSize),
        child: Image.file(
          File(controller.filecompanyLogoUrl ?? ''),
          width: avatarSize,
          height: avatarSize,
          fit: BoxFit.cover,
        ),
      );
    } else if (hasSelLogo) {
      image = Container(
        decoration: BoxDecoration(shape: BoxShape.circle, border: border),
        child: CustomCacheNetworkImage(
          "${ApiEnd.baseUrlMedia}${controller.companyLogoUrl ?? ''}",
          height: avatarSize,
          width: avatarSize,
          boxFit: BoxFit.cover,
          radiusAll: avatarSize,
        ),
      );
    } else {
      image = Container(
        decoration: BoxDecoration(shape: BoxShape.circle, border: border),
        child: CustomCacheNetworkImage(
          fallbackUrl,
          height: avatarSize,
          width: avatarSize,
          boxFit: BoxFit.cover,
          radiusAll: avatarSize,
        ),
      );
    }
    if(hasWebLocalLogo){
      image = Container(
        decoration: BoxDecoration(shape: BoxShape.circle, border: border),
        child:  ClipRRect(
          borderRadius: BorderRadius.circular(avatarSize),
          child: Image.memory(
            controller.filecompanyWeb!.bytes,
            height: avatarSize,
            width: avatarSize,
            fit: BoxFit.cover,
          ),
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            image,
            Positioned(
              bottom: 0,
              right: 0,
              child: MaterialButton(
                elevation: 1,
                onPressed: onEditTap,
                shape: const CircleBorder(),
                color: Colors.white,
                child: const Icon(Icons.edit, color: Colors.blue),
              ),
            ),
          ],
        ),
        vGap(10),
        Text(
          "Select Your Company Logo",
          style: BalooStyles.baloomediumTextStyle(),
        ),

      ],
    );
  }
}


