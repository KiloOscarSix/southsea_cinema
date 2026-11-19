import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart';
import 'package:southsea_cinema/database/cinema_db.dart';
import 'package:southsea_cinema/models/booking.dart';
import 'package:southsea_cinema/models/booking_item.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

Future<void> createVersionOneTables(Database db, int version) async {
  await db.execute('''
      CREATE TABLE IF NOT EXISTS bookings (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        booking_number INTEGER NOT NULL,
        summary TEXT NOT NULL,
        total REAL NOT NULL,
        date TEXT NOT NULL
      )
    ''');
}

void main() {
  test('upgrading from version 1 keeps existing bookings', () async {
    sqfliteFfiInit();
    final Directory dir =
        Directory.systemTemp.createTempSync('cinema_migration_');
    try {
      final String path = join(dir.path, 'cinema_data.db');

      final Database oldDatabase =
          await databaseFactoryFfiNoIsolate.openDatabase(
        path,
        options: OpenDatabaseOptions(
          version: 1,
          onCreate: createVersionOneTables,
        ),
      );
      await oldDatabase.insert('bookings', <String, Object?>{
        'booking_number': 1001,
        'summary': '1 x Dracula',
        'total': 6.0,
        'date': '01/01/2026 10:00',
      });
      await oldDatabase.insert('bookings', <String, Object?>{
        'booking_number': 1002,
        'summary': '2 x Nosferatu',
        'total': 15.0,
        'date': '02/01/2026 11:30',
      });
      await oldDatabase.insert('bookings', <String, Object?>{
        'booking_number': 1003,
        'summary': '3 x Metropolis',
        'total': 22.5,
        'date': '03/01/2026 12:45',
      });
      await oldDatabase.close();

      final Database reopened = await databaseFactoryFfiNoIsolate.openDatabase(
        path,
        options: OpenDatabaseOptions(
          version: CinemaDatabase.databaseVersion,
          onConfigure: CinemaDatabase.instance.configure,
          onCreate: CinemaDatabase.instance.createTables,
          onUpgrade: CinemaDatabase.instance.upgradeTables,
        ),
      );
      CinemaDatabase.instance.setDatabase(reopened);
      final CinemaDatabase database = CinemaDatabase.instance;

      expect(await reopened.getVersion(), 2);

      final List<Booking> migrated = await database.getAllBookings();
      expect(migrated.length, 3);
      expect(migrated[0].bookingNumber, 1003);
      expect(migrated[0].summary, '3 x Metropolis');
      expect(migrated[0].total, 22.5);
      expect(migrated[0].date, '03/01/2026 12:45');
      expect(migrated[1].bookingNumber, 1002);
      expect(migrated[1].summary, '2 x Nosferatu');
      expect(migrated[1].total, 15.0);
      expect(migrated[1].date, '02/01/2026 11:30');
      expect(migrated[2].bookingNumber, 1001);
      expect(migrated[2].summary, '1 x Dracula');
      expect(migrated[2].total, 6.0);
      expect(migrated[2].date, '01/01/2026 10:00');
      for (final Booking booking in migrated) {
        expect(booking.items, isEmpty);
      }

      await database.insertBooking(const Booking(
        bookingNumber: 1004,
        summary: '1 x Dracula, 1 x Nosferatu',
        total: 13.5,
        date: '04/01/2026 09:00',
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
            quantity: 1,
          ),
        ],
      ));

      final List<Booking> after = await database.getAllBookings();
      expect(after.length, 4);
      expect(after[0].bookingNumber, 1004);
      expect(after[0].items.length, 2);
      expect(after[1].items, isEmpty);
      expect(after[2].items, isEmpty);
      expect(after[3].items, isEmpty);
    } finally {
      await CinemaDatabase.instance.close();
      dir.deleteSync(recursive: true);
    }
  });
}
