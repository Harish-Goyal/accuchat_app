import 'package:AccuChat/Constants/assets.dart';
import 'package:AccuChat/Services/APIs/api_ends.dart';
import 'package:AccuChat/routes/app_routes.dart';
import 'package:AccuChat/utils/networl_shimmer_image.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../../Constants/colors.dart';
import '../../../../../../main.dart';
import '../../../../models/chat_user.dart';
import '../../../auth/models/get_uesr_Res_model.dart';
import '../../../../models/recent_chat_user_res_model.dart';
import '../Views/view_profile_screen.dart';
import '../Widgets/profile_zoom.dart';

class ProfileDialog extends StatelessWidget {
  ProfileDialog({super.key, required this.user});

  UserDataAPI? user;

  @override
  Widget build(BuildContext context) {
    final double dialogWidth = kIsWeb ? 420 : mq.width * .6;
    final double dialogHeight = kIsWeb ? 320 : mq.height * .35;

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: kIsWeb ? 520 : double.infinity,
          maxHeight: kIsWeb ? 420 : double.infinity,
          minWidth: 300,
          minHeight: 240,
        ),
        child: AlertDialog(
          backgroundColor: Colors.white.withOpacity(.9),
          contentPadding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          insetPadding: kIsWeb
              ? const EdgeInsets.symmetric(horizontal: 24, vertical: 24)
              : EdgeInsets.zero,
          content: SizedBox(
            width: dialogWidth,
            height: dialogHeight,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Row: name + info button
                Padding(
                  padding: const EdgeInsets.only(left: 16, right: 8, top: 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          user?.userCompany?.displayName ?? '',
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w500),
                        ),
                      ),
                      MaterialButton(
                        onPressed: () {
                          Get.back();
                          if (kIsWeb) {
                            Get.toNamed(
                              "${AppRoutes.view_profile}?userId=${user?.userId.toString()}",
                            );
                          } else {
                            Get.toNamed(AppRoutes.view_profile,
                                arguments: {'user': user});
                          }
                        },
                        minWidth: 0,
                        padding: const EdgeInsets.all(0),
                        shape: const CircleBorder(),
                        child: const Icon(Icons.info_outline,
                            color: Colors.blue, size: 26),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // Profile Image
                Expanded(
                  child: InkWell(
                    onTap: (){
                      Get.to(()=>ProfileZoom(imagePath: "${ApiEnd.baseUrlMedia}${user?.userImage ?? ''}",heroTag: "DetailedProfile"));
                    },
                    child: Hero(
                      tag: "DetailedProfile",
                      child: Align(
                        alignment: Alignment.center,
                        child: AspectRatio(
                          aspectRatio: 1,
                          child: ClipRRect(
                            borderRadius:
                            BorderRadius.circular(dialogHeight * 0.45),
                            child: CustomCacheNetworkImage(
                              width: dialogWidth * .6,
                              height: dialogWidth * .6,
                              "${ApiEnd.baseUrlMedia}${user?.userImage ?? ''}",
                              defaultImage: userIcon,
                              radiusAll: dialogHeight * 0.5,
                              boxFit: BoxFit.cover,
                              borderColor: greyText,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
