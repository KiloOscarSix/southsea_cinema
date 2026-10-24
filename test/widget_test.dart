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
    testWidgets(
        'loads films from the JSON asset, books two, removes one and checks out',
        (WidgetTester tester) async {
      await tester.pumpWidget(const SouthseaCinemaApp());

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byType(MovieCard), findsNothing);

      await tester.pumpAndSettle();

      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.byType(MovieCard), findsWidgets);
      expect(find.byType(HomeView), findsOneWidget);
      expect(find.text(appTitle), findsOneWidget);
      expect(find.text('DRACULA'), findsOneWidget);
      expect(find.text('BOOK NOW'), findsWidgets);

      await tester.tap(find.text('BOOK NOW').first);
      await tester.pumpAndSettle();

      expect(find.byType(MovieListing), findsOneWidget);
      expect(find.byType(HomeView), findsNothing);
      expect(find.text('DRACULA (1931)'), findsOneWidget);
      expect(find.text('(PG)'), findsOneWidget);
      expect(find.text('19:30'), findsOneWidget);
      expect(find.text('£6.00'), findsOneWidget);
      expect(
          find.text('2 tickets for Dracula added to your order'), findsNothing);

      await tester.tap(find.byType(DropdownMenu<int>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('2').last);
      await tester.pumpAndSettle();
      await tester.tap(find.text('ADD TO ORDER'));
      await tester.pump();

      expect(find.text('2 tickets for Dracula added to your order'),
          findsOneWidget);

      await tester.tap(find.byTooltip('Open navigation menu'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Home'));
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(
          find.text('THE PHANTOM OF THE OPERA'), 200);
      expect(find.text('THE PHANTOM OF THE OPERA'), findsOneWidget);
      await tester.ensureVisible(find.text('BOOK NOW').last);
      await tester.pumpAndSettle();
      await tester.tap(find.text('BOOK NOW').last);
      await tester.pumpAndSettle();

      expect(find.text('THE PHANTOM OF THE OPERA (1925)'), findsOneWidget);

      await tester.tap(find.text('ADD TO ORDER'));
      await tester.pump();

      expect(
          find.text(
              '1 ticket for The Phantom of the Opera added to your order'),
          findsOneWidget);
      expect(BasketRepository.instance.getTotalTickets(), 3);
      expect(BasketRepository.instance.getItems()[0].movie.id, 'dracula');

      await tester.tap(find.byTooltip('Open navigation menu'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('My Basket'));
      await tester.pumpAndSettle();

      expect(find.text('YOUR TICKETS'), findsOneWidget);
      expect(find.text('2 x Dracula'), findsOneWidget);
      expect(find.text('£12.00'), findsOneWidget);
      expect(find.text('1 x The Phantom of the Opera'), findsOneWidget);
      expect(find.text('£7.50'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
      expect(find.text('£19.50'), findsOneWidget);
      expect(find.byIcon(Icons.delete), findsNWidgets(2));

      await tester.tap(find.byIcon(Icons.delete).last);
      await tester.pump();

      expect(find.text('1 x The Phantom of the Opera'), findsNothing);
      expect(find.text('2 x Dracula'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
      expect(find.text('£12.00'), findsNWidgets(2));
      expect(BasketRepository.instance.getItems().length, 1);

      await tester.tap(find.text('CHECKOUT'));
      await tester.pump();

      expect(find.text('Your order for 2 tickets has been received.'),
          findsOneWidget);
      expect(find.text('Your basket is empty'), findsOneWidget);
      expect(find.text('CHECKOUT'), findsNothing);
      expect(BasketRepository.instance.getItems(), isEmpty);
    });
  });
}
