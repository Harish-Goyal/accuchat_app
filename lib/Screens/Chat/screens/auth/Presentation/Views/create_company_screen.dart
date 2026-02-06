import 'dart:io';
import 'package:AccuChat/Constants/colors.dart';
import 'package:AccuChat/Extension/text_field_extenstion.dart';
import 'package:AccuChat/Screens/Chat/screens/auth/Presentation/Controllers/create_company_controller.dart';
import 'package:AccuChat/utils/helper_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../../../Constants/themes.dart';
import '../../../../../../utils/common_textfield.dart';
import '../../../../../../utils/custom_container.dart';
import '../../../../../../utils/text_style.dart';
import 'package:flutter/foundation.dart';
/*class CreateCompanyScreen extends GetView<CreateCompanyController> {

   CreateCompanyScreen({super.key});




   @override
   Widget build(BuildContext context) {

     return SafeArea(
       child: GetBuilder<CreateCompanyController>(
           builder: (controller) {
             return Scaffold(
               // appBar: AppBar(title: const Text("Create Company")),
               body: SingleChildScrollView(
                 padding: const EdgeInsets.all(16.0),
                 child: Form(
                   key: controller.formKey,
                   child: Column(

                     children: [
                       vGap(30),
                       Text("Create Company",style: BalooStyles.balooboldTitleTextStyle(),),
                       vGap(30),
                       Stack(
                         children: [
                           //profile picture
                           controller.companyLogoUrl == null || controller.companyLogoUrl == ''||controller.companyLogoUrl!.isEmpty
                               ?SizedBox():

                           //local image
                           ClipRRect(
                               borderRadius:
                               BorderRadius.circular(mq.height * .1),
                               child: Image.file(File(controller.companyLogoUrl!),
                                   width: mq.height * .2,
                                   height: mq.height * .2,
                                   fit: BoxFit.cover)),

                         ],
                       ),
                       CustomTextField(
                         hintText: "Company Name",
                         labletext: "Company Name",
                         controller: controller.nameController,
                         focusNode: controller.nameFocus,
                         validator: (value) =>
                             value?.isEmptyField(messageTitle: "Company Name"),
                         onFieldSubmitted: (_) =>
                             FocusScope.of(context).requestFocus(controller.emailFocus),
                       ),
                       vGap(18),
                       CustomTextField(
                         hintText: "Email (optional)",
                         labletext: "Email",
                         controller: controller.emailController,
                         focusNode: controller.emailFocus,
                         onFieldSubmitted: (_) =>
                             FocusScope.of(context).requestFocus(controller.phoneFocus),
                       ),
                       vGap(18),
                       CustomTextField(
                         hintText: "Phone (optional)",
                         labletext: "Phone",
                         controller: controller.phoneController,
                         focusNode: controller.phoneFocus,
                         onFieldSubmitted: (_) =>
                             FocusScope.of(context).requestFocus(controller.addressFocus),
                       ),
                       vGap(18),
                       CustomTextField(
                         hintText: "Company Address (optional)",
                         labletext: "Address",
                         controller: controller.addressController,
                         focusNode: controller.addressFocus,
                         onFieldSubmitted: (_) =>
                             FocusScope.of(context).requestFocus(controller.websiteFocus),
                       ),
                       vGap(18),
                       CustomTextField(
                         hintText: "Website (optional)",
                         labletext: "Website",
                         controller: controller.websiteController,
                         focusNode: controller.websiteFocus,
                       ),
                       vGap(30),

                       ElevatedButton.icon(
                         icon: const Icon(Icons.cloud_upload_outlined),
                         label: const Text("Upload Logo (optional)"),
                         onPressed: () {
                           _showBottomSheet();
                         },
                       ),
                       vGap(18),
                       ElevatedButton(
                         onPressed: () {
                           controller.createCompany();
                         },
                         child: const Text("Create Company"),
                       )
                     ],
                   ),
                 ),
               ),
             );
           }
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
                                   // companyLogoUrl=  await _cropImage(image.path);

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
             ),
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
       controller.companyLogoUrl = croppedFile.path ?? '';
      controller.update();
       // controller.hitApiToUpdateProfileLogo();
     }
   }

}*/

