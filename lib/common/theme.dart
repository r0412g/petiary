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
  static const colorsDarkGreen =
      Color.fromRGBO(63, 78, 64, 100.0); // Color(0xFF3F4E40);
  static const colorsBlackOfOpacity80 = Color.fromRGBO(0, 0, 0, 80.0);
  static const colorsWhite = Colors.white;
  static const colorsBlack = Colors.black;
}

class MyCardTheme {
  /* Use for cards on both sides */
  // For right
  static const ShapeBorder cardsForRightShapeBorder =
      const RoundedRectangleBorder(
    borderRadius: const BorderRadius.only(
        bottomLeft: const Radius.circular(10),
        topLeft: const Radius.circular(10)),
  );

  // For left
  static const ShapeBorder cardsForLeftShapeBorder =
      const RoundedRectangleBorder(
    borderRadius: const BorderRadius.only(
        bottomRight: const Radius.circular(10),
        topRight: const Radius.circular(10)),
  );
}

class MyDialogTheme {
  static const TextStyle dialogTitleStyle = const TextStyle(
    color: ColorSet.colorsDarkBlueGreenOfOpacity80,
    fontWeight: FontWeight.bold,
    letterSpacing: 2.0,
  );

  static const TextStyle dialogContentStyle = const TextStyle(
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
    backgroundColor: ColorSet.colorsWhite,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
  ),

  // Divider
  dividerTheme: const DividerThemeData(
    color: ColorSet.colorsBlackOfOpacity80,
    space: 1,
    thickness: 1.0,
  ),

  // Tooltip
  tooltipTheme: const TooltipThemeData(
    preferBelow: false,
  ),
);
