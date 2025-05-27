import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart' show rootBundle, ByteData;
import 'dart:io' as io;
import 'dart:async';
import 'dart:math';

class DatabaseHelper {
  static Database? _database;
  static const int _maxRetryAttempts = 3;
  static const int _retryDelayMs = 1000;
  static const int _version = 4; // Increment the version for migration (was 3)

  DatabaseHelper._();

  static Future<Database> get database async {
    if (_database == null || !_database!.isOpen) {
      try {
        _database = await _initDatabaseWithRetry();
      } catch (e) {
        print('Failed to initialize database after retries: $e');
        rethrow;
      }
    }
    return _database!;
  }

  static Future<List<Map<String, dynamic>>> getSupplicationCategories() async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT category, COUNT(*) as total_supplications 
      FROM supplications 
      GROUP BY category
    ''');
    return result;
  }

  static Future<List<Map<String, dynamic>>> getSupplicationSubCategories(String category) async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT subcategory, COUNT(*) as total_supplications 
      FROM supplications 
      WHERE category = ?
      GROUP BY subcategory
    ''', [category]);
    return result;
  }

  static Future<List<Map<String, dynamic>>> getSupplicationsBySubCategory(String subcategory) async {
    final db = await database;
    final result = await db.query(
      'supplications',
      columns: ['arabic', 'urdu', 'english', 'source'],
      where: 'subcategory = ?',
      whereArgs: [subcategory],
    );
    return result;
  }

  static Future<Database> _initDatabaseWithRetry({int attempt = 1}) async {
    try {
      io.Directory documentsDirectory = await getApplicationDocumentsDirectory();
      String path = join(documentsDirectory.path, "quran.db");

      if (!await io.File(path).exists()) {
        print("Copying quran.db from assets to $path");
        ByteData data = await rootBundle.load('assets/database/quran.db');
        List<int> bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
        await io.File(path).writeAsBytes(bytes, flush: true);
      }

      return await openDatabase(
        path,
        version: _version,
        onCreate: (db, version) async {
          await db.execute('''
            CREATE TABLE IF NOT EXISTS ayahs_table (
              id INTEGER PRIMARY KEY,
              arabic_text TEXT,
              translation_text TEXT
            )
          ''');

          await db.execute('''
            CREATE TABLE IF NOT EXISTS favorites (
              id INTEGER PRIMARY KEY,
              english_name TEXT,
              arabic_name TEXT,
              total_verses TEXT
            )
          ''');

          await db.execute('''
            CREATE TABLE IF NOT EXISTS prayer_times (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              date TEXT,
              location TEXT,
              juristic_method TEXT,
              fajr TEXT,
              sunrise TEXT,
              dhuhr TEXT,
              asr TEXT,
              maghrib TEXT,
              isha TEXT
            )
          ''');

          await db.execute('''
            CREATE TABLE IF NOT EXISTS last_read (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              surah_number INTEGER,
              ayah_number INTEGER,
              surah_name TEXT,
              arabic_name TEXT,
              timestamp INTEGER,
              source TEXT,
              parah_number INTEGER
            )
          ''');
        },
        onUpgrade: (db, oldVersion, newVersion) async {
          if (oldVersion < 2) {
            await db.execute('''
              CREATE TABLE IF NOT EXISTS last_read (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                surah_number INTEGER,
                ayah_number INTEGER,
                surah_name TEXT,
                arabic_name TEXT,
                timestamp INTEGER
              )
            ''');
            print('Database upgraded from version $oldVersion to $newVersion: Added last_read table');
          }
          if (oldVersion < 3) {
            await db.execute('ALTER TABLE last_read ADD COLUMN source TEXT');
            print('Database upgraded from version $oldVersion to $newVersion: Added source column to last_read table');
          }
          if (oldVersion < 4) {
            await db.execute('ALTER TABLE last_read ADD COLUMN parah_number INTEGER');
            print('Database upgraded from version $oldVersion to $newVersion: Added parah_number column to last_read table');
          }
        },
      );
    } catch (e) {
      if (attempt < _maxRetryAttempts) {
        print('Database initialization failed (Attempt $attempt/$_maxRetryAttempts): $e. Retrying in $_retryDelayMs ms...');
        await Future.delayed(Duration(milliseconds: _retryDelayMs));
        return _initDatabaseWithRetry(attempt: attempt + 1);
      }
      throw Exception('Database initialization failed after $_maxRetryAttempts attempts: $e');
    }
  }

  static Future<void> insertPrayerTimes({
    required String date,
    required String location,
    required String juristicMethod,
    required Map<String, String> prayerTimes,
  }) async {
    final db = await database;
    await db.delete('prayer_times', where: 'date = ? AND juristic_method = ?', whereArgs: [date, juristicMethod]);
    await db.insert('prayer_times', {
      'date': date,
      'location': location,
      'juristic_method': juristicMethod,
      'fajr': prayerTimes['Fajr'],
      'sunrise': prayerTimes['Sunrise'],
      'dhuhr': prayerTimes['Dhuhr'],
      'asr': prayerTimes['Asr'],
      'maghrib': prayerTimes['Maghrib'],
      'isha': prayerTimes['Isha'],
    });
  }

  static Future<Map<String, dynamic>?> getPrayerTimes(String date, String juristicMethod) async {
    final db = await database;
    final result = await db.query(
      'prayer_times',
      where: 'date = ? AND juristic_method = ?',
      whereArgs: [date, juristicMethod],
    );
    if (result.isNotEmpty) {
      return result.first;
    }
    return null;
  }

  static Future<void> clearPrayerTimes() async {
    final db = await database;
    await db.delete('prayer_times');
  }

  static Future<void> close() async {
    if (_database != null && _database!.isOpen) {
      try {
        await _database!.close();
        _database = null;
        print('Database closed successfully');
      } catch (e) {
        print('Failed to close database: $e');
      }
    }
  }

  static Future<void> reopen() async {
    if (_database == null || !_database!.isOpen) {
      _database = await _initDatabaseWithRetry();
      print('Database reopened successfully');
    }
  }

  // New method to get a random ayah
  static Future<Map<String, dynamic>> getRandomAyah() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM ayahs_table');
    final int count = Sqflite.firstIntValue(result) ?? 0;
    if (count == 0) {
      throw Exception('No ayahs found in the database');
    }
    final random = Random();
    final int randomId = random.nextInt(count) + 1; // +1 because id starts from 1
    final List<Map<String, dynamic>> ayah = await db.query(
      'ayahs_table',
      where: 'id = ?',
      whereArgs: [randomId],
    );
    if (ayah.isNotEmpty) {
      return ayah.first;
    } else {
      // Fallback to id 1 if the random query fails
      return (await db.query('ayahs_table', where: 'id = ?', whereArgs: [1])).first;
    }
  }
}