class CreateCompanyScreen extends GetView<CreateCompanyController> {
  const CreateCompanyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: GetBuilder<CreateCompanyController>(
        builder: (controller) {
          return Scaffold(
            backgroundColor: const Color(0xFFF6F7F9),
            appBar: AppBar(
              scrolledUnderElevation: 0,
              surfaceTintColor: Colors.white,
              title: Text(
                "Create Company",
                style: BalooStyles.balooboldTitleTextStyle(),
              ),
              centerTitle: true,
              elevation: 0,
            ),
            /*body: LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 600;
                return Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: isWide ? 600 : double.infinity,
                    ),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16.0),
                      child: Form(
                        key: controller.formKey,
                        child: Column(
                          children: [
                            vGap(30),
                            Text(
                              "Create Company",
                              style: BalooStyles.balooboldTitleTextStyle(),
                            ),
                            vGap(30),

                            // Logo preview
                            if (controller.companyLogoUrl?.isNotEmpty == true)
                              ClipRRect(
                                 borderRadius: BorderRadius.circular(100),
                                child: Image.file(
                                  File(controller.companyLogoUrl!),
                                  width: 200,
                                  height: 200,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            vGap(20),

                            // Form fields
                            CustomTextField(
                              hintText: "Company Name",
                              labletext: "Company Name",
                              controller: controller.nameController,
                              focusNode: controller.nameFocus,
                              validator: (value) =>
                                  value?.isEmptyField(messageTitle: "Company Name"),
                              onFieldSubmitted: (_) => FocusScope.of(context)
                                  .requestFocus(controller.emailFocus),
                            ),
                            vGap(18),
                            CustomTextField(
                              hintText: "Email (optional)",
                              labletext: "Email",
                              controller: controller.emailController,
                              focusNode: controller.emailFocus,
                              onFieldSubmitted: (_) => FocusScope.of(context)
                                  .requestFocus(controller.phoneFocus),
                            ),
                            vGap(18),
                            CustomTextField(
                              hintText: "Phone (optional)",
                              labletext: "Phone",
                              controller: controller.phoneController,
                              focusNode: controller.phoneFocus,
                              inputFormatters: <TextInputFormatter>[
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(10),
                              ]
                                 ,
                              onFieldSubmitted: (_) => FocusScope.of(context)
                                  .requestFocus(controller.addressFocus),
                              validator: (value){
                               return (value?.isEmpty??true)?"":value?.validateMobile(controller.phoneController.text);
                              },
                            ),
                            vGap(18),
                            CustomTextField(
                              hintText: "Company Address (optional)",
                              labletext: "Address",
                              controller: controller.addressController,
                              focusNode: controller.addressFocus,
                              onFieldSubmitted: (_) => FocusScope.of(context)
                                  .requestFocus(controller.websiteFocus),
                            ),
                            vGap(18),
                            CustomTextField(
                              hintText: "Website (optional)",
                              labletext: "Website",
                              controller: controller.websiteController,
                              focusNode: controller.websiteFocus,
                            ),
                            vGap(30),

                            // Upload logo button
                            ElevatedButton.icon(
                              icon: const Icon(Icons.cloud_upload_outlined),
                              label: const Text("Upload Logo (optional)"),
                              onPressed: _showBottomSheet,
                            ),
                            vGap(18),

                            // Create button
                            ElevatedButton(
                              onPressed: controller.createCompanyApi,
                              child: const Text("Create Company"),
                            ),

                            vGap(50),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),*/


            body:  LayoutBuilder(
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
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                 Text(
                                  "Create Your Company",
                                 style:  BalooStyles.baloomediumTextStyle(color: appColorYellow,size: 20))
                                ,
                                vGap(12),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(100),
                                  child: kIsWeb
                                      ? (controller.companyLogoBytes == null
                                      ? const SizedBox.shrink()
                                      : Image.memory(
                                    controller.companyLogoBytes!,
                                    width: 120,
                                    height: 120,
                                    fit: BoxFit.cover,
                                  ))
                                      : (controller.companyLogoUrl == null
                                      ? const SizedBox.shrink()
                                      : Image.file(
                                    File(controller.companyLogoUrl!),
                                    width: 120,
                                    height: 120,
                                    fit: BoxFit.cover,
                                  )),
                                ),
                                vGap(20),

                                // Form fields
                                CustomTextField(
                                  hintText: "Company Name",
                                  labletext: "Company Name",
                                  controller: controller.nameController,
                                  focusNode: controller.nameFocus,
                                  validator: (value) =>
                                      value?.isEmptyField(messageTitle: "Company Name"),
                                  onFieldSubmitted: (_) => FocusScope.of(context)
                                      .requestFocus(controller.emailFocus),
                                ),
                                vGap(18),
                                CustomTextField(
                                  hintText: "Email (optional)",
                                  labletext: "Email",
                                  controller: controller.emailController,
                                  focusNode: controller.emailFocus,
                                  onFieldSubmitted: (_) => FocusScope.of(context)
                                      .requestFocus(controller.phoneFocus),
                                ),
                                vGap(18),
                                CustomTextField(
                                  hintText: "Phone (optional)",
                                  labletext: "Phone",
                                  controller: controller.phoneController,
                                  focusNode: controller.phoneFocus,
                                  inputFormatters: <TextInputFormatter>[
                                    FilteringTextInputFormatter.digitsOnly,
                                    LengthLimitingTextInputFormatter(10),
                                  ]
                                  ,
                                  onFieldSubmitted: (_) => FocusScope.of(context)
                                      .requestFocus(controller.addressFocus),
                                  validator: (value){
                                    return (value?.isEmpty??true)?"":value?.validateMobile(controller.phoneController.text);
                                  },
                                ),
                                vGap(18),
                                CustomTextField(
                                  hintText: "Company Address (optional)",
                                  labletext: "Address",
                                  controller: controller.addressController,
                                  focusNode: controller.addressFocus,
                                  onFieldSubmitted: (_) => FocusScope.of(context)
                                      .requestFocus(controller.websiteFocus),
                                ),
                                vGap(18),
                                CustomTextField(
                                  hintText: "Website (optional)",
                                  labletext: "Website",
                                  controller: controller.websiteController,
                                  focusNode: controller.websiteFocus,
                                ),
                                vGap(30),

                                // Upload logo button
                                ElevatedButton.icon(
                                  icon: const Icon(Icons.cloud_upload_outlined),
                                  label: const Text("Upload Logo (optional)"),
                                  onPressed: _showBottomSheet,
                                ),
                                vGap(18),

                                // Create button
                                ElevatedButton(
                                  onPressed:()=> controller.createCompanyApi(),
                                  child: const Text("Create Company"),
                                ),

                                vGap(50),

                              ],
                            ).paddingSymmetric(horizontal: 8),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Future<void> pickCompanyLogo() async {
    final c = Get.find<CreateCompanyController>();

    final image = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 90,
    );
    if (image == null) return;

    if (kIsWeb) {
      // ✅ Web: bytes only
      c.companyLogoBytes = await image.readAsBytes();
      c.update();
      return;
    }

  }


