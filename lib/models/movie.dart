class Movie {
  final String id;
  final String title;
  final int year;
  final String description;
  final String imagePath;
  final String genre;
  // Duration in minutes
  final int duration;
  final String rating;

  const Movie(
      {required this.id,
      required this.title,
      required this.year,
      required this.description,
      required this.imagePath,
      required this.genre,
      required this.duration,
      required this.rating});
}

