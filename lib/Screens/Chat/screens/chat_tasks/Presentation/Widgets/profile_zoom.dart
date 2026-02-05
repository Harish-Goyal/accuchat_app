import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pinch_zoom/pinch_zoom.dart';
import '../../../../../../Constants/themes.dart';
import '../../../../../../utils/backappbar.dart';
import '../../../../../../utils/networl_shimmer_image.dart';

class ProfileZoom extends StatelessWidget {
  ProfileZoom({super.key,required this.imagePath,this.heroTag});

  String imagePath = '';

  String? heroTag;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar:backAppBar(context: context,title: ''),
      body: imagePath!=''?  Hero(
        tag:heroTag?? "profile",
        child: PinchZoom(
          child: Center(
            child: Container(
              color: AppTheme.appColor.withOpacity(.1),
              height: Get.height*.47,
              child:imagePath.startsWith("http")? CustomCacheNetworkImage(imagePath??'',boxFit: BoxFit.contain):Image.file(File(imagePath)),
            ),
          ),
        ),
      ):Container(),
    );
  }
}
