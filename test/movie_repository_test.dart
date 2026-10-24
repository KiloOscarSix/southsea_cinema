import 'package:flutter_test/flutter_test.dart';
import 'package:southsea_cinema/models/movie.dart';
import 'package:southsea_cinema/repositories/movie_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('getMovies', () {
    test('returns at least two movies', () {
      final movies = MovieRepository().getMovies();
      expect(movies.length >= 2, isTrue);
    });

    test('each movie has a non-empty id, title and age rating', () {
      for (final movie in MovieRepository().getMovies()) {
        expect(movie.id, isNotEmpty);
        expect(movie.title, isNotEmpty);
        expect(movie.ageRating, isNotEmpty);
      }
    });

    test('each movie has a ticket price greater than zero', () {
      for (final movie in MovieRepository().getMovies()) {
        expect(movie.price > 0, isTrue);
      }
    });

    test('each movie has a unique id', () {
      final movies = MovieRepository().getMovies();
      for (int i = 0; i < movies.length; i++) {
        for (int j = i + 1; j < movies.length; j++) {
          expect(movies[i].id == movies[j].id, isFalse);
        }
      }
    });
  });

  group('getMovieById', () {
    test('returns match when id exists', () {
      final Movie? movie = MovieRepository().getMovieById('dracula');
      expect(movie, isNotNull);
      expect(movie?.id, 'dracula');
      expect(movie?.title, 'Dracula');
      expect(movie?.price, 6.00);
    });

    test('returns null when id does not exist', () {
      final repo = MovieRepository();
      expect(repo.getMovieById('non-existent'), isNull);
    });
  });

  group('getMoviesByAgeRating', () {
    test('returns only movies with the given age rating', () {
      final movies = MovieRepository().getMoviesByAgeRating('PG');
      expect(movies.length, 1);
      expect(movies[0].id, 'dracula');
      for (final movie in movies) {
        expect(movie.ageRating, 'PG');
      }
    });

    test('returns an empty list when no movie has the age rating', () {
      final movies = MovieRepository().getMoviesByAgeRating('18');
      expect(movies, isEmpty);
    });
  });

  group('getMoviesUnderPrice', () {
    test('returns only movies at or below the maximum price', () {
      final movies = MovieRepository().getMoviesUnderPrice(7.00);
      expect(movies.length, 1);
      expect(movies[0].id, 'dracula');
      for (final movie in movies) {
        expect(movie.price <= 7.00, isTrue);
      }
    });

    test('returns all movies when the maximum price is high enough', () {
      final repo = MovieRepository();
      expect(repo.getMoviesUnderPrice(100.00).length, repo.getMovies().length);
    });

    test('returns an empty list when every movie costs more', () {
      final movies = MovieRepository().getMoviesUnderPrice(1.00);
      expect(movies, isEmpty);
    });
  });

  group('loadMoviesFromAsset', () {
    test('reads every movie from the bundled JSON file', () async {
      final MovieRepository repository = MovieRepository();
      final List<Movie> movies = await repository.loadMoviesFromAsset();

      expect(movies.length, 2);
      expect(movies[0].id, 'dracula');
      expect(movies[0].title, 'Dracula');
      expect(movies[0].year, 1931);
      expect(movies[0].genre, 'Dark Fantasy');
      expect(movies[0].duration, 74);
      expect(movies[0].ageRating, 'PG');
      expect(movies[0].price, 6.00);
      expect(movies[0].screeningTime, '19:30');
      expect(movies[0].imagePath, 'assets/images/dracula.jpg');
      expect(movies[1].id, 'phantom-of-the-opera');
      expect(movies[1].title, 'The Phantom of the Opera');
      expect(movies[1].year, 1925);
      expect(movies[1].genre, 'Horror');
      expect(movies[1].duration, 101);
      expect(movies[1].ageRating, '12A');
      expect(movies[1].price, 7.50);
      expect(movies[1].screeningTime, '21:00');
      expect(movies[1].imagePath, 'assets/images/phantom-of-the-opera.jpg');
      expect(repository.getMovies(), movies);
    });

    test('matches the fixed movie list', () async {
      final MovieRepository repository = MovieRepository();
      final List<Movie> fixed = repository.getMovies();
      final List<Movie> loaded = await repository.loadMoviesFromAsset();

      expect(loaded.length, fixed.length);
      for (int i = 0; i < fixed.length; i++) {
        expect(loaded[i].toJson(), fixed[i].toJson());
      }
    });
  });
}
