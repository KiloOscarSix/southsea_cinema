import 'package:flutter/material.dart';
import 'package:southsea_cinema/constants.dart';
import 'package:southsea_cinema/views/home_view.dart';
import 'package:southsea_cinema/views/movie_listing.dart';

void main() {
  runApp(const SouthseaCinemaApp());
}

class SouthseaCinemaApp extends StatelessWidget {
  const SouthseaCinemaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: appTitle,
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: cinemaBackground,
        colorScheme: ColorScheme.fromSeed(
          seedColor: cinemaBrand,
          primary: cinemaBrand,
          surface: cinemaSurface,
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: cinemaBrand,
            foregroundColor: cinemaFontWhite,
            textStyle: cinemaButtonStyle,
            shape: const RoundedRectangleBorder(),
          ),
        ),
        snackBarTheme: const SnackBarThemeData(
          backgroundColor: cinemaSurface,
          contentTextStyle: cinemaBodyStyle,
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
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeView(),
        '/listing': (context) => const MovieListing(),
      },
    );
  }
}
