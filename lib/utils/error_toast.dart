library edge_alert;

import 'package:flutter/material.dart';

class EdgeAlert {
  // ignore: constant_identifier_names
  static const int LENGTH_SHORT = 1; //1 seconds
  // ignore: constant_identifier_names
  static const int LENGTH_LONG = 2; // 2 seconds
  // ignore: constant_identifier_names
  static const int LENGTH_VERY_LONG = 3; // 3 seconds

  // ignore: constant_identifier_names
  static const int TOP = 1;
  // ignore: constant_identifier_names
  static const int BOTTOM = 2;

  static void show(
    BuildContext context, {
    String description = '',
    int? duration,
    int? gravity,
    Color? backgroundColor,
  }) {
    OverlayView.createView(
      context,
      description: description,
      duration: duration,
      gravity: gravity,
      backgroundColor: backgroundColor,
    );
  }
}

class OverlayView {
  OverlayView._private();

  factory OverlayView() {
    _singleton ??= OverlayView._private();
    return _singleton!;
  }
  static OverlayView? _singleton;

  static OverlayState? _overlayState;
  static OverlayEntry? _overlayEntry;
  static bool _isVisible = false;

  static void createView(
    BuildContext context, {
    String description = '',
    int? duration,
    int? gravity,
    Color? backgroundColor,
  }) {
    _overlayState = Navigator.of(context).overlay;
    if (!_isVisible) {
      _isVisible = true;
      _overlayEntry = OverlayEntry(builder: (context) {
        return EdgeOverlay(
          description: description,
          overlayDuration: duration ?? EdgeAlert.LENGTH_SHORT,
          gravity: gravity ?? EdgeAlert.TOP,
          backgroundColor: backgroundColor ?? Colors.grey,
        );
      });

      _overlayState!.insert(_overlayEntry!);
    }
  }

  static dismiss() async {
    if (!_isVisible) {
      return;
    }
    _isVisible = false;
    _overlayEntry?.remove();
  }
}

class EdgeOverlay extends StatefulWidget {
  // ignore: use_key_in_widget_constructors
  const EdgeOverlay({
    required this.description,
    required this.overlayDuration,
    required this.gravity,
    required this.backgroundColor,
  });
  final String description;
  final int overlayDuration;
  final int gravity;
  final Color backgroundColor;

  @override
  // ignore: library_private_types_in_public_api
  _EdgeOverlayState createState() => _EdgeOverlayState();
}

class _EdgeOverlayState extends State<EdgeOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Tween<Offset> _positionTween;
  late Animation<Offset> _positionAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 750));

    if (widget.gravity == 1) {
      _positionTween =
          Tween<Offset>(begin: const Offset(0.0, -1.0), end: Offset.zero);
    } else {
      _positionTween = Tween<Offset>(
          begin: const Offset(0.0, 5.0), end: const Offset(0.0, 0));
    }

    _positionAnimation = _positionTween.animate(
        CurvedAnimation(parent: _controller, curve: Curves.fastOutSlowIn));

    _controller.forward();

    listenToAnimation();
  }

  listenToAnimation() async {
    _controller.addStatusListener((listener) async {
      if (listener == AnimationStatus.completed) {
        await Future.delayed(Duration(seconds: widget.overlayDuration));
        _controller.reverse();
        await Future.delayed(const Duration(milliseconds: 700));
        OverlayView.dismiss();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    final double bottomHeight = MediaQuery.of(context).padding.bottom;

    return Positioned(
      top: widget.gravity == 1 ? 0 : null,
      bottom: widget.gravity == 2 ? 30 : null,
      left: widget.gravity == 2 ? 15 : null,
      right: widget.gravity == 2 ? 15 : null,
      child: SlideTransition(
          position: _positionAnimation,
          child: SafeArea(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  fit: FlexFit.loose,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      color: widget.backgroundColor,
                    ),
                    padding: EdgeInsets.fromLTRB(15, 15, 15, 15),
                    child: OverlayWidget(
                      description: widget.description,
                    ),
                  ),
                ),
              ],
            ),
          )),
    );
  }
}

class OverlayWidget extends StatelessWidget {
  const OverlayWidget({Key? key, required this.description}) : super(key: key);
  final String description;

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Text(
        description,
        style: TextStyle(color: Colors.white),
        textAlign: TextAlign.center,
      ),
    );
  }
}

class AnimatedIcon extends StatefulWidget {
  // ignore: use_key_in_widget_constructors
  const AnimatedIcon({required this.iconData});
  final IconData iconData;

  @override
  // ignore: library_private_types_in_public_api
  _AnimatedIconState createState() => _AnimatedIconState();
}

class _AnimatedIconState extends State<AnimatedIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this,
        lowerBound: 0.8,
        upperBound: 1.1,
        duration: const Duration(milliseconds: 600));

    _controller.forward();
    listenToAnimation();
  }

  listenToAnimation() async {
    _controller.addStatusListener((listener) async {
      if (listener == AnimationStatus.completed) {
        _controller.reverse();
      }
      if (listener == AnimationStatus.dismissed) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      child: Icon(
        widget.iconData,
        size: 35,
        color: Colors.white,
      ),
      builder: (context, widget) =>
          Transform.scale(scale: _controller.value, child: widget),
    );
  }
}
//rha

// extension JSON on String {
//   dynamic fromJson(Map json) {
//     return json[this];
//   }
//
//   showErrorAlert(BuildContext context) {
//     EdgeAlert.show(context,
//         description: this,
//         gravity: EdgeAlert.BOTTOM,
//         backgroundColor: Colors.redAccent);
//   }
//
//   showErrorTopAlert(BuildContext context) {
//     EdgeAlert.show(context,
//         description: this,
//         gravity: EdgeAlert.TOP,
//         backgroundColor: Colors.redAccent);
//   }
//
//   showSuccessAlert(BuildContext context) {
//     EdgeAlert.show(context,
//         description: this,
//         gravity: EdgeAlert.BOTTOM,
//         backgroundColor: Color.fromRGBO(37, 77, 222, 1));
//   }
//
//   showInfoAlert(BuildContext context) {
//     EdgeAlert.show(context,
//         description: this,
//         gravity: EdgeAlert.BOTTOM,
//         backgroundColor: Colors.blueGrey);
//   }
// }
