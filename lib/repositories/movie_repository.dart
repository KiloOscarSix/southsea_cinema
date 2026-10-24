import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:southsea_cinema/models/movie.dart';

class MovieRepository {
  List<Movie>? _movies;

  List<Movie> getMovies() {
    final List<Movie>? movies = _movies;
    if (movies != null) {
      return movies;
    }

    return [];
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

    _movies = loadedMovies;
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
