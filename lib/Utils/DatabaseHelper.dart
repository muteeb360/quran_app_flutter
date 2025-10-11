import 'dart:async';
import 'dart:io' as io;
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle, ByteData;
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  DatabaseHelper._();

  static Database? _database;
  static Completer<Database>? _initCompleter;

  static const int _maxRetryAttempts = 3;
  static const int _initialRetryDelayMs = 500;
  static const int _version = 4; // Keep your version

  /// Get database (singleton). Prevents concurrent inits.
  static Future<Database> get database async {
    if (_database != null && _database!.isOpen) return _database!;
    if (_initCompleter != null) return _initCompleter!.future;

    _initCompleter = Completer();
    try {
      _database = await _initDatabaseWithRetry();
      _initCompleter!.complete(_database);
    } catch (e, st) {
      if (!_initCompleter!.isCompleted) _initCompleter!.completeError(e, st);
      rethrow;
    } finally {
      // allow future re-init if needed by clearing completer only on success/failure handled above
      _initCompleter = null;
    }
    return _database!;
  }

  /// Initialize database with retry and exponential backoff.
  static Future<Database> _initDatabaseWithRetry({int attempt = 1}) async {
    try {
      final documentsDirectory = await getApplicationDocumentsDirectory();
      final dbPath = join(documentsDirectory.path, "quran.db");

      if (!await io.File(dbPath).exists()) {
        // copy bundled asset on first run
        final ByteData data = await rootBundle.load('assets/database/quran.db');
        final bytes = data.buffer.asUint8List(
          data.offsetInBytes,
          data.lengthInBytes,
        );
        await io.File(dbPath).writeAsBytes(bytes, flush: true);
      }

      return await openDatabase(
        dbPath,
        version: _version,
        onCreate: (db, version) async {
          // create lightweight tables you need
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

          // indexes for faster filtering/grouping
          await db.execute(
            'CREATE INDEX IF NOT EXISTS idx_prayer_times_date_method ON prayer_times(date, juristic_method)',
          );
          // supplications table indexes (if you have this table in bundled DB)
          await db.execute(
            'CREATE INDEX IF NOT EXISTS idx_supplications_category ON supplications(category)',
          );
          await db.execute(
            'CREATE INDEX IF NOT EXISTS idx_supplications_subcategory ON supplications(subcategory)',
          );
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
          }
          if (oldVersion < 3) {
            // safe add column: using try/catch because some sqlite versions will throw if column exists
            try {
              await db.execute('ALTER TABLE last_read ADD COLUMN source TEXT');
            } catch (_) {}
          }
          if (oldVersion < 4) {
            try {
              await db.execute(
                'ALTER TABLE last_read ADD COLUMN parah_number INTEGER',
              );
            } catch (_) {}
          }

          // ensure indexes exist after upgrade
          try {
            await db.execute(
              'CREATE INDEX IF NOT EXISTS idx_prayer_times_date_method ON prayer_times(date, juristic_method)',
            );
            await db.execute(
              'CREATE INDEX IF NOT EXISTS idx_supplications_category ON supplications(category)',
            );
            await db.execute(
              'CREATE INDEX IF NOT EXISTS idx_supplications_subcategory ON supplications(subcategory)',
            );
          } catch (_) {}
        },
      );
    } catch (e) {
      if (attempt < _maxRetryAttempts) {
        final delay = _initialRetryDelayMs * pow(2, attempt - 1).toInt();
        await Future.delayed(Duration(milliseconds: delay));
        return _initDatabaseWithRetry(attempt: attempt + 1);
      }
      rethrow;
    }
  }

  /// Safe close
  static Future<void> close() async {
    try {
      if (_database != null && _database!.isOpen) {
        await _database!.close();
        _database = null;
      }
    } catch (e) {
      // swallow or log
      print('Error closing DB: $e');
    }
  }

  /// Reopen helper (if needed)
  static Future<void> reopen() async {
    if (_database == null || !_database!.isOpen) {
      _database = await _initDatabaseWithRetry();
    }
  }

  /// Example optimized random ayah (single query)
  static Future<Map<String, dynamic>> getRandomAyah() async {
    final db = await database;
    final rows = await db.rawQuery(
      'SELECT * FROM ayahs_table ORDER BY RANDOM() LIMIT 1',
    );
    if (rows.isNotEmpty) return rows.first;
    throw Exception('No ayahs found');
  }

  /// Use this to do heavy processing in an isolate AFTER fetching results.
  /// Fetch in main isolate (sqflite safe), then call compute for CPU-heavy tasks.
  static Future<List<Map<String, dynamic>>> queryAndProcess(
      String table, {
        String? where,
        List<Object?>? whereArgs,
        bool processInIsolate = false,
      }) async {
    final db = await database;
    final rows = await db.query(table, where: where, whereArgs: whereArgs);
    if (!processInIsolate) return rows;
    // DO NOT perform DB queries inside an isolate. Only pass raw data for processing.
    final processed = await compute(_heavyProcessRows, rows);
    return processed;
  }

  /// Example heavy processing function to run in compute()
  static List<Map<String, dynamic>> _heavyProcessRows(
      List<Map<String, dynamic>> rows,
      ) {
    // do CPU-heavy transformations here
    return rows.map((r) {
      final copy = Map<String, dynamic>.from(r);
      // example: add derived field
      if (copy.containsKey('english')) {
        final v = copy['english'];
        if (v is String && v.isNotEmpty)
          copy['english_upper'] = v.toUpperCase();
      }
      return copy;
    }).toList();
  }

  /* Prayer times helpers (unchanged but safe) */
  static Future<void> insertPrayerTimes({
    required String date,
    required String location,
    required String juristicMethod,
    required Map<String, String> prayerTimes,
  }) async {
    final db = await database;
    // keep only one row per date + method
    await db.delete(
      'prayer_times',
      where: 'date = ? AND juristic_method = ?',
      whereArgs: [date, juristicMethod],
    );
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

  static Future<Map<String, dynamic>?> getPrayerTimes(
      String date,
      String juristicMethod,
      ) async {
    final db = await database;
    final result = await db.query(
      'prayer_times',
      where: 'date = ? AND juristic_method = ?',
      whereArgs: [date, juristicMethod],
    );
    if (result.isNotEmpty) return result.first;
    return null;
  }

  static Future<void> clearPrayerTimes() async {
    final db = await database;
    await db.delete('prayer_times');
  }

  /* Supplication queries (same sql but ensure indexes exist) */
  static Future<List<Map<String, dynamic>>> getSupplicationCategories() async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT category, COUNT(*) as total_supplications 
      FROM supplications 
      GROUP BY category
    ''');
    return result;
  }

  static Future<List<Map<String, dynamic>>> getSupplicationSubCategories(
      String category,
      ) async {
    final db = await database;
    final result = await db.rawQuery(
      '''
      SELECT subcategory, COUNT(*) as total_supplications 
      FROM supplications 
      WHERE category = ?
      GROUP BY subcategory
    ''',
      [category],
    );
    return result;
  }

  static Future<List<Map<String, dynamic>>> getSupplicationsBySubCategory(
      String subcategory,
      ) async {
    final db = await database;
    final result = await db.query(
      'supplications',
      columns: ['arabic', 'urdu', 'english', 'source'],
      where: 'subcategory = ?',
      whereArgs: [subcategory],
    );
    return result;
  }
}
