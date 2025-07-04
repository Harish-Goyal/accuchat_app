// import 'package:AccuChat_erp_flutter/constants/localfiles.dart';
// import 'package:AccuChat_erp_flutter/utils/helper_widget.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:AccuChat_erp_flutter/widgets/common_button.dart';
// import 'package:get/get.dart';
//
// class FacebookTwitterButtonView extends StatelessWidget {
//    FacebookTwitterButtonView({Key? key,required this.onTap}) : super(key: key);
//    Function() onTap;
//   @override
//   Widget build(BuildContext context) {
//     return _fTButtonUI();
//   }
//
//   Widget _fTButtonUI() {
//     return CommonButton(
//     padding: EdgeInsets.zero,
//     backgroundColor: Colors.white,
//     onTap: onTap,
//     buttonTextWidget: Row(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         const Text(
//           "Continue with Google",
//           style: TextStyle(
//               fontWeight: FontWeight.w500, fontSize: 16, color: Colors.black),
//         ),
//         hGap(5),
//         // SvgPicture.asset(Localfiles.googleSvg,height: 30,width: 30,),
//       ],
//     ),
//             ).marginSymmetric(horizontal: 20,vertical: 4);
//   }
//
//   Widget _buttonTextUI({bool isFacebook = true}) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.center,
//       crossAxisAlignment: CrossAxisAlignment.center,
//       children: <Widget>[
//         Icon(isFacebook ? FontAwesomeIcons.facebookF : FontAwesomeIcons.google,
//             size: 20, color: Colors.white),
//         const SizedBox(
//           width: 4,
//         ),
//         Text(
//           isFacebook ? "Facebook" : "Google",
//           style: const TextStyle(
//               fontWeight: FontWeight.w500, fontSize: 16, color: Colors.white),
//         ),
//       ],
//     );
//   }
// }
