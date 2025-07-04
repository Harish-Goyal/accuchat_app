import 'package:flutter/material.dart';

// class RPSCustomPainter extends StatelessWidget {
//   const RPSCustomPainter({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Image.asset(Localfiles.redCardPng,height: 150,width: 75,);
//   }
// }

class RPSCustomPainter extends CustomPainter{

  @override
  void paint(Canvas canvas, Size size) {



    // Layer 1

    Paint paint_fill_0 = Paint()
      ..color = const Color.fromARGB(255, 188, 14, 14)
      ..style = PaintingStyle.fill
      ..strokeWidth = size.width*0.00
      ..strokeCap = StrokeCap.butt
      ..strokeJoin = StrokeJoin.miter;


    Path path_0 = Path();
    path_0.moveTo(size.width*0.0416667,size.height*0.0714286);
    path_0.lineTo(size.width*0.4575000,size.height*0.0700000);
    path_0.lineTo(size.width*0.4591667,size.height*0.7914286);
    path_0.lineTo(size.width*0.2500000,size.height*0.7128571);
    path_0.lineTo(size.width*0.0425000,size.height*0.7900000);
    path_0.lineTo(size.width*0.0416667,size.height*0.0714286);
    path_0.close();

    canvas.drawPath(path_0, paint_fill_0);


    // Layer 1

    Paint paint_stroke_0 = Paint()
      ..color = const Color.fromARGB(255, 33, 150, 243)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width*0.00
      ..strokeCap = StrokeCap.butt
      ..strokeJoin = StrokeJoin.miter;



    canvas.drawPath(path_0, paint_stroke_0);


  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }

}
