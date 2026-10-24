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

  factory Movie.fromJson(Map<String, dynamic> json) {
    final String id = json['id'] as String;
    final String title = json['title'] as String;
    final int year = json['year'] as int;
    final String description = json['description'] as String;
    final String imagePath = json['imagePath'] as String;
    final String genre = json['genre'] as String;
    final int duration = json['duration'] as int;
    final String ageRating = json['ageRating'] as String;
    final num priceNumber = json['price'] as num;
    final double price = priceNumber.toDouble();
    final String screeningTime = json['screeningTime'] as String;

    return Movie(
      id: id,
      title: title,
      year: year,
      description: description,
      imagePath: imagePath,
      genre: genre,
      duration: duration,
      ageRating: ageRating,
      price: price,
      screeningTime: screeningTime,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'year': year,
      'description': description,
      'imagePath': imagePath,
      'genre': genre,
      'duration': duration,
      'ageRating': ageRating,
      'price': price,
      'screeningTime': screeningTime,
    };
  }

  String get formattedPrice => '£${price.toStringAsFixed(2)}';

  bool get isChildFriendly => ageRating == 'U' || ageRating == 'PG';

  bool get isAdultOnly => ageRating == '18';
}
