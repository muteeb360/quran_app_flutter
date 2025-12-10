import 'package:flutter/material.dart';

class PrivacyAndTermsScreen extends StatelessWidget {
  const PrivacyAndTermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.background,
          elevation: 0,
          leading: IconButton(icon: Icon(Icons.arrow_back_ios, color: Theme.of(context).colorScheme.onSurface), onPressed: () {
            Navigator.pop(context);
          },),
          title: Text("Hidaya AI", style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
          centerTitle: true,
          bottom: TabBar(
            labelColor: Colors.green,
            unselectedLabelColor: Theme.of(context).colorScheme.onSurface,
            indicatorColor: Colors.green,
            tabs: [
              Tab(text: "Privacy Policy"),
              Tab(text: "Terms of Service"),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            PrivacyPolicyView(),
            TermsOfServiceView(),
          ],
        ),
      ),
    );
  }
}

class PrivacyPolicyView extends StatelessWidget {
  const PrivacyPolicyView({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      color: Colors.white,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            SectionTitle("Introduction"),
            SectionText(
              "Hidaya AI is designed for reading Quran in PDF and digital format, Islamic research, providing Hadith and Quran references, scholarly views, prayer times (Hanafi & Shafi), verse of the day, Asma ul Husna, Asma ul Muhammad, Qibla direction, and supplications.",
            ),

            SectionTitle("Data Collection Summary"),
            SectionText(
              "We do not collect any personal data from users. All chat memory stays inside the device and is never uploaded to any server or shared with third parties. Users can delete their chat history anytime, and it will be removed permanently.",
            ),

            SectionText(
              "Location is used ONLY inside the app for accurate prayer times and Qibla direction. The microphone is used solely for speech-to-text features. No data is stored or sent externally.",
            ),

            SectionTitle("Children's Privacy"),
            SectionText(
              "Hidaya AI can be used by individuals of all ages. No personal information is collected from children.",
            ),

            SectionTitle("Security"),
            SectionText(
              "We prioritize user privacy and ensure that all usage remains fully offline except essential API features. We do not store, share, or sell any data.",
            ),

            SectionTitle("Privacy Policy Updates"),
            SectionText(
              "We may update this Privacy Policy to improve clarity or comply with regulations. Changes will be reflected within the app, and continued use of the app implies acceptance of these updates.",
            ),

            SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class TermsOfServiceView extends StatelessWidget {
  const TermsOfServiceView({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      color: Colors.white,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            SectionTitle("Acceptance of Terms"),
            SectionText(
              "By using Hidaya AI, you agree to follow all rules and respect Islamic values. The app is provided for Quran reading, Islamic research, prayer times, Qibla direction, and supplications.",
            ),

            SectionTitle("Prohibited Usage"),
            SectionText(
              "• Disrespecting Islamic content in any form.\n• Attempting to hack, reverse engineer, or copy the app.\n• Using the app for political, misleading, or hateful activities.\n• Uploading harmful, inappropriate, or anti-Islamic content.\n• Misusing AI to generate inappropriate religious statements.",
            ),

            SectionTitle("AI Assistant Disclaimer"),
            SectionText(
              "The AI assistant provides general Islamic information and references but is NOT a replacement for qualified Islamic scholars or muftis. It may occasionally provide incomplete or inaccurate responses. Users should consult certified scholars for authoritative religious decisions.",
            ),

            SectionTitle("Intellectual Property"),
            SectionText(
              "All Quranic text, translations, UI elements, icons, app design, and features belong to Hidaya AI or their original authors/licensors. Users may not copy, modify, redistribute, or resell any content without permission.",
            ),

            SectionTitle("Modifications & Updates"),
            SectionText(
              "We reserve the right to update or remove features at any time. Continued use of the app after updates indicates acceptance of the changes.",
            ),

            SectionTitle("Limitation of Liability"),
            SectionText(
              "Hidaya AI is provided 'as is'. We are not responsible for errors, inaccuracies, or interruptions in service. We are not liable for decisions made based on AI-generated content.",
            ),

            SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String text;
  const SectionTitle(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 6),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
    );
  }
}

class SectionText extends StatelessWidget {
  final String text;
  const SectionText(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        text,
        style: const TextStyle(fontSize: 15, color: Colors.black87, height: 1.45),
      ),
    );
  }
}
