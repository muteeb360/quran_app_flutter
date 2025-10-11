import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '/Utils/colors.dart';
import '/Utils/DatabaseHelper.dart';
import '/repository/quran_repository.dart';
import 'surahMediumScreen.dart';
import 'parahMediumScreen.dart';

class QuranMediumScreen extends StatefulWidget {
  const QuranMediumScreen({super.key});

  @override
  State<QuranMediumScreen> createState() => _QuranMediumScreenState();
}

class _QuranMediumScreenState extends State<QuranMediumScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ValueNotifier<Color> _iconColor = ValueNotifier(AppColors.unselected);
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  // Cached images
  final AssetImage _starImage = const AssetImage('assets/images/star.png');
  final AssetImage _bookImage = const AssetImage('assets/images/book.png');
  final AssetImage _quranCardImage = const AssetImage(
    'assets/images/qurancardpic.png',
  );

  bool _isInitializing = true;

  @override
  void initState() {
    super.initState();
    // Tab controller
    _tabController = TabController(length: 3, vsync: this);

    // Initialize repository + DB cache
    _initialize();

    // Focus & text listeners update only the icon color notifier
    _focusNode.addListener(() {
      _iconColor.value =
      _focusNode.hasFocus ? AppColors.main : AppColors.unselected;
    });
    _controller.addListener(() {
      _iconColor.value =
      _controller.text.isNotEmpty ? AppColors.main : AppColors.unselected;
    });
  }

  Future<void> _initialize() async {
    await DatabaseHelper.database;
    await QuranRepository.init();
    setState(() {
      _isInitializing = false;
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _controller.dispose();
    _focusNode.dispose();
    _iconColor.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;

    if (_isInitializing) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: Padding(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
          child: const Text("Quran"),
        ),
        backgroundColor: AppColors.background,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.07,
              vertical: 12,
            ),
            child: Card(
              color: AppColors.searchfieldbgcolor,
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(19),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    Expanded(
                      child: ValueListenableBuilder<Color>(
                        valueListenable: _iconColor,
                        builder: (context, color, _) {
                          return TextField(
                            focusNode: _focusNode,
                            controller: _controller,
                            decoration: InputDecoration(
                              hintText: 'Search anything in Quran...',
                              hintStyle: const TextStyle(
                                color: AppColors.unselected,
                                fontSize: 16,
                              ),
                              border: InputBorder.none,
                              prefixIcon: Icon(Icons.search, color: color),
                            ),
                          );
                        },
                      ),
                    ),
                    ValueListenableBuilder<Color>(
                      valueListenable: _iconColor,
                      builder: (context, color, _) {
                        if (_controller.text.isEmpty)
                          return const SizedBox.shrink();
                        return IconButton(
                          icon: Icon(Icons.close, color: color),
                          onPressed: () {
                            _controller.clear();
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Spacing
          SizedBox(height: screenHeight * 0.02),

          // Last read card
          ValueListenableBuilder<Map<String, dynamic>?>(
            valueListenable: QuranRepository.lastRead,
            builder: (context, lastRead, _) {
              final lr =
                  lastRead ??
                      {
                        'surah_number': 1,
                        'ayah_number': 1,
                        'surah_name': 'Al-Fatihah',
                        'arabic_name': 'الفَاتِحَة',
                        'source': 'surah',
                      };
              return GestureDetector(
                onTap: () {
                  final source = lr['source'] ?? 'surah';
                  if (source == 'parah') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => ParaMediumScreen(
                          parahNumber: lr['parah_number'] ?? 1,
                          lastReadSurah: lr['surah_number'],
                          lastReadAyah: lr['ayah_number'],
                        ),
                      ),
                    );
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => SurahMediumScreen(
                          surahNumber: lr['surah_number'] ?? 1,
                          lastReadAyah: lr['ayah_number'],
                        ),
                      ),
                    );
                  }
                },
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 4,
                  child: Container(
                    width: screenWidth * 0.84,
                    height: screenHeight * 0.19,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF8ED9AF), Color(0xFF44C17B)],
                      ),
                    ),
                    child: Row(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(left: screenWidth * 0.02),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Image(
                                    image: _bookImage,
                                    width: screenWidth * 0.06,
                                    height: screenHeight * 0.06,
                                  ),
                                  SizedBox(width: screenWidth * 0.02),
                                  const Text(
                                    "Last Read",
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 13,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: screenHeight * 0.02),
                              Text(
                                lr['surah_name'] ?? 'Al-Fatihah',
                                style: const TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                "Ayah No: ${lr['ayah_number'] ?? 1}",
                                style: const TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 13,
                                  fontWeight: FontWeight.w200,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(
                                  right: screenWidth * 0.02,
                                  bottom: screenHeight * 0.01,
                                ),
                                child: Image(
                                  image: _quranCardImage,
                                  width: screenWidth * 0.35,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),

          // Tab bar
          Container(
            padding: EdgeInsets.only(right: screenWidth * 0.03, top: 12),
            child: TabBar(
              controller: _tabController,
              indicatorColor: Colors.green,
              indicatorWeight: 4.0,
              labelColor: Colors.green,
              unselectedLabelColor: Colors.grey,
              tabs: const [
                Tab(text: 'Surah'),
                Tab(text: 'Para'),
                Tab(text: 'Favourites'),
              ],
            ),
          ),

          // Tab views
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: const [SurahTab(), ParahTab(), FavoritesTab()],
            ),
          ),
        ],
      ),
    );
  }
}

