import 'package:AccuChat/Constants/colors.dart';
import 'package:AccuChat/Constants/themes.dart';
import 'package:flutter/material.dart';

import 'text_style.dart';
import 'helper_widget.dart';


class GradientButton extends StatelessWidget {
  GradientButton(
      {super.key,
      required this.name,
      required this.onTap,
        this.textWidget,
      this.width,
      this.btnSize,
      this.vPadding,
      this.hPadding,
      this.btnColor,
      this.gradient,
      this.color});
  final String name;
  Gradient? gradient;
  double? width;
  double? btnSize;
  double? vPadding;
  double? hPadding;
  Color? color;
  Color? btnColor;
  Widget? textWidget;
  Function()? onTap;
  @override
  Widget build(BuildContext context) {
    return Material(
        color: btnColor ?? AppTheme.appColor, // Button color
        borderRadius: BorderRadius.circular(30),
        child: InkWell(
            splashColor: Colors.white.withOpacity(.3),
            onTap: onTap,
            child: Container(
              width: width ?? MediaQuery.of(context).size.width,
              padding: EdgeInsets.symmetric(
                  vertical: vPadding ?? 14, horizontal:hPadding?? 15),
              //alignment: Alignment.center,
              decoration: BoxDecoration(
                gradient: gradient ??
                     buttonGradient,
                borderRadius: BorderRadius.circular(30),
                // border: Border.all(color: appColor)
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    name,
                    textAlign: TextAlign.center,
                    style:BalooStyles.baloonormalTextStyle(size: btnSize ?? 14,
                        color: color ?? Colors.white,weight: FontWeight.w500)
                  ),
                  hGap(5),
                  textWidget??Container()

                ],
              ),
            )));
  }
}

class CustomButton extends StatelessWidget {
  CustomButton({super.key, this.color, this.textcolor, this.title, this.onTap});
  Color? color;
  Color? textcolor;
  String? title;
  Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: color ?? Colors.grey),
        child: Center(
          child: Text(
            title ?? '',
            textAlign: TextAlign.center,
            style:BalooStyles.balooregularTextStyle(color: textcolor ?? Colors.white)
          ),
        ),
      ),
    );
  }
}
