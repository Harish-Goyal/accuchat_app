// import 'package:flutter/material.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:get/get.dart';
//
// import '../constants/text_style.dart';
// import '../constants/themes.dart';
// import 'helper_widget.dart';
//
// class CustomDropdown extends StatefulWidget {
//   final String title; // Title like "Adults" or "Rooms"
//   final IconData iconData; // Title like "Adults" or "Rooms"
//   final List<int> options;
//    int selectedValue;
//   final ValueChanged onChanged;
//
//   CustomDropdown({required this.title, required this.options, required this.iconData, required this.selectedValue, required this.onChanged});
//
//   @override
//   _CustomDropdownState createState() => _CustomDropdownState();
// }
//
// class _CustomDropdownState extends State<CustomDropdown> {
//   // Store selected value
//
//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: () => _showDropdownMenu(context,widget.iconData), // Tap to show dropdown
//       child: Container(
//         padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Row(
//               children: [
//                 Icon(
//                   widget.iconData,
//                   color: AppTheme.primaryColor,
//                   size: 15,
//                 ),
//                 hGap(8),
//                 Text(
//                   widget.selectedValue != null ? " ${widget.title}" : widget.title,
//                   style: BalooStyles.baloosemiBoldTextStyle(),
//                 ),
//               ],
//             ),
//
//
//             containerBox( widget.selectedValue != null ? "${widget.selectedValue} ${widget.title}" : widget.title,),
//
//           ],
//         ),
//       ),
//     );
//   }
//
//   // Display the dropdown menu in a dialog
//   void _showDropdownMenu(BuildContext context,IconData icon) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return Container(
//           width: 50,
//           margin: EdgeInsets.only(left: 100),
//           child: AlertDialog(
//             contentPadding: EdgeInsets.all(0),
//             content: Container(
//               width: 50,
//               height: Get.height*.5,
//               // margin: EdgeInsets.symmetric(horizontal: 55),
//               child: ListView(
//                 shrinkWrap: true,
//                 children: widget.options.map((int value) {
//                   return ListTile(
//                     title: SizedBox(
//                         width: 50,
//                         child: Text(
//                           '$value ${widget.title}',
//                           style: BalooStyles.baloosemiBoldTextStyle(),
//                         )),
//                     onTap: (){
//                       widget.onChanged;
//
//                     }/*() {
//                       setState(() {
//                         widget.selectedValue = value;
//                       });
//                       Navigator.of(context).pop(); // Close the dropdown
//                     },*/
//                   );
//                 }).toList(),
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }
//
//   containerBox(val) {
//     return Container(
//       padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 18),
//       decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(8),
//           color: Colors.blue.withOpacity(.05),
//           border: Border.all(color: AppTheme.primaryColor, width: .3),
//           boxShadow: [BoxShadow(color: Colors.grey.shade300, blurRadius: 2)]),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Text(
//             '${val}',
//             style: BalooStyles.baloosemiBoldTextStyle(),
//           ),
//           hGap(8),
//           Icon(
//             FontAwesomeIcons.angleDown,
//             color: AppTheme.primaryColor,
//             size: 15,
//           ),
//         ],
//       ),
//     );
//   }
// }
//
//
