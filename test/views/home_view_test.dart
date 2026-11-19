import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:southsea_cinema/constants.dart';
import 'package:southsea_cinema/views/home_view.dart';
import 'package:southsea_cinema/widgets/movie_card.dart';

void main() {
  setUp(() {
    rootBundle.clear();
  });

  group('HomeView', () {
    testWidgets('shows a spinner, then one card per film in the JSON asset',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: HomeView()));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byType(MovieCard), findsNothing);

      await tester.pumpAndSettle();

      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.text(appTitle), findsOneWidget);
      expect(find.text('DRACULA'), findsOneWidget);
      expect(find.textContaining('Could not load the films'), findsNothing);
    });

    testWidgets('shows an error message when the films cannot be loaded',
        (WidgetTester tester) async {
      tester.binding.defaultBinaryMessenger
          .setMockMessageHandler('flutter/assets', (ByteData? message) async {
        return null;
      });
      addTearDown(() {
        tester.binding.defaultBinaryMessenger
            .setMockMessageHandler('flutter/assets', null);
      });

      await tester.pumpWidget(const MaterialApp(home: HomeView()));
      await tester.pumpAndSettle();

      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.byType(MovieCard), findsNothing);
      expect(
        find.textContaining('Could not load the films: Unable to load asset: '
            '"assets/data/movies.json"'),
        findsOneWidget,
      );
    });
  });
}
