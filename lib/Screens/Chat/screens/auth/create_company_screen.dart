import 'dart:io';

import 'package:AccuChat/Components/custom_loader.dart';
import 'package:AccuChat/Extension/text_field_extenstion.dart';
import 'package:AccuChat/Screens/Home/Presentation/View/invite_member.dart';
import 'package:AccuChat/Services/APIs/local_keys.dart';
import 'package:AccuChat/utils/custom_flashbar.dart';
import 'package:AccuChat/utils/helper_widget.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../Constants/colors.dart';
import '../../../../Constants/colors.dart' as AppTheme;
import '../../../../main.dart';
import '../../../../utils/common_textfield.dart';
import '../../../../utils/custom_container.dart';
import '../../../../utils/text_style.dart';
import '../../api/apis.dart';
import '../../models/company_model.dart';

class CreateCompanyScreen extends StatefulWidget {

   CreateCompanyScreen({super.key,required this.isHome});

   bool isHome = false;

  @override
  State<CreateCompanyScreen> createState() => _CreateCompanyScreenState();
}

class _CreateCompanyScreenState extends State<CreateCompanyScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController websiteController = TextEditingController();

  final FocusNode nameFocus = FocusNode();
  final FocusNode emailFocus = FocusNode();
  final FocusNode phoneFocus = FocusNode();
  final FocusNode addressFocus = FocusNode();
  final FocusNode websiteFocus = FocusNode();

  // Placeholder for file picker result
  String? companyLogoUrl;

  bool isLoading=false;



  @override
  Widget build(BuildContext context) {
    print("companyLogoUrl.toString()");
    print(companyLogoUrl.toString());
    return SafeArea(
      child: Scaffold(
        // appBar: AppBar(title: const Text("Create Company")),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(

              children: [
                vGap(30),
                Text("Create Company",style: BalooStyles.balooboldTitleTextStyle(),),
                vGap(30),
                Stack(
                  children: [
                    //profile picture
                    companyLogoUrl == null || companyLogoUrl == ''||companyLogoUrl!.isEmpty
                        ?SizedBox():
      
                    //local image
                    ClipRRect(
                        borderRadius:
                        BorderRadius.circular(mq.height * .1),
                        child: Image.file(File(companyLogoUrl!),
                            width: mq.height * .2,
                            height: mq.height * .2,
                            fit: BoxFit.cover)),
      
                  ],
                ),
                CustomTextField(
                  hintText: "Company Name",
                  labletext: "Company Name",
                  controller: nameController,
                  focusNode: nameFocus,
                  validator: (value) =>
                      value?.isEmptyField(messageTitle: "Company Name"),
                  onFieldSubmitted: (_) =>
                      FocusScope.of(context).requestFocus(emailFocus),
                ),
                vGap(18),
                CustomTextField(
                  hintText: "Email (optional)",
                  labletext: "Email",
                  controller: emailController,
                  focusNode: emailFocus,
                  onFieldSubmitted: (_) =>
                      FocusScope.of(context).requestFocus(phoneFocus),
                ),
                vGap(18),
                CustomTextField(
                  hintText: "Phone (optional)",
                  labletext: "Phone",
                  controller: phoneController,
                  focusNode: phoneFocus,
                  onFieldSubmitted: (_) =>
                      FocusScope.of(context).requestFocus(addressFocus),
                ),
                vGap(18),
                CustomTextField(
                  hintText: "Company Address (optional)",
                  labletext: "Address",
                  controller: addressController,
                  focusNode: addressFocus,
                  onFieldSubmitted: (_) =>
                      FocusScope.of(context).requestFocus(websiteFocus),
                ),
                vGap(18),
                CustomTextField(
                  hintText: "Website (optional)",
                  labletext: "Website",
                  controller: websiteController,
                  focusNode: websiteFocus,
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
                    if (_formKey.currentState!.validate()) {
                      SystemChannels.textInput.invokeMethod('TextInput.hide');
                      customLoader.show();
                      APIs.createCompany(
                        email:emailController.text.isNotEmpty? emailController.text.trim():"",
                        phone:phoneController.text.isNotEmpty?
                        "+91${phoneController.text.trim()}":
                          APIs.me.phone,
                        name: nameController.text.trim(),
                        address: addressController.text.trim(),
                        logoUrl:companyLogoUrl!=''? File(companyLogoUrl??''):null
                      ).then((v){
                        storage.write(isLoggedIn, true);
                        customLoader.hide();
                        toast( "Company created successfully!");
                      }).onError((e,v){
                        customLoader.hide();
                        errorDialog( "Something went wrong!");
                      });
      
                    }
                  },
                  child: const Text("Create Company"),
                )
              ],
            ),
          ),
        ),
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

                                 setState(() {

                                 });
            
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
            
                                  setState(() {
            
                                  });
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
      companyLogoUrl = croppedFile.path ?? '';
      setState(() {

      });
      // controller.hitApiToUpdateProfileLogo();
    }
  }
}

