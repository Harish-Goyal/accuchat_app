import 'dart:io';

import 'package:AccuChat/Components/custom_loader.dart';
import 'package:AccuChat/Constants/assets.dart';
import 'package:AccuChat/Extension/text_field_extenstion.dart';
import 'package:AccuChat/Screens/Chat/models/company_model.dart';
import 'package:AccuChat/Screens/Home/Presentation/View/invite_member.dart';
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
import '../../../../main.dart';
import '../../../../utils/common_textfield.dart';
import '../../../../utils/custom_container.dart';
import '../../../../utils/custom_dialogue.dart';
import '../../../../utils/text_style.dart';
import '../../../Chat/api/apis.dart';
import '../../../Chat/screens/auth/landing_screen.dart';

class UpdateCompanyScreen extends StatefulWidget {
  UpdateCompanyScreen({super.key,this.company});

  CompanyModel? company;

  @override
  State<UpdateCompanyScreen> createState() => _UpdateCompanyScreenState();
}

class _UpdateCompanyScreenState extends State<UpdateCompanyScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController phoneController;
  late TextEditingController addressController;
  late TextEditingController websiteController;

  final FocusNode nameFocus = FocusNode();
  final FocusNode emailFocus = FocusNode();
  final FocusNode phoneFocus = FocusNode();
  final FocusNode addressFocus = FocusNode();
  final FocusNode websiteFocus = FocusNode();

  // Placeholder for file picker result
  String? companyLogoUrl;
  String? filecompanyLogoUrl;

  bool isLoading=false;

  @override
  void initState() {
    initData();
    super.initState();
  }


  initData(){
    companyLogoUrl = widget.company?.logoUrl??'';
    nameController = TextEditingController(text: widget.company?.name??'');
    emailController = TextEditingController(text: widget.company?.email??'');
    phoneController = TextEditingController(text: widget.company?.phone??'');
    addressController = TextEditingController(text: widget.company?.address??'');
    websiteController = TextEditingController(text: widget.company?.websiteURL??'');
  }

  Future<bool> doesCollectionExist(String collectionPath) async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection(collectionPath)
        .limit(1) // We limit the result to one document
        .get();

    return querySnapshot.docs.isNotEmpty;
  }

  Future<void> deleteCompany(BuildContext context, CompanyModel company) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Company"),
        backgroundColor: Colors.white,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            vGap(20),
            Text(
              "⚠️ Are you sure you want to delete this company?",
              style: BalooStyles.balooboldTextStyle(color: AppTheme.redErrorColor, size: 16),
            ),
            vGap(20),
            Text(
              "All related members, invitations, and references will be permanently removed. You cannot retrieve it again in future, make sure before delete!",
              style: BalooStyles.baloomediumTextStyle(color: AppTheme.redErrorColor),
            ),
            vGap(20),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text("Delete")),
        ],
      ),
    );

    if (confirm != true) return;

    final companyId = company.id;
    final firestore = FirebaseFirestore.instance;
    final batch = firestore.batch();

    try {
      customLoader.show();
      // 1. Delete all invitations related to this company
      final invitesSnap = await firestore.collection('invitations').where('companyId', isEqualTo: companyId).get();
      for (var doc in invitesSnap.docs) {
        batch.delete(doc.reference);
      }

      // 2. Delete all member subcollection docs under the company
      final membersSnap = await firestore.collection('companies').doc(companyId).collection('members').get();
      for (var doc in membersSnap.docs) {
        batch.delete(doc.reference);
      }

      // 3. Remove company from all users (from `company` list and `selectedCompany` if matched)
      final userSnap = await firestore.collection('users').get();

      for (var userDoc in userSnap.docs) {
        final data = userDoc.data();

        // Get the current list of companies the user is part of
        final List<dynamic> joinedCompanies = List.from(data['company'] ?? []);

        // Remove company from the joined list if it's present
        joinedCompanies.removeWhere((comp) => comp is Map && comp['id'] == companyId);

        final Map<String, dynamic> updateData = {
          'company': joinedCompanies,
        };

        // Check if the company to be deleted is the selected company
        final selectedCompany = data['selectedCompany'];
        final isSelectedCompanyDeleted = selectedCompany != null &&
            selectedCompany is Map &&
            selectedCompany['id'] == companyId;

        if (isSelectedCompanyDeleted) {
          // If the selected company is being deleted, remove it from selectedCompany
          updateData['selectedCompany'] = FieldValue.delete();
        }

        // Apply the update to the user's document
        batch.update(userDoc.reference, updateData);
      }

      // 4. Delete associated group chats, broadcasts, and groups related to this company
      final chatsSnap = await firestore.collection('chats').where('companyId', isEqualTo: companyId).get();
      for (var chatDoc in chatsSnap.docs) {
        batch.delete(chatDoc.reference);
      }

      final broadcastSnap = await firestore.collection('broadcasts').where('companyId', isEqualTo: companyId).get();
      for (var broadcastDoc in broadcastSnap.docs) {
        batch.delete(broadcastDoc.reference);
      }

      final groupSnap = await firestore.collection('groups').where('companyId', isEqualTo: companyId).get();
      for (var groupDoc in groupSnap.docs) {
        batch.delete(groupDoc.reference);
      }

      // 5. Delete the actual company document
      batch.delete(firestore.collection('companies').doc(companyId));

      await batch.commit();

      toast("✅ Company and related data deleted successfully.");
      customLoader.hide();
      Get.offAll(() => LandingPage());
      setState(() {});
    } catch (e) {
      customLoader.hide();
      print("❌ Error deleting company: $e");
      errorDialog("Something went wrong while deleting the company.");
    }
  }

