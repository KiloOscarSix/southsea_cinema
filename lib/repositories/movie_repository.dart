import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:southsea_cinema/models/movie.dart';

class MovieRepository {
  // TODO: Reevaluate this name once the const list in getMovies is removed
  List<Movie>? _jsonMovies;

  List<Movie> getMovies() {
    final List<Movie>? jsonMovies = _jsonMovies;
    if (jsonMovies != null) {
      return jsonMovies;
    }

    return const [
      Movie(
          id: "dracula",
          title: "Dracula",
          year: 1931,
          description:
              "The dashing, mysterious Count Dracula (Bela Lugosi) travels to London and takes up residence in an old castle. Soon he begins to wreak havoc, sucking the blood of young women and turning them into vampires. Van Helsing is enlisted to put a stop to the count's never-ending bloodlust.",
          imagePath: "assets/images/dracula.jpg",
          genre: "Dark Fantasy",
          duration: 74,
          ageRating: "PG",
          price: 6.00,
          screeningTime: "19:30"),
      Movie(
          id: "phantom-of-the-opera",
          title: "The Phantom of the Opera",
          year: 1925,
          description:
              "The deformed Phantom who haunts the Paris Opera House causes murder and mayhem in an attempt to make the woman he loves a star.",
          imagePath: "assets/images/phantom-of-the-opera.jpg",
          genre: "Horror",
          duration: 101,
          ageRating: "12A",
          price: 7.50,
          screeningTime: "21:00")
    ];
  }

  Movie? getMovieById(String id) {
    for (final movie in getMovies()) {
      if (movie.id == id) return movie;
    }

    return null;
  }

  Future<List<Movie>> loadMoviesFromAsset({
    String assetPath = 'assets/data/movies.json',
  }) async {
    final String jsonString = await rootBundle.loadString(assetPath);
    final dynamic decodedData = jsonDecode(jsonString);
    final List<dynamic> jsonList = decodedData as List<dynamic>;
    final List<Movie> loadedMovies = [];

    for (final dynamic item in jsonList) {
      final Map<String, dynamic> itemMap = item as Map<String, dynamic>;
      final Movie movie = Movie.fromJson(itemMap);
      loadedMovies.add(movie);
    }

    _jsonMovies = loadedMovies;
    return loadedMovies;
  }

  List<Movie> getMoviesByAgeRating(String rating) {
    final List<Movie> matches = [];
    for (final movie in getMovies()) {
      if (movie.ageRating == rating) matches.add(movie);
    }

    return matches;
  }

  List<Movie> getMoviesUnderPrice(double maxPrice) {
    final List<Movie> matches = [];
    for (final movie in getMovies()) {
      if (movie.price <= maxPrice) matches.add(movie);
    }

    return matches;
  }
}