  void _showBottomSheet() {
    showModalBottomSheet(
      context: Get.context!,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      builder: (_) {
        final controller = Get.find<CreateCompanyController>();
        return SafeArea(
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.only(top: 20, bottom: 20),
            children: [
              vGap(10),
              Text(
                'Select Your Company Logo',
                textAlign: TextAlign.center,
                style: BalooStyles.balooboldTitleTextStyle(),
              ),
              vGap(30),
              /*Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Camera
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CustomContainer(
                        radius: 36,
                        color: AppTheme.appColor.withOpacity(.2),
                        childWidget: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: const BorderRadius.all(Radius.circular(24)),
                            onTap: () async {
                              final image = await ImagePicker().pickImage(
                                source: ImageSource.camera,
                                imageQuality: 100,
                              );
                              if (image != null) {
                                await _cropImage(image.path);
                                controller.update();
                                Get.back();
                              }
                            },
                            child: const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Icon(Icons.camera_alt, size: 22),
                            ),
                          ),
                        ),
                      ),
                      vGap(10),
                      Text('Camera', style: BalooStyles.baloonormalTextStyle()),
                    ],
                  ),

                  // Gallery
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CustomContainer(
                        radius: 36,
                        color: AppTheme.appColor.withOpacity(.2),
                        childWidget: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: const BorderRadius.all(Radius.circular(24)),
                            onTap: () async {
                              final image = await ImagePicker().pickImage(
                                source: ImageSource.gallery,
                                imageQuality: 100,
                              );
                              if (image != null) {
                                await _cropImage(image.path);
                                controller.update();
                                Get.back();
                              }
                            },
                            child: const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Icon(Icons.image, size: 22),
                            ),
                          ),
                        ),
                      ),
                      vGap(10),
                      Text('Gallery', style: BalooStyles.baloonormalTextStyle()),
                    ],
                  ),
                ],
              ),*/
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  if (!kIsWeb) // ✅ camera only on mobile
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CustomContainer(
                          radius: 36,
                          color: AppTheme.appColor.withOpacity(.2),
                          childWidget: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: const BorderRadius.all(Radius.circular(24)),
                              onTap: () async {
                                final image = await ImagePicker().pickImage(
                                  source: ImageSource.camera,
                                  imageQuality: 100,
                                );
                                if (image != null) {
                                  await _cropImage(image.path);
                                  controller.update();
                                  Get.back();
                                }
                              },
                              child: const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Icon(Icons.camera_alt, size: 22),
                              ),
                            ),
                          ),
                        ),
                        vGap(10),
                        Text('Camera', style: BalooStyles.baloonormalTextStyle()),
                      ],
                    ),

