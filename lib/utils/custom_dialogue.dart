import 'dart:ui';
import 'package:AccuChat/Constants/strings.dart';
import 'package:AccuChat/Constants/themes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../Constants/assets.dart';
import 'text_style.dart';
import 'helper_widget.dart';

class CustomDialogue extends StatelessWidget {
  CustomDialogue(
      {super.key,
      required this.title,
      this.isShowAppIcon,
      required this.content,
      required this.onOkTap});
  String title = "";
  Function() onOkTap;
  Widget content;
  bool? isShowAppIcon =true;

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: AlertDialog(
          contentPadding: EdgeInsets.all(12),
          insetPadding: EdgeInsets.all(12),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          backgroundColor: Colors.grey.shade100,
          // contentPadding: EdgeInsets.all(20),

          title: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(
                alignment: Alignment.topRight,
                child: InkWell(
                  onTap: () {
                    Get.back();
                  },
                  borderRadius: BorderRadius.circular(100),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    margin: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                        color: AppTheme.appColor.withOpacity(.1),
                        shape: BoxShape.circle,
                        border: Border.all(color: AppTheme.appColor, width: 1)),
                    child: Icon(
                      Icons.clear,
                      color: AppTheme.appColor,
                      size: 17,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 5.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    isShowAppIcon!? getAppLogo():SizedBox(),
                    isShowAppIcon!?   vGap(10):vGap(0),
                    Text(
                      title,
                      style: BalooStyles.baloosemiBoldTextStyle(size: 18),
                      textAlign: TextAlign.center,
                    ),

                  ],
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                content,
                isShowAppIcon!?vGap(20):vGap(0),
                isShowAppIcon!?    Row(
                  children: [
                    Expanded(
                      child: dynamicButton(
                        name: STRING_cancel,
                        isShowText: true,
                        onTap: () {
            
                          Get.back();
                        },
                        isShowIconText: false, leanIcon: null,
                        btnColor: AppTheme.redErrorColor,
                      ),
                    ),
                    hGap(10),
                    Expanded(
                        child: dynamicButton(
                            name: STRING_yes,
                            isShowText: true,
                          btnColor: AppTheme.appColor,
                            onTap:onOkTap, isShowIconText: false, leanIcon: null,)),
                  ],
                ):SizedBox()
              ],
            ).paddingOnly(bottom: 15),
          ),
        ));
  }
}

class dynamicButton extends StatelessWidget {
  dynamicButton(
      {super.key,
      required this.name,
      required this.onTap,
      this.gradient,
      this.btnColor,
      this.iconColor,
      this.vPad,
      this.hPad,
      required this.isShowText,
      required this.isShowIconText,
      required this.leanIcon,
      this.color});
  final String name;
  Gradient? gradient;
  Color? color;
  bool isShowText=false;
  bool isShowIconText=false;
  Color? btnColor;
  Color? iconColor;
  final void Function()? onTap;
  var leanIcon;
  double? vPad;
  double? hPad;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        padding:  EdgeInsets.symmetric(vertical:isShowText?(vPad?? 10):(vPad??9), horizontal: isShowText!? hPad??15:hPad??12),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            // color: btnColor ?? AppTheme.appColor.withOpacity(.1),
          gradient: gradient
        ),
        child:isShowText? Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            isShowIconText? Image.asset(leanIcon,height: 20,color: iconColor??null):Container(),
            isShowIconText?hGap(5):hGap(0),
            Text(name,
                style: BalooStyles.baloosemiBoldTextStyle(
                    color: color ?? Colors.white,),
              textAlign: TextAlign.center,

            ),

          ],
        ):Image.asset(leanIcon,height: 20,color: iconColor??null),
      ),
    );
  }
}
