import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'helper_widget.dart';

class CustomScaffold extends StatelessWidget {
  CustomScaffold(
      {super.key,
        required this.body,
        this.appBar,
        this.backgroundColor,
        this.bottomNavigationBar,
        this.bottomSheet,
        this.drawer,
        this.drawerEdgeDragWidth,
        this.drawerScrimColor,
        this.endDrawer,
        this.drawerEnableOpenDragGesture,
        this.endDrawerEnableOpenDragGesture,
        this.extendBody,
        this.extendBodyBehindAppBar,
        this.floatingActionButton,
        this.floatingActionButtonAnimator,
        this.floatingActionButtonLocation,
        this.onDrawerChanged,
        this.onEndDrawerChanged,
        this.persistentFooterButtons,
        this.primary,
        this.drawerDragStartBehavior,
        this.resizeToAvoidBottomInset}); // and maybe other Scaffold properties

  final Widget body;
  final PreferredSizeWidget? appBar;

  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final FloatingActionButtonAnimator? floatingActionButtonAnimator;
  final List<Widget>? persistentFooterButtons;

  final Widget? drawer;
  void Function(bool)? onDrawerChanged;
  final Widget? endDrawer;
  void Function(bool)? onEndDrawerChanged;
  final Widget? bottomNavigationBar;
  final Widget? bottomSheet;
  final Color? backgroundColor;
  bool? resizeToAvoidBottomInset = false;
  bool? primary = true;
  DragStartBehavior? drawerDragStartBehavior = DragStartBehavior.start;
  bool? extendBody = false;
  bool? extendBodyBehindAppBar = false;
  final Color? drawerScrimColor;
  final double? drawerEdgeDragWidth;
  bool? drawerEnableOpenDragGesture = true;
  bool? endDrawerEnableOpenDragGesture = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: extendBodyBehindAppBar??true,
      extendBody: true,
      floatingActionButton: floatingActionButton,
      appBar: appBar,
      backgroundColor: backgroundColor,
      bottomNavigationBar: bottomNavigationBar,
      bottomSheet: bottomSheet,
      drawer: drawer,
      drawerEdgeDragWidth: drawerEdgeDragWidth,
      drawerScrimColor: drawerScrimColor,
      endDrawer: endDrawer,
      onDrawerChanged: onDrawerChanged,
      onEndDrawerChanged: onDrawerChanged,
      floatingActionButtonAnimator: floatingActionButtonAnimator,
      floatingActionButtonLocation: floatingActionButtonLocation,
      persistentFooterButtons: persistentFooterButtons,
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          gradient: homeLinearGradient,
        ),
        child: SafeArea(bottom: false, child: body),
      ),
    );
  }
}