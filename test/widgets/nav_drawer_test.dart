import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:southsea_cinema/constants.dart';
import 'package:southsea_cinema/widgets/nav_drawer.dart';

Future<void> pumpWithDrawer(WidgetTester tester) async {
  await tester.pumpWidget(MaterialApp(
    initialRoute: '/',
    routes: {
      '/': (BuildContext context) => Scaffold(
            appBar: AppBar(title: const Text('Start page')),
            drawer: const NavDrawer(),
          ),
      '/basket': (BuildContext context) => const Text('Basket page'),
      '/settings': (BuildContext context) => const Text('Settings page'),
    },
  ));
}

Future<void> openDrawer(WidgetTester tester) async {
  await tester.tap(find.byTooltip('Open navigation menu'));
  await tester.pumpAndSettle();
}

bool isDrawerOpen(WidgetTester tester) {
  return tester.firstState<ScaffoldState>(find.byType(Scaffold)).isDrawerOpen;
}

void main() {
  group('NavDrawer', () {
    testWidgets('lists the title and the three pages',
        (WidgetTester tester) async {
      await pumpWithDrawer(tester);
      await openDrawer(tester);

      expect(isDrawerOpen(tester), isTrue);
      expect(find.text(appTitle), findsOneWidget);
      expect(find.byType(DrawerTile), findsNWidgets(3));
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('My Basket'), findsOneWidget);
      expect(find.text('My Settings'), findsOneWidget);
    });

    testWidgets('the close button shuts the drawer and stays on the page',
        (WidgetTester tester) async {
      await pumpWithDrawer(tester);
      await openDrawer(tester);

      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      expect(isDrawerOpen(tester), isFalse);
      expect(find.byType(NavDrawer), findsNothing);
      expect(find.text('Start page'), findsOneWidget);
    });

    testWidgets('My Basket closes the drawer and opens the basket route',
        (WidgetTester tester) async {
      await pumpWithDrawer(tester);
      await openDrawer(tester);

      await tester.tap(find.text('My Basket'));
      await tester.pumpAndSettle();

      expect(find.text('Basket page'), findsOneWidget);
      expect(find.text('Settings page'), findsNothing);
      expect(find.text('Start page'), findsNothing);
    });

    testWidgets('My Settings opens the settings route',
        (WidgetTester tester) async {
      await pumpWithDrawer(tester);
      await openDrawer(tester);

      await tester.tap(find.text('My Settings'));
      await tester.pumpAndSettle();

      expect(find.text('Settings page'), findsOneWidget);
      expect(find.text('Basket page'), findsNothing);
    });

    testWidgets('a tile without a route only closes the drawer',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(drawer: Drawer(child: DrawerTile(title: 'Nowhere'))),
      ));
      tester.firstState<ScaffoldState>(find.byType(Scaffold)).openDrawer();
      await tester.pumpAndSettle();

      await tester.tap(find.text('Nowhere'));
      await tester.pumpAndSettle();

      expect(isDrawerOpen(tester), isFalse);
      expect(find.text('Nowhere'), findsNothing);
    });
  });
}
