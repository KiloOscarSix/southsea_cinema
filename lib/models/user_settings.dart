class UserSettings {
  final String address;
  final String email;
  final String patronNumber;
  final bool marketingEmails;

  const UserSettings({
    this.address = '',
    this.email = '',
    this.patronNumber = '',
    this.marketingEmails = false,
  });
}
