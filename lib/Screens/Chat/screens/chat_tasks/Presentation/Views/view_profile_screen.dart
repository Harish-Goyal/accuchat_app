import 'package:AccuChat/Constants/assets.dart';
import 'package:AccuChat/Screens/Chat/screens/chat_tasks/Presentation/Controllers/view_profile_controller.dart';
import 'package:AccuChat/utils/networl_shimmer_image.dart';
import 'package:AccuChat/utils/text_style.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../../Services/APIs/api_ends.dart';
import '../../../../../../main.dart';
import '../../../../helper/my_date_util.dart';
import '../../../../models/chat_user.dart';

//view profile screen -- to view profile of user
class ViewProfileScreen extends GetView<ViewProfileController> {


  const ViewProfileScreen({super.key});


  @override
  Widget build(BuildContext context) {
    return GetBuilder<ViewProfileController>(
      builder: (controller) {
        print(controller.user?.userImage);
        return GestureDetector(
          // for hiding keyboard
          onTap: () => FocusScope.of(context).unfocus(),
          child: Scaffold(
            //app bar
              appBar: AppBar(title: Text(controller.user?.userName==null||controller.user?.userName=='null'||controller.user?.userName==''?
              controller.user?.phone??'':controller.user?.userName??'',style: BalooStyles.balooboldTitleTextStyle(),),),
              floatingActionButton: //user about
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                    Text(
                    'Joined On: ',
                    style: BalooStyles.baloomediumTextStyle(),
                  ),
                  Text(
                      MyDateUtil.getLastMessageTime(
                          context: context,
                          time: controller.user?.createdOn??'',
                          showYear: true),
                      style: BalooStyles.baloonormalTextStyle()),
                ],
              ),

              //body
              body: Padding(
                padding: EdgeInsets.symmetric(horizontal: mq.width * .05),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // for adding some space
                      SizedBox(width: mq.width, height: mq.height * .03),

                      //user profile picture
               controller.user?.userImage!=null?CustomCacheNetworkImage(
                        "${ApiEnd.baseUrlMedia}${controller.user?.userImage??''}",

                        height: mq.height * .2,
                        width: mq.height * .2,
                        radiusAll: 100,
                        boxFit: BoxFit.cover,
                        defaultImage: userIcon,
                        borderColor: Colors.black,
                      ):const SizedBox(),

                      // for adding some space
                      SizedBox(height: mq.height * .03),

                      // user email label
                      Text(
                          controller.user?.email==null||controller.user?.email=='null'||controller.user?.email==''?
                          controller.user?.phone??'':controller.user?.email??'',
                          style:
                          const TextStyle(color: Colors.black87, fontSize: 16)),

                      // for adding some space
                      SizedBox(height: mq.height * .02),

                      //user about
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'About: ',
                            style: TextStyle(
                                color: Colors.black87,
                                fontWeight: FontWeight.w500,
                                fontSize: 15),
                          ),
                          Text(controller.user?.about??'',
                              style: const TextStyle(
                                  color: Colors.black54, fontSize: 15)),
                        ],
                      ),
                    ],
                  ),
                ),
              )),
        );
      }
    );
  }

}
