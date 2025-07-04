

import 'package:flutter/material.dart';
import 'colors.dart';
import 'font_family.dart';

ThemeData themeData =  ThemeData(
  brightness: Brightness.light,
  primaryColor: Colors.white,
  scaffoldBackgroundColor: Colors.white,
  bottomAppBarTheme: const BottomAppBarTheme(),
  fontFamily: FontFamily.mazzard,
  appBarTheme: AppBarTheme(
    backgroundColor: COLOR_white,
    iconTheme: IconThemeData(
      color:blackColor
    ),
    titleTextStyle: const TextStyle(
        color: Colors.black,fontSize: 20, fontWeight: FontWeight.w900),
    elevation: 0,
  ),
  textTheme: const TextTheme(
headlineLarge:TextStyle(
    color: Colors.black, fontSize: 24, fontWeight: FontWeight.w900) ,
    headlineMedium: TextStyle(
        color: Colors.black, fontSize: 18, fontWeight: FontWeight.w900),
    headlineSmall: TextStyle(
      color: Colors.black, fontSize: 16, fontWeight: FontWeight.w900),

    bodyLarge:
    TextStyle(
        color: Colors.black, fontSize: 18, fontWeight: FontWeight.w500),
    bodyMedium: TextStyle(
        color: Colors.black, fontSize: 16, fontWeight: FontWeight.w500),
    bodySmall: TextStyle(
        color: Colors.black, fontSize: 14, fontWeight: FontWeight.w500),


  ),
  iconTheme: const IconThemeData(color: COLOR_middleBlueM),

  inputDecorationTheme: InputDecorationTheme(
      border: outlineBorder(),
      enabledBorder: outlineBorder(),
      focusedBorder: outlineBorder(),
      errorBorder: outlineBorder(),
      disabledBorder: outlineBorder(),
      focusedErrorBorder: outlineBorder(),
      labelStyle: const TextStyle(
          color: COLOR_lightGray, fontSize: 16.0, fontWeight: FontWeight.w400)),
  textButtonTheme: TextButtonThemeData(
    style: ButtonStyle(
      textStyle: WidgetStateProperty.all(
          const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
      backgroundColor: WidgetStateProperty.all<Color>(COLOR_white),
      foregroundColor: WidgetStateProperty.all<Color>(appColor),
      overlayColor: WidgetStateProperty.all<Color>(appColor.withOpacity(0.4)),
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ButtonStyle(
      textStyle: WidgetStateProperty.all(
          const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
      backgroundColor: WidgetStateProperty.all<Color>(appColor),
      foregroundColor: WidgetStateProperty.all<Color>(COLOR_white),
      overlayColor: WidgetStateProperty.all<Color>(appColor.withOpacity(0.4)),
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: ButtonStyle(
      textStyle: WidgetStateProperty.all(
          const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
      foregroundColor: WidgetStateProperty.all<Color>(appColor.withOpacity(0.3)),
      overlayColor: WidgetStateProperty.all<Color>(appColor),
    ),
  ),
);
ThemeData themeDark =  ThemeData(
  brightness: Brightness.dark,
  primaryColor: Colors.black,
  scaffoldBackgroundColor: Colors.black,
  bottomAppBarTheme: const BottomAppBarTheme(),
  fontFamily: FontFamily.mazzard,
  appBarTheme: AppBarTheme(
    backgroundColor: blackColor,
    iconTheme: IconThemeData(
        color:blackColor
    ),
     titleTextStyle: const TextStyle(
         color: Colors.white,fontSize: 20, fontWeight: FontWeight.w900),

    elevation: 0,
  ),
  textTheme: TextTheme(
    headlineLarge: const TextStyle(
        color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900),
    headlineMedium: const TextStyle(
        color: Colors.white,fontSize: 20, fontWeight: FontWeight.w900),
    headlineSmall: const TextStyle(
        color: Colors.white,fontSize: 18, fontWeight: FontWeight.w900),

    bodyLarge: const TextStyle(
        color: Colors.white, fontSize: 16, fontWeight: FontWeight.w400),
    bodyMedium: TextStyle(
        color: Colors.white.withOpacity(0.8),
        fontSize: 14,
        fontWeight: FontWeight.w400),
    bodySmall: const TextStyle(color: Colors.black),
  ),
  iconTheme: const IconThemeData(color: COLOR_middleBlueM),

  inputDecorationTheme: InputDecorationTheme(
      border: outlineBorder(),
      enabledBorder: outlineBorder(),
      focusedBorder: outlineBorder(),
      errorBorder: outlineBorder(),
      disabledBorder: outlineBorder(),
      focusedErrorBorder: outlineBorder(),
      labelStyle: const TextStyle(
          color: COLOR_lightGray, fontSize: 16.0, fontWeight: FontWeight.w400)),
  textButtonTheme: TextButtonThemeData(
    style: ButtonStyle(
      textStyle: WidgetStateProperty.all(
          const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
      backgroundColor: WidgetStateProperty.all<Color>(COLOR_white),
      foregroundColor: WidgetStateProperty.all<Color>(appColor),
      overlayColor: WidgetStateProperty.all<Color>(appColor.withOpacity(0.4)),
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ButtonStyle(
      textStyle: WidgetStateProperty.all(
          const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
      backgroundColor: WidgetStateProperty.all<Color>(appColor),
      foregroundColor: WidgetStateProperty.all<Color>(COLOR_white),
      overlayColor: WidgetStateProperty.all<Color>(appColor.withOpacity(0.4)),
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: ButtonStyle(
      textStyle: WidgetStateProperty.all(
          const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
      foregroundColor: WidgetStateProperty.all<Color>(appColor.withOpacity(0.3)),
      overlayColor: WidgetStateProperty.all<Color>(appColor),
    ),
  ),
);

OutlineInputBorder outlineBorder() => OutlineInputBorder(
      borderRadius: BorderRadius.circular(6),
      borderSide: BorderSide(
        width: 1,
        color: COLOR_lightGray.withOpacity(0.5),
      ),
    );
