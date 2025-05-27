import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import '../../../Utils/colors.dart';
import '../../../Utils/QuranData.dart';
import 'package:hidaya_app/Utils/DatabaseHelper.dart';

class ParaMediumScreen extends StatefulWidget {
  final int parahNumber;

  const ParaMediumScreen({Key? key, required this.parahNumber})
      : super(key: key);

  @override
  State<ParaMediumScreen> createState() => _ParaMediumScreenState();
}

class _ParaMediumScreenState extends State<ParaMediumScreen> {
  List<Map<String, dynamic>> groupedAyahs = [];
  bool isLoading = true;
  String? errorMessage;
  bool showTranslation = true; // State to control translation visibility

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
      for (var surah in parahInfo['surahs']) {
        final startAyah = surah['start_ayah'];
        final endAyah = surah['end_ayah'];

        final List<Map<String, dynamic>> result = await db.query(
          'ayahs_table',
          where: 'id BETWEEN ? AND ?',
          whereArgs: [startAyah, endAyah],
          orderBy: 'id ASC',
        );

        allAyahs.add({
          'surah_info': surah,
          'ayahs': result,
        });
      }

      setState(() {
        groupedAyahs = allAyahs;
        isLoading = false;
      });
      print("Fetched ${groupedAyahs.length} Surahs for Parah ${widget.parahNumber}");
    } catch (e) {
      setState(() {
        errorMessage = "Failed to fetch ayahs: $e";
        isLoading = false;
      });
      print(errorMessage);
    }
  }

  // Save the last read ayah to the database
  Future<void> _saveLastRead(int surahNumber, int ayahIndex, String surahName, String arabicName) async {
    try {
      final db = await DatabaseHelper.database;
      // Clear previous last read entries (we only want one last read)
      await db.delete('last_read');
      // Insert the new last read
      await db.insert(
        'last_read',
        {
          'surah_number': surahNumber,
          'ayah_number': ayahIndex + 1, // Ayah number is 1-based
          'surah_name': surahName,
          'arabic_name': arabicName,
          'timestamp': DateTime.now().millisecondsSinceEpoch,
          'source': 'parah', // Indicate that the last read is from a Parah
          'parah_number': widget.parahNumber, // Save the parah number
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      print("Saved last read: Surah $surahNumber, Ayah ${ayahIndex + 1}, Source: parah");

      // Show a confirmation to the user
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

  @override
  void dispose() {
    // No need to close the database; DatabaseHelper manages it
    super.dispose();
  }

  // Toggle translation visibility
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
    final startAyah = parahInfo['start_ayah'] ?? 'Unknown Start';
    final endAyah = parahInfo['end_ayah'] ?? 'Unknown End';
    final totalAyahs = (endAyah - startAyah + 1);

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
          : ListView(
        padding: EdgeInsets.symmetric(
            vertical: screenHeight * 0.02,
            horizontal: screenWidth * 0.05),
        children: [
          const SizedBox(height: 16),
          ...groupedAyahs.asMap().entries.map((entry) {
            final surahIndex = entry.key;
            final surahData = entry.value;
            final surahInfo = surahData['surah_info'];
            final ayahs = surahData['ayahs'] as List<Map<String, dynamic>>;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SurahInfoCard(
                  surahInfo: surahInfo,
                  showTranslation: showTranslation, // Pass the toggle state
                ),
                const SizedBox(height: 8),
                ...ayahs.asMap().entries.map((ayahEntry) {
                  final ayahIndex = ayahEntry.key;
                  final ayah = ayahEntry.value;
                  return AyahCard(
                    index: ayahIndex + 1,
                    arabicText: ayah['arabic_text'],
                    translationText: ayah['translation_text'],
                    showTranslation: showTranslation, // Pass the toggle state
                    onLongPress: () {
                      // Show dialog on long press
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
                                  surahInfo['surah_number'],
                                  ayahIndex,
                                  surahInfo['surah_name'],
                                  surahInfo['arabic_name'],
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
                }).toList(),
              ],
            );
          }).toList(),
        ],
      ),
    );
  }
}

class SurahInfoCard extends StatelessWidget {
  final Map<String, dynamic> surahInfo;
  final bool showTranslation; // Add this to control translation visibility

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
  final bool showTranslation; // Add this to control translation visibility
  final VoidCallback onLongPress; // Add callback for long press

  const AyahCard({
    Key? key,
    required this.index,
    required this.arabicText,
    required this.translationText,
    required this.showTranslation,
    required this.onLongPress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: onLongPress, // Trigger the long press callback
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        elevation: 4,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.white,
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