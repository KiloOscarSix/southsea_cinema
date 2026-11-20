import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:southsea_cinema/constants.dart';
import 'package:southsea_cinema/theme.dart';
import 'package:southsea_cinema/views/basket_view.dart';
import 'package:southsea_cinema/views/home_view.dart';
import 'package:southsea_cinema/views/settings_view.dart';
// import 'package:southsea_cinema/views/movie_listing.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

void main() {
  if (kIsWeb) {
    databaseFactory = databaseFactoryFfiWeb;
  }

  runApp(const SouthseaCinemaApp());
}

class SouthseaCinemaApp extends StatefulWidget {
  const SouthseaCinemaApp({super.key});

  @override
  State<SouthseaCinemaApp> createState() => _SouthseaCinemaAppState();
}

class _SouthseaCinemaAppState extends State<SouthseaCinemaApp> {
  ThemeMode _themeMode = ThemeMode.dark;

  @override
  void initState() {
    super.initState();
    _loadThemeMode();
  }

  Future<void> _loadThemeMode() async {
    final SharedPreferencesAsync prefs = SharedPreferencesAsync();
    final bool? savedDarkMode = await prefs.getBool(prefDarkMode);
    bool darkMode = true;
    if (savedDarkMode != null) {
      darkMode = savedDarkMode;
    }
    if (!mounted) return;

    setState(() {
      _themeMode = darkMode ? ThemeMode.dark : ThemeMode.light;
    });
  }

  void _setThemeMode(ThemeMode themeMode) {
    setState(() {
      _themeMode = themeMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: appTitle,
      debugShowCheckedModeBanner: false,
      theme: cinemaLightTheme,
      darkTheme: cinemaDarkTheme,
      themeMode: _themeMode,
      initialRoute: '/',
      routes: {
        '/': (BuildContext context) {
          return const HomeView();
        },
        '/basket': (BuildContext context) {
          return const BasketView();
        },
        '/settings': (BuildContext context) {
          return SettingsView(onThemeModeChanged: _setThemeMode);
        },
        // '/listing': (BuildContext context) {
        //   return const MovieListing();
        // },
      },
    );
  }
}
