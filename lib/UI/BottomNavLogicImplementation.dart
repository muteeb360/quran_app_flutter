import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:hidaya_app/UI/ChatBot/MediumScreenLayouts/chatbotMediumScreen.dart';
import 'package:hidaya_app/UI/Quran/MediumScreenLayouts/quranMediumScreenLayout.dart';
import '../Utils/bottomnavigationbar.dart';
import '../Utils/chat_service.dart';
import 'Home/MediumScreenLayouts/homeMediumScreenLayout.dart';
import 'Settings/MediumScreenLayouts/settingsMediumScreenLayout.dart';

class homescreen extends StatefulWidget {
  const homescreen({super.key});

  @override
  State<homescreen> createState() => _homescreenState();
}

class _homescreenState extends State<homescreen> {
  int _currentIndex = 0;

  // List of screens corresponding to navigation items
  final List<Widget> _screens = [
    HomeContent(),
    QuranContent(),
    ChatbotContent(),
    SettingsContent()
  ];

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Bottomnavlayout(
            currentIndex: _currentIndex,
            onItemTapped: _onItemTapped,
            content: _screens[_currentIndex],
          );
        },
      ),
    );
  }
}

class Bottomnavlayout extends StatelessWidget {
  final int currentIndex;
  final Function(int) onItemTapped;
  final Widget content;

  const Bottomnavlayout({
    required this.currentIndex,
    required this.onItemTapped,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: content,
      bottomNavigationBar: CustomBottomNavigation(
        selectedIndex: currentIndex,
        onItemTapped: onItemTapped,
      ),
    );
  }
}

// HomeScreen Content
class HomeContent extends StatefulWidget {
  const HomeContent({super.key});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return HomeMediumScreenLayout();
    });
  }
}

//Quran Screen Content
class QuranContent extends StatefulWidget {
  const QuranContent({super.key});

  @override
  State<QuranContent> createState() => _QuranContentState();
}

class _QuranContentState extends State<QuranContent> {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return QuranMediumScreen();
    });
  }
}

//Chatbot Screen Content
class ChatbotContent extends StatefulWidget {
  const ChatbotContent({super.key});

  @override
  State<ChatbotContent> createState() => _ChatbotContentState();
}

class _ChatbotContentState extends State<ChatbotContent> {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return ChatbotMediumScreen(chatService: ChatService(),);
    });
  }
}

//Settings Screen Content
class SettingsContent extends StatefulWidget {
  const SettingsContent({super.key});

  @override
  State<SettingsContent> createState() => _SettingsContentState();
}

class _SettingsContentState extends State<SettingsContent> {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return settingsMediumScreenLayout();
    });
  }
}

