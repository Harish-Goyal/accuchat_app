import 'package:AccuChat/Constants/themes.dart';
import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';

import '../Constants/colors.dart';


class IndicatorLoading extends StatelessWidget {
  const IndicatorLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return   Center(
      child:  SizedBox(
          height: 40,
          width: 40,
          child: LoadingIndicator(
              indicatorType: Indicator.lineSpinFadeLoader,
              colors:  [appColorGreen,appColorPerple,appColorYellow],
              strokeWidth: 2,
              backgroundColor: Colors.transparent,
              pathBackgroundColor: Colors.transparent
          )
      ),
    );
  }
}

// class NoDataFound extends StatelessWidget {
//   const NoDataFound({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return  const Column(
//       crossAxisAlignment: CrossAxisAlignment.center,
//       mainAxisAlignment:MainAxisAlignment.center,
//       children: [
//         // Text("OOPS!",style: BalooStyles.balooboldTextStyle(),),
//         CircleAvatar(
//           radius: 75,
//             backgroundImage: AssetImage(noData),
//             // child: Image.asset(noData,height: 150,width: 150,)
//         ),
//         // Text("OOPS!",style: BalooStyles.balooboldTextStyle(size: 17),),
//       ],
//     );
//   }
// }

// class LoggerX {
//   static void write(String text, {bool isError = false}) {
//     Future.microtask(() => isError ? log.v("$text") : log.i("$text"));
//   }
// }
