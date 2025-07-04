import 'package:AccuChat/Constants/themes.dart';
import 'package:flutter/material.dart';

class CircleContainer extends StatelessWidget {
   CircleContainer({super.key,this.setSize,this.colorIS});

   double? setSize =6.0;
   Color? colorIS;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(setSize!),
      decoration:
          BoxDecoration(shape: BoxShape.circle, color: colorIS?? AppTheme.redColor),
    );
  }
}
