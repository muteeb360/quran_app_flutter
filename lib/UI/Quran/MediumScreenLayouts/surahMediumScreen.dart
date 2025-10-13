import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sqflite/sqflite.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import '../../../Utils/colors.dart';
import '../../../Utils/QuranData.dart';
import 'package:hidaya_app/Utils/DatabaseHelper.dart';
import 'package:hidaya_app/repository/quran_repository.dart';

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
  double arabicFontSize = 22.0; // Default Arabic text size
  double translationFontSize = 14.0; // Default translation text size

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
      int lastReadAyah =
      widget.lastReadAyah != null &&
          widget.lastReadAyah! > 0 &&
          widget.lastReadAyah! <= totalAyahs
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
        if (!mounted) return;
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
          print(
            "Scrolled to Ayah $lastReadAyah (index ${lastReadAyahIndex + 1})",
          );
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
      if (!mounted) return;
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
        if (!mounted) return;
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
        if (!mounted) return;
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

  void _saveLastRead(int ayahIndex) async {
    final surahInfo = QuranData.surahRanges.firstWhere(
          (surah) => surah['surah_number'] == widget.surahNumber,
      orElse:
          () => {"name": "Unknown Surah", "arabic_name": "Unknown Arabic Name"},
    );
    await QuranRepository.updateLastRead(
      surahNumber: widget.surahNumber,
      ayahIndex: ayahIndex,
      surahName: surahInfo['name'] ?? 'Unknown Surah',
      arabicName: surahInfo['arabic_name'] ?? 'Unknown Arabic Name',
      source: 'surah',
      context: context,
    );
  }

  void _toggleTranslation() {
    if (!mounted) return;
    setState(() {
      showTranslation = !showTranslation;
    });
  }

  void _showFontSizeDialog() {
    double tempArabicFontSize = arabicFontSize;
    double tempTranslationFontSize = translationFontSize;

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
        title: Text(
          'Adjust Font Sizes',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: StatefulBuilder(
          builder: (context, setDialogState) {
            return SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Arabic Text Size: ${tempArabicFontSize.round()}',
                    style: GoogleFonts.poppins(fontSize: 14),
                  ),
                  Slider(
                    value: tempArabicFontSize,
                    min: 12.0,
                    max: 40.0,
                    divisions: 14,
                    label: tempArabicFontSize.round().toString(),
                    onChanged: (value) {
                      setDialogState(() {
                        tempArabicFontSize = value;
                      });
                    },
                  ),
                  Text(
                    'Translation Text Size: ${tempTranslationFontSize.round()}',
                    style: GoogleFonts.poppins(fontSize: 14),
                  ),
                  Slider(
                    value: tempTranslationFontSize,
                    min: 10.0,
                    max: 30.0,
                    divisions: 10,
                    label: tempTranslationFontSize.round().toString(),
                    onChanged: (value) {
                      setDialogState(() {
                        tempTranslationFontSize = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Preview:',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  AyahCard(
                    index: 0,
                    displayAyahNumber: 1,
                    arabicText: 'الْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ',
                    translationText:
                    'تمام تعریفیں اللہ کے لیے ہیں جو تمام جہانوں کا رب ہے',
                    showTranslation: showTranslation,
                    isLastRead: false,
                    arabicFontSize: tempArabicFontSize,
                    translationFontSize: tempTranslationFontSize,
                    onLongPress: () {}, // No action for preview
                  ),
                ],
              ),
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: GoogleFonts.poppins(fontSize: 14)),
          ),
          TextButton(
            onPressed: () {
              if (!mounted) return;
              setState(() {
                arabicFontSize = tempArabicFontSize;
                translationFontSize = tempTranslationFontSize;
              });
              Navigator.pop(context);
            },
            child: Text('Apply', style: GoogleFonts.poppins(fontSize: 14)),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
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
              colors: [Color(0xFF44C17B), Color(0xFF205B3A)],
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
              } else if (value == 'adjust_font_size') {
                _showFontSizeDialog();
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem<String>(
                  value: 'toggle_translation',
                  child: Text(
                    showTranslation
                        ? 'Turn Translation Off'
                        : 'Turn Translation On',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'adjust_font_size',
                  child: Text(
                    'Adjust Font Size',
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
      body:
      isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
          ? Center(child: Text(errorMessage!))
          : ScrollablePositionedList.builder(
        itemScrollController: _scrollController,
        padding: EdgeInsets.symmetric(
          vertical: screenHeight * 0.02,
          horizontal: screenWidth * 0.05,
        ),
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
                  colors: [Color(0xFF44C17B), Color(0xFF205B3A)],
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.05,
                      ),
                      child: Row(
                        mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
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
                              style: TextStyle(
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
              translationText:
              ayah['translation_text'] ??
                  'No translation available',
              showTranslation: showTranslation,
              isLastRead: ayahIndex + 1 == (widget.lastReadAyah ?? 1),
              arabicFontSize: arabicFontSize,
              translationFontSize: translationFontSize,
              onLongPress: () {
                showDialog(
                  context: context,
                  builder:
                      (context) => AlertDialog(
                    title: Text('Ayah ${ayahIndex + 1}'),
                    content: const Text(
                      'Do you want to set this ayah as your last read?',
                    ),
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
  final double arabicFontSize;
  final double translationFontSize;
  final VoidCallback onLongPress;

  const AyahCard({
    Key? key,
    required this.index,
    required this.displayAyahNumber,
    required this.arabicText,
    required this.translationText,
    required this.showTranslation,
    required this.onLongPress,
    required this.arabicFontSize,
    required this.translationFontSize,
    this.isLastRead = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: onLongPress,
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
                RichText(
                  textDirection: TextDirection.rtl,
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: arabicText,
                        style: TextStyle(
                          fontFamily: 'NotoNaskhArabic',
                          color: Colors.black,
                          fontSize: arabicFontSize,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextSpan(
                        text: ' ۝',
                        style: TextStyle(
                          fontFamily: 'NotoNaskhArabic',
                          color: Colors.black,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                if (showTranslation) ...[
                  const SizedBox(height: 8),
                  Text(
                    translationText,
                    style: TextStyle(
                      color: AppColors.main,
                      fontWeight: FontWeight.bold,
                      fontSize: translationFontSize,
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
