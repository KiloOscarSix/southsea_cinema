import 'package:flutter_test/flutter_test.dart';
import 'package:southsea_cinema/models/user_settings.dart';

void main() {
  group('UserSettings', () {
    test('uses defaults and stores the values passed to the constructor', () {
      const UserSettings defaults = UserSettings();

      expect(defaults.address, isEmpty);
      expect(defaults.email, isEmpty);
      expect(defaults.patronNumber, isEmpty);
      expect(defaults.marketingEmails, isFalse);

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
