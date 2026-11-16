import 'package:flutter/material.dart';
import 'package:southsea_cinema/constants.dart';

ThemeData buildCinemaTheme(Brightness brightness) {
  final bool isDark = brightness == Brightness.dark;
  final Color background = isDark ? cinemaBackground : cinemaLightBackground;
  final Color surface = isDark ? cinemaSurface : cinemaLightSurface;
  final Color foreground = isDark ? cinemaFontWhite : cinemaFontDark;
  final Color titleColour = isDark ? cinemaBrand : cinemaFontDark;

  final ThemeData base = ThemeData(
    brightness: brightness,
    scaffoldBackgroundColor: background,
    colorScheme: ColorScheme.fromSeed(
      seedColor: cinemaBrand,
      brightness: brightness,
      primary: cinemaBrand,
      surface: surface,
      onSurface: foreground,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: surface,
      foregroundColor: foreground,
      iconTheme: const IconThemeData(color: cinemaBrand),
      titleTextStyle: cinemaHeaderStyle.copyWith(color: foreground),
      elevation: 0,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: cinemaBrand,
        foregroundColor: cinemaFontWhite,
        textStyle: cinemaButtonStyle,
        shape: const RoundedRectangleBorder(),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: surface,
      contentTextStyle: cinemaBodyStyle.copyWith(color: foreground),
    ),
    inputDecorationTheme: const InputDecorationTheme(
      labelStyle: TextStyle(color: cinemaBrand),
      border: OutlineInputBorder(
        borderSide: BorderSide(color: cinemaBrand),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: cinemaBrand),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: cinemaBrandLight, width: 2),
      ),
    ),
  );

  return base.copyWith(
    textTheme: base.textTheme
        .apply(bodyColor: foreground, displayColor: foreground)
        .copyWith(titleLarge: cinemaTitleStyle.copyWith(color: titleColour)),
  );
}

final ThemeData cinemaDarkTheme = buildCinemaTheme(Brightness.dark);
final ThemeData cinemaLightTheme = buildCinemaTheme(Brightness.light);
