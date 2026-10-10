class Movie {
  final String id;
  final String title;
  final int year;
  final String description;
  final String imagePath;
  final String genre;
  // Duration in minutes
  final int duration;
  final String ageRating;
  final double price;
  final String screeningTime;

  const Movie(
      {required this.id,
      required this.title,
      required this.year,
      required this.description,
      required this.imagePath,
      required this.genre,
      required this.duration,
      required this.ageRating,
      required this.price,
      required this.screeningTime});

  String get formattedPrice => '£${price.toStringAsFixed(2)}';

  bool get isChildFriendly => ageRating == 'U' || ageRating == 'PG';

  bool get isAdultOnly => ageRating == '18';
}
