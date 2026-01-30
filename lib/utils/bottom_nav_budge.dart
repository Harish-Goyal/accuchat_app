import 'package:AccuChat/Constants/themes.dart';
import 'package:AccuChat/utils/text_style.dart';
import 'package:flutter/material.dart';

import '../Constants/colors.dart';

class BottomNavBudge extends StatelessWidget {
  const BottomNavBudge({super.key,required this.budgeCount});

  final String budgeCount;

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.symmetric(horizontal: 6,vertical: 6),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white),
          shape: BoxShape.circle
          // borderRadius: BorderRadius.only(topRight: Radius.circular(50),topLeft: Radius.circular(50,),bottomLeft: Radius.circular(50,))
          ,color: AppTheme.redErrorColor,
        ),
        /*child: Text(
          budgeCount,
          style: BalooStyles.baloomediumTextStyle(size: 11,color: Colors.white),
        )*/);
  }
}
