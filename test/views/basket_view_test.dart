import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:southsea_cinema/database/cinema_db.dart';
import 'package:southsea_cinema/models/basket_item.dart';
import 'package:southsea_cinema/models/booking.dart';
import 'package:southsea_cinema/models/movie.dart';
import 'package:southsea_cinema/repositories/basket_repository.dart';
import 'package:southsea_cinema/views/basket_view.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

const Movie testMovie1 = Movie(
  id: 'test-movie-1',
  title: 'Test Movie One',
  year: 2024,
  description: 'A movie used for testing.',
  imagePath: 'assets/images/test_movie_1.jpg',
  genre: 'Drama',
  duration: 120,
  ageRating: 'PG',
  price: 6.0,
  screeningTime: '19:30',
);

const Movie testMovie2 = Movie(
  id: 'test-movie-2',
  title: 'Test Movie Two',
  year: 2025,
  description: 'Another movie used for testing.',
  imagePath: 'assets/images/test_movie_2.jpg',
  genre: 'Horror',
  duration: 95,
  ageRating: '15',
  price: 7.5,
  screeningTime: '21:00',
);

const Movie testMovie3 = Movie(
  id: 'test-movie-3',
  title: 'Test Movie Three',
  year: 2023,
  description: 'A third movie used for testing.',
  imagePath: 'assets/images/test_movie_3.jpg',
  genre: 'Comedy',
  duration: 100,
  ageRating: '12A',
  price: 5.0,
  screeningTime: '17:15',
);

Future<void> pumpBasketView(WidgetTester tester) async {
  await tester.pumpWidget(const MaterialApp(home: BasketView()));
}

