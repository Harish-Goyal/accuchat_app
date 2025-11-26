import 'dart:io' show File; // keep File import guarded for non-web usage

import 'package:AccuChat/Constants/assets.dart';
import 'package:AccuChat/Constants/colors.dart';
import 'package:AccuChat/Extension/text_field_extenstion.dart';
import 'package:AccuChat/Screens/Home/Presentation/Controller/profile_controller.dart';
import 'package:AccuChat/Services/APIs/api_ends.dart';
import 'package:AccuChat/utils/gradient_button.dart';
import 'package:AccuChat/utils/loading_indicator.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
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
import '../../../Chat/screens/auth/Presentation/Views/landing_screen.dart';
import '../Controller/home_controller.dart';
import 'home_screen.dart';
import '../../../Settings/Presentation/Views/settings_screen.dart';
import '../../../Chat/api/apis.dart';
import '../../../Chat/helper/dialogs.dart';
import '../../../../main.dart';
import '../../../Chat/models/chat_user.dart';
import '../../../Chat/screens/auth/Presentation/Views/login_screen.dart';

// profile screen -- to show signed in user info
class ProfileScreen extends GetView<HProfileController> {
  ProfileScreen({super.key});

  final _formKey = GlobalKey<FormState>();

  /// Breakpoints & sizing (desktop/tablet only; mobile untouched)
  double _maxContentWidth(double w) {
    if (w >= 1400) return 920; // large desktop
    if (w >= 1100) return 820; // desktop
    if (w >= 900) return 720;  // small desktop / landscape tablet
    if (w >= 600) return 560;  // portrait tablet
    return w; // phones -> full width (preserves mobile UI)
  }

  EdgeInsets _pagePadding(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    if (w >= 900) return const EdgeInsets.symmetric(horizontal: 24, vertical: 12);
    if (w >= 600) return const EdgeInsets.symmetric(horizontal: 16, vertical: 12);
    // phones use your original padding based on mq
    return EdgeInsets.symmetric(horizontal: mq.width * .05);
  }

