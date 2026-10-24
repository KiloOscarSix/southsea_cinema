import 'package:flutter_test/flutter_test.dart';
import 'package:southsea_cinema/models/movie.dart';
import 'package:southsea_cinema/repositories/movie_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('MovieRepository', () {
    test('returns no movies before loading', () {
      final MovieRepository repository = MovieRepository();

      expect(repository.getMovies(), isEmpty);
      expect(repository.getMovieById('dracula'), isNull);
    });

    test('loads every movie from the bundled JSON and looks them up', () async {
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

      // getMovieById
      expect(repository.getMovieById('dracula')?.title, 'Dracula');
      expect(repository.getMovieById('non-existent'), isNull);

      // getMoviesByAgeRating
      final List<Movie> pgMovies = repository.getMoviesByAgeRating('PG');
      expect(pgMovies.length, 1);
      expect(pgMovies[0].id, 'dracula');
      expect(repository.getMoviesByAgeRating('18'), isEmpty);

      // getMoviesUnderPrice (inclusive)
      final List<Movie> cheapMovies = repository.getMoviesUnderPrice(6.00);
      expect(cheapMovies.length, 1);
      expect(cheapMovies[0].id, 'dracula');
      expect(repository.getMoviesUnderPrice(100.00).length, 2);
      expect(repository.getMoviesUnderPrice(1.00), isEmpty);
    });
  });
}
