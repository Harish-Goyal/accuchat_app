import 'package:flutter/material.dart';

class AppTheme {
  static bool isLightMode = true;

  // static bool get isLightMode {
  //   try {
  //     return Get.find<ThemeController>().isLightMode;
  //   } catch (e) {
  //     return true;
  //   }
  // }
  //
  // // colors
  // static Color get primaryColor {
  //   try {
  //     ColorType colortypedata = Get.find<ThemeController>().colorType;
  //     return getColor(colortypedata);
  //   } catch (e) {
  //     return getColor(ColorType.verdigris);
  //   }
  // }

  static Color get scaffoldBackgroundColor =>
      isLightMode ? Colors.grey.shade100 : Colors.grey.shade100;

  // isLightMode ? const Color(0xFFF7F7F7) : const Color(0xFFF7F7F7);

  static Color get redErrorColor =>
      isLightMode ? const Color(0xFFAC0000) : const Color(0xFFAC0000);

  static Color get redColor =>
      isLightMode ? const Color(0xFFE31E24) : const Color(0xFFE31E24);

  static Color get green =>
      isLightMode ? const Color(0x2C5403FF) : const Color(0x2C5403FF);

  static Color get appColor =>
      isLightMode ?  Color(0xFF08c189): Color(0xFF08c189);

  static Color get backgroundColor =>
      isLightMode ? const Color(0xFFFFFFFF) : const Color(0xFFFFFFFF);

  static Color get primaryTextColor =>
      isLightMode ? const Color(0xFF262626) : const Color(0xFF262626);

  static Color get secondaryTextColor =>
      isLightMode ? const Color(0xFF747474) : const Color(0xFF747474);

  static Color get whiteColor => const Color(0xFFFFFFFF);

  static Color get backColor => const Color(0xFF262626);

  static Color get fontcolor =>
      isLightMode ? const Color(0xFF1A1A1A) : const Color(0xFF1A1A1A);


