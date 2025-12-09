import 'package:flutter/material.dart';
import 'package:hidaya_app/repository/quran_repository.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:sqflite/sqflite.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  double arabicFontSize = 22.0;
  double translationFontSize = 14.0;
  double ayahEndSignFontSize = 12.0;

  @override
  void initState() {
    super.initState();
    _loadFontSizes();
    _fetchAyahs();
  }

  Future<void> _loadFontSizes() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      arabicFontSize = prefs.getDouble('arabicFontSize') ?? 22.0;
      translationFontSize = prefs.getDouble('translationFontSize') ?? 14.0;
      ayahEndSignFontSize = prefs.getDouble('ayahEndSignFontSize') ?? 12.0;
    });
  }

  Future<void> _fetchAyahs() async {
    try {
      final parahInfo = QuranData.parahRanges.firstWhere(
            (parah) => parah['para_number'] == widget.parahNumber,
        orElse: () => {"surahs": []},
      );
      print("Parah number: ${widget.parahNumber}");

      List<Map<String, dynamic>> allAyahs = [];
      final db = await DatabaseHelper.database;
      int cumulativeIndex = 0;
      bool foundLastRead = false;

      for (var surah in parahInfo['surahs']) {
        final surahNumber = surah['surah_number'] as int? ?? 1;
        final startAyah = (surah['start_ayah'] as num?)?.toInt() ?? 1;
        final endAyah = (surah['end_ayah'] as num?)?.toInt() ?? 1;
        final verseCount = (endAyah >= startAyah) ? endAyah - startAyah + 1 : 1;

        int preloadStart = 1;
        int preloadEnd = verseCount;
        if (widget.lastReadSurah == surahNumber &&
            widget.lastReadAyah != null) {
          final lastReadAyah = widget.lastReadAyah!.clamp(1, verseCount);
          preloadStart = (lastReadAyah - 5).clamp(1, verseCount);
          preloadEnd = (lastReadAyah + 5).clamp(1, verseCount);
          lastReadIndex = cumulativeIndex + 1 + (lastReadAyah - 1);
          foundLastRead = true;
        }

        final List<Map<String, dynamic>> result = await db.query(
          'ayahs_table',
          where: 'id BETWEEN ? AND ?',
          whereArgs: [startAyah, endAyah],
          orderBy: 'id ASC',
        );

        allAyahs.add({'surah_info': surah, 'ayahs': result});

        cumulativeIndex += 1 + result.length;

        print("Fetched Ayahs $startAyah to $endAyah for Surah $surahNumber");
      }
      if (!mounted) return;
      setState(() {
        groupedAyahs = allAyahs;
        isLoading = false;
      });

      if (foundLastRead && widget.lastReadAyah != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.isAttached) {
            _scrollController.jumpTo(index: lastReadIndex, alignment: 0.5);
            print(
              "Scrolled to Surah ${widget.lastReadSurah}, Ayah ${widget.lastReadAyah} (index $lastReadIndex)",
            );
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

      print(
        "Fetched ${groupedAyahs.length} Surahs for Parah ${widget.parahNumber}",
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        errorMessage = "Failed to fetch ayahs: $e";
        isLoading = false;
      });
      print(errorMessage);
    }
  }

  void _saveLastRead(
      int surahNumber,
      int ayahIndex,
      String surahName,
      String arabicName,
      ) async {
    await QuranRepository.updateLastRead(
      surahNumber: surahNumber,
      ayahIndex: ayahIndex,
      surahName: surahName,
      arabicName: arabicName,
      source: 'parah',
      parahNumber: widget.parahNumber,
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
    double tempAyahEndSignFontSize = ayahEndSignFontSize;

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
        title: const Text(
          'Adjust Font Sizes',
          style: TextStyle(
            fontFamily: 'Poppins',
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
                    'Arabic Text Size:',
                    style: TextStyle(fontFamily: 'Poppins', fontSize: 14, color: Theme.of(context).colorScheme.onSurface,)
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
                    'Translation Text Size:',
                    style: TextStyle(fontFamily: 'Poppins', fontSize: 14,color: Theme.of(context).colorScheme.onSurface,),
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
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  AyahCard(
                    index: 1,
                    arabicText: 'الْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ',
                    translationText:
                    'تمام تعریفیں اللہ کے لیے ہیں جو تمام جہانوں کا رب ہے',
                    showTranslation: showTranslation,
                    isLastRead: false,
                    arabicFontSize: tempArabicFontSize,
                    translationFontSize: tempTranslationFontSize,
                    ayahEndSignFontSize: tempAyahEndSignFontSize,
                    onLongPress: () {},
                  ),
                ],
              ),
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(fontFamily: 'Poppins', fontSize: 14),
            ),
          ),
          TextButton(
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.setDouble('arabicFontSize', tempArabicFontSize);
              await prefs.setDouble(
                'translationFontSize',
                tempTranslationFontSize,
              );
              await prefs.setDouble(
                'ayahEndSignFontSize',
                tempAyahEndSignFontSize,
              );
              if (!mounted) return;
              setState(() {
                arabicFontSize = tempArabicFontSize;
                translationFontSize = tempTranslationFontSize;
                ayahEndSignFontSize = tempAyahEndSignFontSize;
              });
              Navigator.pop(context);
            },
            child: const Text(
              'Apply',
              style: TextStyle(fontFamily: 'Poppins', fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = MediaQuery.of(context).size.height;

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
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'adjust_font_size',
                  child: Text(
                    'Adjust Font Size',
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
      backgroundColor: Theme.of(context).colorScheme.background,
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
        itemCount: totalItems,
        itemBuilder: (context, index) {
          int currentIndex = 0;
          for (var surahData in groupedAyahs) {
            final surahInfo = surahData['surah_info'];
            final ayahs =
            surahData['ayahs'] as List<Map<String, dynamic>>;
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

            for (
            int ayahIndex = 0;
            ayahIndex < ayahs.length;
            ayahIndex++
            ) {
              if (index == currentIndex) {
                final ayah = ayahs[ayahIndex];
                print(
                  "Rendering index $index: Surah $surahNumber, Ayah ${ayahIndex + 1}",
                );
                return AyahCard(
                  index: ayahIndex + 1,
                  arabicText:
                  ayah['arabic_text'] ?? 'No text available',
                  translationText:
                  ayah['translation_text'] ??
                      'No translation available',
                  showTranslation: showTranslation,
                  isLastRead:
                  widget.lastReadSurah == surahNumber &&
                      widget.lastReadAyah == (ayahIndex + 1),
                  arabicFontSize: arabicFontSize,
                  translationFontSize: translationFontSize,
                  ayahEndSignFontSize: ayahEndSignFontSize,
                  onLongPress: () {
                    showDialog(
                      context: context,
                      builder:
                          (context) => AlertDialog(
                        title: Text('Ayah ${ayahIndex + 1}',style: TextStyle(color: Theme.of(context).colorScheme.onSurface,),),
                        content: Text(
                          'Do you want to set this ayah as your last read?',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
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
                              _saveLastRead(
                                surahNumber,
                                ayahIndex,
                                surahInfo['surah_name'] ??
                                    'Unknown Surah',
                                surahInfo['arabic_name'] ??
                                    'Unknown Arabic',
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
          colors: [Color(0xFF44C17B), Color(0xFF205B3A)],
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
  final double arabicFontSize;
  final double translationFontSize;
  final double ayahEndSignFontSize;
  final VoidCallback onLongPress;

  const AyahCard({
    Key? key,
    required this.index,
    required this.arabicText,
    required this.translationText,
    required this.showTranslation,
    required this.onLongPress,
    this.isLastRead = false,
    required this.arabicFontSize,
    required this.translationFontSize,
    required this.ayahEndSignFontSize,
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
            color: isLastRead ? Colors.green.withOpacity(0.1) : Theme.of(context).colorScheme.surface,
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
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
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
                          color: Theme.of(context).colorScheme.onSurface,
                          fontSize: arabicFontSize,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextSpan(
                        text: ' ۝',
                        style: TextStyle(
                          fontFamily: 'NotoNaskhArabic',
                          color: Theme.of(context).colorScheme.onSurface,
                          fontSize: ayahEndSignFontSize,
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
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.bold,
                      color: AppColors.main,
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
