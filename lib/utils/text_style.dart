import 'package:AccuChat/Constants/themes.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BalooStyles {
  static baloothinTextStyle({
    double size = 14,
    double height = 1.2,
    Color? color,
    bool underLineNeeded = false,
  }) {
    return GoogleFonts.inter(
      fontSize: size,
      height: height,
      fontWeight: FontWeight.w100,
      color:color?? AppTheme.primaryTextColor,
      decoration:
          underLineNeeded ? TextDecoration.underline : TextDecoration.none,
    );
  }

  static baloonormalTextStyle({
    double size = 14,
    double height = 1.2,
    Color? color,
    FontWeight weight = FontWeight.w400,
    bool underLineNeeded = false,
    List<Shadow>? shadows,
  }) {
    return GoogleFonts.inter(
      fontSize: size,
      height: height,
      fontWeight: weight,
      color:color?? AppTheme.primaryTextColor,
      decoration:
          underLineNeeded ? TextDecoration.underline : TextDecoration.none,
        shadows: shadows
    );
  }

  static  baloomediumTextStyle({
    double size = 14,
    double height = 1.2,
    Color? color,
    bool underLineNeeded = false,
  }) {
    return GoogleFonts.inter(
      fontSize: size,
      height: height,
      fontWeight: FontWeight.w500,
      color:color?? AppTheme.primaryTextColor,
      decoration:
          underLineNeeded ? TextDecoration.underline : TextDecoration.none,
    );
  }

  static balooregularTextStyle({
    double size = 14,
    double height = 1.2,
    Color? color,
    FontWeight? weight ,
    TextDecoration? decoration ,
    Color? decorationColor,
    bool italicFontStyle = false,
  }) {
    return GoogleFonts.inter(
      fontStyle: italicFontStyle ? FontStyle.italic : FontStyle.normal,
      fontSize: size,
      fontWeight:weight?? FontWeight.w400,
      height: height,
      // overflow: TextOverflow.ellipsis,
      decoration:
      decoration ??TextDecoration.none,
      decorationColor:decorationColor ??Colors.transparent,
      color:color?? AppTheme.primaryTextColor,
    );
  }

  static baloosemiBoldTextStyle({
    double size = 14,
    double height = 1.2,
    Color? color,
    TextDecoration? decoration ,
    Color? decorationColor,
    bool underLineNeeded = false,
  }) {
    return GoogleFonts.inter(
      fontSize: size,
      height: height,
      fontWeight: FontWeight.w600,
      decoration:
      decoration ??TextDecoration.none,
      decorationColor:decorationColor ??Colors.transparent,
      color:color?? AppTheme.primaryTextColor,
    );
  }

  static balooboldTextStyle({
    double size = 14,
    double height = 1.2,
    Color? color,
    bool underLineNeeded = false,
    List<Shadow>? shadows,
  }) {
    return GoogleFonts.inter(
        fontSize: size,
        height: height,
        decoration:
            underLineNeeded ? TextDecoration.underline : TextDecoration.none,
        fontWeight: FontWeight.bold,
        color:color?? AppTheme.primaryTextColor,
        shadows: shadows);
  }

  static balooboldTitleTextStyle({
    double size = 15,
    double height = 1.2,
    Color? color,
    bool underLineNeeded = false,
    List<Shadow>? shadows,
  }) {
    return GoogleFonts.inter(
        fontSize: size,
        height: height,
        decoration:
            underLineNeeded ? TextDecoration.underline : TextDecoration.none,
        fontWeight: FontWeight.bold,
        color:color?? AppTheme.primaryTextColor,
        shadows: shadows);
  }

  static TextStyle? commonTextStyle(
      double fontSize, FontWeight fontWeight, Color color) {
    return TextStyle(fontSize: fontSize, fontWeight: fontWeight, color: color);
  }
}

class LatoStyles {
  static latothinTextStyle({
    double size = 14,
    double height = 1.2,
    Color color = Colors.white,
    bool underLineNeeded = false,
  }) {
    return TextStyle(
      fontSize: size,
      height: height,
      fontWeight: FontWeight.w100,
      color: color,
      decoration:
          underLineNeeded ? TextDecoration.underline : TextDecoration.none,
    );
  }

  static latonormalTextStyle({
    double size = 14,
    double height = 1.2,
    Color color = Colors.white,
    bool underLineNeeded = false,
    FontWeight weight = FontWeight.w400,
    double letterSpacing = -0.3,
    shadows,
  }) {
    return TextStyle(
      fontSize: size,
      height: height,
      fontWeight: weight,
      color: color,
      letterSpacing: letterSpacing,
      shadows: shadows ?? [],
      decoration:
          underLineNeeded ? TextDecoration.underline : TextDecoration.none,
    );
  }

  static latomediumTextStyle({
    double size = 14,
    double height = 1.2,
    Color color = Colors.white,
    bool underLineNeeded = false,
  }) {
    return TextStyle(
      fontSize: size,
      height: height,
      fontWeight: FontWeight.w500,
      color: color,
      decoration:
          underLineNeeded ? TextDecoration.underline : TextDecoration.none,
    );
  }

  static latoregularTextStyle({
    double size = 14,
    double height = 1.2,
    Color color = Colors.white,
    bool underLineNeeded = false,
    bool italicFontStyle = false,
  }) {
    return TextStyle(
      fontStyle: italicFontStyle ? FontStyle.italic : FontStyle.normal,
      fontSize: size,
      fontWeight: FontWeight.w300,
      height: height,
      // overflow: TextOverflow.ellipsis,
      decoration:
          underLineNeeded ? TextDecoration.underline : TextDecoration.none,
      color: color,
    );
  }

  static latosemiBoldTextStyle({
    double size = 14,
    double height = 1.2,
    Color color = Colors.white,
    bool underLineNeeded = false,
  }) {
    return TextStyle(
      fontSize: size,
      height: height,
      decoration:
          underLineNeeded ? TextDecoration.underline : TextDecoration.none,
      fontWeight: FontWeight.w600,
      color: color,
    );
  }

  static latoboldTextStyle({
    double size = 14,
    double height = 1.2,
    Color color = Colors.black,
    bool underLineNeeded = false,
    List<Shadow>? shadows,
  }) {
    return TextStyle(
        fontSize: size,
        height: height,
        decoration:
            underLineNeeded ? TextDecoration.underline : TextDecoration.none,
        fontWeight: FontWeight.bold,
        color: color,
        shadows: shadows);
  }

  static TextStyle? commonTextStyle(
      double fontSize, FontWeight fontWeight, Color color) {
    return TextStyle(fontSize: fontSize, fontWeight: fontWeight, color: color);
  }
}
