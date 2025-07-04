// ignore_for_file: use_build_context_synchronously

import 'dart:developer';
import 'dart:io';

import 'package:AccuChat/Constants/assets.dart';
import 'package:AccuChat/Constants/colors.dart';
import 'package:AccuChat/Extension/text_field_extenstion.dart';
import 'package:AccuChat/utils/gradient_button.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';

import '../../../Constants/themes.dart';
import '../../../Services/APIs/local_keys.dart';
import '../../../utils/common_textfield.dart';
import '../../../utils/custom_dialogue.dart';
import '../../../utils/helper_widget.dart';
import '../../../utils/networl_shimmer_image.dart';
import '../../../utils/text_style.dart';
import '../../Home/Presentation/View/home_screen.dart';
import '../../Settings/Presentation/Views/settings_screen.dart';
import '../api/apis.dart';
import '../helper/dialogs.dart';
import '../../../main.dart';
import '../models/chat_user.dart';
import 'auth/login_screen.dart';

//profile screen -- to show signed in user info
class ProfileScreen extends StatefulWidget {
  final ChatUser? user;

  const ProfileScreen({super.key, required this.user});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _image;

  String profileImg = '';

  late TextEditingController nameC;
  late TextEditingController aboutC;
  late TextEditingController phoneC;
  late TextEditingController mailC;
  @override
  void initState() {
    profileImg=widget.user?.image??'';
    nameC =TextEditingController(text:widget.user?.name=='null'?'':widget.user?.name.toString()??'');
    aboutC =TextEditingController(text:widget.user?.about.toString()??'');
    phoneC =TextEditingController(text:widget.user?.phone=='null'?'':widget.user?.phone.toString()??'');
    mailC =TextEditingController(text:widget.user?.email=='null'?'':widget.user?.email.toString()??'');
    super.initState();
  }



  Future<void> signOutUser() async {
    final user = FirebaseAuth.instance.currentUser;
    try {
      if (user != null) {
        try {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .update({'is_online': false, 'last_active': DateTime.now().millisecondsSinceEpoch});
          APIs.me = ChatUser(
              id: '',
              name: "",
              email:"",
              about:"",
              image:"",
              createdAt: '',

              phone: '',
              isOnline: false,
              lastActive:  "",
              isTyping: false,
              lastMessageTime: '',
              pushToken: '', xStikers: '', role: null, company: [],selectedCompany: null);

        } catch (e) {
          debugPrint('Firestore update failed: $e');
        }
      }
      // Sign out from Google
      final googleSignIn = GoogleSignIn();
      if (await googleSignIn.isSignedIn()) {
        await googleSignIn.signOut();
      }


      // Then sign out from Firebase
      await FirebaseAuth.instance.signOut();

      storage.write(isLoggedIn, false);
      storage.write(isFirstTime, true);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreenG()),
      );
      print("User successfully signed out.");
    } catch (e) {
      print("Sign out error: $e");
    }
  }
  Future<void> logout(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({'is_online': false, 'last_active': DateTime.now()});
      } catch (e) {
        debugPrint('Firestore update failed: $e');
      }
    }

    await FirebaseAuth.instance.signOut();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreenG()),
    );
  }


  @override
  Widget build(BuildContext context) {

    return GestureDetector(
      // for hiding keyboard
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
          //app bar
          appBar: AppBar(title: const Text('Profile'),actions: [
            InkWell(
              onTap: ()async {
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
                                    await signOutUser();
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
          body: Form(
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
                        _image != null
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
                                  child: Image.file(File(_image!),
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
                                APIs.me?.image??'',
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
                          controller:nameC,
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
                          hintText: "Phone".tr,
                          controller:phoneC,
                          // textInputType: TextInputType.number,
                          readOnly: true,

                          focusNode: FocusNode(),
                          onFieldSubmitted: (String? value) {
                            // FocusScope.of(Get.context!)
                            //     .requestFocus(controller.passwordFocusNode);
                          },
                          labletext: "Phone",

                          validator: (value) {
                            // return value?.isEmptyField(messageTitle: "Username");
                          },
                        ),

                        vGap(10),

                        CustomTextField(
                          hintText: "Email".tr,
                          controller:mailC,
                          readOnly:widget.user?.email==null? true:false,
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
                        ),
                        vGap(10),

                        CustomTextField(
                          hintText: "About".tr,
                          controller:aboutC,
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
                         APIs.updateUserInfo(
                           nameC.text.trim(),
                             mailC.text.trim(),
                           phoneC.text.trim(),
                           aboutC.text.trim()

                         ).then((value)async {
                           await APIs.getSelfInfo();
                           Dialogs.showSnackbar(
                               context, 'Profile Updated Successfully!');
                         });
                       }
                   }),

                     SettingsScreen()
                  ],
                ),
              ),
            ),
          )),
    );
  }

  // bottom sheet for picking a profile picture for user
  void _showBottomSheet() {
    showModalBottomSheet(
        context: context,
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
                          setState(() {
                            _image = image.path;
                          });

                          await APIs.updateProfilePicture(File(_image!));
                          // for hiding bottom sheet
                          Navigator.pop(context);
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
                          setState(() {
                            _image = image.path;
                          });

                          await APIs.updateProfilePicture(File(_image!));
                           // for hiding bottom sheet
                          Navigator.pop(context);
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
