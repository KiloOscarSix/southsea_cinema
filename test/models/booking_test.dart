import 'package:flutter_test/flutter_test.dart';
import 'package:southsea_cinema/models/booking.dart';
import 'package:southsea_cinema/models/booking_item.dart';

void main() {
  group('Booking', () {
    const Booking booking = Booking(
      bookingNumber: 1004,
      summary: '2 x Dune: Part Two',
      total: 16.50,
      date: '01/01/2026 09:05',
    );

    test('New bookings omit database ids and convert to map', () {
      expect(booking.id, isNull);
      expect(booking.toMap(), <String, Object?>{
        'booking_number': 1004,
        'summary': '2 x Dune: Part Two',
        'total': 16.50,
        'date': '01/01/2026 09:05',
      });
    });

    test('A database map converts back into a booking', () {
      final Map<String, Object?> row = <String, Object?>{
        'id': 7,
        'booking_number': 1010,
        'summary': '1 x Oppenheimer',
        'total': 6.0,
        'date': '02/01/2026 10:20',
      };

      final Booking restored = Booking.fromMap(row);

      expect(restored.id, 7);
      expect(restored.bookingNumber, 1010);
      expect(restored.summary, '1 x Oppenheimer');
      expect(restored.total, 6.0);
      expect(restored.date, '02/01/2026 10:20');
      expect(restored.toMap(), row);
    });

    test('Items are kept by fromMap and left out of toMap', () {
      final Map<String, Object?> row = booking.toMap();
      const List<BookingItem> items = <BookingItem>[
        BookingItem(
          movieId: 'dune-2',
          movieTitle: 'Dune: Part Two',
          screeningTime: '20:00',
          unitPrice: 8.25,
          quantity: 2,
        ),
      ];

      final Booking restored = Booking.fromMap(row, items: items);

      expect(booking.items, isEmpty);
      expect(Booking.fromMap(row).items, isEmpty);
      expect(restored.items, items);
      expect(restored.toMap().containsKey('items'), isFalse);
      expect(restored.toMap(), row);
    });

    test('Whole-number SQLite totals become doubles', () {
      final Map<String, Object?> row = booking.toMap();
      row['total'] = 6;

      final Booking restored = Booking.fromMap(row);

      expect(restored.total, 6.0);
      expect(restored.total, isA<double>());
    });
  });
}
