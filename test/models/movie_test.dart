import 'package:flutter_test/flutter_test.dart';
import 'package:southsea_cinema/models/movie.dart';

Movie createMovie({String ageRating = 'PG', double price = 8.5}) {
  return Movie(
    id: 'test-movie',
    title: 'Test Movie',
    year: 2024,
    description: 'A movie used for testing.',
    imagePath: 'assets/images/test_movie.jpg',
    genre: 'Drama',
    duration: 120,
    ageRating: ageRating,
    price: price,
    screeningTime: '19:30',
  );
}

void main() {
  group('Movie', () {
    test('formattedPrice shows a pound sign and two decimal places', () {
      expect(createMovie(price: 9.99).formattedPrice, '£9.99');
      expect(createMovie(price: 8).formattedPrice, '£8.00');
      expect(createMovie(price: 7.5).formattedPrice, '£7.50');
      expect(createMovie(price: 6.499).formattedPrice, '£6.50');
      expect(createMovie(price: 0).formattedPrice, '£0.00');
    });

    test('age rating getters match each rating', () {
      expect(createMovie(ageRating: 'U').isChildFriendly, isTrue);
      expect(createMovie(ageRating: 'U').isAdultOnly, isFalse);
      expect(createMovie(ageRating: 'PG').isChildFriendly, isTrue);
      expect(createMovie(ageRating: 'PG').isAdultOnly, isFalse);
      expect(createMovie(ageRating: '12A').isChildFriendly, isFalse);
      expect(createMovie(ageRating: '12A').isAdultOnly, isFalse);
      expect(createMovie(ageRating: '15').isChildFriendly, isFalse);
      expect(createMovie(ageRating: '15').isAdultOnly, isFalse);
      expect(createMovie(ageRating: '18').isChildFriendly, isFalse);
      expect(createMovie(ageRating: '18').isAdultOnly, isTrue);
    });

    test('fromJson reads every field and toJson returns the same map', () {
      final Map<String, dynamic> json = <String, dynamic>{
        'id': 'test-movie',
        'title': 'Test Movie',
        'year': 2024,
        'description': 'A movie used for testing.',
        'imagePath': 'assets/images/test_movie.jpg',
        'genre': 'Drama',
        'duration': 120,
        'ageRating': 'PG',
        'price': 8.5,
        'screeningTime': '19:30',
      };
      final Movie movie = Movie.fromJson(json);

      expect(movie.id, json['id']);
      expect(movie.title, json['title']);
      expect(movie.year, json['year']);
      expect(movie.description, json['description']);
      expect(movie.imagePath, json['imagePath']);
      expect(movie.genre, json['genre']);
      expect(movie.duration, json['duration']);
      expect(movie.ageRating, json['ageRating']);
      expect(movie.price, json['price']);
      expect(movie.screeningTime, json['screeningTime']);
      expect(movie.toJson(), json);

      // Check a whole-number price is converted to a double
      json['price'] = 7;
      final Movie wholePriceMovie = Movie.fromJson(json);

      expect(wholePriceMovie.price, isA<double>());
      expect(wholePriceMovie.price, 7.0);
      expect(wholePriceMovie.toJson()['price'], isA<double>());
    });
  });
}
