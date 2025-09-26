import 'package:flutter/material.dart';

class AppStyle {
  // COLOR

  //  Brand
  // ignore: non_constant_identifier_names
  static Color PRIMERYCOLOR = const Color.fromARGB(255, 96, 114, 252);

  // Gray color
  // ignore: non_constant_identifier_names
  static Color GRAY_0 = const Color.fromARGB(255, 0, 0, 0);
  // ignore: non_constant_identifier_names
  static Color GRAY_50 = const Color(0xFF202020);
  // ignore: non_constant_identifier_names
  static Color GRAY_100 = const Color(0xFF2A2A2A);
  // ignore: non_constant_identifier_names
  static Color GRAY_200 = const Color(0xFF3B3A3A);
  // ignore: non_constant_identifier_names
  static Color GRAY_500 = const Color(0xFF7C7C7C);
  // ignore: non_constant_identifier_names
  static Color GRAY_600 = const Color(0xFFAFAFAF);
  // ignore: non_constant_identifier_names
  static Color GRAY_700 = const Color(0xFFDFDFDF);
  // ignore: non_constant_identifier_names
  static Color GRAY_800 = const Color(0xFFE9E9E9);
  // ignore: non_constant_identifier_names
  static Color GRAY_900 = const Color(0xFFF5F5F5);
  // ignore: non_constant_identifier_names
  static Color WHITE = const Color(0xFFFFFFFF);
  // ignore: non_constant_identifier_names

  // Info
  // ignore: non_constant_identifier_names
  static Color ERROR = const Color(0xFFFC6075);

  // RADIUS
  // ignore: non_constant_identifier_names
  static double RADIUS_SM = 4;
  // ignore: non_constant_identifier_names
  static double RADIUS_MD = 8;
  // ignore: non_constant_identifier_names
  static double RADIUS_LG = 16;
  // ignore: non_constant_identifier_names
  static double RADIUS_XL = 24;
  // ignore: non_constant_identifier_names
  static double RADIUS_2XL = 32;
  // ignore: non_constant_identifier_names
  static double RADIUS_3XL = 64;
  // ignore: non_constant_identifier_names
  static double RADIUS_4XL = 128;

  // SPACING
  // ignore: non_constant_identifier_names
  static double SPACING_NONE = 0;
  // ignore: non_constant_identifier_names
  static double SPACING_XXS = 2;
  // ignore: non_constant_identifier_names
  static double SPACING_XS = 4;
  // ignore: non_constant_identifier_names
  static double SPACING_SM = 8;
  // ignore: non_constant_identifier_names
  static double SPACING_LG = 16;

  // ignore: non_constant_identifier_names
  static double SPACING_XL = 24;
  // ignore: non_constant_identifier_names
  static double SPACING_2XL = 32;
// ignore: non_constant_identifier_names
  static double SPACING_3XL = 64;
  // ignore: non_constant_identifier_names
  static double SPACING_5XL = 96;
  // ignore: non_constant_identifier_names
  static double SPACING_6XL = 128;

  // Icons size
  // ignore: non_constant_identifier_names
  static double ICON_SM = 4;
  // ignore: non_constant_identifier_names
  static double ICON_SML = 12;
  // ignore: non_constant_identifier_names
  static double ICON_NORMAL = 16;
  // ignore: non_constant_identifier_names
  static double ICON_NX = 20;
  // ignore: non_constant_identifier_names
  static double ICON_LARG = 24;
  // ignore: non_constant_identifier_names
  static double ICON_XL = 32;
  // ignore: non_constant_identifier_names
  static double ICON_2XL = 40;

  ThemeData darkTheme(BuildContext context) {
    return ThemeData(
      scaffoldBackgroundColor: GRAY_0,
      disabledColor: GRAY_100,
      inputDecorationTheme: const InputDecorationTheme(
        isDense: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(10),
          ),
          gapPadding: 4,
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: GRAY_100,
      ),
      textTheme: TextTheme(
        displayLarge: TextStyle(
          color: GRAY_900,
          height: 1.5,
          fontSize: 24,
        ),
        displayMedium: TextStyle(
          color: GRAY_900,
          height: 1.5,
          fontSize: 20,
        ),
        displaySmall: TextStyle(
          color: GRAY_900,
          height: 1.5,
          fontSize: 18,
        ),
        bodyLarge: TextStyle(
          color: GRAY_900,
          height: 1.5,
          fontSize: 16,
        ),
        bodyMedium: TextStyle(
          color: GRAY_900,
          height: 1.5,
          fontSize: 14,
        ),
        bodySmall: TextStyle(
          fontSize: 14,
          color: GRAY_600,
          height: 1.5,
        ),
      ),
      cardColor: GRAY_50,
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: PRIMERYCOLOR,
      unselectedWidgetColor: Colors.transparent,
      fontFamily: "montserrat",
    );
  }

  ThemeData lightTheme(BuildContext context) {
    return ThemeData(
      scaffoldBackgroundColor: GRAY_900,
      disabledColor: GRAY_800,
      cardColor: WHITE,
      inputDecorationTheme: const InputDecorationTheme(
        isDense: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(10),
          ),
          gapPadding: 4,
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: WHITE,
      ),
      textTheme: TextTheme(
        displayLarge: TextStyle(
          color: GRAY_50,
          height: 1.5,
          fontSize: 24,
        ),
        displayMedium: TextStyle(
          color: GRAY_50,
          height: 1.5,
          fontSize: 20,
        ),
        displaySmall: TextStyle(
          color: GRAY_50,
          height: 1.5,
          fontSize: 18,
        ),
        bodyLarge: TextStyle(
          color: GRAY_50,
          height: 1.5,
          fontSize: 16,
        ),
        bodyMedium: TextStyle(
          color: GRAY_50,
          height: 1.5,
          fontSize: 14,
        ),
        bodySmall: TextStyle(
          fontSize: 14,
          color: GRAY_500,
          height: 1.5,
        ),
      ),
      fontFamily: "montserrat",
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: PRIMERYCOLOR,
    );
  }
}