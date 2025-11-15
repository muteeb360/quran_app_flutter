import 'package:flutter/material.dart';
import 'package:hidaya_app/main.dart';

class LanguageSelector extends StatelessWidget {
  final bool showAsButton;
  final Color? iconColor;

  const LanguageSelector({
    Key? key,
    this.showAsButton = false,
    this.iconColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (showAsButton) {
      // Display as a button (for settings page)
      return _buildButton(context);
    } else {
      // Display as icon button in app bar
      return PopupMenuButton<String>(
        icon: Icon(Icons.language, color: iconColor ?? Colors.black),
        onSelected: (localeCode) => _changeLanguage(context, localeCode),
        itemBuilder: (context) => [
          PopupMenuItem(
            value: 'en',
            child: Row(
              children: [
                Text('🇬🇧', style: TextStyle(fontSize: 20)),
                SizedBox(width: 10),
                Text('English'),
              ],
            ),
          ),
          PopupMenuItem(
            value: 'ur',
            child: Row(
              children: [
                Text('🇵🇰', style: TextStyle(fontSize: 20)),
                SizedBox(width: 10),
                Text('اردو'),
              ],
            ),
          ),
          PopupMenuItem(
            value: 'ar',
            child: Row(
              children: [
                Text('🇸🇦', style: TextStyle(fontSize: 20)),
                SizedBox(width: 10),
                Text('العربية'),
              ],
            ),
          ),
        ],
      );
    }
  }

  Widget _buildButton(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(Icons.language),
        title: Text('Language / زبان / اللغة'),
        trailing: Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () => _showLanguageDialog(context),
      ),
    );
  }

  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Select Language'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildLanguageOption(context, 'en', '🇬🇧', 'English'),
            _buildLanguageOption(context, 'ur', '🇵🇰', 'اردو (Urdu)'),
            _buildLanguageOption(context, 'ar', '🇸🇦', 'العربية (Arabic)'),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageOption(
      BuildContext context,
      String localeCode,
      String flag,
      String language,
      ) {
    return ListTile(
      leading: Text(flag, style: TextStyle(fontSize: 30)),
      title: Text(language),
      onTap: () {
        _changeLanguage(context, localeCode);
        Navigator.pop(context);
      },
    );
  }

  void _changeLanguage(BuildContext context, String localeCode) {
    hidaya.setLocale(context, Locale(localeCode));
  }
}