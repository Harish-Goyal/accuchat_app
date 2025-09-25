import 'package:AccuChat/Constants/colors.dart';
import 'package:flutter/material.dart';

class CustomContainer extends StatelessWidget {

   CustomContainer({super.key,required this.childWidget,this.color,this.elevation,this.hPadding,this.vPadding,this.radius});

   Widget childWidget;
   Color? color;
   double? hPadding = 12.0;
   double? vPadding = 12.0;
   double? radius = 12.0;
   double? elevation = 8.0;



  @override
  Widget build(BuildContext context) {
    return  Container(
        padding:  EdgeInsets.symmetric(horizontal:hPadding??12.0,vertical: vPadding??12.0),
    decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(radius??12),
    color:color?? whiteColor,
      boxShadow: [
        BoxShadow(color: Colors.grey.shade300,blurRadius:elevation?? 10)
      ]


    ),
    child:childWidget);
  }
}