  double _avatarSize(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    // Original used mq.height * .18; keep that for phones
    final fallback = mq.height * .18;
    if (w < 600) return fallback; // mobile untouched
    // On wider screens, clamp the size so it doesn’t explode
    return 140.0; // nice desktop/tablet size
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HProfileController>(builder: (controller) {
      return GestureDetector(
        // for hiding keyboard
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          backgroundColor: Colors.white,

          appBar: AppBar(
            backgroundColor: Colors.white,
            foregroundColor: Colors.white,
            shadowColor: Colors.white,
            title: Text(
              'Profile',
              style: BalooStyles.balooboldTitleTextStyle(),
            ),
            actions: [
              IconButton(
                onPressed: () async {
                  showResponsiveLogoutDialog();
                },
                icon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text("Logout",style: BalooStyles.baloosemiBoldTextStyle(),),
                    hGap(5),
                    const Icon(Icons.logout,size: 16,),
                  ],
                ),
              ).marginSymmetric(horizontal: 15),
            ],
          ),

          body: controller.isLoading
              ? IndicatorLoading()
              : Form(
            key: _formKey,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final maxW = _maxContentWidth(constraints.maxWidth);

                return Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: maxW,
                      // keep minWidth small so phones are unaffected
                      minWidth: 280,
                    ),
                    child: Padding(
                      padding: _pagePadding(context),
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            // for adding some space
                            SizedBox(width: mq.width, height: mq.height * .01),

                            // user profile picture
                            _ProfileAvatar(
                              controller: controller,
                              size: _avatarSize(context),
                            ),

                            SizedBox(height: mq.height * .03),

                            // Form fields block (kept same; only constrained by parent width)
                            Column(
                              children: [
                                CustomTextField(
                                  hintText: "Username".tr,
                                  controller: controller.nameC,
                                  focusNode: FocusNode(),
                                  onFieldSubmitted: (String? value) {},
                                  labletext: "Username",
                                  validator: (value) {
                                    return value?.isEmptyField(messageTitle: "Username");
                                  },
                                ),
                                vGap(10),
                                CustomTextField(
                                  hintText: "Phone or Email".tr,
                                  controller: controller.phoneC,
                                  readOnly: true,
                                  focusNode: FocusNode(),
                                  onFieldSubmitted: (String? value) {},
                                  labletext: "Phone or Email",
                                  validator: (value) {},
                                ),
                                vGap(10),
                                CustomTextField(
                                  hintText: "About".tr,
                                  controller: controller.aboutC,
                                  maxLines: 4,
                                  focusNode: FocusNode(),
                                  onFieldSubmitted: (String? value) {},
                                  labletext: "About",
                                  validator: (value) {},
                                ),
                              ],
                            ).marginSymmetric(horizontal: 5),

                            // spacing
                            SizedBox(height: mq.height * .05),

                            // update profile button
                            GradientButton(
                              name: "Update",
                              onTap: () {
                                SystemChannels.textInput.invokeMethod('TextInput.hide');
                                if (_formKey.currentState!.validate()) {
                                  _formKey.currentState!.save();
                                  controller.hitAPIToUpdateUser();
                                }
                              },
                            ),

                            // Settings section (kept same)
                            const SizedBox(height: 16),
                            SettingsScreen(),

                            const SizedBox(height: 8),
                            TextButton(
                              child: Text(
                                "Delete Account",
                                style: BalooStyles.baloomediumTextStyle(
                                  color: AppTheme.redErrorColor,
                                ),
                              ),
                              onPressed: () async {
                                await showDeleteAccountDialog(
                                  context,
                                  Get.find<DashboardController>().user?.userId ?? 0,
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      );
    });
  }

  Future<void> showDeleteAccountDialog(BuildContext context, int userId) async {
    final w = MediaQuery.of(context).size.width;
    EdgeInsets inset;
    if (w >= 1100) {
      inset = const EdgeInsets.symmetric(horizontal: 160, vertical: 40);
    } else if (w >= 900) {
      inset = const EdgeInsets.symmetric(horizontal: 120, vertical: 36);
    } else if (w >= 600) {
      inset = const EdgeInsets.symmetric(horizontal: 48, vertical: 28);
    } else {
      inset = const EdgeInsets.symmetric(horizontal: 16, vertical: 16); // phones: similar to default
    }

    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        insetPadding: inset,
        backgroundColor: Colors.white,
        actionsAlignment: MainAxisAlignment.center,
        title: Text(
          'Delete Account',
          style: BalooStyles.balooboldTitleTextStyle(color: AppTheme.redErrorColor),
        ),
        content: SingleChildScrollView( // prevent overflow on smaller screens
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Are you sure you want to permanently delete your account?',
                style: BalooStyles.balooregularTextStyle(),
              ),
              vGap(15),
              Text(
                'All your messages, group participation, and data will be deleted and cannot be recovered.',
                style: BalooStyles.baloomediumTextStyle(color: AppTheme.redErrorColor),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel', style: BalooStyles.baloomediumTextStyle()),
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


}

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar({
    required this.controller,
    required this.size,
  });

  final HProfileController controller;
  final double size;

  @override
  Widget build(BuildContext context) {
    final border = Border.all(color: appColorGreen, width: 1);

    return Stack(
      children: [
        // *****************************
        // SHOW IMAGE FOR WEB + MOBILE
        // *****************************
        _buildProfileImage(border),

        // *****************************
        // EDIT BUTTON (WEB + MOBILE)
        // *****************************
        Positioned(
          bottom: 0,
          right: 0,
          child: MaterialButton(
            elevation: 1,
            onPressed: () async {
              if (kIsWeb) {
                // WEB: pick image using file_picker
                FilePickerResult? result = await FilePicker.platform.pickFiles(
                  type: FileType.image,
                  allowMultiple: false,
                );

                if (result != null) {
                  controller.webImageBytes = result.files.first.bytes;
                  controller.update();
                }
              } else {
                // MOBILE: show bottom sheet
                _showBottomSheet();
              }
            },
            shape: const CircleBorder(),
            color: Colors.white,
            child: const Icon(Icons.edit, color: Colors.blue),
          ),
        ),
      ],
    );
  }

  // ================================================================
  // PROFILE IMAGE HANDLER FOR WEB + MOBILE
  // ================================================================
  Widget _buildProfileImage(Border border) {
    if (kIsWeb) {
      // WEB IMAGE PICKED
      if (controller.webImageBytes != null) {
        return Container(
          decoration: BoxDecoration(shape: BoxShape.circle, border: border),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(size / 2),
            child: Image.memory(
              controller.webImageBytes!,
              width: size,
              height: size,
              fit: BoxFit.cover,
            ),
          ),
        );
      }
    } else {
      // MOBILE IMAGE PICKED
      if (controller.image != null) {
        return Container(
          decoration: BoxDecoration(shape: BoxShape.circle, border: border),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(size / 2),
            child: Image.file(
              File(controller.image!),
              width: size,
              height: size,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) =>
                  Image.asset(userIcon, height: 40),
            ),
          ),
        );
      }
    }

    // NETWORK IMAGE (DEFAULT)
    return CustomCacheNetworkImage(
      "${ApiEnd.baseUrlMedia}${controller.profileImg}",
      height: size,
      width: size,
      boxFit: BoxFit.cover,
      radiusAll: 100,
      defaultImage: userIcon,
      borderColor: AppTheme.appColor,
    );
  }

