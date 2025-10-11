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
  final List<Map<String, String>> surahs = const [
    {
      "name": "Al-Fatihah",
      "arabic": "الفَاتِحَة",
      "origin": "Meccan",
      "verses": "7",
    },
    {
      "name": "Al-Baqarah",
      "arabic": "البَقَرَة",
      "origin": "Medinan",
      "verses": "286",
    },
    {
      "name": "Aal-E-Imran",
      "arabic": "آلِ عِمرَان",
      "origin": "Medinan",
      "verses": "200",
    },
    // ... include the full list here as in your original file
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
  final List<Map<String, String>> parahs = const [
    {"arabic": "الٓمِٓ", "verses": "148", "english": "Alif Lam Meem"},
    {"arabic": "سَيَقُولُ", "verses": "111", "english": "Sayaqool"},
    // ... include all parahs here as in original file
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
