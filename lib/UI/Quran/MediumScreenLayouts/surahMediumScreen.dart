import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sqflite/sqflite.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import '../../../Utils/colors.dart';
import '../../../Utils/QuranData.dart';
import 'package:hidaya_app/Utils/DatabaseHelper.dart';

class SurahMediumScreen extends StatefulWidget {
  final int surahNumber;
  final int? lastReadAyah;

  const SurahMediumScreen({
    Key? key,
    required this.surahNumber,
    this.lastReadAyah,
  }) : super(key: key);

  @override
  State<SurahMediumScreen> createState() => _SurahMediumScreenState();
}

class _SurahMediumScreenState extends State<SurahMediumScreen> {
  List<Map<String, dynamic>?> ayahs = []; // Nullable for unfetched Ayahs
  bool isLoading = true;
  String? errorMessage;
  bool showTranslation = true;
  final ItemScrollController _scrollController = ItemScrollController();
  int surahStart = 1;
  int totalAyahs = 0;
  int lastReadAyahIndex = 0; // 0-based index of last read Ayah

  @override
  void initState() {
    super.initState();
    _fetchLastReadAyah();
  }

  Future<void> _fetchLastReadAyah() async {
    try {
      final surahInfo = QuranData.surahRanges.firstWhere(
            (surah) => surah['surah_number'] == widget.surahNumber,
        orElse: () => {"name": "Unknown Surah", "verse_count": 0},
      );
      surahStart = (surahInfo['start_ayah'] as num? ?? 1).toInt();
      totalAyahs = (surahInfo['verse_count'] as num? ?? 0).toInt();

      // Initialize ayahs list with nulls
      ayahs = List<Map<String, dynamic>?>.filled(totalAyahs, null);

      // Determine last read Ayah (default to 1 if invalid)
      int lastReadAyah = widget.lastReadAyah != null && widget.lastReadAyah! > 0 && widget.lastReadAyah! <= totalAyahs
          ? widget.lastReadAyah!
          : 1;
      lastReadAyahIndex = lastReadAyah - 1; // 0-based

      // Fetch a range around last read Ayah (±10 Ayahs)
      final db = await DatabaseHelper.database;
      final startAyah = (lastReadAyah - 10).clamp(1, totalAyahs);
      final endAyah = (lastReadAyah + 10).clamp(1, totalAyahs);
      final List<Map<String, dynamic>> result = await db.query(
        'ayahs_table',
        where: 'id BETWEEN ? AND ?',
        whereArgs: [surahStart + startAyah - 1, surahStart + endAyah - 1],
        orderBy: 'id ASC',
      );

      if (result.isNotEmpty) {
        setState(() {
          for (int i = startAyah - 1; i < endAyah; i++) {
            if (i - (startAyah - 1) < result.length) {
              ayahs[i] = result[i - (startAyah - 1)];
            }
          }
          isLoading = false;
        });
        print("Fetched Ayahs $startAyah to $endAyah: ${result.length} Ayahs");
      } else {
        throw Exception("Ayahs $startAyah to $endAyah not found");
      }

      // Scroll to last read Ayah
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.isAttached) {
          _scrollController.jumpTo(
            index: lastReadAyahIndex + 1, // +1 for header
            alignment: 0.5, // Center in viewport
          );
          print("Scrolled to Ayah $lastReadAyah (index ${lastReadAyahIndex + 1})");
          // Animate for smoother transition
          Future.delayed(Duration(milliseconds: 100), () {
            if (_scrollController.isAttached) {
              _scrollController.scrollTo(
                index: lastReadAyahIndex + 1,
                duration: Duration(milliseconds: 500),
                curve: Curves.easeInOut,
                alignment: 0.5,
              );
            }
          });
        }
      });

      // Fetch remaining Ayahs asynchronously
      _fetchRemainingAyahs();
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
      int chunkSize = 20;

      // Fetch Ayahs below last read Ayah
      int currentAyah = lastReadAyahIndex + 11; // Start after preloaded range
      while (currentAyah <= totalAyahs) {
        int endAyah = (currentAyah + chunkSize - 1).clamp(1, totalAyahs);
        print("Fetching Ayahs $currentAyah to $endAyah (below)");
        final List<Map<String, dynamic>> result = await db.query(
          'ayahs_table',
          where: 'id BETWEEN ? AND ?',
          whereArgs: [surahStart + currentAyah - 1, surahStart + endAyah - 1],
          orderBy: 'id ASC',
        );

        setState(() {
          for (int i = currentAyah - 1; i < endAyah; i++) {
            if (i - (currentAyah - 1) < result.length) {
              ayahs[i] = result[i - (currentAyah - 1)];
            }
          }
        });

        currentAyah = endAyah + 1;
        await Future.delayed(Duration(milliseconds: 100)); // Prevent UI freeze
      }

      // Fetch Ayahs above last read Ayah
      currentAyah = lastReadAyahIndex - 9; // Start before preloaded range
      while (currentAyah >= 1) {
        int startAyah = (currentAyah - chunkSize + 1).clamp(1, totalAyahs);
        print("Fetching Ayahs $startAyah to $currentAyah (above)");
        final List<Map<String, dynamic>> result = await db.query(
          'ayahs_table',
          where: 'id BETWEEN ? AND ?',
          whereArgs: [surahStart + startAyah - 1, surahStart + currentAyah - 1],
          orderBy: 'id ASC',
        );

        setState(() {
          for (int i = startAyah - 1; i < currentAyah; i++) {
            if (i - (startAyah - 1) < result.length) {
              ayahs[i] = result[i - (startAyah - 1)];
            }
          }
        });

        currentAyah = startAyah - 1;
        await Future.delayed(Duration(milliseconds: 100)); // Prevent UI freeze
      }
    } catch (e) {
      print("Failed to fetch remaining ayahs: $e");
    }
  }

  Future<void> _saveLastRead(int ayahIndex) async {
    try {
      final surahInfo = QuranData.surahRanges.firstWhere(
            (surah) => surah['surah_number'] == widget.surahNumber,
        orElse: () => {"name": "Unknown Surah"},
      );
      final surahName = surahInfo['name'] ?? 'Unknown Surah';
      final arabicName = surahInfo['arabic_name'] ?? 'Unknown Arabic Name';
      final int actualAyahNumber = ayahIndex + 1; // 1-based

      final db = await DatabaseHelper.database;
      await db.delete('last_read');
      await db.insert(
        'last_read',
        {
          'surah_number': widget.surahNumber,
          'ayah_number': actualAyahNumber,
          'surah_name': surahName,
          'arabic_name': arabicName,
          'timestamp': DateTime.now().millisecondsSinceEpoch,
          'source': 'surah',
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      print("Saved last read: Surah ${widget.surahNumber}, Ayah $actualAyahNumber");

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Last read updated: $surahName, Ayah $actualAyahNumber'),
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

  @override
  void dispose() {
    super.dispose();
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

    final surahInfo = QuranData.surahRanges.firstWhere(
          (surah) => surah['surah_number'] == widget.surahNumber,
      orElse: () => {"name": "Unknown Surah"},
    );
    final surahName = surahInfo['name'] ?? 'Unknown Surah';
    final int totalAyahs = (surahInfo['verse_count'] as num? ?? 0).toInt();
    final arabicName = surahInfo['arabic_name'] ?? 'Unknown arabic name';

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          '$surahName  |  $arabicName',
          style: GoogleFonts.poppins(
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
                    style: GoogleFonts.poppins(
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
        itemCount: totalAyahs + 1, // +1 for header
        itemBuilder: (context, index) {
          if (index == 0) {
            return Container(
              width: screenWidth * 0.9,
              height: screenHeight * 0.22,
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
                            "Ayats: $totalAyahs",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w200,
                            ),
                          ),
                          Text(
                            "$arabicName",
                            style: TextStyle(
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
                              style: TextStyle(color: Colors.white, fontSize: 13),
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
          final ayahIndex = index - 1;
          final ayah = ayahs[ayahIndex];
          if (ayah == null) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          return Padding(
            padding: EdgeInsets.only(top: ayahIndex == 0 ? 16.0 : 0),
            child: AyahCard(
              index: ayahIndex, // 0-based
              displayAyahNumber: ayahIndex + 1, // 1-based
              arabicText: ayah['arabic_text'] ?? 'No text available',
              translationText: ayah['translation_text'] ?? 'No translation available',
              showTranslation: showTranslation,
              isLastRead: ayahIndex + 1 == (widget.lastReadAyah ?? 1),
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
                          _saveLastRead(ayahIndex);
                          Navigator.pop(context);
                        },
                        child: const Text('Add Last Read'),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class AyahCard extends StatelessWidget {
  final int index;
  final int displayAyahNumber;
  final String arabicText;
  final String translationText;
  final bool showTranslation;
  final bool isLastRead;
  final VoidCallback onLongPress;

  const AyahCard({
    Key? key,
    required this.index,
    required this.displayAyahNumber,
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
            color: isLastRead ? Colors.green.withOpacity(0.1) : Colors.white,
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '﴾$displayAyahNumber﴿',
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