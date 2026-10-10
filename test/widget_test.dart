import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:southsea_cinema/constants.dart';
import 'package:southsea_cinema/main.dart';
import 'package:southsea_cinema/views/home_view.dart';

void main() {
  group('SouthseaCinemaApp', () {
    testWidgets('displays home page with title, movies and booking buttons',
        (WidgetTester tester) async {
      await tester.pumpWidget(const SouthseaCinemaApp());
      await tester.pumpAndSettle();

      expect(find.byType(HomeView), findsOneWidget);
      expect(find.text(appTitle), findsOneWidget);
      expect(find.text('DRACULA'), findsOneWidget);
      expect(find.text('THE PHANTOM OF THE OPERA'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsNWidgets(2));
      expect(find.text('BOOK NOW'), findsNWidgets(2));
    });
  });
}
