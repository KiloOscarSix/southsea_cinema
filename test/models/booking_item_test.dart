import 'package:flutter_test/flutter_test.dart';
import 'package:southsea_cinema/models/booking_item.dart';

void main() {
  group('BookingItem', () {
    const BookingItem item = BookingItem(
      movieId: 'dracula',
      movieTitle: 'Dracula',
      screeningTime: '19:30',
      unitPrice: 6.0,
      quantity: 3,
    );

    test('lineTotal multiplies the unit price by the quantity', () {
      expect(item.lineTotal, 18.0);
    });

    test('New items omit database ids when converted to a map', () {
      expect(item.toMap(), <String, Object?>{
        'movie_id': 'dracula',
        'movie_title': 'Dracula',
        'screening_time': '19:30',
        'unit_price': 6.0,
        'quantity': 3,
      });
    });

    test('A database map converts back into an item', () {
      final Map<String, Object?> row = <String, Object?>{
        'id': 4,
        'booking_id': 9,
        'movie_id': 'dracula',
        'movie_title': 'Dracula',
        'screening_time': '19:30',
        'unit_price': 6.0,
        'quantity': 3,
      };

      final BookingItem restored = BookingItem.fromMap(row);

      expect(restored.id, 4);
      expect(restored.bookingId, 9);
      expect(restored.movieTitle, 'Dracula');
      expect(restored.lineTotal, 18.0);
      expect(restored.toMap(), row);
    });
  });
}