  // ================================================================
  // MOBILE BOTTOM SHEET
  // ================================================================
  void _showBottomSheet() {
    showModalBottomSheet(
      context: Get.context!,
      useSafeArea: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      builder: (_) {
        final size = MediaQuery.of(Get.context!).size;
        final isWide = size.width >= 900;

        return ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: isWide ? 720 : size.width,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Pick Profile Picture',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
              ),

              SizedBox(height: mq.height * .02),

              Row(
                children: [
                  // ******** GALLERY *********
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        shape: const CircleBorder(),
                        fixedSize: Size(
                          isWide ? 220 : mq.width * .2,
                          isWide ? 140 : mq.height * .1,
                        ),
                      ),
                      onPressed: () async {
                        final ImagePicker picker = ImagePicker();
                        final XFile? image = await picker.pickImage(
                          source: ImageSource.gallery,
                          imageQuality: 80,
                        );
                        if (image != null) {
                          controller.image = image.path;
                          controller.update();
                          Get.back();
                        }
                      },
                      child: Image.asset('assets/images/add_image.png'),
                    ),
                  ),

                  // ******** CAMERA *********
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        shape: const CircleBorder(),
                        fixedSize: Size(
                          isWide ? 220 : mq.width * .2,
                          isWide ? 140 : mq.height * .1,
                        ),
                      ),
                      onPressed: () async {
                        final ImagePicker picker = ImagePicker();
                        final XFile? image = await picker.pickImage(
                          source: ImageSource.camera,
                          imageQuality: 80,
                        );
                        if (image != null) {
                          controller.image = image.path;
                          controller.update();
                          Get.back();
                        }
                      },
                      child: Image.asset('assets/images/camera.png'),
                    ),
                  ),
                ],
              ),

              vGap(40),
            ],
          ).paddingSymmetric(vertical: 30, horizontal: 20),
        );
      },
    );
  }
}


/// Extracted avatar area with responsive sizing (mobile visual preserved)
/*class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar({
    required this.controller,
    required this.size,
  });

  final HProfileController controller;
  final double size;

  @override
  Widget build(BuildContext context) {
    final border = Border.all(color: appColorGreen, width: 1);

    return Stack(
      children: [
        // Profile picture
        controller.image != null
            ? Container(
          decoration: BoxDecoration(shape: BoxShape.circle, border: border),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(size / 2),
            child: Image.file(
              File(controller.image ?? ''),
              width: size,
              height: size,
              fit: BoxFit.cover,
              errorBuilder: (b, c, v) => Image.asset(userIcon, height: 40),
            ),
          ),
        )
            : CustomCacheNetworkImage(
          "${ApiEnd.baseUrlMedia}${controller.profileImg}",
          height: size,
          width: size,
          boxFit: BoxFit.cover,
          radiusAll: 100,
          defaultImage: userIcon,
          borderColor: AppTheme.appColor,
        ),

        // edit image button
       !kIsWeb? Positioned(
          bottom: 0,
          right: 0,
          child: MaterialButton(
            elevation: 1,
            onPressed: () async {

              if (kIsWeb) {
                // WEB: pick image using file_picker
                FilePickerResult? result = await FilePicker.platform.pickFiles(
                  type: FileType.image,
                  allowMultiple: false,
                );

                if (result != null) {
                  Uint8List fileBytes = result.files.first.bytes!;
                  controller.webImageBytes = fileBytes;
                  controller.update();
                  Get.back();
                }
              }else{
                _showBottomSheet();
              }

            },
            shape: const CircleBorder(),
            color: Colors.white,
            child: const Icon(Icons.edit, color: Colors.blue),
          ),
        ):SizedBox(),
      ],
    );
  }

  // bottom sheet for picking a profile picture for user
  void _showBottomSheet() {
    showModalBottomSheet(
      context: Get.context!,
      useSafeArea: true,
      backgroundColor: Colors.white,
      // isScrollControlled: true, // nicer on web
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
      ),
      builder: (_) {
        final size = MediaQuery.of(Get.context!).size;
        final isWide = size.width >= 900;

        // Web/tablet: center content in a max-width container; phones unchanged.
        final child = ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: isWide ? 720 : size.width, // web/tablet get narrower sheet
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Pick Profile Picture',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
              ),
              SizedBox(height: mq.height * .02),

              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        shape: const CircleBorder(),
                        fixedSize: Size(
                          // keep original phone size; desktop gets a sane cap
                          (isWide ? 220 : mq.width * .2),
                          (isWide ? 140 : mq.height * .1),
                        ),
                      ),
                      onPressed: () async {
                        final ImagePicker picker = ImagePicker();
                        final XFile? image =
                        await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
                        if (image != null) {
                          controller.image = image.path;
                          controller.update();
                          Get.back();
                        }
                      },
                      child: Image.asset('assets/images/add_image.png'),
                    ),
                  ),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        shape: const CircleBorder(),
                        fixedSize: Size(
                          (isWide ? 220 : mq.width * .2),
                          (isWide ? 140 : mq.height * .1),
                        ),
                      ),
                      onPressed: () async {
                        final ImagePicker picker = ImagePicker();
                        final XFile? image =
                        await picker.pickImage(source: ImageSource.camera, imageQuality: 80);
                        if (image != null) {
                          controller.image = image.path;
                          controller.update();
                          Get.back();
                        }
                      },
                      child: Image.asset('assets/images/camera.png'),
                    ),
                  ),
                ],
              ),
              vGap(40)
            ],
          ).paddingSymmetric(vertical: 30,horizontal: 20),
        );

        return child;
      },
    );
  }
}*/
