import 'package:AccuChat/Constants/themes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'text_style.dart';
import 'helper_widget.dart';

AppBar backAppBar({bool? centertitle,title,tilteWidget,context,Function()? onTap,backICon,List<Widget>? actionss}) {
  return AppBar(
    scrolledUnderElevation: 0,
    surfaceTintColor: Colors.white,
    backgroundColor: AppTheme.scaffoldBackgroundColor,
    centerTitle:centertitle?? true,
    elevation: 0,
    leading: InkWell(
      borderRadius: BorderRadius.circular(100),
        onTap:onTap?? () {
          Get.focusScope!.unfocus();
          Get.back();
        },
        child:backICon?? Container(
          padding: const EdgeInsets.all(10),
          margin: const EdgeInsets.only(right: 10,left: 10),
          decoration: BoxDecoration(
            shape: BoxShape.circle, color: AppTheme.appColor.withOpacity(0.2),
          ),

          child:  Icon(
            Icons.arrow_back,
            color:AppTheme.appColor,
            size: 20,
          ),
        )),
    actions: actionss,

    title:tilteWidget?? Text(
      title ?? "",
      style:BalooStyles.balooboldTitleTextStyle()
    ),
  );
}


Widget backApp(context,title, {size}){
  return Row(
    // mainAxisSize: MainAxisSize.min,
    mainAxisAlignment: MainAxisAlignment.start,
    children: [
      InkWell(
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              shape: BoxShape.circle, color: AppTheme.appColor.withOpacity(0.2),

            ),

            child:  Icon(
              Icons.arrow_back,
              color:Colors.black,
              size: 16,
            ),
          ),
          onTap: () {
            Get.focusScope!.unfocus();
            Get.back();
          }),
      hGap(10),
      Text(
        title ?? "",
        style:BalooStyles.balooboldTitleTextStyle(color: Colors.black,size: size??18.0)
      )
    ],
  ).marginSymmetric(horizontal: 15);
}
