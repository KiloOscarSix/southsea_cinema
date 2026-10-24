import 'package:flutter/material.dart';
import 'package:southsea_cinema/constants.dart';
import 'package:southsea_cinema/models/user_settings.dart';
import 'package:southsea_cinema/widgets/nav_drawer.dart';
import 'package:southsea_cinema/widgets/primary_button.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  late TextEditingController _addressController;
  late TextEditingController _emailController;
  late TextEditingController _patronNumberController;
  bool _receiveNews = false;
  UserSettings _savedSettings = const UserSettings(patronNumber: '1234');
  String _confirmationMessage = '';

  @override
  void initState() {
    super.initState();

    _addressController = TextEditingController();
    _emailController = TextEditingController();
    _patronNumberController =
        TextEditingController(text: _savedSettings.patronNumber);
  }

  @override
  void dispose() {
    _addressController.dispose();
    _emailController.dispose();
    _patronNumberController.dispose();

    super.dispose();
  }

  void _saveSettings() {
    final UserSettings settings = UserSettings(
      address: _addressController.text.trim(),
      email: _emailController.text.trim(),
      patronNumber: _patronNumberController.text.trim(),
      marketingEmails: _receiveNews,
    );

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
            const Text('Customer Profile', style: cinemaTitleStyle),
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
            // -- Save / Cancel
            Row(
              spacing: cinemaSpacingMedium,
              children: [
                TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: cinemaSurface,
                    foregroundColor: cinemaFontWhite,
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
