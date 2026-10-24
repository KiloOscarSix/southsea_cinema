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

    testWidgets('displays the form fields, switch and buttons',
        (WidgetTester tester) async {
      await pumpSettingsView(tester);

      expect(find.text('My Settings'), findsOneWidget);
      expect(find.text('Customer Profile'), findsOneWidget);
      expect(find.text('Address'), findsOneWidget);
      expect(find.text('Email Address'), findsOneWidget);
      expect(find.text('Patron Number'), findsOneWidget);
      expect(find.byType(TextField), findsNWidgets(3));
      expect(find.byType(Switch), findsOneWidget);
      expect(find.text('CANCEL'), findsOneWidget);
      expect(find.text('SAVE SETTINGS'), findsOneWidget);
      expect(find.text('Your settings have been saved.'), findsNothing);
    });

    testWidgets('entering details, toggling news and saving shows a message',
        (WidgetTester tester) async {
      await pumpSettingsView(tester);

      await tester.enterText(
          textFieldWithHint('Enter your address'), 'Lion Terrace, Portsmouth');
      await tester.enterText(
          textFieldWithHint('Enter your email'), 'alex@example.com');
      final Finder switchFinder = find.byType(Switch);
      expect(tester.widget<Switch>(switchFinder).value, isFalse);
      await tester.tap(switchFinder);
      await tester.pump();
      expect(tester.widget<Switch>(switchFinder).value, isTrue);

      await tapButton(tester, 'SAVE SETTINGS');
      await tester.pumpAndSettle();

      expect(find.text('Your settings have been saved.'), findsOneWidget);
      expect(find.text('Lion Terrace, Portsmouth'), findsOneWidget);
      expect(find.text('alex@example.com'), findsOneWidget);
      expect(find.text('1234'), findsOneWidget);
    });

    testWidgets('patron number is seeded and read-only',
        (WidgetTester tester) async {
      await pumpSettingsView(tester);

      final Finder patronField = find.widgetWithText(TextField, '1234');
      expect(tester.widget<TextField>(patronField).readOnly, isTrue);
      expect(find.text('1234'), findsOneWidget);
    });

    testWidgets('clear icon empties the address field',
        (WidgetTester tester) async {
      await pumpSettingsView(tester);

      await tester.enterText(
          textFieldWithHint('Enter your address'), 'Lion Terrace, Portsmouth');
      expect(find.text('Lion Terrace, Portsmouth'), findsOneWidget);

      await tester.tap(find.byTooltip('Clear address'));
      await tester.pump();

      expect(find.text('Lion Terrace, Portsmouth'), findsNothing);
    });

    testWidgets('cancel restores the last saved settings',
        (WidgetTester tester) async {
      await pumpSettingsView(tester);

      await tester.enterText(
          textFieldWithHint('Enter your email'), 'alex@example.com');
      await tapButton(tester, 'SAVE SETTINGS');
      await tester.pumpAndSettle();

      await tester.enterText(
          textFieldWithHint('Enter your email'), 'changed@example.com');
      await tester.tap(find.byType(Switch));
      await tester.pump();

      await tapButton(tester, 'CANCEL');
      await tester.pump();

      expect(find.text('alex@example.com'), findsOneWidget);
      expect(find.text('changed@example.com'), findsNothing);
      expect(tester.widget<Switch>(find.byType(Switch)).value, isFalse);
      expect(find.text('Your settings have been saved.'), findsNothing);
    });

    testWidgets('loads saved settings when the page opens',
        (WidgetTester tester) async {
      SharedPreferencesAsyncPlatform.instance =
          InMemorySharedPreferencesAsync.withData({
        prefAddress: '11 Downing Street',
        prefEmail: 'up2559676@myport.ac.uk',
        prefReceiveNews: true,
      });

      await pumpSettingsView(tester);

      expect(find.text('11 Downing Street'), findsOneWidget);
      expect(find.text('up2559676@myport.ac.uk'), findsOneWidget);
      expect(tester.widget<Switch>(find.byType(Switch)).value, isTrue);
    });

    testWidgets('uses defaults when nothing has been saved',
        (WidgetTester tester) async {
      await pumpSettingsView(tester);

      final TextField addressField =
          tester.widget<TextField>(textFieldWithHint('Enter your address'));
      final TextField emailField =
          tester.widget<TextField>(textFieldWithHint('Enter your email'));
      expect(addressField.controller!.text, isEmpty);
      expect(emailField.controller!.text, isEmpty);
      expect(tester.widget<Switch>(find.byType(Switch)).value, isFalse);
    });

    testWidgets('saving writes the profile to preferences',
        (WidgetTester tester) async {
      await pumpSettingsView(tester);

      await tester.enterText(
          textFieldWithHint('Enter your address'), '11 Downing Street');
      await tester.enterText(
          textFieldWithHint('Enter your email'), 'up2559676@myport.ac.uk');
      await tester.tap(find.byType(Switch));
      await tester.pump();
      await tapButton(tester, 'SAVE SETTINGS');
      await tester.pumpAndSettle();

      final SharedPreferencesAsync prefs = SharedPreferencesAsync();
      expect(await prefs.getString(prefAddress), '11 Downing Street');
      expect(await prefs.getString(prefEmail), 'up2559676@myport.ac.uk');
      expect(await prefs.getBool(prefReceiveNews), isTrue);
    });
  });
}
