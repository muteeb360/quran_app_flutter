import 'package:flutter/material.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:sqflite/sqflite.dart';
import '../../../Utils/colors.dart';
import '../../../Utils/QuranData.dart';
import 'package:hidaya_app/Utils/DatabaseHelper.dart';

class ParaMediumScreen extends StatefulWidget {
  final int parahNumber;
  final int? lastReadAyah;
  final int? lastReadSurah;

  const ParaMediumScreen({
    Key? key,
    required this.parahNumber,
    this.lastReadAyah,
    this.lastReadSurah,
  }) : super(key: key);

  @override
  State<ParaMediumScreen> createState() => _ParaMediumScreenState();
}

class _ParaMediumScreenState extends State<ParaMediumScreen> {
  List<Map<String, dynamic>> groupedAyahs = [];
  bool isLoading = true;
  String? errorMessage;
  bool showTranslation = true;
  final ItemScrollController _scrollController = ItemScrollController();
  int lastReadIndex = 0;

  @override
  void initState() {
    super.initState();
    _fetchAyahs();
  }

  Future<void> _fetchAyahs() async {
    try {
      final parahInfo = QuranData.parahRanges.firstWhere(
            (parah) => parah['para_number'] == widget.parahNumber,
        orElse: () => {"surahs": []},
      );

      List<Map<String, dynamic>> allAyahs = [];
      final db = await DatabaseHelper.database;
      int cumulativeIndex = 0;
      bool foundLastRead = false;

      for (var surah in parahInfo['surahs']) {
        final surahNumber = surah['surah_number'] as int? ?? 1;
        final startAyah = (surah['start_ayah'] as num?)?.toInt() ?? 1;
        final endAyah = (surah['end_ayah'] as num?)?.toInt() ?? 1;
        final startDbId = (surah['start_db_id'] as num?)?.toInt() ?? 1;
        final verseCount = (endAyah >= startAyah) ? endAyah - startAyah + 1 : 1;

        int? preloadStart;
        int? preloadEnd;
        if (widget.lastReadSurah == surahNumber && widget.lastReadAyah != null) {
          final lastReadAyah = widget.lastReadAyah!.clamp(1, verseCount);
          // Preload ±5 Ayahs to show more placeholders
          preloadStart = (lastReadAyah - 5).clamp(1, verseCount);
          preloadEnd = (lastReadAyah + 5).clamp(1, verseCount);
          lastReadIndex = cumulativeIndex + 1 + (lastReadAyah - 1);
          foundLastRead = true;
        } else {
          preloadStart = 1;
          preloadEnd = (verseCount >= 5) ? 5 : verseCount;
        }

        List<Map<String, dynamic>?> ayahsList = List.filled(verseCount, null);

        // Fetch preload range
        final List<Map<String, dynamic>> result = await db.query(
          'ayahs_table',
          where: 'id BETWEEN ? AND ?',
          whereArgs: [
            startDbId + (preloadStart - 1),
            startDbId + (preloadEnd - 1),
          ],
          orderBy: 'id ASC',
        );

        for (int i = preloadStart - 1; i < preloadEnd; i++) {
          if (i - (preloadStart - 1) < result.length) {
            ayahsList[i] = result[i - (preloadStart - 1)];
          }
        }

        allAyahs.add({
          'surah_info': surah,
          'ayahs': ayahsList,
        });

        cumulativeIndex += 1 + verseCount;

        print("Fetched Ayahs $preloadStart to $preloadEnd for Surah $surahNumber");
      }

      setState(() {
        groupedAyahs = allAyahs;
        isLoading = false;
      });

      if (foundLastRead && widget.lastReadAyah != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.isAttached) {
            _scrollController.jumpTo(
              index: lastReadIndex,
              alignment: 0.5,
            );
            print("Scrolled to Surah ${widget.lastReadSurah}, Ayah ${widget.lastReadAyah} (index $lastReadIndex)");
            Future.delayed(Duration(milliseconds: 200), () {
              if (_scrollController.isAttached) {
                _scrollController.scrollTo(
                  index: lastReadIndex,
                  duration: Duration(milliseconds: 500),
                  curve: Curves.easeInOut,
                  alignment: 0.5,
                );
              }
            });
          }
        });
      }

      if (allAyahs.isNotEmpty) {
        _fetchRemainingAyahs();
      }

      print("Fetched ${groupedAyahs.length} Surahs for Parah ${widget.parahNumber}");
    } catch (e) {
      setState(() {
        errorMessage = "Failed to fetch ayahs: $e";
        isLoading = false;
      });
      print(errorMessage);
    }
  }

  Future<void> _fetchRemainingAyahs() async {
    try {
      final db = await DatabaseHelper.database;
      int chunkSize = 10; // Smaller chunks for faster updates

      for (int s = 0; s < groupedAyahs.length; s++) {
        final surahData = groupedAyahs[s];
        final surahInfo = surahData['surah_info'];
        final surahNumber = surahInfo['surah_number'] as int? ?? 1;
        List<Map<String, dynamic>?> ayahsList = List.filled(surahData['ayahs'].length, null);
        ayahsList.setAll(0, surahData['ayahs']); // Copy existing Ayahs
        final startAyah = (surahInfo['start_ayah'] as num?)?.toInt() ?? 1;
        final endAyah = (surahInfo['end_ayah'] as num?)?.toInt() ?? 1;
        final startDbId = (surahInfo['start_db_id'] as num?)?.toInt() ?? 1;
        final verseCount = (endAyah >= startAyah) ? endAyah - startAyah + 1 : 1;

        bool hasNulls = ayahsList.any((ayah) => ayah == null);
        if (!hasNulls) {
          print("No null Ayahs for Surah $surahNumber, skipping fetch");
          continue;
        }

        // Fetch all null Ayahs in chunks
        for (int i = 0; i < verseCount; i += chunkSize) {
          int start = i + 1;
          int end = (i + chunkSize).clamp(1, verseCount);
          if (ayahsList.getRange(start - 1, end).every((ayah) => ayah != null)) {
            continue; // Skip if chunk is fully loaded
          }

          print("Fetching Ayahs $start to $end for Surah $surahNumber");
          final result = await db.query(
            'ayahs_table',
            where: 'id BETWEEN ? AND ?',
            whereArgs: [
              startDbId + (start - 1),
              startDbId + (end - 1),
            ],
            orderBy: 'id ASC',
          );

          setState(() {
            for (int j = start - 1; j < end; j++) {
              if (j - (start - 1) < result.length) {
                ayahsList[j] = result[j - (start - 1)];
              }
            }
            groupedAyahs[s]['ayahs'] = ayahsList;
          });

          await Future.delayed(Duration(milliseconds: 50)); // Faster updates
        }
      }
    } catch (e) {
      print("Failed to fetch remaining ayahs: $e");
    }
  }

  Future<void> _saveLastRead(int surahNumber, int ayahIndex, String surahName, String arabicName) async {
    try {
      final db = await DatabaseHelper.database;
      await db.delete('last_read');
      await db.insert(
        'last_read',
        {
          'surah_number': surahNumber,
          'ayah_number': ayahIndex + 1,
          'surah_name': surahName,
          'arabic_name': arabicName,
          'timestamp': DateTime.now().millisecondsSinceEpoch,
          'source': 'parah',
          'parah_number': widget.parahNumber,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      print("Saved last read: Surah $surahNumber, Ayah ${ayahIndex + 1}, Source: parah");

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Last read updated: $surahName, Ayah ${ayahIndex + 1}'),
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      print("Failed to save last read: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to update last read'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _toggleTranslation() {
    setState(() {
      showTranslation = !showTranslation;
    });
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;

    final parahInfo = QuranData.parahRanges.firstWhere(
          (parah) => parah['para_number'] == widget.parahNumber,
      orElse: () => {"name": "Unknown Parah"},
    );
    final parahName = parahInfo['name_english'] ?? 'Unknown Parah';
    final arabicName = parahInfo['name_arabic'] ?? 'Unknown Arabic Name';

    int totalItems = 0;
    for (var surahData in groupedAyahs) {
      final ayahs = surahData['ayahs'] as List;
      totalItems += 1 + ayahs.length;
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          '$parahName  |  $arabicName',
          style: const TextStyle(
            fontFamily: 'Poppins',
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF44C17B),
                Color(0xFF205B3A),
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
        ),
        backgroundColor: Colors.transparent,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: (value) {
              if (value == 'toggle_translation') {
                _toggleTranslation();
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem<String>(
                  value: 'toggle_translation',
                  child: Text(
                    showTranslation ? 'Turn Translation Off' : 'Turn Translation On',
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ];
            },
          ),
        ],
      ),
      backgroundColor: AppColors.background,
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
          ? Center(child: Text(errorMessage!))
          : ScrollablePositionedList.builder(
        itemScrollController: _scrollController,
        padding: EdgeInsets.symmetric(
            vertical: screenHeight * 0.02, horizontal: screenWidth * 0.05),
        itemCount: totalItems,
        itemBuilder: (context, index) {
          int currentIndex = 0;
          for (var surahData in groupedAyahs) {
            final surahInfo = surahData['surah_info'];
            final ayahs = surahData['ayahs'] as List<Map<String, dynamic>?>;
            final surahNumber = surahInfo['surah_number'] as int? ?? 1;

            if (index == currentIndex) {
              return Column(
                children: [
                  const SizedBox(height: 16),
                  SurahInfoCard(
                    surahInfo: surahInfo,
                    showTranslation: showTranslation,
                  ),
                  const SizedBox(height: 8),
                ],
              );
            }
            currentIndex++;

            for (int ayahIndex = 0; ayahIndex < ayahs.length; ayahIndex++) {
              if (index == currentIndex) {
                final ayah = ayahs[ayahIndex];
                print("Rendering index $index: Surah $surahNumber, Ayah ${ayahIndex + 1}, IsNull: ${ayah == null}");
                if (ayah == null) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                return AyahCard(
                  index: ayahIndex + 1,
                  arabicText: ayah['arabic_text'] ?? 'No text available',
                  translationText: ayah['translation_text'] ?? 'No translation available',
                  showTranslation: showTranslation,
                  isLastRead: widget.lastReadSurah == surahNumber &&
                      widget.lastReadAyah == (ayahIndex + 1),
                  onLongPress: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text('Ayah ${ayahIndex + 1}'),
                        content: const Text('Do you want to set this ayah as your last read?'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              _saveLastRead(
                                surahNumber,
                                ayahIndex,
                                surahInfo['surah_name'] ?? 'Unknown Surah',
                                surahInfo['arabic_name'] ?? 'Unknown Arabic',
                              );
                              Navigator.pop(context);
                            },
                            child: const Text('Add Last Read'),
                          ),
                        ],
                      ),
                    );
                  },
                );
              }
              currentIndex++;
            }
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class SurahInfoCard extends StatelessWidget {
  final Map<String, dynamic> surahInfo;
  final bool showTranslation;

  const SurahInfoCard({
    Key? key,
    required this.surahInfo,
    required this.showTranslation,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final surahName = surahInfo['surah_name'] ?? 'Unknown Surah';
    final arabicName = surahInfo['arabic_name'] ?? 'Unknown Arabic Name';
    final versesInPara = surahInfo['verses_in_para'] ?? 'Unknown Verses';

    return Container(
      width: screenWidth * 0.9,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF44C17B),
            Color(0xFF205B3A),
          ],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Ayahs: $versesInPara",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w200,
                    ),
                  ),
                  Text(
                    "$arabicName",
                    style: TextStyle(
                      fontFamily: 'NotoNaskhArabic',
                      color: Colors.white,
                      fontSize: screenWidth * 0.1,
                      fontWeight: FontWeight.bold,
                    ),
                    textDirection: TextDirection.rtl,
                  ),
                ],
              ),
            ),
            Container(
              height: 2,
              color: Colors.white,
              margin: const EdgeInsets.symmetric(vertical: 8),
            ),
            Center(
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  const Text(
                    "بِسْمِ ٱللَّٰهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ",
                    style: TextStyle(
                      fontFamily: 'NotoNaskhArabic',
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                    ),
                    textDirection: TextDirection.rtl,
                  ),
                  if (showTranslation) ...[
                    const SizedBox(height: 8),
                    const Text(
                      "شروع اللہ کے نام سے جو بڑا مہربان نہایت رحم والا ہے",
                      style: TextStyle(
                        fontFamily: 'NotoNaskhArabic',
                        color: Colors.white,
                        fontSize: 13,
                      ),
                      textDirection: TextDirection.rtl,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AyahCard extends StatelessWidget {
  final int index;
  final String arabicText;
  final String translationText;
  final bool showTranslation;
  final bool isLastRead;
  final VoidCallback onLongPress;

  const AyahCard({
    Key? key,
    required this.index,
    required this.arabicText,
    required this.translationText,
    required this.showTranslation,
    required this.onLongPress,
    this.isLastRead = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: onLongPress,
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        elevation: 4,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: isLastRead ? Colors.green.withOpacity(0.1
            ) : Colors.white,
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '﴾$index﴿',
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  arabicText,
                  style: const TextStyle(
                    fontFamily: 'NotoNaskhArabic',
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  textDirection: TextDirection.rtl,
                ),
                if (showTranslation) ...[
                  const SizedBox(height: 8),
                  Text(
                    translationText,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      color: AppColors.main,
                      fontSize: 14,
                    ),
                    textDirection: TextDirection.rtl,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}