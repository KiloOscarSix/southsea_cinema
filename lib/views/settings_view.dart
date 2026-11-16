import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:southsea_cinema/constants.dart';
import 'package:southsea_cinema/models/user_settings.dart';
import 'package:southsea_cinema/widgets/nav_drawer.dart';
import 'package:southsea_cinema/widgets/primary_button.dart';

const String prefAddress = 'profile_address';
const String prefEmail = 'profile_email';
const String prefReceiveNews = 'profile_receive_news';
const String prefDarkMode = 'appearance_dark_mode';

class SettingsView extends StatefulWidget {
  final ValueChanged<ThemeMode>? onThemeModeChanged;

  const SettingsView({super.key, this.onThemeModeChanged});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  late TextEditingController _addressController;
  late TextEditingController _emailController;
  late TextEditingController _patronNumberController;
  bool _receiveNews = false;
  bool _darkMode = true;
  UserSettings _savedSettings = const UserSettings(patronNumber: '1234');
  String _confirmationMessage = '';

  @override
  void initState() {
    super.initState();

    _addressController = TextEditingController();
    _emailController = TextEditingController();
    _patronNumberController =
        TextEditingController(text: _savedSettings.patronNumber);

    _loadSettings();
  }

  @override
  void dispose() {
    _addressController.dispose();
    _emailController.dispose();
    _patronNumberController.dispose();

    super.dispose();
  }

  Future<void> _loadSettings() async {
    final SharedPreferencesAsync prefs = SharedPreferencesAsync();
    final String? savedAddress = await prefs.getString(prefAddress);
    final String? savedEmail = await prefs.getString(prefEmail);
    final bool? savedReceiveNews = await prefs.getBool(prefReceiveNews);
    final bool? savedDarkMode = await prefs.getBool(prefDarkMode);

    // Handle null keys
    String address = '';
    if (savedAddress != null) {
      address = savedAddress;
    }
    String email = '';
    if (savedEmail != null) {
      email = savedEmail;
    }
    bool receiveNews = false;
    if (savedReceiveNews != null) {
      receiveNews = savedReceiveNews;
    }
    bool darkMode = true;
    if (savedDarkMode != null) {
      darkMode = savedDarkMode;
    }
    if (!mounted) return;

    setState(() {
      _addressController.text = address;
      _emailController.text = email;
      _receiveNews = receiveNews;
      _darkMode = darkMode;
      _savedSettings = UserSettings(
        address: address,
        email: email,
        patronNumber: _savedSettings.patronNumber,
        marketingEmails: receiveNews,
        darkMode: darkMode,
      );
    });
  }

  Future<void> _saveSettings() async {
    final UserSettings settings = UserSettings(
      address: _addressController.text.trim(),
      email: _emailController.text.trim(),
      patronNumber: _patronNumberController.text.trim(),
      marketingEmails: _receiveNews,
      darkMode: _darkMode,
    );

    final SharedPreferencesAsync prefs = SharedPreferencesAsync();
    await prefs.setString(prefAddress, settings.address);
    await prefs.setString(prefEmail, settings.email);
    await prefs.setBool(prefReceiveNews, settings.marketingEmails);
    await prefs.setBool(prefDarkMode, settings.darkMode);
    widget.onThemeModeChanged
        ?.call(settings.darkMode ? ThemeMode.dark : ThemeMode.light);
    if (!mounted) return;

    setState(() {
      _savedSettings = settings;
      _confirmationMessage = 'Your settings have been saved.';
    });
  }

  // Restore the last saved settings
  void _cancel() {
    setState(() {
      _addressController.text = _savedSettings.address;
      _emailController.text = _savedSettings.email;
      _patronNumberController.text = _savedSettings.patronNumber;
      _receiveNews = _savedSettings.marketingEmails;
      _darkMode = _savedSettings.darkMode;
      _confirmationMessage = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Settings'),
      ),
      drawer: const NavDrawer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(cinemaSpacingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: cinemaSpacingSmall,
          children: [
            Text('Customer Profile',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: cinemaSpacingSmall),
            // -- Address
            const Text('Address', style: cinemaMutedStyle),
            TextField(
              controller: _addressController,
              minLines: 4,
              maxLines: 4,
              keyboardType: TextInputType.streetAddress,
              style: cinemaBodyStyle,
              decoration: InputDecoration(
                hintText: 'Enter your address',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.close, color: cinemaFontMuted),
                  tooltip: 'Clear address',
                  onPressed: _addressController.clear,
                ),
              ),
            ),
            const SizedBox(height: cinemaSpacingSmall),
            // -- Email
            const Text('Email Address', style: cinemaMutedStyle),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              style: cinemaBodyStyle,
              decoration: const InputDecoration(
                hintText: 'Enter your email',
              ),
            ),
            const SizedBox(height: cinemaSpacingSmall),
            // -- Patron number
            const Text('Patron Number', style: cinemaMutedStyle),
            TextField(
              controller: _patronNumberController,
              readOnly: true,
              keyboardType: TextInputType.number,
              style: cinemaBodyStyle,
            ),
            const SizedBox(height: cinemaSpacingSmall),
            // -- Marketing
            const Text('Email Preferences', style: cinemaMutedStyle),
            Row(
              children: [
                const Expanded(
                  child:
                      Text('Receive marketing emails', style: cinemaBodyStyle),
                ),
                Switch(
                  key: const Key('marketing_emails_switch'),
                  value: _receiveNews,
                  activeThumbColor: cinemaBrand,
                  onChanged: (bool value) {
                    setState(() {
                      _receiveNews = value;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: cinemaSpacingSmall),
            // -- Appearance
            const Text('Appearance', style: cinemaMutedStyle),
            Row(
              children: [
                const Expanded(
                  child: Text('Dark mode', style: cinemaBodyStyle),
                ),
                Switch(
                  key: const Key('dark_mode_switch'),
                  value: _darkMode,
                  activeThumbColor: cinemaBrand,
                  onChanged: (bool value) {
                    setState(() {
                      _darkMode = value;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: cinemaSpacingSmall),
            // -- Save / Cancel
            Row(
              spacing: cinemaSpacingMedium,
              children: [
                TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.surface,
                    foregroundColor: Theme.of(context).colorScheme.onSurface,
                    textStyle: cinemaButtonStyle,
                    shape: const RoundedRectangleBorder(),
                  ),
                  onPressed: _cancel,
                  child: Text('Cancel'.toUpperCase()),
                ),
                PrimaryButton(
                  label: 'Save Settings'.toUpperCase(),
                  onPressed: _saveSettings,
                ),
              ],
            ),
            if (_confirmationMessage.isNotEmpty)
              Text(
                _confirmationMessage,
                style: cinemaBodyStyle.copyWith(fontWeight: FontWeight.bold),
              ),
          ],
        ),
      ),
    );
  }
}
