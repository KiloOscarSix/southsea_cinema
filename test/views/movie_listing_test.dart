import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:southsea_cinema/models/movie.dart';
import 'package:southsea_cinema/repositories/basket_repository.dart';
import 'package:southsea_cinema/views/movie_listing.dart';
import 'package:southsea_cinema/widgets/primary_button.dart';

const Movie dracula = Movie(
  id: 'dracula',
  title: 'Dracula',
  year: 1931,
  description: 'Count Dracula moves to London.',
  imagePath: 'assets/images/dracula.jpg',
  genre: 'Dark Fantasy',
  duration: 74,
  ageRating: 'PG',
  price: 6.0,
  screeningTime: '19:30',
);

Future<void> pumpListing(WidgetTester tester, Size size) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  await tester
      .pumpWidget(const MaterialApp(home: MovieListing(movie: dracula)));
  await tester.pumpAndSettle();
}

Future<void> chooseQuantity(WidgetTester tester, int quantity) async {
  await tester.tap(find.byType(DropdownMenu<int>));
  await tester.pumpAndSettle();
  await tester.tap(find.text('$quantity').last);
  await tester.pumpAndSettle();
}

void main() {
  setUp(() {
    BasketRepository.instance.clear();
  });

  group('MovieListing', () {
    testWidgets('shows the film details', (WidgetTester tester) async {
      await pumpListing(tester, const Size(1000, 800));

      expect(find.text('DRACULA (1931)'), findsOneWidget);
      expect(find.text('(PG)'), findsOneWidget);
      expect(find.text('19:30'), findsOneWidget);
      expect(find.text('£6.00'), findsOneWidget);
      expect(find.text('Count Dracula moves to London.'), findsOneWidget);
    });

    testWidgets('puts the order panel beside the details on a wide screen',
        (WidgetTester tester) async {
      await pumpListing(tester, const Size(1000, 800));

      final Offset title = tester.getTopLeft(find.text('DRACULA (1931)'));
      final Offset button = tester.getTopLeft(find.text('ADD TO ORDER'));
      expect(button.dx, greaterThan(title.dx + 500));
      expect(button.dy, lessThan(tester.getTopLeft(find.text('£6.00')).dy));
      expect(tester.getSize(find.byType(PrimaryButton)).width, 240);
      expect(tester.takeException(), isNull);
    });

    testWidgets('puts the order panel under the details on a narrow phone',
        (WidgetTester tester) async {
      await pumpListing(tester, const Size(360, 800));

      final Offset description =
          tester.getTopLeft(find.text('Count Dracula moves to London.'));
      final Offset button = tester.getTopLeft(find.text('ADD TO ORDER'));
      expect(button.dy, greaterThan(description.dy));
      expect(tester.getSize(find.byType(PrimaryButton)).width, 360 - 2 * 16);
      expect(tester.takeException(), isNull);
    });

    testWidgets('offers one to five tickets', (WidgetTester tester) async {
      await pumpListing(tester, const Size(1000, 800));

      final DropdownMenu<int> menu =
          tester.widget<DropdownMenu<int>>(find.byType(DropdownMenu<int>));
      final List<int> values = <int>[];
      for (final DropdownMenuEntry<int> entry in menu.dropdownMenuEntries) {
        values.add(entry.value);
      }
      expect(values, <int>[1, 2, 3, 4, 5]);
      expect(menu.initialSelection, 1);
    });

    testWidgets('adds one ticket by default with a singular message',
        (WidgetTester tester) async {
      await pumpListing(tester, const Size(1000, 800));

      expect(
          find.text('1 ticket for Dracula added to your order'), findsNothing);

      await tester.tap(find.text('ADD TO ORDER'));
      await tester.pump();

      expect(find.text('1 ticket for Dracula added to your order'),
          findsOneWidget);
      expect(BasketRepository.instance.getItems().length, 1);
      expect(BasketRepository.instance.getItems()[0].quantity, 1);
      expect(BasketRepository.instance.getTotal(), 6.0);
    });

    testWidgets('adds the chosen quantity with a plural message',
        (WidgetTester tester) async {
      await pumpListing(tester, const Size(360, 800));
      await chooseQuantity(tester, 3);

      await tester.ensureVisible(find.text('ADD TO ORDER'));
      await tester.tap(find.text('ADD TO ORDER'));
      await tester.pump();

      expect(find.text('3 tickets for Dracula added to your order'),
          findsOneWidget);
      expect(BasketRepository.instance.getItems()[0].movie.id, 'dracula');
      expect(BasketRepository.instance.getTotalTickets(), 3);
      expect(BasketRepository.instance.getTotal(), 18.0);
    });
  });
}
