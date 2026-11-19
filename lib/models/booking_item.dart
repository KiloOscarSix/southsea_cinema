class BookingItem {
  final int? id;
  final int? bookingId;
  final String movieId;
  final String movieTitle;
  final String screeningTime;
  final double unitPrice;
  final int quantity;

  const BookingItem({
    this.id,
    this.bookingId,
    required this.movieId,
    required this.movieTitle,
    required this.screeningTime,
    required this.unitPrice,
    required this.quantity,
  });

  double get lineTotal => unitPrice * quantity;

  Map<String, Object?> toMap() {
    final Map<String, Object?> data = <String, Object?>{
      'movie_id': movieId,
      'movie_title': movieTitle,
      'screening_time': screeningTime,
      'unit_price': unitPrice,
      'quantity': quantity,
    };
    if (id != null) {
      data['id'] = id;
    }
    if (bookingId != null) {
      data['booking_id'] = bookingId;
    }
    return data;
  }

  factory BookingItem.fromMap(Map<String, Object?> map) {
    final String movieId = map['movie_id'] as String;
    final String movieTitle = map['movie_title'] as String;
    final String screeningTime = map['screening_time'] as String;
    final num unitPriceNumber = map['unit_price'] as num;
    final double unitPrice = unitPriceNumber.toDouble();
    final int quantity = map['quantity'] as int;
    return BookingItem(
      id: map['id'] as int?,
      bookingId: map['booking_id'] as int?,
      movieId: movieId,
      movieTitle: movieTitle,
      screeningTime: screeningTime,
      unitPrice: unitPrice,
      quantity: quantity,
    );
  }
}
