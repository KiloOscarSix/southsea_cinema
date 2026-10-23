import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:southsea_cinema/models/basket_item.dart';
import 'package:southsea_cinema/models/movie.dart';
import 'package:southsea_cinema/repositories/basket_repository.dart';
import 'package:southsea_cinema/views/basket_view.dart';

const Movie testMovie1 = Movie(
  id: 'test-movie-1',
  title: 'Test Movie One',
  year: 2024,
  description: 'A movie used for testing.',
  imagePath: 'assets/images/test_movie_1.jpg',
  genre: 'Drama',
  duration: 120,
  ageRating: 'PG',
  price: 6.0,
  screeningTime: '19:30',
);

const Movie testMovie2 = Movie(
  id: 'test-movie-2',
  title: 'Test Movie Two',
  year: 2024,
  description: 'Another movie used for testing.',
  imagePath: 'assets/images/test_movie_2.jpg',
  genre: 'Horror',
  duration: 90,
  ageRating: '15',
  price: 7.5,
  screeningTime: '21:00',
);

Future<void> pumpBasketView(WidgetTester tester) async {
  await tester.pumpWidget(const MaterialApp(home: BasketView()));
}

void main() {
  setUp(() {
    BasketRepository.instance.clear();
  });

  group('BasketView', () {
    testWidgets('shows empty message and no checkout button when empty',
        (WidgetTester tester) async {
      await pumpBasketView(tester);

      expect(find.text('My Basket'), findsOneWidget);
      expect(find.text('Your basket is empty'), findsOneWidget);
      expect(find.text('CHECKOUT'), findsNothing);
      expect(find.byIcon(Icons.delete), findsNothing);
    });

    testWidgets('displays line items and totals from the repository',
        (WidgetTester tester) async {
      BasketRepository.instance
          .addItem(const BasketItem(movie: testMovie1, quantity: 2));
      BasketRepository.instance
          .addItem(const BasketItem(movie: testMovie2, quantity: 1));

      await pumpBasketView(tester);

      expect(find.text('YOUR TICKETS'), findsOneWidget);
      expect(find.text('2 x Test Movie One'), findsOneWidget);
      expect(find.text('£12.00'), findsOneWidget);
      expect(find.text('1 x Test Movie Two'), findsOneWidget);
      expect(find.text('£7.50'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
      expect(find.text('£19.50'), findsOneWidget);
      expect(find.byIcon(Icons.delete), findsNWidgets(2));
      expect(find.text('CHECKOUT'), findsOneWidget);
      expect(find.text('Your basket is empty'), findsNothing);
    });

    testWidgets('removes the selected line and updates the totals',
        (WidgetTester tester) async {
      BasketRepository.instance
          .addItem(const BasketItem(movie: testMovie1, quantity: 2));
      BasketRepository.instance
          .addItem(const BasketItem(movie: testMovie2, quantity: 1));

      await pumpBasketView(tester);

      await tester.tap(find.byIcon(Icons.delete).first);
      await tester.pump();

      expect(find.text('2 x Test Movie One'), findsNothing);
      expect(find.text('1 x Test Movie Two'), findsOneWidget);
      expect(find.text('1'), findsOneWidget);
      expect(find.text('£7.50'), findsNWidgets(2));
      expect(BasketRepository.instance.getItems().length, 1);
    });

    testWidgets('shows empty state after removing the last line',
        (WidgetTester tester) async {
      BasketRepository.instance
          .addItem(const BasketItem(movie: testMovie1, quantity: 1));

      await pumpBasketView(tester);

      await tester.tap(find.byIcon(Icons.delete));
      await tester.pump();

      expect(find.text('Your basket is empty'), findsOneWidget);
      expect(find.text('CHECKOUT'), findsNothing);
      expect(BasketRepository.instance.getItems(), isEmpty);
    });

    testWidgets('checkout clears the basket and shows a confirmation',
        (WidgetTester tester) async {
      BasketRepository.instance
          .addItem(const BasketItem(movie: testMovie1, quantity: 2));
      BasketRepository.instance
          .addItem(const BasketItem(movie: testMovie2, quantity: 1));

      await pumpBasketView(tester);

      await tester.tap(find.text('CHECKOUT'));
      await tester.pump();

      expect(find.text('Your basket is empty'), findsOneWidget);
      expect(
          find.text('Thank you! Your order for 3 tickets has been received.'),
          findsOneWidget);
      expect(find.text('CHECKOUT'), findsNothing);
      expect(BasketRepository.instance.getItems(), isEmpty);
    });
  });
}
