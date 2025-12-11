import 'package:flutter/material.dart';
import 'package:hidaya_app/Utils/noti_service.dart';

class testing extends StatelessWidget {
  const testing({super.key});

  Future<void> _rescheduleNotifications() async {
    final notiService = NotificationService();
    final now = DateTime.now();

    // Schedule prayer times (2 minutes in future for testing)
    final testTime = now.add(const Duration(seconds: 10));

    final prayerTimes = {
      'Fajr': testTime,
      'Dhuhr': testTime.add(const Duration(seconds: 40)),
      'Asr': testTime.add(const Duration(minutes: 1)),
      'Maghrib': testTime.add(const Duration(minutes: 2)),
      'Isha': testTime.add(const Duration(minutes: 3)),
    };

    await notiService.scheduleDailyPrayerTimes(prayerTimes: prayerTimes);

    // Schedule verse of the day for 8:00 AM
    await notiService.scheduleDailyVerse(
      verseText: 'Alif-Laam-Meem. This is the Book...',
      surahName: 'Al-Baqarah',
      verseNumber: 1,
      hour: 7,
      minute: 10,
      id: 100,
    );

    print('Notifications scheduled');
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Islamic App')),
        body: Center(
          child: ElevatedButton(
            onPressed: (){ _rescheduleNotifications();},
            child: const Text('Test Notifications'),
          ),
        ),
      ),
    );
  }
}
