
import 'package:AccuChat/utils/text_style.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../Constants/themes.dart';
import 'custom_dialogue.dart';
import 'gradient_button.dart';
import 'helper_widget.dart';

void showResponsiveConfirmationDialog({required Function() onConfirm, title}) {
  final ctx = Get.context!;
  final size = MediaQuery.of(ctx).size;

  // Responsive width breakpoints (desktop / tablet / large phone / phone)
  double targetWidth;
  if (size.width >= 1280) {
    targetWidth = size.width * 0.25; // desktop
  } else if (size.width >= 992) {
    targetWidth = size.width * 0.35; // laptop / large tablet
  } else if (size.width >= 768) {
    targetWidth = size.width * 0.5; // tablet
  } else {
    targetWidth = size.width * 0.85; // phones / small windows
  }
  // Keep width within reasonable min/max
  targetWidth = targetWidth.clamp(360.0, 560.0);

  final maxHeight = size.height * 0.90;

  Get.dialog(
    // Keeps dialog within safe areas and nicely centered
    SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: targetWidth,
            maxHeight: maxHeight,
          ),
          child: Material(
            color: Colors.transparent,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: SingleChildScrollView(
                // 👇 Your dialog code is untouched and placed as-is
                child: CustomDialogue(
                  title: title,
                  isShowActions: false,
                  isShowAppIcon: false,
                  content: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      vGap(20),
                      Text(
                        "Do you really want to ${title}",
                        style: BalooStyles.baloonormalTextStyle(),
                        textAlign: TextAlign.center,
                      ),
                      vGap(30),
                      Row(
                        children: [
                          Expanded(
                            child: GradientButton(
                              name: "Yes",
                              btnColor: AppTheme.redErrorColor,
                              gradient: LinearGradient(
                                colors: [AppTheme.redErrorColor, AppTheme.redErrorColor],
                              ),
                              vPadding: 6,
                              onTap:onConfirm,
                            ),
                          ),
                          hGap(15),
                          Expanded(
                            child: GradientButton(
                              name: "Cancel",
                              btnColor: Colors.black,
                              color: Colors.black,
                              gradient: LinearGradient(
                                colors: [AppTheme.whiteColor, AppTheme.whiteColor],
                              ),
                              vPadding: 6,
                              onTap: () {
                                Get.back();
                              },
                            ),
                          ),
                        ],
                      ),
                      // Text(STRING_logoutHeading,style: BalooStyles.baloomediumTextStyle(),),
                    ],
                  ),
                  onOkTap: () {},
                ),
              ),
            ),
          ),
        ),
      ),
    ),
    barrierColor: Colors.black54, // nice dim on web
    name: title,
  );
}