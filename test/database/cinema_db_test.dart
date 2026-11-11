import 'package:flutter_test/flutter_test.dart';
import 'package:southsea_cinema/database/cinema_db.dart';
import 'package:southsea_cinema/models/booking.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUp(() async {
    sqfliteFfiInit();
    final Database database = await databaseFactoryFfiNoIsolate.openDatabase(
      inMemoryDatabasePath,
      options: OpenDatabaseOptions(
        version: 1,
        onCreate: CinemaDatabase.instance.createTables,
      ),
    );
    CinemaDatabase.instance.setDatabase(database);
  });

  tearDown(() async {
    await CinemaDatabase.instance.close();
  });

  Booking buildBooking(int bookingNumber, String summary, double total) {
    return Booking(
      bookingNumber: bookingNumber,
      summary: summary,
      total: total,
      date: '01/01/2026 10:00',
    );
  }

  test('insertBooking stores a booking and returns its id', () async {
    final CinemaDatabase database = CinemaDatabase.instance;

    final int id = await database.insertBooking(
      buildBooking(1001, '1 x Dracula', 6.00),
    );
    final List<Booking> bookings = await database.getAllBookings();

    expect(id, greaterThan(0));
    expect(bookings.length, 1);
    expect(bookings[0].id, id);
    expect(bookings[0].bookingNumber, 1001);
    expect(bookings[0].summary, '1 x Dracula');
    expect(bookings[0].total, 6.00);
    expect(bookings[0].date, '01/01/2026 10:00');
  });

  test('getNextBookingNumber increments the current maximum', () async {
    final CinemaDatabase database = CinemaDatabase.instance;

    expect(await database.getNextBookingNumber(), 1001);

    await database.insertBooking(
      buildBooking(1005, '2 x The Phantom of the Opera', 15.00),
    );

    expect(await database.getNextBookingNumber(), 1006);
  });

  test('getAllBookings returns the highest booking number first', () async {
    final CinemaDatabase database = CinemaDatabase.instance;

    await database.insertBooking(buildBooking(1001, '1 x Dracula', 6.00));
    await database.insertBooking(
      buildBooking(1003, '1 x The Phantom of the Opera', 7.50),
    );
    await database.insertBooking(buildBooking(1002, '2 x Dracula', 12.00));

    final List<Booking> bookings = await database.getAllBookings();
    final List<int> numbers = <int>[];
    for (final Booking booking in bookings) {
      numbers.add(booking.bookingNumber);
    }

    expect(numbers, <int>[1003, 1002, 1001]);
  });

  test('close resets the cached connection', () async {
    final CinemaDatabase database = CinemaDatabase.instance;
    final Database first = await database.database;

    await database.close();

    expect(first.isOpen, isFalse);
  });
}
