import 'package:flutter/material.dart';
import 'package:hidaya_app/UI/Settings/MediumScreenLayouts/privacyandtermsMediumScreen.dart';
import 'package:provider/provider.dart';
import '../../theme_provider.dart';
import 'feedbackMediumScreen.dart';

class settingsMediumScreenLayout extends StatelessWidget {
  const settingsMediumScreenLayout({super.key});

  @override
  Widget build(BuildContext context) {
    final textColor = Colors.black.withOpacity(0.8);
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.background,
        elevation: 0,
        automaticallyImplyLeading: false,
        centerTitle: false,
        title: Text(
          "Settings",
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w700,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: ListView(
          children: [
            const SizedBox(height: 10),

            // Language
            _settingsTile(
              context: context,
              icon: Icons.language,
              title: "Language",
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("English", style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
                  const SizedBox(width: 8),
                  const Icon(Icons.chevron_right),
                ],
              ),
            ),

            const SizedBox(height: 8),
            Divider(color: Colors.grey.shade300),
            // Prayer Notification Switch
            _switchTile(
              context: context,
              icon: Icons.notifications_none,
              title: "Prayer Notification",
              value: true,
              onChanged: (v) {},
            ),
            const SizedBox(height: 8),
            Divider(color: Colors.grey.shade300),
            _settingsTile(
              context: context,
              icon: Icons.brightness_6_outlined,
              title: "Theme",
              trailing: ThemeSwitch(themeProvider: themeProvider),
            ),
            Divider(color: Colors.grey.shade300),
            // Ayat Notification
            _switchTile(
              context: context,
              icon: Icons.menu_book_outlined,
              title: "Ayat of the Day Notification",
              value: true,
              onChanged: (v) {},
            ),
            const SizedBox(height: 8),
            Divider(color: Colors.grey.shade300),
            // Feedback
            _settingsTile(
              context: context,
              icon: Icons.feedback_outlined,
              title: "Feedback",
              trailing: const Icon(Icons.chevron_right),
            ),
            const SizedBox(height: 8),
            Divider(color: Colors.grey.shade300),
            // Privacy Policy
            _settingsTile(
              context: context,
              icon: Icons.lock_outline,
              title: "Privacy Policy and Terms of Service",
              trailing: const Icon(Icons.chevron_right),
            ),
            const SizedBox(height: 8),
            Divider(color: Colors.grey.shade300),
          ],
        ),
      ),
    );
  }

  Widget _settingsTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    Widget? trailing,
  }) {
    return GestureDetector(
      onTap: (){
        _navigateToScreen(context, title);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          children: [
            Icon(icon, size: 24, color: Theme.of(context).colorScheme.onSurface),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (trailing != null) trailing,
          ],
        ),
      ),
    );
  }

  void _navigateToScreen(BuildContext context, String itemText) {
    switch (itemText) {
      case 'Feedback':
        Navigator.push(context, MaterialPageRoute(builder: (context) => feedbackMediumScreen()));
        break;
      case 'Privacy Policy and Terms of Service':
        Navigator.push(context, MaterialPageRoute(builder: (context) => PrivacyAndTermsScreen()));
        break;
    }
  }

  Widget _switchTile({
    required IconData icon,
    required String title,
    required bool value,
    required Function(bool) onChanged, required BuildContext context,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          Icon(icon, size: 24, color: Theme.of(context).colorScheme.onSurface),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Colors.white,
            activeTrackColor: Colors.green,
            inactiveTrackColor: Colors.grey.shade300,
          ),
        ],
      ),
    );
  }
}

class ThemeSwitch extends StatelessWidget {
  final ThemeProvider themeProvider;

  const ThemeSwitch({super.key, required this.themeProvider});

  @override
  Widget build(BuildContext context) {
    bool isDark = themeProvider.themeMode == ThemeMode.dark;

    return GestureDetector(
      onTap: () {
        themeProvider.toggleTheme(!isDark);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 60,
        height: 32,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          color: isDark ? Colors.black26 : Colors.grey.shade300,
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 300),
          alignment: isDark ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 26,
            height: 26,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
            child: Icon(
              isDark ? Icons.dark_mode : Icons.light_mode,
              size: 18,
              color: isDark ? Colors.yellow : Colors.orange,
            ),
          ),
        ),
      ),
    );
  }
}





