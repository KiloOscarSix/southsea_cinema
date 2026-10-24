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

Future<void> pumpBasketView(WidgetTester tester) async {
  await tester.pumpWidget(const MaterialApp(home: BasketView()));
}

void main() {
  setUp(() {
    BasketRepository.instance.clear();
  });

  group('BasketView', () {
    testWidgets('shows a ticket line, then the empty state after removing it',
        (WidgetTester tester) async {
      BasketRepository.instance
          .addItem(const BasketItem(movie: testMovie1, quantity: 1));

      await pumpBasketView(tester);

      expect(find.text('My Basket'), findsOneWidget);
      expect(find.text('1 x Test Movie One'), findsOneWidget);
      expect(find.text('CHECKOUT'), findsOneWidget);
      expect(find.text('Your basket is empty'), findsNothing);

      await tester.tap(find.byIcon(Icons.delete));
      await tester.pump();

      expect(find.text('1 x Test Movie One'), findsNothing);
      expect(find.text('Your basket is empty'), findsOneWidget);
      expect(find.text('CHECKOUT'), findsNothing);
      expect(find.byIcon(Icons.delete), findsNothing);
      expect(BasketRepository.instance.getItems(), isEmpty);
    });
  });
}
