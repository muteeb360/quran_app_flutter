import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import '../Utils/DatabaseHelper.dart';

/// A small repository that caches DB results in memory and exposes ValueNotifiers
/// so UI can listen to changes without heavy rebuilds.
class QuranRepository {
  // cached primitive data
  static final ValueNotifier<List<int>> favoriteSurahIds = ValueNotifier([]);
  static final ValueNotifier<Map<String, dynamic>?> lastRead = ValueNotifier(
    null,
  );

  /// Call this once early (e.g., app startup or before first screen) to load cached data.
  static Future<void> init() async {
    try {
      final db = await DatabaseHelper.database;
      // Load favorites
      final favRows = await db.query('favorites');
      final favIds = favRows.map<int>((r) => (r['id'] as int)).toList();
      favoriteSurahIds.value = favIds;

      // Load last_read (most recent)
      final lr = await db.query(
        'last_read',
        orderBy: 'timestamp DESC',
        limit: 1,
      );
      if (lr.isNotEmpty) {
        lastRead.value = lr.first;
      } else {
        lastRead.value = {
          'surah_number': 1,
          'ayah_number': 1,
          'surah_name': 'Al-Fatihah',
          'arabic_name': 'الفَاتِحَة',
          'source': 'surah',
        };
      }
    } catch (e) {
      // provide sensible defaults on error
      favoriteSurahIds.value = [];
      lastRead.value = {
        'surah_number': 1,
        'ayah_number': 1,
        'surah_name': 'Al-Fatihah',
        'arabic_name': 'الفَاتِحَة',
        'source': 'surah',
      };
    }
  }

  /// Toggle favorite in DB and update notifier
  static Future<void> toggleFavorite(
      int surahId,
      Map<String, String> surah,
      ) async {
    try {
      final db = await DatabaseHelper.database;
      final current = List<int>.from(favoriteSurahIds.value);
      if (current.contains(surahId)) {
        await db.delete('favorites', where: 'id = ?', whereArgs: [surahId]);
        current.remove(surahId);
        favoriteSurahIds.value = current;
      } else {
        final englishName = surah['name'] ?? 'Unknown Surah';
        final arabicName = surah['arabic'] ?? 'Unknown Arabic';
        final totalVerses = surah['verses'] ?? '0';
        await db.insert('favorites', {
          'id': surahId,
          'english_name': englishName,
          'arabic_name': arabicName,
          'total_verses': totalVerses,
        }, conflictAlgorithm: ConflictAlgorithm.replace);
        current.add(surahId);
        favoriteSurahIds.value = current;
      }
    } catch (e) {
      // log or handle error according to your telemetry strategy
      print('toggleFavorite error: $e');
    }
  }

  /// Returns the list of favorite records (full rows) from DB.
  /// Use this sparingly; UI that needs the list should call this once and keep results.
  static Future<List<Map<String, dynamic>>> fetchFavoriteRecords() async {
    final db = await DatabaseHelper.database;
    return await db.query('favorites', orderBy: 'english_name');
  }

  /// Update last_read both in DB and cache
  static Future<void> updateLastRead({
    required int surahNumber,
    required int ayahIndex,
    required String surahName,
    required String arabicName,
    required String source,
    int? parahNumber,
    BuildContext? context,
  }) async {
    try {
      final db = await DatabaseHelper.database;
      final int actualAyahNumber = ayahIndex + 1; // Convert to 1-based indexing

      // Prepare data map
      final data = {
        'surah_number': surahNumber,
        'ayah_number': actualAyahNumber,
        'surah_name': surahName,
        'arabic_name': arabicName,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'source': source,
        if (parahNumber != null) 'parah_number': parahNumber,
      };

      // Delete existing record and insert new one
      await db.delete('last_read');
      await db.insert(
        'last_read',
        data,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      // Update the ValueNotifier
      lastRead.value = data;

      print(
        "Saved last read: Surah $surahNumber, Ayah $actualAyahNumber, Source: $source",
      );

      // Show SnackBar if context is provided
      if (context != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Last read updated: $surahName, Ayah $actualAyahNumber',
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      print("Failed to save last read: $e");
      if (context != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to update last read'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }
}
