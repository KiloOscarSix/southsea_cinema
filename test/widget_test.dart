import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:southsea_cinema/constants.dart';
import 'package:southsea_cinema/main.dart';
import 'package:southsea_cinema/repositories/basket_repository.dart';
import 'package:southsea_cinema/views/home_view.dart';
import 'package:southsea_cinema/views/movie_listing.dart';
import 'package:southsea_cinema/widgets/movie_card.dart';

void main() {
  setUp(() {
    rootBundle.clear();
    BasketRepository.instance.clear();
  });

  group('SouthseaCinemaApp', () {
    testWidgets('shows a loading indicator until the movies load',
        (WidgetTester tester) async {
      await tester.pumpWidget(const SouthseaCinemaApp());

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byType(MovieCard), findsNothing);

      await tester.pumpAndSettle();

      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.byType(MovieCard), findsWidgets);
    });

    testWidgets('displays home page with title, movies and booking buttons',
        (WidgetTester tester) async {
      await tester.pumpWidget(const SouthseaCinemaApp());
      await tester.pumpAndSettle();

      expect(find.byType(HomeView), findsOneWidget);
      expect(find.text(appTitle), findsOneWidget);
      expect(find.text('DRACULA'), findsOneWidget);
      expect(find.text('BOOK NOW'), findsWidgets);

      await tester.scrollUntilVisible(
          find.text('THE PHANTOM OF THE OPERA'), 200);

      expect(find.text('THE PHANTOM OF THE OPERA'), findsOneWidget);
    });

    testWidgets('navigates from home page to movie listing and adds to order',
        (WidgetTester tester) async {
      await tester.pumpWidget(const SouthseaCinemaApp());
      await tester.pumpAndSettle();

      await tester.tap(find.text('BOOK NOW').first);
      await tester.pumpAndSettle();

      expect(find.byType(MovieListing), findsOneWidget);
      expect(find.byType(HomeView), findsNothing);
      expect(find.text('DRACULA (1931)'), findsOneWidget);
      expect(find.text('(PG)'), findsOneWidget);
      expect(find.text('19:30'), findsOneWidget);
      expect(find.text('£6.00'), findsOneWidget);
      expect(find.text('ADD TO ORDER'), findsOneWidget);
      expect(
          find.text('1 ticket for Dracula added to your order'), findsNothing);

      await tester.tap(find.text('ADD TO ORDER'));
      await tester.pump();

      expect(find.text('1 ticket for Dracula added to your order'),
          findsOneWidget);
      expect(BasketRepository.instance.getTotalTickets(), 1);
      expect(BasketRepository.instance.getItems()[0].movie.id, 'dracula');
    });
  });
}
