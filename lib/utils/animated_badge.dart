import 'package:AccuChat/Constants/colors.dart';
import 'package:AccuChat/Constants/themes.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AnimatedBadge extends StatelessWidget {
  final int count;

  const AnimatedBadge({super.key, required this.count});

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      duration: const Duration(milliseconds: 240),
      scale: count > 0 ? 1 : 0,        // bubble appears/disappears smoothly
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 240),
        opacity: count > 0 ? 1 : 0,
        child: Container(
          padding: const EdgeInsets.all(2),
          height: 20,
          width: 20,
          decoration: BoxDecoration(
            color:AppTheme.redColor,
            border: Border.all(color: AppTheme.redColor),
            borderRadius: BorderRadius.only(topRight: Radius.circular(100),topLeft:Radius.circular(100),bottomRight: Radius.circular(100) )
          ),
          child: Text(
            count.toString(),
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
