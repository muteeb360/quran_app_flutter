import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:workmanager/workmanager.dart';

// Top-level function for background tasks - MUST be top-level
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    print('Background task executed: $task');

    try {
      final notificationService = NotificationService();

      if (task == 'prayer_notification') {
        final id = inputData?['id'] as int? ?? 0;
        final prayerName = inputData?['prayerName'] as String? ?? 'Prayer';

        await notificationService._showNotification(
          id: id,
          title: 'Time for $prayerName',
          body: 'It\'s time to perform $prayerName prayer',
          isPrayer: true,
        );
      } else if (task == 'verse_notification') {
        final id = inputData?['id'] as int? ?? 0;
        final surahName = inputData?['surahName'] as String? ?? 'Verse';
        final verseNumber = inputData?['verseNumber'] as int? ?? 0;
        final verseText = inputData?['verseText'] as String? ?? '';

        await notificationService._showNotification(
          id: id,
          title: 'Verse of the Day',
          body: '$surahName $verseNumber: $verseText',
          isPrayer: false,
        );
      }

      return true;
    } catch (e) {
      print('Error in background task: $e');
      return false;
    }
  });
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  factory NotificationService() {
    return _instance;
  }

  NotificationService._internal();

  // INITIALIZE NOTIFICATION SERVICE
  Future<void> initNotification() async {
    // Initialize timezone
    tzdata.initializeTimeZones();

    // Initialize workmanager
    await Workmanager().initialize(
      callbackDispatcher,
      isInDebugMode: true, // Set to false in production
    );

    // Android initialization settings
    const AndroidInitializationSettings androidInitializationSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS initialization settings
    const DarwinInitializationSettings iosInitializationSettings =
    DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    // Combined initialization settings
    const InitializationSettings initializationSettings =
    InitializationSettings(
      android: androidInitializationSettings,
      iOS: iosInitializationSettings,
    );

    // Initialize the plugin
    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: onDidReceiveNotificationResponse,
    );

    // Create notification channels
    await _createNotificationChannels();

    print('Notification service initialized successfully');
  }

  // CREATE NOTIFICATION CHANNELS
  Future<void> _createNotificationChannels() async {
    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
    _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    if (androidImplementation != null) {
      // Prayer times channel with sound
      await androidImplementation.createNotificationChannel(
        AndroidNotificationChannel(
          'prayer_channel',
          'Prayer Times',
          description: 'Notifications for prayer times',
          importance: Importance.max,
          sound: const RawResourceAndroidNotificationSound('adhan'),
          enableVibration: true,
        ),
      );

      // Verse of the day channel
      await androidImplementation.createNotificationChannel(
        AndroidNotificationChannel(
          'verse_channel',
          'Verse of the Day',
          description: 'Daily Quran verse notifications',
          importance: Importance.defaultImportance,
          enableVibration: true,
        ),
      );
    }
  }

  // NOTIFICATION DETAILS FOR PRAYER TIMES
  NotificationDetails _getPrayerNotificationDetails() {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        'prayer_channel',
        'Prayer Times',
        channelDescription: 'Notifications for prayer times',
        importance: Importance.max,
        priority: Priority.high,
        sound: RawResourceAndroidNotificationSound('adhan'),
        enableVibration: true,
        fullScreenIntent: true,
      ),
      iOS: DarwinNotificationDetails(
        sound: 'adhan.caf',
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );
  }

  // NOTIFICATION DETAILS FOR VERSE OF THE DAY
  NotificationDetails _getVerseNotificationDetails() {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        'verse_channel',
        'Verse of the Day',
        channelDescription: 'Daily Quran verse notifications',
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,
        enableVibration: true,
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );
  }

  // Internal method to show notifications
  Future<void> _showNotification({
    required int id,
    required String title,
    required String body,
    required bool isPrayer,
  }) async {
    try {
      final notificationDetails = isPrayer
          ? _getPrayerNotificationDetails()
          : _getVerseNotificationDetails();

      await _flutterLocalNotificationsPlugin.show(
        id,
        title,
        body,
        notificationDetails,
      );

      print('Notification shown: $title');
    } catch (e) {
      print('Error showing notification: $e');
    }
  }

  // SCHEDULE PRAYER TIME NOTIFICATION
  Future<void> schedulePrayerNotification({
    required String prayerName,
    required DateTime prayerTime,
    required int id,
  }) async {
    try {
      final now = DateTime.now();

      // Only schedule if time is in the future
      if (prayerTime.isBefore(now)) {
        print('Prayer time $prayerName is in the past');
        return;
      }

      // Schedule with workmanager for background execution
      await Workmanager().registerOneOffTask(
        'prayer_$id',
        'prayer_notification',
        initialDelay: prayerTime.difference(now),
        inputData: {
          'id': id,
          'prayerName': prayerName,
        },
      );

      // Also schedule with zonedSchedule for when app is running
      final tz.TZDateTime scheduledDate =
      tz.TZDateTime.from(prayerTime, tz.local);

      await _flutterLocalNotificationsPlugin.zonedSchedule(
        id,
        'Time for $prayerName',
        'It\'s time to perform $prayerName prayer',
        scheduledDate,
        _getPrayerNotificationDetails(),
        androidScheduleMode: AndroidScheduleMode.alarmClock,
        matchDateTimeComponents: DateTimeComponents.time,
      );

      print('Prayer notification scheduled for $prayerName at $prayerTime');
    } catch (e) {
      print('Error scheduling prayer notification: $e');
    }
  }

  // SCHEDULE VERSE OF THE DAY NOTIFICATION
  Future<void> scheduleVerseNotification({
    required String verseText,
    required String surahName,
    required int verseNumber,
    required DateTime scheduledTime,
    required int id,
  }) async {
    try {
      final now = DateTime.now();

      // Only schedule if time is in the future
      if (scheduledTime.isBefore(now)) {
        print('Verse notification time is in the past');
        return;
      }

      final displayText = verseText.length > 50
          ? '${verseText.substring(0, 50)}...'
          : verseText;

      // Schedule with workmanager for background execution
      await Workmanager().registerOneOffTask(
        'verse_$id',
        'verse_notification',
        initialDelay: scheduledTime.difference(now),
        inputData: {
          'id': id,
          'surahName': surahName,
          'verseNumber': verseNumber,
          'verseText': displayText,
        },
      );

      // Also schedule with zonedSchedule for when app is running
      final tz.TZDateTime scheduledDate =
      tz.TZDateTime.from(scheduledTime, tz.local);

      await _flutterLocalNotificationsPlugin.zonedSchedule(
        id,
        'Verse of the Day',
        '$surahName $verseNumber: $displayText',
        scheduledDate,
        _getVerseNotificationDetails(),
        androidScheduleMode: AndroidScheduleMode.alarmClock,
      );

      print('Verse notification scheduled for $scheduledTime');
    } catch (e) {
      print('Error scheduling verse notification: $e');
    }
  }

  // SCHEDULE DAILY VERSE AT SPECIFIC TIME
  Future<void> scheduleDailyVerse({
    required String verseText,
    required String surahName,
    required int verseNumber,
    required int hour,
    required int minute,
    required int id,
  }) async {
    try {
      final now = DateTime.now();
      var scheduledTime = DateTime(now.year, now.month, now.day, hour, minute);

      // If the time has already passed today, schedule for tomorrow
      if (scheduledTime.isBefore(now)) {
        scheduledTime = scheduledTime.add(const Duration(days: 1));
      }

      print('Scheduling verse for: $scheduledTime (now: $now)');

      await scheduleVerseNotification(
        verseText: verseText,
        surahName: surahName,
        verseNumber: verseNumber,
        scheduledTime: scheduledTime,
        id: id,
      );
    } catch (e) {
      print('Error scheduling daily verse: $e');
    }
  }

  // SCHEDULE ALL PRAYER TIMES
  Future<void> scheduleDailyPrayerTimes({
    required Map<String, DateTime> prayerTimes,
  }) async {
    int id = 1;
    for (var entry in prayerTimes.entries) {
      await schedulePrayerNotification(
        prayerName: entry.key,
        prayerTime: entry.value,
        id: id,
      );
      id++;
    }
  }

  // GET PENDING NOTIFICATIONS
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    try {
      return await _flutterLocalNotificationsPlugin
          .pendingNotificationRequests();
    } catch (e) {
      print('Error getting pending notifications: $e');
      return [];
    }
  }

  // CANCEL SPECIFIC NOTIFICATION
  Future<void> cancelNotification(int id) async {
    try {
      await _flutterLocalNotificationsPlugin.cancel(id);
      await Workmanager().cancelByUniqueName('prayer_$id');
      await Workmanager().cancelByUniqueName('verse_$id');
      print('Notification $id cancelled');
    } catch (e) {
      print('Error canceling notification: $e');
    }
  }

  // CANCEL ALL NOTIFICATIONS
  Future<void> cancelAllNotifications() async {
    try {
      await _flutterLocalNotificationsPlugin.cancelAll();
      await Workmanager().cancelAll();
      print('All notifications cancelled');
    } catch (e) {
      print('Error canceling all notifications: $e');
    }
  }

  // HANDLE NOTIFICATION TAP
  void onDidReceiveNotificationResponse(
      NotificationResponse notificationResponse) {
    final String? payload = notificationResponse.payload;
    print('Notification tapped with payload: $payload');
    // Add navigation logic here if needed
  }
}