/// Surah list tab - kept alive to avoid rebuilds on tab switch
class SurahTab extends StatefulWidget {
  const SurahTab({super.key});

  @override
  State<SurahTab> createState() => _SurahTabState();
}

class _SurahTabState extends State<SurahTab>
    with AutomaticKeepAliveClientMixin {
  // copy of lists are intentionally const / final to prevent recreation
  // Use the same surahs list as in original app; trimmed here for brevity in example
  // In the real app, keep the full list.
  final List<Map<String, String>> surahs = [
    {"name": "Al-Fatihah", "arabic": "الفَاتِحَة", "origin": "Meccan", "verses": "7"},
    {"name": "Al-Baqarah", "arabic": "البَقَرَة", "origin": "Medinan", "verses": "286"},
    {"name": "Aal-E-Imran", "arabic": "آلِ عِمرَان", "origin": "Medinan", "verses": "200"},
    {"name": "An-Nisa", "arabic": "النِّسَاء", "origin": "Medinan", "verses": "176"},
    {"name": "Al-Maidah", "arabic": "المَائدة", "origin": "Medinan", "verses": "120"},
    {"name": "Al-An'am", "arabic": "الأنعَام", "origin": "Meccan", "verses": "165"},
    {"name": "Al-A'raf", "arabic": "الأعرَاف", "origin": "Meccan", "verses": "206"},
    {"name": "Al-Anfal", "arabic": "الأنفَال", "origin": "Medinan", "verses": "75"},
    {"name": "At-Tawbah", "arabic": "التوبَة", "origin": "Medinan", "verses": "129"},
    {"name": "Yunus", "arabic": "يُونس", "origin": "Meccan", "verses": "109"},
    {"name": "Hud", "arabic": "هُود", "origin": "Meccan", "verses": "123"},
    {"name": "Yusuf", "arabic": "يُوسُف", "origin": "Meccan", "verses": "111"},
    {"name": "Ar-Ra'd", "arabic": "الرَّعْد", "origin": "Medinan", "verses": "43"},
    {"name": "Ibrahim", "arabic": "إبراهِيم", "origin": "Meccan", "verses": "52"},
    {"name": "Al-Hijr", "arabic": "الحِجْر", "origin": "Meccan", "verses": "99"},
    {"name": "An-Nahl", "arabic": "النَّحل", "origin": "Meccan", "verses": "128"},
    {"name": "Al-Isra", "arabic": "الإسرَاء", "origin": "Meccan", "verses": "111"},
    {"name": "Al-Kahf", "arabic": "الكهْف", "origin": "Meccan", "verses": "110"},
    {"name": "Maryam", "arabic": "مَريَم", "origin": "Meccan", "verses": "98"},
    {"name": "Ta-Ha", "arabic": "طه", "origin": "Meccan", "verses": "135"},
    {"name": "Al-Anbiya", "arabic": "الأنبِيَاء", "origin": "Meccan", "verses": "112"},
    {"name": "Al-Hajj", "arabic": "الحَجّ", "origin": "Medinan", "verses": "78"},
    {"name": "Al-Mu'minun", "arabic": "المؤمنون", "origin": "Meccan", "verses": "118"},
    {"name": "An-Nur", "arabic": "النُّور", "origin": "Medinan", "verses": "64"},
    {"name": "Al-Furqan", "arabic": "الفُرقان", "origin": "Meccan", "verses": "77"},
    {"name": "Ash-Shu'ara", "arabic": "الشُّعَرَاء", "origin": "Meccan", "verses": "227"},
    {"name": "An-Naml", "arabic": "النَّمْل", "origin": "Meccan", "verses": "93"},
    {"name": "Al-Qasas", "arabic": "القَصَص", "origin": "Meccan", "verses": "88"},
    {"name": "Al-Ankabut", "arabic": "العَنكبُوت", "origin": "Meccan", "verses": "69"},
    {"name": "Ar-Rum", "arabic": "الرُّوم", "origin": "Meccan", "verses": "60"},
    {"name": "Luqman", "arabic": "لقمَان", "origin": "Meccan", "verses": "34"},
    {"name": "As-Sajda", "arabic": "السَّجدَة", "origin": "Meccan", "verses": "30"},
    {"name": "Al-Ahzab", "arabic": "الأحزَاب", "origin": "Medinan", "verses": "73"},
    {"name": "Saba", "arabic": "سَبَأ", "origin": "Meccan", "verses": "54"},
    {"name": "Fatir", "arabic": "فَاطِر", "origin": "Meccan", "verses": "45"},
    {"name": "Ya-Sin", "arabic": "يس", "origin": "Meccan", "verses": "83"},
    {"name": "As-Saffat", "arabic": "الصَّافات", "origin": "Meccan", "verses": "182"},
    {"name": "Sad", "arabic": "ص", "origin": "Meccan", "verses": "88"},
    {"name": "Az-Zumar", "arabic": "الزُّمَر", "origin": "Meccan", "verses": "75"},
    {"name": "Ghafir", "arabic": "غَافِر", "origin": "Meccan", "verses": "85"},
    {"name": "Fussilat", "arabic": "فُصِّلَتْ", "origin": "Meccan", "verses": "54"},
    {"name": "Ash-Shura", "arabic": "الشُّورى", "origin": "Meccan", "verses": "53"},
    {"name": "Az-Zukhruf", "arabic": "الزُّخْرُف", "origin": "Meccan", "verses": "89"},
    {"name": "Ad-Dukhan", "arabic": "الدُّخَان", "origin": "Meccan", "verses": "59"},
    {"name": "Al-Jathiya", "arabic": "الجَاثِيَة", "origin": "Meccan", "verses": "37"},
    {"name": "Al-Ahqaf", "arabic": "الأحقاف", "origin": "Meccan", "verses": "35"},
    {"name": "Muhammad", "arabic": "مُحَمَّد", "origin": "Medinan", "verses": "38"},
    {"name": "Al-Fath", "arabic": "الفَتْح", "origin": "Medinan", "verses": "29"},
    {"name": "Al-Hujurat", "arabic": "الحُجُرَات", "origin": "Medinan", "verses": "18"},
    {"name": "Qaf", "arabic": "ق", "origin": "Meccan", "verses": "45"},
    {"name": "Adh-Dhariyat", "arabic": "الذَّاريَات", "origin": "Meccan", "verses": "60"},
    {"name": "At-Tur", "arabic": "الطُّور", "origin": "Meccan", "verses": "49"},
    {"name": "An-Najm", "arabic": "النَّجْم", "origin": "Meccan", "verses": "62"},
    {"name": "Al-Qamar", "arabic": "القَمَر", "origin": "Meccan", "verses": "55"},
    {"name": "Ar-Rahman", "arabic": "الرَّحمٰن", "origin": "Medinan", "verses": "78"},
    {"name": "Al-Waqia", "arabic": "الوَاقِعَة", "origin": "Meccan", "verses": "96"},
    {"name": "Al-Hadid", "arabic": "الحَديد", "origin": "Medinan", "verses": "29"},
    {"name": "Al-Mujadila", "arabic": "المُجَادلَة", "origin": "Medinan", "verses": "22"},
    {"name": "Al-Hashr", "arabic": "الحَشر", "origin": "Medinan", "verses": "24"},
    {"name": "Al-Mumtahina", "arabic": "المُمتَحنَة", "origin": "Medinan", "verses": "13"},
    {"name": "As-Saff", "arabic": "الصَّفّ", "origin": "Medinan", "verses": "14"},
    {"name": "Al-Jumua", "arabic": "الجُمُعَة", "origin": "Medinan", "verses": "11"},
    {"name": "Al-Munafiqun", "arabic": "المُنَافِقون", "origin": "Medinan", "verses": "11"},
    {"name": "At-Taghabun", "arabic": "التغَابُن", "origin": "Medinan", "verses": "18"},
    {"name": "At-Talaq", "arabic": "الطَّلَاق", "origin": "Medinan", "verses": "12"},
    {"name": "At-Tahrim", "arabic": "التَّحرِيم", "origin": "Medinan", "verses": "12"},
    {"name": "Al-Mulk", "arabic": "المُلك", "origin": "Meccan", "verses": "30"},
    {"name": "Al-Qalam", "arabic": "القَلَم", "origin": "Meccan", "verses": "52"},
    {"name": "Al-Haqqa", "arabic": "الحَاقَّة", "origin": "Meccan", "verses": "52"},
    {"name": "Al-Ma'arij", "arabic": "المَعَارِج", "origin": "Meccan", "verses": "44"},
    {"name": "Nuh", "arabic": "نُوح", "origin": "Meccan", "verses": "28"},
    {"name": "Al-Jinn", "arabic": "الجِنّ", "origin": "Meccan", "verses": "28"},
    {"name": "Al-Muzzammil", "arabic": "المُزَّمِّل", "origin": "Meccan", "verses": "20"},
    {"name": "Al-Muddaththir", "arabic": "المُدَّثِّر", "origin": "Meccan", "verses": "56"},
    {"name": "Al-Qiyama", "arabic": "القِيَامَة", "origin": "Meccan", "verses": "40"},
    {"name": "Al-Insan", "arabic": "الإنسَان", "origin": "Medinan", "verses": "31"},
    {"name": "Al-Mursalat", "arabic": "المُرسَلَات", "origin": "Meccan", "verses": "50"},
    {"name": "An-Naba", "arabic": "النَّبَأ", "origin": "Meccan", "verses": "40"},
    {"name": "An-Nazi'at", "arabic": "النَّازعَات", "origin": "Meccan", "verses": "46"},
    {"name": "Abasa", "arabic": "عَبَس", "origin": "Meccan", "verses": "42"},
    {"name": "At-Takwir", "arabic": "التَّكْوِير", "origin": "Meccan", "verses": "29"},
    {"name": "Al-Infitar", "arabic": "الانفِطَار", "origin": "Meccan", "verses": "19"},
    {"name": "Al-Mutaffifin", "arabic": "المُطَفِّفِين", "origin": "Meccan", "verses": "36"},
    {"name": "Al-Inshiqaq", "arabic": "الانشِقَاق", "origin": "Meccan", "verses": "25"},
    {"name": "Al-Buruj", "arabic": "البُرُوج", "origin": "Meccan", "verses": "22"},
    {"name": "At-Tariq", "arabic": "الطَّارِق", "origin": "Meccan", "verses": "17"},
    {"name": "Al-A'la", "arabic": "الأعلَى", "origin": "Meccan", "verses": "19"},
    {"name": "Al-Ghashiya", "arabic": "الغَاشِيَة", "origin": "Meccan", "verses": "26"},
    {"name": "Al-Fajr", "arabic": "الفَجر", "origin": "Meccan", "verses": "30"},
    {"name": "Al-Balad", "arabic": "البَلَد", "origin": "Meccan", "verses": "20"},
    {"name": "Ash-Shams", "arabic": "الشَّمْس", "origin": "Meccan", "verses": "15"},
    {"name": "Al-Lail", "arabic": "اللَّيل", "origin": "Meccan", "verses": "21"},
    {"name": "Ad-Duhaa", "arabic": "الضُّحَى", "origin": "Meccan", "verses": "11"},
    {"name": "Ash-Sharh", "arabic": "الشَّرْح", "origin": "Meccan", "verses": "8"},
    {"name": "At-Tin", "arabic": "التِّين", "origin": "Meccan", "verses": "8"},
    {"name": "Al-Alaq", "arabic": "العَلق", "origin": "Meccan", "verses": "19"},
    {"name": "Al-Qadr", "arabic": "القَدر", "origin": "Meccan", "verses": "5"},
    {"name": "Al-Bayyina", "arabic": "البَيِّنَة", "origin": "Medinan", "verses": "8"},
    {"name": "Az-Zalzala", "arabic": "الزَّلزَلة", "origin": "Medinan", "verses": "8"},
    {"name": "Al-Adiyat", "arabic": "العَادِيَات", "origin": "Meccan", "verses": "11"},
    {"name": "Al-Qaria", "arabic": "القَارِعَة", "origin": "Meccan", "verses": "11"},
    {"name": "At-Takathur", "arabic": "التَّكَاثُر", "origin": "Meccan", "verses": "8"},
    {"name": "Al-Asr", "arabic": "العَصر", "origin": "Meccan", "verses": "3"},
    {"name": "Al-Humaza", "arabic": "الهُمَزَة", "origin": "Meccan", "verses": "9"},
    {"name": "Al-Fil", "arabic": "الفِيل", "origin": "Meccan", "verses": "5"},
    {"name": "Quraish", "arabic": "قُرَيش", "origin": "Meccan", "verses": "4"},
    {"name": "Al-Ma'un", "arabic": "المَاعُون", "origin": "Meccan", "verses": "7"},
    {"name": "Al-Kawthar", "arabic": "الكَوثَر", "origin": "Meccan", "verses": "3"},
    {"name": "Al-Kafiroon", "arabic": "الكَافِرُون", "origin": "Meccan", "verses": "6"},
    {"name": "An-Nasr", "arabic": "النَّصر", "origin": "Medinan", "verses": "3"},
    {"name": "Al-Masad", "arabic": "المَسَد", "origin": "Meccan", "verses": "5"},
    {"name": "Al-Ikhlas", "arabic": "الإخْلَاص", "origin": "Meccan", "verses": "4"},
    {"name": "Al-Falaq", "arabic": "الفَلَق", "origin": "Meccan", "verses": "5"},
    {"name": "An-Nas", "arabic": "النَّاس", "origin": "Meccan", "verses": "6"},
  ];


@override
  Widget build(BuildContext context) {
    super.build(context); // required by AutomaticKeepAliveClientMixin
    final screenWidth = MediaQuery.of(context).size.width;

    return ValueListenableBuilder<List<int>>(
      valueListenable: QuranRepository.favoriteSurahIds,
      builder: (context, favoriteIds, _) {
        return ListView.builder(
          itemCount: surahs.length,
          itemExtent: 72, // fixed tile height to speed up layout
          itemBuilder: (context, index) {
            final surah = surahs[index];
            final surahId = index + 1;
            final isFavorite = favoriteIds.contains(surahId);

            return ListTile(
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (c) => SurahMediumScreen(surahNumber: surahId),
                  ),
                );
                // Do not re-query DB; Surah screen should call QuranRepository.updateLastRead when needed
              },
              leading: Stack(
                alignment: Alignment.center,
                children: [
                  Image(
                    image: const AssetImage('assets/images/star.png'),
                    width: 35,
                    height: 35,
                    fit: BoxFit.cover,
                  ),
                  Text(
                    '$surahId',
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              title: Text(
                surah["name"]!,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                '${surah["origin"]!.toUpperCase()} - ${surah["verses"]!} VERSES',
                style: const TextStyle(fontFamily: 'Poppins', fontSize: 12),
              ),
              trailing: IconButton(
                icon: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: isFavorite ? Colors.red : Colors.grey,
                ),
                onPressed: () {
                  QuranRepository.toggleFavorite(surahId, surah);
                },
              ),
            );
          },
        );
      },
    );
  }

  @override
  bool get wantKeepAlive => true;
}

