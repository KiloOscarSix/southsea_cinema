import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:southsea_cinema/database/cinema_db.dart';
import 'package:southsea_cinema/models/booking.dart';
import 'package:southsea_cinema/models/booking_item.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUp(() async {
    sqfliteFfiInit();
    final Database database = await databaseFactoryFfiNoIsolate.openDatabase(
      inMemoryDatabasePath,
      options: OpenDatabaseOptions(
        version: CinemaDatabase.databaseVersion,
        onConfigure: CinemaDatabase.instance.configure,
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

  test('insertBooking saves the booking and its items in both tables',
      () async {
    final CinemaDatabase database = CinemaDatabase.instance;
    const Booking booking = Booking(
      bookingNumber: 1001,
      summary: '2 x Dracula, 1 x Nosferatu',
      total: 19.50,
      date: '01/01/2026 10:00',
      items: <BookingItem>[
        BookingItem(
          movieId: 'dracula',
          movieTitle: 'Dracula',
          screeningTime: '19:30',
          unitPrice: 6.0,
          quantity: 2,
        ),
        BookingItem(
          movieId: 'nosferatu',
          movieTitle: 'Nosferatu',
          screeningTime: '21:00',
          unitPrice: 7.5,
          quantity: 1,
        ),
      ],
    );

    final int id = await database.insertBooking(booking);
    final Database db = await database.database;
    final List<Map<String, Object?>> rows = await db.query('booking_items');
    final List<Booking> bookings = await database.getAllBookings();

    expect(rows.length, 2);
    expect(rows[0]['booking_id'], id);
    expect(rows[1]['booking_id'], id);
    expect(bookings[0].items.length, 2);
    expect(bookings[0].items[0].bookingId, id);
    expect(bookings[0].items[0].movieId, 'dracula');
    expect(bookings[0].items[0].movieTitle, 'Dracula');
    expect(bookings[0].items[0].screeningTime, '19:30');
    expect(bookings[0].items[0].unitPrice, 6.0);
    expect(bookings[0].items[0].quantity, 2);
    expect(bookings[0].items[0].lineTotal, 12.0);
    expect(bookings[0].items[1].movieId, 'nosferatu');
    expect(bookings[0].items[1].movieTitle, 'Nosferatu');
    expect(bookings[0].items[1].screeningTime, '21:00');
    expect(bookings[0].items[1].unitPrice, 7.5);
    expect(bookings[0].items[1].quantity, 1);
    expect(bookings[0].items[1].lineTotal, 7.5);
  });

  test('a failed item insert rolls back the whole booking', () async {
    final CinemaDatabase database = CinemaDatabase.instance;
    const Booking booking = Booking(
      bookingNumber: 1001,
      summary: '1 x Dracula, 0 x Nosferatu',
      total: 6.0,
      date: '01/01/2026 10:00',
      items: <BookingItem>[
        BookingItem(
          movieId: 'dracula',
          movieTitle: 'Dracula',
          screeningTime: '19:30',
          unitPrice: 6.0,
          quantity: 1,
        ),
        BookingItem(
          movieId: 'nosferatu',
          movieTitle: 'Nosferatu',
          screeningTime: '21:00',
          unitPrice: 7.5,
          quantity: 0,
        ),
      ],
    );

    await expectLater(
      database.insertBooking(booking),
      throwsA(isA<DatabaseException>()),
    );

    final Database db = await database.database;
    expect(await db.query('bookings'), isEmpty);
    expect(await db.query('booking_items'), isEmpty);
  });

  test('foreign keys reject an item with no parent booking', () async {
    final Database db = await CinemaDatabase.instance.database;

    await expectLater(
      db.insert('booking_items', <String, Object?>{
        'booking_id': 999,
        'movie_id': 'dracula',
        'movie_title': 'Dracula',
        'screening_time': '19:30',
        'unit_price': 6.0,
        'quantity': 1,
      }),
      throwsA(isA<DatabaseException>()),
    );
  });

  test('bookings without item rows load with an empty item list', () async {
    final CinemaDatabase database = CinemaDatabase.instance;

    await database.insertBooking(buildBooking(1001, '1 x Dracula', 6.00));
    final List<Booking> bookings = await database.getAllBookings();

    expect(bookings.length, 1);
    expect(bookings[0].items, isEmpty);
  });

  test('close resets the cached connection', () async {
    final CinemaDatabase database = CinemaDatabase.instance;
    final Database first = await database.database;

    await database.close();

    expect(first.isOpen, isFalse);
  });

  test('opens the app database file once and seeds the three past bookings',
      () async {
    final CinemaDatabase database = CinemaDatabase.instance;
    await database.close();
    final Directory dir = Directory.systemTemp.createTempSync('cinema_db_');
    databaseFactory = databaseFactoryFfiNoIsolate;
    await databaseFactory.setDatabasesPath(dir.path);
    addTearDown(() => dir.deleteSync(recursive: true));

    final Database db = await database.database;
    final List<Booking> seeded = await database.getAllBookings();

    expect(db.path, endsWith('cinema_data.db'));
    expect(identical(await database.database, db), isTrue);
    expect(await db.getVersion(), CinemaDatabase.databaseVersion);
    expect(seeded.length, 3);
    expect(seeded[0].bookingNumber, 1003);
    expect(seeded[0].summary, '2 x The Phantom of the Opera');
    expect(seeded[0].total, 15.00);
    expect(seeded[0].date, '18/04/2026 20:15');
    expect(seeded[1].bookingNumber, 1002);
    expect(seeded[1].summary, '1 x Dracula');
    expect(seeded[1].total, 6.00);
    expect(seeded[1].date, '02/03/2026 18:10');
    expect(seeded[2].bookingNumber, 1001);
    expect(seeded[2].summary, '3 x Dracula, 1 x The Phantom of the Opera');
    expect(seeded[2].total, 25.50);
    expect(seeded[2].date, '11/01/2026 19:02');
    expect(seeded[0].items, isEmpty);
    expect(await database.getNextBookingNumber(), 1004);
    expect(await db.rawQuery('PRAGMA foreign_keys'), <Map<String, Object?>>[
      <String, Object?>{'foreign_keys': 1},
    ]);

    await database.close();
    final List<Booking> reopened = await database.getAllBookings();

    expect(reopened.length, 3);
    await database.close();
  });
}