  static Color get dividerColor =>
      isLightMode ? const Color(0xFFE5E7EB) : const Color(0xFFE5E7EB);

/*
  static TextTheme _buildTextTheme(TextTheme base) {
    FontFamilyType fontType = FontFamilyType.workSans;
    try {
      fontType = Get.find<ThemeController>().fontType;
    } catch (_) {}

    return base.copyWith(
      displayLarge: getTextStyle(fontType, base.displayLarge!), //f-size 96
      displayMedium: getTextStyle(fontType, base.displayMedium!), //f-size 60
      displaySmall: getTextStyle(fontType, base.displaySmall!), //f-size 48
      headlineMedium: getTextStyle(fontType, base.headlineMedium!), //f-size 34
      headlineSmall: getTextStyle(fontType, base.headlineSmall!), //f-size 24
      titleLarge: getTextStyle(
        fontType,
        base.titleLarge!.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ), //f-size 20
      labelLarge: getTextStyle(fontType, base.labelLarge!), //f-size 14
      bodySmall: getTextStyle(fontType, base.bodySmall!), //f-size 12
      bodyLarge: getTextStyle(fontType, base.bodyLarge!), //f-size 16
      bodyMedium: getTextStyle(fontType, base.bodyMedium!), //f-size 14
      titleMedium: getTextStyle(
        fontType,
        base.titleMedium!.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ), //f-size 16
      titleSmall: getTextStyle(fontType, base.titleSmall!), //f-size 14
      labelSmall: getTextStyle(fontType, base.labelSmall!), //f-size 10
    );
  }

// we also get some Light and Dark color variants
  static Color getColor(ColorType colordata) {
    switch (colordata) {
      case ColorType.verdigris:
        return isLightMode ? const Color(0xFF1d508d) : const Color(0xFF1d508d);
      case ColorType.malibu:
        return isLightMode ? const Color(0xFF5DCAEC) : const Color(0xFF5DCAEC);
      case ColorType.darkSkyBlue:
        return isLightMode ? const Color(0xFF458CEA) : const Color(0xFF458CEA);
      case ColorType.bilobaFlower:
        return isLightMode ? const Color(0xFFff5f5f) : const Color(0xFFff5f5f);
    }
  }

  static TextStyle getTextStyle(
      FontFamilyType fontFamilyType, TextStyle textStyle) {
    switch (fontFamilyType) {
      case FontFamilyType.montserrat:
        return GoogleFonts.montserrat(textStyle: textStyle);
      case FontFamilyType.workSans:
        return GoogleFonts.workSans(textStyle: textStyle);
      case FontFamilyType.varela:
        return GoogleFonts.varela(textStyle: textStyle);
      case FontFamilyType.satisfy:
        return GoogleFonts.satisfy(textStyle: textStyle);
      case FontFamilyType.dancingScript:
        return GoogleFonts.dancingScript(textStyle: textStyle);
      case FontFamilyType.kaushanScript:
        return GoogleFonts.kaushanScript(textStyle: textStyle);
      default:
        return GoogleFonts.roboto(textStyle: textStyle);
    }
  }

  static ThemeData _buildLightTheme() {
    final ColorScheme colorScheme = const ColorScheme.light().copyWith(
      primary: primaryColor,
      secondary: primaryColor,
      background: backgroundColor,
    );
    final ThemeData base = ThemeData.light();

    return base.copyWith(
      colorScheme: colorScheme,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: scaffoldBackgroundColor,
      dividerColor: dividerColor,
      dividerTheme: DividerThemeData(color: dividerColor),
      canvasColor: scaffoldBackgroundColor,
      buttonTheme: _buttonThemeData(colorScheme),
      dialogTheme: _dialogTheme(),
      cardTheme: _cardTheme(),
      textTheme: _buildTextTheme(base.textTheme),
      primaryTextTheme: _buildTextTheme(base.textTheme),
      platform: TargetPlatform.iOS,
      visualDensity: VisualDensity.adaptivePlatformDensity,
    );
  }
*/
  //
  // static ThemeData _buildDarkTheme() {
    // final ColorScheme colorScheme = const ColorScheme.dark().copyWith(
    //   primary: primaryColor,
    //   secondary: primaryColor,
    //   background: backgroundColor,
    // );
    // final ThemeData base = ThemeData.dark();
    //
    // return base.copyWith(
    //   colorScheme: colorScheme,
    //   primaryColor: primaryColor,
    //   scaffoldBackgroundColor: scaffoldBackgroundColor,
    //   dividerColor: dividerColor,
    //   dividerTheme: DividerThemeData(color: dividerColor),
    //   canvasColor: scaffoldBackgroundColor,
    //   buttonTheme: _buttonThemeData(colorScheme),
    //   dialogTheme: _dialogTheme(),
    //   cardTheme: _cardTheme(),
    //   textTheme: _buildTextTheme(base.textTheme),
    //   primaryTextTheme: _buildTextTheme(base.textTheme),
    //   platform: TargetPlatform.iOS,
    //   visualDensity: VisualDensity.adaptivePlatformDensity,
    // );
    /* final ColorScheme colorScheme = const ColorScheme.light().copyWith(
      primary: primaryColor,
      secondary: primaryColor,
      background: backgroundColor,
    );
    final ThemeData base = ThemeData.light();

    return base.copyWith(
      colorScheme: colorScheme,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: scaffoldBackgroundColor,
      dividerColor: dividerColor,
      dividerTheme: DividerThemeData(color: dividerColor),
      canvasColor: scaffoldBackgroundColor,
      buttonTheme: _buttonThemeData(colorScheme),
      dialogTheme: _dialogTheme(),
      cardTheme: _cardTheme(),
      textTheme: _buildTextTheme(base.textTheme),
      primaryTextTheme: _buildTextTheme(base.textTheme),
      platform: TargetPlatform.iOS,
      visualDensity: VisualDensity.adaptivePlatformDensity,
    );
  }

  static ButtonThemeData _buttonThemeData(ColorScheme colorScheme) {
    return ButtonThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      colorScheme: colorScheme,
      textTheme: ButtonTextTheme.primary,
    );
  }

  static DialogTheme _dialogTheme() {
    return DialogTheme(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      elevation: 0,
      backgroundColor: backgroundColor,
    );
  }

  static CardTheme _cardTheme() {
    return CardTheme(
      clipBehavior: Clip.antiAlias,
      color: backgroundColor,
      surfaceTintColor: Colors.transparent,
      shadowColor: secondaryTextColor.withOpacity(0.2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      elevation: 8,
      margin: const EdgeInsets.all(0),
    );
  }

  static get mapCardDecoration => BoxDecoration(
        color: AppTheme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.all(Radius.circular(24.0)),
        boxShadow: <BoxShadow>[
          BoxShadow(
              color: AppTheme.getThemeData.dividerColor,
              offset: const Offset(4, 4),
              blurRadius: 8.0),
        ],
      );
  static get buttonDecoration => BoxDecoration(
        color: AppTheme.primaryColor,
        borderRadius: const BorderRadius.all(Radius.circular(24.0)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppTheme.getThemeData.dividerColor,
            blurRadius: 8,
            offset: const Offset(4, 4),
          ),
        ],
      );
  static get searchBarDecoration => BoxDecoration(
        color: AppTheme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.all(Radius.circular(38)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppTheme.getThemeData.dividerColor,
            blurRadius: 8,
            // offset: Offset(4, 4),
          ),
        ],
      );

  static get boxDecoration => BoxDecoration(
        color: AppTheme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.all(Radius.circular(16.0)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppTheme.getThemeData.dividerColor,
            //   offset: Offset(2, 2),
            blurRadius: 8,
          ),
        ],
      );*/

}


