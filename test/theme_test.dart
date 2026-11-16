import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:southsea_cinema/constants.dart';
import 'package:southsea_cinema/theme.dart';

void main() {
  group('cinema themes', () {
    test('dark theme uses the dark palette', () {
      expect(cinemaDarkTheme.brightness, Brightness.dark);
      expect(cinemaDarkTheme.scaffoldBackgroundColor, cinemaBackground);
      expect(cinemaDarkTheme.colorScheme.surface, cinemaSurface);
      expect(cinemaDarkTheme.textTheme.titleLarge!.color, cinemaBrand);
    });

    test('light theme uses the light palette', () {
      expect(cinemaLightTheme.brightness, Brightness.light);
      expect(cinemaLightTheme.scaffoldBackgroundColor, cinemaLightBackground);
      expect(cinemaLightTheme.colorScheme.surface, cinemaLightSurface);
      expect(cinemaLightTheme.colorScheme.onSurface, cinemaFontDark);
      expect(cinemaLightTheme.appBarTheme.backgroundColor, cinemaLightSurface);
      expect(cinemaLightTheme.textTheme.titleLarge!.color, cinemaFontDark);
    });
  });
}
