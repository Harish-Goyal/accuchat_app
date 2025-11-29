import 'package:AccuChat/utils/text_style.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../Constants/colors.dart';

class CustomTextButton extends StatelessWidget {
  const CustomTextButton({super.key,required this.onTap,required this.title,this.bgColor});

  final Function() onTap;
  final String title;
  final Color?  bgColor;

  @override
  Widget build(BuildContext context) {
    return   TextButton(onPressed: onTap,
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.resolveWith<Color?>(
                (states) {
              if (states.contains(MaterialState.hovered)) {
                return bgColor ?? appColorGreen.withOpacity(0.1);   // hover color
              }
              return Colors.transparent;                 // default background
            },
          ),
          foregroundColor: MaterialStateProperty.all(Colors.transparent),
          shadowColor: MaterialStateProperty.all(Colors.transparent),
          overlayColor: MaterialStateProperty.all(Colors.transparent),

          shape: MaterialStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(100),
            ),
          ),
          padding: MaterialStateProperty.all(
            EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
        ),
        child: AnimatedDefaultTextStyle(child: Text(title, style:BalooStyles.baloonormalTextStyle(color: appColorGreen,size: 13)), style: BalooStyles.baloonormalTextStyle(color: appColorGreen,size: 13), duration: Duration(seconds: 1)))
    ;
  }
}
