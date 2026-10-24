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
  group('Movie model tests', () {
    test('creates Movie instance with given properties', () {
      final movie = createMovie();

      expect(movie.id, 'test-movie');
      expect(movie.title, 'Test Movie');
      expect(movie.year, 2024);
      expect(movie.description, 'A movie used for testing.');
      expect(movie.imagePath, 'assets/images/test_movie.jpg');
      expect(movie.genre, 'Drama');
      expect(movie.duration, 120);
      expect(movie.ageRating, 'PG');
      expect(movie.price, 8.5);
      expect(movie.screeningTime, '19:30');
    });
  });

  group('formattedPrice', () {
    test('formats price with pound sign and two decimal places', () {
      expect(createMovie(price: 9.99).formattedPrice, '£9.99');
    });

    test('pads whole number prices with two zeros', () {
      expect(createMovie(price: 8).formattedPrice, '£8.00');
    });

    test('pads prices with one decimal place', () {
      expect(createMovie(price: 7.5).formattedPrice, '£7.50');
    });

    test('rounds prices with more than two decimal places', () {
      expect(createMovie(price: 6.499).formattedPrice, '£6.50');
    });

    test('formats a zero price', () {
      expect(createMovie(price: 0).formattedPrice, '£0.00');
    });
  });

  group('isChildFriendly', () {
    test('returns true for U rating', () {
      expect(createMovie(ageRating: 'U').isChildFriendly, isTrue);
    });

    test('returns true for PG rating', () {
      expect(createMovie(ageRating: 'PG').isChildFriendly, isTrue);
    });

    test('returns false for 12A rating', () {
      expect(createMovie(ageRating: '12A').isChildFriendly, isFalse);
    });

    test('returns false for 15 rating', () {
      expect(createMovie(ageRating: '15').isChildFriendly, isFalse);
    });

    test('returns false for 18 rating', () {
      expect(createMovie(ageRating: '18').isChildFriendly, isFalse);
    });
  });

  group('isAdultOnly', () {
    test('returns true for 18 rating', () {
      expect(createMovie(ageRating: '18').isAdultOnly, isTrue);
    });

    test('returns false for U rating', () {
      expect(createMovie(ageRating: 'U').isAdultOnly, isFalse);
    });

    test('returns false for PG rating', () {
      expect(createMovie(ageRating: 'PG').isAdultOnly, isFalse);
    });

    test('returns false for 12A rating', () {
      expect(createMovie(ageRating: '12A').isAdultOnly, isFalse);
    });

    test('returns false for 15 rating', () {
      expect(createMovie(ageRating: '15').isAdultOnly, isFalse);
    });
  });

  group('JSON conversion', () {
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
    });

    test('fromJson converts a whole-number price to a double', () {
      final Map<String, dynamic> json = <String, dynamic>{
        'id': 'test-movie',
        'title': 'Test Movie',
        'year': 2024,
        'description': 'A movie used for testing.',
        'imagePath': 'assets/images/test_movie.jpg',
        'genre': 'Drama',
        'duration': 120,
        'ageRating': 'PG',
        'price': 7,
        'screeningTime': '19:30',
      };
      final Movie movie = Movie.fromJson(json);

      expect(movie.price, isA<double>());
      expect(movie.price, 7.0);
      expect(movie.toJson()['price'], isA<double>());
    });
  });
}