/// Parah tab
class ParahTab extends StatefulWidget {
  const ParahTab({super.key});

  @override
  State<ParahTab> createState() => _ParahTabState();
}

class _ParahTabState extends State<ParahTab>
    with AutomaticKeepAliveClientMixin {
  final List<Map<String, String>> parahs = [
    {
      "arabic": "الٓمِٓ",
      "verses": "148",
      "english": "Alif Lam Meem"
    },
    {
      "arabic": "سَيَقُولُ",
      "verses": "111",
      "english": "Sayaqool"
    },
    {
      "arabic": "تِلْكَ الرُّسُلُ",
      "verses": "126",
      "english": "Tilkal Rusulu"
    },
    {
      "arabic": "لَنْ تَنَالُوا الْبِرَّ",
      "verses": "131",
      "english": "Lan Tana loo Al-Birra"
    },
    {
      "arabic": "وَالْمُحْصَنَاتُ",
      "verses": "124",
      "english": "Wal Mohsanat"
    },
    {
      "arabic": "لَا يُحِبُّ اللَّهُ",
      "verses": "110",
      "english": "La Yuhibbullah"
    },
    {
      "arabic": "وَإِذَا سَمِعُوا",
      "verses": "149",
      "english": "Wa Iza Samiu"
    },
    {
      "arabic": "وَلَوْ أَنَّنَا",
      "verses": "142",
      "english": "Wa Lau Annana"
    },
    {
      "arabic": "قَالَلْمَلَأُ",
      "verses": "159",
      "english": "Qalal Malao"
    },
    {
      "arabic": "وَاعْلَمُوا",
      "verses": "127",
      "english": "Wa A'lamu"
    },
    {
      "arabic": "يَعْتَذِرُونَ",
      "verses": "151",
      "english": "Yatazeroon"
    },
    {
      "arabic": "وَمَا مِن دَآبَّةٍ",
      "verses": "170",
      "english": "Wa Mamin Daabat"
    },
    {
      "arabic": "وَمَا أُبَرِّئُ",
      "verses": "154",
      "english": "Wa Ma Ubrioo"
    },
    {
      "arabic": "رُبَمَا",
      "verses": "227",
      "english": "Rubama"
    },
    {
      "arabic": "سُبْحَانَ الَّذِي",
      "verses": "185",
      "english": "Subhan Alladhi"
    },
    {
      "arabic": "قَالَ أَلَمْ",
      "verses": "269",
      "english": "Qala Alam"
    },
    {
      "arabic": "اقْتَرَبَ لِلْنَّاسِ",
      "verses": "190",
      "english": "Iqtaraba Lin-Nasi"
    },
    {
      "arabic": "قَدْ أَفْلَحَ",
      "verses": "202",
      "english": "Qadd Aflaha"
    },
    {
      "arabic": "وَقَالَ الَّذِينَ",
      "verses": "339",
      "english": "Wa Qalallazina"
    },
    {
      "arabic": "أَمَّنْ خَلَقَ",
      "verses": "171",
      "english": "A’man Khalaq"
    },
    {
      "arabic": "أُتْلُ مَاأُوْحِيَ",
      "verses": "178",
      "english": "Utlu Ma Oohi"
    },
    {
      "arabic": "وَمَنْ يَّقْنُتْ",
      "verses": "169",
      "english": "Wa Man Yaqnut"
    },
    {
      "arabic": "وَمَآ لِيَ",
      "verses": "357",
      "english": "Wa Mali"
    },
    {
      "arabic": "فَمَنْ أَظْلَمُ",
      "verses": "175",
      "english": "Faman Azlamu"
    },
    {
      "arabic": "إِلَيْهِ يُرَدُّ",
      "verses": "246",
      "english": "Ilayhi Yuruddo"
    },
    {
      "arabic": "حَــــم",
      "verses": "195",
      "english": "Ha Meem"
    },
    {
      "arabic": "قَالَ فَمَا خَطْبُكُم",
      "verses": "399",
      "english": "Qala Fama Khatbukum"
    },
    {
      "arabic": "قَدْ سَمِعَ اللَّهُ",
      "verses": "137",
      "english": "Qadd Sami Allah"
    },
    {
      "arabic": "تَبَارَكَ الَّذِي",
      "verses": "431",
      "english": "Tabarakallazi"
    },
    {
      "arabic": "عَمَّ يَتَسَاءَلُونَ",
      "verses": "564",
      "english": "Amma Yatasa’aloon"
    },
  ];

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return ListView.builder(
      itemExtent: 72,
      itemCount: parahs.length,
      itemBuilder: (context, index) {
        final parah = parahs[index];
        return ListTile(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (c) => ParaMediumScreen(parahNumber: index + 1),
              ),
            );
          },
          leading: Stack(
            alignment: Alignment.center,
            children: [
              Image.asset(
                'assets/images/star.png',
                width: 35,
                height: 35,
                fit: BoxFit.cover,
              ),
              Text(
                '${index + 1}',
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          title: Text(
            parah["english"]!,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            '${parah["verses"]!} VERSES',
            style: const TextStyle(fontFamily: 'Poppins', fontSize: 12),
          ),
          trailing: Text(
            parah["arabic"]!,
            style: const TextStyle(
              fontFamily: 'NotoNaskhArabic',
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.main,
            ),
          ),
        );
      },
    );
  }

  @override
  bool get wantKeepAlive => true;
}

