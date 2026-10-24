import 'package:flutter_test/flutter_test.dart';
import 'package:southsea_cinema/models/user_settings.dart';

void main() {
  group('UserSettings', () {
    test('defaults to empty fields and no news', () {
      const UserSettings settings = UserSettings();

      expect(settings.address, isEmpty);
      expect(settings.email, isEmpty);
      expect(settings.patronNumber, isEmpty);
      expect(settings.marketingEmails, isFalse);
    });

    test('stores the values passed to the constructor', () {
      const UserSettings settings = UserSettings(
        address: 'Buckingham Building, Lion Terrace',
        email: 'alex@example.com',
        patronNumber: '1234',
        marketingEmails: true,
      );

      expect(settings.address, 'Buckingham Building, Lion Terrace');
      expect(settings.email, 'alex@example.com');
      expect(settings.patronNumber, '1234');
      expect(settings.marketingEmails, isTrue);
    });
  });
}
