import 'package:flutter/material.dart';

class ColorSet {
  static const primaryColors = Color(0xFF455A64);
  static const primaryLightColors = Color(0xFF718792);
  static const secondaryColors = Color(0xFFD7CCC8);
  static const secondaryDarkColors = Color(0xFFA69B97);
  static const thirdColors = Color(0xFFC4C4C4);
}

class MyCardTheme {
  static ShapeBorder cardShapeBorder =
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0));
  static const EdgeInsetsGeometry cardMargin = EdgeInsets.all(35.0);
}

final appTheme = ThemeData(
  primaryColor: ColorSet.primaryColors,
  primaryColorLight: ColorSet.primaryLightColors,
  tooltipTheme: TooltipThemeData(
    preferBelow: false,
  ),
);
