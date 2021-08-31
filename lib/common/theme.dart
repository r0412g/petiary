import 'package:flutter/material.dart';

class ColorSet {
  static const primaryColorsGreenOfOpacity80 =
      Color.fromRGBO(145, 200, 146, 80.0); // Color(0xFF91C892);
  static const colorsWhiteGrayOfOpacity80 =
      Color.fromRGBO(226, 226, 226, 80.0); // Color(0xFFE2E2E2);
  static const colorsDarkBlueGreenOfOpacity80 =
      Color.fromRGBO(85, 116, 121, 80.0); // Color(0xFF557479);
  static const colorsGrayOfOpacity80 =
      Color.fromRGBO(186, 186, 186, 80.0); // Color(0xFFBABABA);
  static const colorsBlackOfOpacity80 = Color.fromRGBO(0, 0, 0, 80.0);
  static const colorsWhite = Colors.white;
}

class MyCardTheme {
  /* Use for cards on both sides */
  // For right
  static ShapeBorder cardsForRightShapeBorder = RoundedRectangleBorder(
    borderRadius: BorderRadius.only(
        bottomLeft: Radius.circular(10), topLeft: Radius.circular(10)),
  );

  // For left
  static ShapeBorder cardsForLeftShapeBorder = RoundedRectangleBorder(
    borderRadius: BorderRadius.only(
        bottomRight: Radius.circular(10), topRight: Radius.circular(10)),
  );
}

class MyDialogTheme {
  static TextStyle dialogTitleStyle = TextStyle(
    color: ColorSet.colorsDarkBlueGreenOfOpacity80,
    fontWeight: FontWeight.bold,
    letterSpacing: 2.0,
  );

  static TextStyle dialogContentStyle = TextStyle(
    color: ColorSet.colorsBlackOfOpacity80,
  );
}

class ForAllTheme {
  static BorderRadius allRadius = BorderRadius.circular(10.0);
}

final appTheme = ThemeData(
  // Card
  cardTheme: CardTheme(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
  ),

  // Dialog
  dialogTheme: DialogTheme(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
  ),

  // Divider
  dividerTheme: DividerThemeData(
    color: ColorSet.colorsBlackOfOpacity80,
    space: 1,
    thickness: 1.0,
  ),

  // Tooltip
  tooltipTheme: TooltipThemeData(
    preferBelow: false,
  ),
);