                  // ✅ Gallery works on web + mobile
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CustomContainer(
                        radius: 36,
                        color: AppTheme.appColor.withOpacity(.2),
                        childWidget: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: const BorderRadius.all(Radius.circular(24)),
                            onTap:()=>pickCompanyLogo(),
                            child: const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Icon(Icons.image, size: 22),
                            ),
                          ),
                        ),
                      ),
                      vGap(10),
                      Text('Gallery', style: BalooStyles.baloonormalTextStyle()),
                    ],
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
  Future<void> _handlePickedImage(XFile image) async {
    final controller = Get.find<CreateCompanyController>();

    if (kIsWeb) {
      // ✅ No crop on web (avoid web cropper issues)
      controller.companyLogoUrl = image.path; // usually blob:url -> preview with Image.network
      controller.update();
      return;
    }

    // ✅ Mobile: crop
    await _cropImage(image.path);
  }

  Future _cropImage(String pickedFile) async {
    final controller = Get.find<CreateCompanyController>();
    final croppedFile = await ImageCropper().cropImage(
      sourcePath: pickedFile,
      compressFormat: ImageCompressFormat.jpg,
      compressQuality: 100,
      maxHeight: 250,
      maxWidth: 250,
      aspectRatio:CropAspectRatio(ratioX: 1,ratioY: 1),
      uiSettings: [
        AndroidUiSettings(
          hideBottomControls: true,
          showCropGrid: true,
          toolbarTitle: 'Cropper',
          toolbarColor: AppTheme.appColor,
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.square,
          lockAspectRatio: true,
        ),
        IOSUiSettings(
          title: 'Cropper',
          aspectRatioLockEnabled: true,
        ),

        if (kIsWeb)
          if (kIsWeb)
            WebUiSettings(
              context: Get.context!,
              presentStyle: WebPresentStyle.dialog,
              size: CropperSize(
                width: int.parse(((Get.width * .5).toString())),
                height: int.parse(((Get.height * .7).toString())),
              ),
              viewwMode: WebViewMode.mode_3,
              dragMode: WebDragMode.move,
              movable: true,
              scalable: true,
              zoomable: true,
              zoomOnTouch: true,
              zoomOnWheel: true,
              wheelZoomRatio: 0.1,
              cropBoxMovable: true,
              cropBoxResizable: true,
            ),

        if (!kIsWeb && Platform.isAndroid)
            AndroidUiSettings(
              toolbarTitle: 'Crop Image',
              toolbarColor: Colors.blue,
              toolbarWidgetColor: Colors.white,
              initAspectRatio: CropAspectRatioPreset.original,
              lockAspectRatio: false,
            ),
          if (!kIsWeb && Platform.isIOS)
            IOSUiSettings(
              title: 'Crop Image',
            ),

      ],
    );
    if (croppedFile != null) {
      controller.companyLogoUrl = croppedFile.path;
      controller.update();
    }
  }
}

