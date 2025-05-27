import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sqflite/sqflite.dart';
import '../../../Utils/colors.dart';
import '../../../Utils/QuranData.dart';
import 'package:hidaya_app/Utils/DatabaseHelper.dart';

class SurahMediumScreen extends StatefulWidget {
  final int surahNumber;

  const SurahMediumScreen({Key? key, required this.surahNumber})
      : super(key: key);

  @override
  State<SurahMediumScreen> createState() => _SurahMediumScreenState();
}

class _SurahMediumScreenState extends State<SurahMediumScreen> {
  List<Map<String, dynamic>> ayahs = [];
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
      final surahInfo = QuranData.surahRanges.firstWhere(
            (surah) => surah['surah_number'] == widget.surahNumber,
        orElse: () => {"name": "Unknown Surah"},
      );
      final surahStart = surahInfo['start_ayah'] ?? 1;
      final surahEnd = surahInfo['end_ayah'] ?? 1;

      final db = await DatabaseHelper.database;
      final List<Map<String, dynamic>> result = await db.query(
        'ayahs_table',
        where: 'id BETWEEN ? AND ?',
        whereArgs: [surahStart, surahEnd],
        orderBy: 'id ASC',
      );

      setState(() {
        ayahs = result;
        isLoading = false;
      });
      print("Fetched ${ayahs.length} ayahs from database");
    } catch (e) {
      setState(() {
        errorMessage = "Failed to fetch ayahs: $e";
        isLoading = false;
      });
      print(errorMessage);
    }
  }

  // Save the last read ayah to the database
  Future<void> _saveLastRead(int ayahIndex) async {
    try {
      final surahInfo = QuranData.surahRanges.firstWhere(
            (surah) => surah['surah_number'] == widget.surahNumber,
        orElse: () => {"name": "Unknown Surah"},
      );
      final surahName = surahInfo['name'] ?? 'Unknown Surah';
      final arabicName = surahInfo['arabic_name'] ?? 'Unknown Arabic Name';

      final db = await DatabaseHelper.database;
      // Clear previous last read entries (we only want one last read)
      await db.delete('last_read');
      // Insert the new last read
      await db.insert(
        'last_read',
        {
          'surah_number': widget.surahNumber,
          'ayah_number': ayahIndex + 1, // Ayah number is 1-based
          'surah_name': surahName,
          'arabic_name': arabicName,
          'timestamp': DateTime.now().millisecondsSinceEpoch,
          'source': 'surah',
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      print("Saved last read: Surah ${widget.surahNumber}, Ayah ${ayahIndex + 1}");

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

    final surahInfo = QuranData.surahRanges.firstWhere(
          (surah) => surah['surah_number'] == widget.surahNumber,
      orElse: () => {"name": "Unknown Surah"},
    );
    final surahName = surahInfo['name'] ?? 'Unknown Surah';
    final surahStart = surahInfo['start_ayah'] ?? 'Unknown start';
    final surahEnd = surahInfo['end_ayah'] ?? 'Unknown end';
    final totalAyahs = surahInfo['verse_count'] ?? 'Unknown count';
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
          : ListView(
        padding: EdgeInsets.symmetric(
            vertical: screenHeight * 0.02,
            horizontal: screenWidth * 0.05),
        children: [
          Container(
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
                    padding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.05),
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
                            style: TextStyle(
                                color: Colors.white, fontSize: 13),
                            textDirection: TextDirection.rtl,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          ...List.generate(ayahs.length, (index) {
            final ayah = ayahs[index];
            return AyahCard(
              index: index,
              arabicText: ayah['arabic_text'],
              translationText: ayah['translation_text'],
              showTranslation: showTranslation,
              onLongPress: () {
                // Show dialog on long press
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('Ayah ${index + 1}'),
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
                          _saveLastRead(index);
                          Navigator.pop(context);
                        },
                        child: const Text('Add Last Read'),
                      ),
                    ],
                  ),
                );
              },
            );
          }),
        ],
      ),
    );
  }
}

class AyahCard extends StatelessWidget {
  final int index;
  final String arabicText;
  final String translationText;
  final bool showTranslation;
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
                    '﴾${index + 1}﴿',
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