void main() {
  setUp(() async {
    BasketRepository.instance.clear();
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

  group('BasketView', () {
    testWidgets('shows a ticket line, then the empty state after removing it',
        (WidgetTester tester) async {
      BasketRepository.instance
          .addItem(const BasketItem(movie: testMovie1, quantity: 1));

      await pumpBasketView(tester);

      expect(find.text('My Basket'), findsOneWidget);
      expect(find.text('1 x Test Movie One'), findsOneWidget);
      expect(find.text('CHECKOUT'), findsOneWidget);
      expect(find.text('Your basket is empty'), findsNothing);

      await tester.tap(find.byIcon(Icons.delete));
      await tester.pump();

      expect(find.text('1 x Test Movie One'), findsNothing);
      expect(find.text('Your basket is empty'), findsOneWidget);
      expect(find.text('CHECKOUT'), findsNothing);
      expect(find.byIcon(Icons.delete), findsNothing);
      expect(BasketRepository.instance.getItems(), isEmpty);
    });

    testWidgets('removing the middle of three films keeps the other two',
        (WidgetTester tester) async {
      BasketRepository.instance
          .addItem(const BasketItem(movie: testMovie1, quantity: 1));
      BasketRepository.instance
          .addItem(const BasketItem(movie: testMovie2, quantity: 2));
      BasketRepository.instance
          .addItem(const BasketItem(movie: testMovie3, quantity: 3));

      await pumpBasketView(tester);

      expect(find.byIcon(Icons.delete), findsNWidgets(3));
      expect(find.text('2 x Test Movie Two'), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('remove-test-movie-2')));
      await tester.pump();

      expect(find.text('1 x Test Movie One'), findsOneWidget);
      expect(find.text('2 x Test Movie Two'), findsNothing);
      expect(find.text('3 x Test Movie Three'), findsOneWidget);
      expect(find.byIcon(Icons.delete), findsNWidgets(2));
      expect(find.byKey(const ValueKey('remove-test-movie-2')), findsNothing);
      expect(find.text('4'), findsOneWidget);
      expect(find.text('£21.00'), findsOneWidget);

      final List<BasketItem> items = BasketRepository.instance.getItems();
      expect(items.length, 2);
      expect(items[0].movie.id, 'test-movie-1');
      expect(items[1].movie.id, 'test-movie-3');
    });

    testWidgets('Update Order returns to the home page and keeps the basket',
        (WidgetTester tester) async {
      BasketRepository.instance
          .addItem(const BasketItem(movie: testMovie1, quantity: 1));

      // Start on the basket with the home page underneath it
      await tester.pumpWidget(MaterialApp(
        initialRoute: '/basket',
        routes: {
          '/': (BuildContext context) => const Text('Home page'),
          '/basket': (BuildContext context) => const BasketView(),
        },
      ));

      expect(find.byType(BasketView), findsOneWidget);
      expect(find.text('UPDATE ORDER'), findsOneWidget);

      await tester.tap(find.text('UPDATE ORDER'));
      await tester.pumpAndSettle();

      expect(find.byType(BasketView), findsNothing);
      expect(find.text('Home page'), findsOneWidget);
      expect(BasketRepository.instance.getItems().length, 1);
    });

    testWidgets('fits the order buttons on a narrow phone',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      BasketRepository.instance
          .addItem(const BasketItem(movie: testMovie1, quantity: 1));

      await pumpBasketView(tester);

      expect(tester.takeException(), isNull);
      expect(find.text('UPDATE ORDER'), findsOneWidget);
      expect(find.text('CHECKOUT'), findsOneWidget);
    });
  });
  group('BasketView checkout', () {
    testWidgets('saves a numbered booking, clears the basket and lists it',
        (WidgetTester tester) async {
      BasketRepository.instance
          .addItem(const BasketItem(movie: testMovie1, quantity: 2));
      BasketRepository.instance
          .addItem(const BasketItem(movie: testMovie2, quantity: 1));

      await tester.runAsync(() async {
        await pumpBasketView(tester);
        await tester.pumpAndSettle();
        await tester.tap(find.text('CHECKOUT'));
        await tester.pumpAndSettle();
      });
      await tester.pumpAndSettle();

      final List<Booking>? bookings = await tester.runAsync(() {
        return CinemaDatabase.instance.getAllBookings();
      });

      expect(bookings, isNotNull);
      expect(bookings!.length, 1);
      expect(bookings[0].bookingNumber, 1001);
      expect(bookings[0].summary, '2 x Test Movie One, 1 x Test Movie Two');
      expect(bookings[0].total, 19.50);
      expect(BasketRepository.instance.getItems(), isEmpty);
      expect(find.text('Your basket is empty'), findsOneWidget);
      expect(
          find.text('Booking #1001 confirmed for 3 tickets.'), findsOneWidget);
      expect(find.text('Booking #1001'), findsOneWidget);
      expect(find.text('No bookings yet'), findsNothing);
    });

    testWidgets('keeps the basket and shows an error when saving fails',
        (WidgetTester tester) async {
      BasketRepository.instance
          .addItem(const BasketItem(movie: testMovie1, quantity: 2));

      await tester.runAsync(() async {
        final Database database = await CinemaDatabase.instance.database;
        await pumpBasketView(tester);
        await tester.pumpAndSettle();
        await database.execute('DROP TABLE bookings');
        await tester.tap(find.text('CHECKOUT'));
        await tester.pumpAndSettle();
      });
      await tester.pumpAndSettle();

      expect(BasketRepository.instance.getItems().length, 1);
      expect(find.text('2 x Test Movie One'), findsOneWidget);
      expect(
          find.textContaining('Could not save your booking'), findsOneWidget);
    });
  });

  group('BasketView past bookings', () {
    testWidgets('lists saved bookings with the newest first',
        (WidgetTester tester) async {
      await tester.runAsync(() async {
        await CinemaDatabase.instance.insertBooking(const Booking(
          bookingNumber: 1001,
          summary: '1 x Test Movie One',
          total: 6.00,
          date: '01/01/2026 10:00',
        ));
        await CinemaDatabase.instance.insertBooking(const Booking(
          bookingNumber: 1002,
          summary: '2 x Test Movie Two',
          total: 15.00,
          date: '02/01/2026 18:30',
        ));
        await pumpBasketView(tester);
        await tester.pumpAndSettle();
      });
      await tester.pump();

      expect(find.text('PAST BOOKINGS'), findsOneWidget);
      expect(find.text('Booking #1001'), findsOneWidget);
      expect(find.text('Booking #1002'), findsOneWidget);
      expect(find.text('2 x Test Movie Two'), findsOneWidget);
      expect(find.text('£15.00'), findsOneWidget);
      expect(find.text('02/01/2026 18:30'), findsOneWidget);
      expect(find.text('No bookings yet'), findsNothing);
      expect(
        tester.getTopLeft(find.text('Booking #1002')).dy,
        lessThan(tester.getTopLeft(find.text('Booking #1001')).dy),
      );
    });

    testWidgets('shows a message when there are no bookings',
        (WidgetTester tester) async {
      await tester.runAsync(() async {
        await pumpBasketView(tester);
        await tester.pumpAndSettle();
      });
      await tester.pump();

      expect(find.text('Your basket is empty'), findsOneWidget);
      expect(find.text('PAST BOOKINGS'), findsOneWidget);
      expect(find.text('No bookings yet'), findsOneWidget);
    });
  });
}
