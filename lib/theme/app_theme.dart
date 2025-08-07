import 'package:flutter/material.dart';

class AppTheme {
  static const primaryColor = Color(0xFF0F172A);
  static const secondaryColor = Color(0xFF64748B);
  static const backgroundColor = Color(0xFFF8FAFC);
  static const surfaceColor = Colors.white;
  static const errorColor = Color(0xFFDC2626);
  static const successColor = Color(0xFF16A34A);

  static final borderRadius = BorderRadius.circular(8);
  static const padding = EdgeInsets.all(16);

  static final elevatedButtonTheme = ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      shape: RoundedRectangleBorder(borderRadius: borderRadius),
    ),
  );

  static final inputDecorationTheme = InputDecorationTheme(
    filled: true,
    fillColor: surfaceColor,
    border: OutlineInputBorder(
      borderRadius: borderRadius,
      borderSide: BorderSide(color: secondaryColor.withOpacity(0.2)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: borderRadius,
      borderSide: BorderSide(color: secondaryColor.withOpacity(0.2)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: borderRadius,
      borderSide: BorderSide(color: primaryColor),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: borderRadius,
      borderSide: BorderSide(color: errorColor),
    ),
    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    labelStyle: TextStyle(color: secondaryColor),
  );

  static ThemeData get theme => ThemeData(
    primaryColor: primaryColor,
    scaffoldBackgroundColor: backgroundColor,
    elevatedButtonTheme: elevatedButtonTheme,
    inputDecorationTheme: inputDecorationTheme,
    cardTheme: CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: borderRadius,
        side: BorderSide(color: secondaryColor.withOpacity(0.2)),
      ),
      color: surfaceColor,
    ),
    tabBarTheme: TabBarThemeData(
      labelColor: primaryColor,
      unselectedLabelColor: secondaryColor,
      indicatorSize: TabBarIndicatorSize.tab,
      indicator: UnderlineTabIndicator(
        borderSide: BorderSide(width: 2, color: primaryColor),
      ),
    ),
  );
}