/*  Future<void> deleteCompany(BuildContext context, CompanyModel company) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Company"),
        backgroundColor: Colors.white,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            vGap(20),
            Text(
              "⚠️ Are you sure you want to delete this company?",style: BalooStyles.balooboldTextStyle(color: AppTheme.redErrorColor,size: 16),),
            vGap(20),
            Text(
              "All related members, invitations, and references will be permanently removed. You cannot retrieve it again in future, make sure before delete!",style: BalooStyles.baloomediumTextStyle(color: AppTheme.redErrorColor),),
            vGap(20),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text("Delete")),
        ],
      ),
    );

    if (confirm != true) return;

    final companyId = company.id;
    final firestore = FirebaseFirestore.instance;
    final batch = firestore.batch();

    try {
      // 1. Delete all invitations related to this company
      final invitesSnap = await firestore
          .collection('invitations')
          .where('companyId', isEqualTo: companyId)
          .get();

      for (var doc in invitesSnap.docs) {
        batch.delete(doc.reference);
      }

      // 2. Delete all member subcollection docs under the company
      final membersSnap = await firestore
          .collection('companies')
          .doc(companyId)
          .collection('members')
          .get();

      for (var doc in membersSnap.docs) {
        batch.delete(doc.reference);
      }

      // 3. Remove company from all users (from `companies` list and `selectedCompany` if matched)
      final userSnap = await firestore.collection('users').get();

      for (var userDoc in userSnap.docs) {
        final data = userDoc.data();

        // Step 1: Remove from user's joined company list
        final List<dynamic> joinedCompanies = List.from(data['company'] ?? []);
        joinedCompanies.removeWhere((comp) => comp is Map && comp['id'] == companyId);

        // Step 2: Clear selectedCompany if it matches the one being deleted
        final selectedCompany = data['selectedCompany'];
        final isSelectedCompanyDeleted = selectedCompany != null &&
            selectedCompany is Map &&
            selectedCompany['id'] == companyId;

        final updateData = <String, dynamic>{
          'company': joinedCompanies,
        };

        print("selectedCompany");
        print(selectedCompany);
        print(selectedCompany['id']);
        print("updateData['selectedCompany']");
        print(updateData['selectedCompany']);

        if (isSelectedCompanyDeleted) {
          updateData['company'] = FieldValue.delete();
        }
        batch.update(userDoc.reference, updateData);
      }

// 5. Remove associated group chats and broadcasts related to this company
      final chatsSnap = await firestore
          .collection('chats')
          .where('companyId', isEqualTo: companyId)
          .get();

      final isChat =await doesCollectionExist('chats');

      if(isChat) {
        for (var chatDoc in chatsSnap.docs) {
          // If you have separate collections for group chats or broadcasts, delete them here
          batch.delete(chatDoc.reference);
        }
      }
      // 6. Delete associated broadcast data (if any)
      final broadcastSnap = await firestore
          .collection('broadcasts')
          .where('companyId', isEqualTo: companyId)
          .get();
      final isBroad =await doesCollectionExist('broadcasts');
      if(isBroad) {
        for (var broadcastDoc in broadcastSnap.docs) {
          batch.delete(broadcastDoc.reference);
        }
      }
      // 6. Delete associated groups data (if any)
      final group = await firestore
          .collection('groups')
          .where('companyId', isEqualTo: companyId)
          .get();
      final isGroup =await doesCollectionExist('groups');
      if(isGroup) {
      for (var g in group.docs) {
        batch.delete(g.reference);
      }}
      // 4. Delete the actual company doc
      batch.delete(firestore.collection('companies').doc(companyId));

      await batch.commit();

      toast("✅ Company and related data deleted successfully.");
      Get.offAll(()=>LandingPage()); // Or your preferred route
    } catch (e) {
      print("❌ Error deleting company: $e");
      errorDialog("Something went wrong while deleting the company.");
    }
  }*/


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title:  Text("Update Company",style: BalooStyles.balooboldTitleTextStyle(),),
        actions: [
          dynamicButton(
              name: "Add",
              onTap: () {
                // controller.updateIndex(1);
                // setState(() {
                //   isTaskMode =false;
                // });
                Get.to(() => InviteMembersScreen(
                  company: widget.company,
                  invitedBy: APIs.me.id,
                ));
              },
              isShowText: true,
              isShowIconText: true,
              // gradient: buttonGradient,
              vPad: 5,
              color: Colors.black,
              iconColor: Colors.black,
              leanIcon: addUserIcon)
              .paddingOnly(top: 0)
        ],
       ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [

                Stack(
                  children: [
                    //profile picture
                    APIs.me.selectedCompany?.logoUrl != '' || APIs.me.selectedCompany?.logoUrl!=null
                        ?

                    //local image

                    //image from server
                    Container(
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: appColorGreen,width: 1)
                      ),
                      child:  CustomCacheNetworkImage(
                        APIs.me.selectedCompany?.logoUrl??'',
                        height: mq.height * .18,
                        width: mq.height * .18,
                        boxFit: BoxFit.cover,
                        radiusAll: 100,
                      ),
                    ):
                    filecompanyLogoUrl!=''?


                    ClipRRect(
                        borderRadius:
                        BorderRadius.circular(mq.height * .1),
                        child: Image.file(File(companyLogoUrl!),
                            width: mq.height * .18,
                            height: mq.height * .18,
                            fit: BoxFit.cover)):

                    Container(
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: appColorGreen,width: 1)
                      ),
                      child: CustomCacheNetworkImage(
                        companyLogoUrl??'',
                        height: mq.height * .18,
                        width: mq.height * .18,
                        boxFit: BoxFit.cover,
                        radiusAll: 100,
                      ),
                    )
                        ,

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
                vGap(25),
                GradientButton(
                  onTap: ()async {
                    if (_formKey.currentState!.validate()) {
                      SystemChannels.textInput.invokeMethod('TextInput.hide');
                      customLoader.show();
                      CompanyModel company = CompanyModel(
                        id: widget.company?.id,
                        name: nameController.text.trim(),
                        address: addressController.text.trim(),
                        logoUrl: companyLogoUrl,
                        email: emailController.text.trim() ?? '',
                        phone: phoneController.text.trim() ?? '',
                        websiteURL: websiteController.text.trim()??'',
                        members: widget.company?.members??[],
                        adminUserId: widget.company?.adminUserId,
                        allowedCompany: widget.company?.allowedCompany,
                        createdBy: widget.company?.createdBy,
                        createdAt: widget.company?.createdAt,
                      );

                     await APIs.updateCompany(company).onError((e,v){
                       customLoader.hide();
                     });
                      customLoader.hide();
                      // Get.back();
                    }
                  },
                  name: "Update Company",
                ),
                vGap(30),
                TextButton(child: Text("Delete Company",
                style: BalooStyles.baloomediumTextStyle(color: AppTheme.redErrorColor),), onPressed: ()async{

                  await deleteCompany(context, widget.company!);

                })


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

      customLoader.show();

      setState(() {
        filecompanyLogoUrl = croppedFile.path ?? '';
      });

      await APIs.updateCompanyLogo(File(filecompanyLogoUrl??''));
      customLoader.hide();
      Get.back();

      // controller.hitApiToUpdateProfileLogo();
    }
  }
}

