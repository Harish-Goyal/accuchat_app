import 'package:AccuChat/utils/text_style.dart';
import 'package:flutter/material.dart';

import '../Constants/assets.dart';
import '../Constants/themes.dart';

class DataNotFoundText extends StatelessWidget {
   DataNotFoundText({super.key,this.texts});

  String? texts;

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        // decoration: BoxDecoration(
        //   color: AppTheme.appColor.withOpacity(.2),
        //   borderRadius: const BorderRadius.only(
        //       topLeft: Radius.circular(15),
        //       topRight: Radius.circular(15),
        //       // bottomLeft: Radius.circular(15),
        //       bottomRight: Radius.circular(15)),
        // ),
        child: Image.asset(noDataFoundPng,height: 200,width: 200,));
  }
}
