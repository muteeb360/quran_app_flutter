import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme_provider.dart';

class settingsMediumScreenLayout extends StatelessWidget {
  const settingsMediumScreenLayout({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context); // 👈 get provider

    return Scaffold(
      body: Center(
          child: Switch(
            value: themeProvider.themeMode == ThemeMode.dark,
            onChanged: (value) {
              themeProvider.toggleTheme(value); // 👈 works now
            },
          ),
      ),
    );
  }
}
