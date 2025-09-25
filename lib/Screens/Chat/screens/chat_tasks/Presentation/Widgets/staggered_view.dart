// AnimationLimiter
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

class StaggeredAnimationListItem extends StatelessWidget {
  final int index;
  final Widget child;
  StaggeredAnimationListItem({Key? key,required this.child,required this.index}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return   AnimationConfiguration.staggeredList(
        position: index,
        duration: const Duration(milliseconds: 375),
        child: SlideAnimation(
            horizontalOffset: 80,
            curve: Curves.easeInOutBack,
            child:child));
  }
}
class StaggeredAnimationGridListItem extends StatelessWidget {
  final int index;
  final Widget child;
  StaggeredAnimationGridListItem({Key? key,required this.child,required this.index}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return   AnimationConfiguration.staggeredGrid(
        columnCount: 3,
        position: index,
        duration: const Duration(milliseconds: 375),
        child: SlideAnimation(
            horizontalOffset: 80,
            curve: Curves.easeInOutBack,
            child:child));
  }
}
