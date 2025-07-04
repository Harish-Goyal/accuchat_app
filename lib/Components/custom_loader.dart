

// Project imports:
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loading_indicator/loading_indicator.dart';

import '../Constants/colors.dart';
import '../Constants/themes.dart';


class CustomLoader {
  static CustomLoader? _loader;

  CustomLoader._createObject();

  factory CustomLoader() {
    if (_loader != null) {
      return _loader!;
    } else {
      _loader = CustomLoader._createObject();
      return _loader!;
    }
  }

  OverlayState? _overlayState;
  OverlayEntry? _overlayEntry;

  _buildLoader() {
    _overlayEntry = OverlayEntry(
      builder: (context) {
        return Stack(
          alignment: Alignment.center,
          children: <Widget>[
            Container(
              child: buildLoader(),
              color: Colors.black.withOpacity(.3),
            )
          ],
        );
      },
    );
  }

  show() {
    _overlayState = Overlay.of(Get.context!);
    _buildLoader();
    _overlayState!.insert(_overlayEntry!);
  }

  hide() {
    try {
      if (_overlayEntry != null) {
        _overlayEntry!.remove();
        _overlayEntry = null;
      }
    } catch (_) {}
  }

  buildLoader() {
    return Center(
      child: Container(
        color:  Colors.transparent,
        child: SizedBox(
            height: 40,
            width: 40,
            child: LoadingIndicator(
                indicatorType: Indicator.lineSpinFadeLoader,
                colors:  [appColorGreen,appColorPerple,appColorYellow],
                strokeWidth: 2,
                backgroundColor: Colors.transparent,
                pathBackgroundColor: Colors.transparent
            )), //CircularProgressIndicator(),
      ),
    );
  }
}
