import 'package:flutter_test/flutter_test.dart';
import 'package:southsea_cinema/models/basket_item.dart';
import 'package:southsea_cinema/models/movie.dart';
import 'package:southsea_cinema/repositories/basket_repository.dart';

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

void main() {
  setUp(() {
    BasketRepository.instance.clear();
  });

  group('BasketRepository', () {
    test('adds, removes and clears tickets while keeping the totals right', () {
      final BasketRepository basket = BasketRepository.instance;
      expect(basket.getItems(), isEmpty);
      expect(basket.getTotalTickets(), 0);
      expect(basket.getTotal(), 0.0);

      basket.addItem(const BasketItem(movie: testMovie1, quantity: 2));
      basket.addItem(const BasketItem(movie: testMovie2, quantity: 3));

      expect(basket.getItems().length, 2);
      expect(basket.getItems()[0].movie.id, 'test-movie-1');
      expect(basket.getItems()[1].movie.id, 'test-movie-2');
      expect(basket.getItems()[1].lineTotal, 22.5);
      expect(basket.getTotalTickets(), 5);
      expect(basket.getTotal(), 34.5);

      // Ensure returned items cannot be modified from outside
      final List<BasketItem> items = basket.getItems();
      expect(() => items.add(const BasketItem(movie: testMovie1, quantity: 1)),
          throwsUnsupportedError);
      expect(basket.getItems().length, 2);

      // Check out-of-range indexes are ignored
      basket.removeItem(-1);
      basket.removeItem(2);
      expect(basket.getItems().length, 2);

      basket.removeItem(0);
      expect(basket.getItems().length, 1);
      expect(basket.getItems()[0].movie.id, 'test-movie-2');
      expect(basket.getTotalTickets(), 3);
      expect(basket.getTotal(), 22.5);

      basket.clear();
      expect(basket.getItems(), isEmpty);
      expect(basket.getTotalTickets(), 0);
      expect(basket.getTotal(), 0.0);
    });
  });
}
