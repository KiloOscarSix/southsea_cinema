import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:southsea_cinema/views/settings_view.dart';

Future<void> pumpSettingsView(WidgetTester tester) async {
  await tester.pumpWidget(const MaterialApp(home: SettingsView()));
  // Wait for the saved settings
  await tester.pumpAndSettle();
}

Finder textFieldWithHint(String hint) {
  return find.byWidgetPredicate((Widget widget) =>
      widget is TextField && widget.decoration?.hintText == hint);
}

Future<void> tapButton(WidgetTester tester, String label) async {
  await tester.ensureVisible(find.text(label));
  await tester.tap(find.text(label));
}

void main() {
  group('SettingsView', () {
    setUp(() {
      SharedPreferencesAsyncPlatform.instance =
          InMemorySharedPreferencesAsync.empty();
    });

    testWidgets('fills in a new profile, saves it and cancels later edits',
        (WidgetTester tester) async {
      await pumpSettingsView(tester);

      // Layout and defaults when nothing has been saved
      expect(find.text('My Settings'), findsOneWidget);
      expect(find.text('Customer Profile'), findsOneWidget);
      expect(find.text('Address'), findsOneWidget);
      expect(find.text('Email Address'), findsOneWidget);
      expect(find.text('Patron Number'), findsOneWidget);
      expect(find.byType(TextField), findsNWidgets(3));
      expect(find.text('CANCEL'), findsOneWidget);
      expect(find.text('SAVE SETTINGS'), findsOneWidget);
      expect(find.text('Your settings have been saved.'), findsNothing);
      final TextField addressField =
          tester.widget<TextField>(textFieldWithHint('Enter your address'));
      final TextField emailField =
          tester.widget<TextField>(textFieldWithHint('Enter your email'));
      expect(addressField.controller!.text, isEmpty);
      expect(emailField.controller!.text, isEmpty);
      final Finder switchFinder =
          find.byKey(const Key('marketing_emails_switch'));
      expect(tester.widget<Switch>(switchFinder).value, isFalse);
      expect(
          tester
              .widget<Switch>(find.byKey(const Key('dark_mode_switch')))
              .value,
          isTrue);
      expect(find.text('Appearance'), findsOneWidget);
      expect(find.text('Dark mode'), findsOneWidget);
      final Finder patronField = find.widgetWithText(TextField, '1234');
      expect(tester.widget<TextField>(patronField).readOnly, isTrue);

      // Ensure the clear icon empties the address field
      await tester.enterText(
          textFieldWithHint('Enter your address'), 'Wrong address');
      await tester.tap(find.byTooltip('Clear address'));
      await tester.pump();
      expect(find.text('Wrong address'), findsNothing);

      await tester.enterText(
          textFieldWithHint('Enter your address'), 'Lion Terrace, Portsmouth');
      await tester.enterText(
          textFieldWithHint('Enter your email'), 'alex@example.com');
      await tester.tap(switchFinder);
      await tester.pump();
      expect(tester.widget<Switch>(switchFinder).value, isTrue);

      await tapButton(tester, 'SAVE SETTINGS');
      await tester.pumpAndSettle();

      expect(find.text('Your settings have been saved.'), findsOneWidget);
      final SharedPreferencesAsync prefs = SharedPreferencesAsync();
      expect(await prefs.getString(prefAddress), 'Lion Terrace, Portsmouth');
      expect(await prefs.getString(prefEmail), 'alex@example.com');
      expect(await prefs.getBool(prefReceiveNews), isTrue);

      // Cancel restores the last saved settings
      await tester.enterText(
          textFieldWithHint('Enter your email'), 'changed@example.com');
      await tester.tap(switchFinder);
      await tester.pump();
      await tapButton(tester, 'CANCEL');
      await tester.pump();

      expect(find.text('Lion Terrace, Portsmouth'), findsOneWidget);
      expect(find.text('alex@example.com'), findsOneWidget);
      expect(find.text('changed@example.com'), findsNothing);
      expect(tester.widget<Switch>(switchFinder).value, isTrue);
      expect(find.text('1234'), findsOneWidget);
      expect(find.text('Your settings have been saved.'), findsNothing);
    });

    testWidgets('loads saved settings, saves edits and shows them on reopening',
        (WidgetTester tester) async {
      SharedPreferencesAsyncPlatform.instance =
          InMemorySharedPreferencesAsync.withData({
        prefAddress: '11 Downing Street',
        prefEmail: 'up1234567@myport.ac.uk',
        prefReceiveNews: true,
      });
      await pumpSettingsView(tester);

      expect(find.text('11 Downing Street'), findsOneWidget);
      expect(find.text('up1234567@myport.ac.uk'), findsOneWidget);
      expect(
          tester
              .widget<Switch>(find.byKey(const Key('marketing_emails_switch')))
              .value,
          isTrue);

      await tester.enterText(
          textFieldWithHint('Enter your address'), '10 Downing Street');
      await tester.enterText(
          textFieldWithHint('Enter your email'), 'updated@example.com');
      await tester.tap(find.byKey(const Key('marketing_emails_switch')));
      await tester.pump();
      await tapButton(tester, 'SAVE SETTINGS');
      await tester.pumpAndSettle();

      // Close and reopen the page
      await tester.pumpWidget(const SizedBox());
      await pumpSettingsView(tester);

      expect(find.text('10 Downing Street'), findsOneWidget);
      expect(find.text('updated@example.com'), findsOneWidget);
      expect(find.text('11 Downing Street'), findsNothing);
      expect(find.text('up1234567@myport.ac.uk'), findsNothing);
      expect(
          tester
              .widget<Switch>(find.byKey(const Key('marketing_emails_switch')))
              .value,
          isFalse);
      expect(find.text('Your settings have been saved.'), findsNothing);
    });

    testWidgets(
        'saves dark mode off, reports light mode and cancel restores it',
        (WidgetTester tester) async {
      ThemeMode? reported;
      await tester.pumpWidget(MaterialApp(
        home: SettingsView(onThemeModeChanged: (ThemeMode m) {
          reported = m;
        }),
      ));
      await tester.pumpAndSettle();

      final Finder darkSwitch = find.byKey(const Key('dark_mode_switch'));
      await tester.ensureVisible(darkSwitch);
      await tester.tap(darkSwitch);
      await tester.pump();
      expect(tester.widget<Switch>(darkSwitch).value, isFalse);
      expect(reported, isNull);

      await tapButton(tester, 'SAVE SETTINGS');
      await tester.pumpAndSettle();
      expect(reported, ThemeMode.light);
      expect(await SharedPreferencesAsync().getBool(prefDarkMode), isFalse);

      await tester.ensureVisible(darkSwitch);
      await tester.tap(darkSwitch);
      await tester.pump();
      expect(tester.widget<Switch>(darkSwitch).value, isTrue);
      await tapButton(tester, 'CANCEL');
      await tester.pump();
      expect(tester.widget<Switch>(darkSwitch).value, isFalse);
    });

    testWidgets('loads a saved light mode preference',
        (WidgetTester tester) async {
      SharedPreferencesAsyncPlatform.instance =
          InMemorySharedPreferencesAsync.withData({prefDarkMode: false});
      await pumpSettingsView(tester);

      expect(
          tester
              .widget<Switch>(find.byKey(const Key('dark_mode_switch')))
              .value,
          isFalse);
    });

    testWidgets('fits the Cancel and Save buttons on a narrow phone',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await pumpSettingsView(tester);

      expect(tester.takeException(), isNull);
      expect(find.text('CANCEL'), findsOneWidget);
      expect(find.text('SAVE SETTINGS'), findsOneWidget);
    });
  });
}
