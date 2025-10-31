import 'package:AccuChat/Constants/assets.dart';
import 'package:AccuChat/Services/APIs/api_ends.dart';
import 'package:AccuChat/routes/app_routes.dart';
import 'package:AccuChat/utils/networl_shimmer_image.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../../main.dart';
import '../../../../models/chat_user.dart';
import '../../../auth/models/get_uesr_Res_model.dart';
import '../../../../models/recent_chat_user_res_model.dart';
import '../Views/view_profile_screen.dart';

class ProfileDialog extends StatelessWidget {
   ProfileDialog({super.key, required this.user});

   UserDataAPI? user;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: EdgeInsets.zero,
      backgroundColor: Colors.white.withOpacity(.9),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      content: SizedBox(
          width: mq.width * .6,
          height: mq.height * .35,
          child: Stack(
            children: [
              //user profile picture
              Positioned(
                top: mq.height * .075,
                left: mq.width * .1,
                child: SizedBox(
                    width: mq.width * .5,
                    child: CustomCacheNetworkImage(

                      width: mq.width * .5,
                      height: mq.width * .5,
                      "${ApiEnd.baseUrlMedia}${user?.userImage??''}",defaultImage: userIcon,
                      radiusAll: mq.height * .25,
                      boxFit: BoxFit.cover,
                    ))

                /*ClipRRect(
                  borderRadius: BorderRadius.circular(mq.height * .25),
                  child: CachedNetworkImage(
                    width: mq.width * .5,
                    fit: BoxFit.cover,
                    imageUrl: user.image,
                    errorWidget: (context, url, error) =>
                        const CircleAvatar(child: Icon(CupertinoIcons.person)),
                  ),
                ),*/
              ),

              //user name
              Positioned(
                left: mq.width * .04,
                top: mq.height * .02,
                width: mq.width * .55,
                child: Text(user?.displayName??'',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w500)),
              ),

              //info button
              Positioned(
                  right: 8,
                  top: 6,
                  child: MaterialButton(
                    onPressed: () {
                      //for hiding image dialog
                     Get.back();
                     if(kIsWeb){
                       Get.toNamed(
                         "${AppRoutes.view_profile}?userId=${user?.userId.toString()}",
                       );
                     }
                     else{
                       Get.toNamed(AppRoutes.view_profile,
                           arguments: {'user': user});
                     }

                    },
                    minWidth: 0,
                    padding: const EdgeInsets.all(0),
                    shape: const CircleBorder(),
                    child: const Icon(Icons.info_outline,
                        color: Colors.blue, size: 30),
                  ))
            ],
          )),
    );
  }
}