/// Favorites Tab - uses repository cache + fetches full records once
class FavoritesTab extends StatefulWidget {
  const FavoritesTab({super.key});

  @override
  State<FavoritesTab> createState() => _FavoritesTabState();
}

class _FavoritesTabState extends State<FavoritesTab>
    with AutomaticKeepAliveClientMixin {
  // keep a local cached copy of the favorite rows to avoid re-querying on each build
  List<Map<String, dynamic>> _favoriteRows = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    // load records initially
    _loadFavoritesRecords();

    // listen to favorites change to refresh the list once
    QuranRepository.favoriteSurahIds.addListener(_onFavoritesChanged);
  }

  Future<void> _loadFavoritesRecords() async {
    setState(() => _loading = true);
    _favoriteRows = await QuranRepository.fetchFavoriteRecords();
    setState(() => _loading = false);
  }

  void _onFavoritesChanged() {
    // when favorite ids change we re-fetch the full favorite rows.
    _loadFavoritesRecords();
  }

  @override
  void dispose() {
    QuranRepository.favoriteSurahIds.removeListener(_onFavoritesChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_favoriteRows.isEmpty) {
      return const Center(
        child: Text('No Favorites Added', style: TextStyle(fontSize: 20)),
      );
    }

    return ListView.builder(
      itemCount: _favoriteRows.length,
      itemExtent: 120,
      itemBuilder: (context, index) {
        final favorite = _favoriteRows[index];
        final surahId = favorite['id'] as int? ?? 0;
        final englishName = favorite['english_name'] ?? 'Unknown Surah';
        final arabicName = favorite['arabic_name'] ?? 'Unknown Arabic';
        final totalVerses = favorite['total_verses'] ?? '0';

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SurahMediumScreen(surahNumber: surahId),
              ),
            );
          },
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
            child: Container(
              padding: const EdgeInsets.all(18),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        arabicName,
                        style: const TextStyle(
                          fontFamily: 'NotoNaskhArabic',
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                        textDirection: TextDirection.rtl,
                      ),
                      const SizedBox(width: 12),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            englishName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '$totalVerses verses',
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 14,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.favorite,
                      color: Colors.red,
                      size: 30,
                    ),
                    onPressed: () {
                      // toggle via repository
                      QuranRepository.toggleFavorite(surahId, {
                        'name': englishName,
                        'arabic': arabicName,
                        'verses': totalVerses,
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  bool get wantKeepAlive => true;
}
