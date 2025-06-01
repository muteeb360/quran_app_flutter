import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import '../../../Utils/colors.dart';
import 'surahMediumScreen.dart';
import 'parahMediumScreen.dart';
import 'package:hidaya_app/Utils/DatabaseHelper.dart';

class QuranMediumScreen extends StatefulWidget {
  const QuranMediumScreen({super.key});

  @override
  State<QuranMediumScreen> createState() => _QuranMediumScreenState();
}

class _QuranMediumScreenState extends State<QuranMediumScreen>
    with SingleTickerProviderStateMixin {
  final FocusNode _focusNode = FocusNode();
  final TextEditingController _controller = TextEditingController();
  Color _iconColor = AppColors.unselected;
  late TabController _tabController;
  List<int> favoriteSurahIds = [];
  bool _isDatabaseLoading = true;
  Map<String, dynamic>? lastRead;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_onTabChanged);
    _focusNode.addListener(_onFocusChange);
    _controller.addListener(_onTextChange);
    _initializeData();
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _controller.removeListener(_onTextChange);
    _focusNode.dispose();
    _controller.dispose();
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) {
      _loadLastRead();
    }
  }

  Future<void> _initializeData() async {
    try {
      await _loadFavorites();
      await _loadLastRead();
    } catch (e) {
      print("Failed to initialize data: $e");
    } finally {
      setState(() {
        _isDatabaseLoading = false;
      });
    }
  }

  Future<void> _loadFavorites() async {
    try {
      final db = await DatabaseHelper.database;
      final List<Map<String, dynamic>> favorites = await db.query('favorites');
      setState(() {
        favoriteSurahIds = favorites.map((fav) => fav['id'] as int).toList();
      });
      print("Loaded favorites: $favoriteSurahIds");
    } catch (e) {
      print("Failed to load favorites: $e");
    }
  }

  Future<void> _loadLastRead() async {
    try {
      final db = await DatabaseHelper.database;
      final List<Map<String, dynamic>> result = await db.query(
        'last_read',
        orderBy: 'timestamp DESC',
        limit: 1,
      );
      if (result.isNotEmpty) {
        setState(() {
          lastRead = result.first;
        });
        print("Loaded last read: $lastRead");
      } else {
        setState(() {
          lastRead = {
            'surah_number': 1,
            'ayah_number': 1,
            'surah_name': 'Al-Fatihah',
            'arabic_name': 'الفَاتِحَة',
            'source': 'surah',
          };
        });
        print("No last read found, set default: $lastRead");
      }
    } catch (e) {
      print("Failed to load last read: $e");
      setState(() {
        lastRead = {
          'surah_number': 1,
          'ayah_number': 1,
          'surah_name': 'Al-Fatihah',
          'arabic_name': 'الفَاتِحَة',
          'source': 'surah',
        };
      });
    }
  }

  Future<void> _toggleFavorite(int surahId, Map<String, String> surah) async {
    try {
      final db = await DatabaseHelper.database;

      if (favoriteSurahIds.contains(surahId)) {
        await db.delete('favorites', where: 'id = ?', whereArgs: [surahId]);
        setState(() {
          favoriteSurahIds.remove(surahId);
        });
        print("Removed Surah $surahId from favorites");
      } else {
        final englishName = surah['name'] ?? 'Unknown Surah';
        final arabicName = surahs[surahId - 1]['arabic'] ?? 'Unknown Arabic';
        final totalVerses = surah['verses'] ?? '0';

        await db.insert(
          'favorites',
          {
            'id': surahId,
            'english_name': englishName,
            'arabic_name': arabicName,
            'total_verses': totalVerses,
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
        setState(() {
          favoriteSurahIds.add(surahId);
        });
        print("Added Surah $surahId to favorites");
      }
    } catch (e) {
      print("Failed to toggle favorite: $e");
    }
  }

  void _onFocusChange() {
    setState(() {
      _iconColor = _focusNode.hasFocus ? AppColors.main : AppColors.unselected;
    });
  }

  void _onTextChange() {
    setState(() {
      _iconColor = _controller.text.isNotEmpty ? AppColors.main : AppColors.unselected;
    });
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;

    return Scaffold(
      appBar: AppBar(
        title: Padding(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
          child: const Text("Quran"),
        ),
        backgroundColor: AppColors.background,
      ),
      backgroundColor: AppColors.background,
      resizeToAvoidBottomInset: true,
      body: _isDatabaseLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.07),
              child: Card(
                color: AppColors.searchfieldbgcolor,
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(19),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextField(
                    focusNode: _focusNode,
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Search anything in Quran...',
                      hintStyle: const TextStyle(
                        color: AppColors.unselected,
                        fontSize: 16,
                      ),
                      border: InputBorder.none,
                      prefixIcon: Icon(Icons.search, color: _iconColor),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: screenHeight * 0.05),
            GestureDetector(
              onTap: () {
                if (lastRead != null) {
                  final source = lastRead!['source'] ?? 'surah';
                  if (source == 'parah') {
                    print("Navigating to Parah ${lastRead!['parah_number']}, Surah ${lastRead!['surah_number']}, Ayah ${lastRead!['ayah_number']}");
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ParaMediumScreen(
                          parahNumber: lastRead!['parah_number'] ?? 1,
                          lastReadSurah: lastRead!['surah_number'],
                          lastReadAyah: lastRead!['ayah_number'],
                        ),
                      ),
                    ).then((_) {
                      _loadLastRead();
                    });
                  } else {
                    print("Navigating to Surah ${lastRead!['surah_number']}, Ayah ${lastRead!['ayah_number']}");
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SurahMediumScreen(
                          surahNumber: lastRead!['surah_number'] ?? 1,
                          lastReadAyah: lastRead!['ayah_number'],
                        ),
                      ),
                    ).then((_) {
                      _loadLastRead();
                    });
                  }
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
                      colors: [
                        Color(0xFF8ED9AF),
                        Color(0xFF44C17B),
                      ],
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
                                  image: const AssetImage('assets/images/book.png'),
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
                              lastRead?['surah_name'] ?? 'Al-Fatihah',
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              "Ayah No: ${lastRead?['ayah_number'] ?? 1}",
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
                                  right: screenWidth * 0.02, bottom: screenHeight * 0.01),
                              child: Image(
                                image: const AssetImage('assets/images/qurancardpic.png'),
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
            ),
            Container(
              padding: EdgeInsets.only(right: screenWidth * 0.03, top: screenHeight * 0.02),
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
            Container(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
              width: screenWidth,
              height: screenHeight * 0.42,
              child: TabBarView(
                controller: _tabController,
                children: [
                  ListView.builder(
                    itemCount: surahs.length,
                    itemBuilder: (context, index) {
                      final surah = surahs[index];
                      final surahId = index + 1;
                      final isFavorite = favoriteSurahIds.contains(surahId);

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SurahMediumScreen(surahNumber: surahId),
                            ),
                          ).then((_) {
                            _loadLastRead();
                          });
                        },
                        child: ListTile(
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
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 12,
                            ),
                          ),
                          trailing: IconButton(
                            icon: Icon(
                              isFavorite ? Icons.favorite : Icons.favorite_border,
                              color: isFavorite ? Colors.red : Colors.grey,
                            ),
                            onPressed: () {
                              _toggleFavorite(surahId, surah);
                            },
                          ),
                        ),
                      );
                    },
                  ),
                  ListView.builder(
                    itemCount: parahs.length,
                    itemBuilder: (context, index) {
                      final parah = parahs[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ParaMediumScreen(parahNumber: index + 1),
                            ),
                          ).then((_) {
                            _loadLastRead();
                          });
                        },
                        child: ListTile(
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
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 12,
                            ),
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
                        ),
                      );
                    },
                  ),
                  FutureBuilder<List<Map<String, dynamic>>>(
                    future: DatabaseHelper.database.then((db) => db.query('favorites')),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      }
                      final favorites = snapshot.data ?? [];
                      return favorites.isEmpty
                          ? const Center(
                        child: Text(
                          'No Favorites Added',
                          style: TextStyle(fontSize: 20),
                        ),
                      )
                          : ListView.builder(
                        itemCount: favorites.length,
                        itemBuilder: (context, index) {
                          final favorite = favorites[index];
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
                              ).then((_) {
                                _loadLastRead();
                              });
                            },
                            child: Card(
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              margin: const EdgeInsets.symmetric(vertical: 8.0),
                              child: Container(
                                padding: const EdgeInsets.all(25),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                ),
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
                                        Padding(
                                          padding: EdgeInsets.only(left: screenWidth * 0.03),
                                          child: Column(
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
                                              const SizedBox(height: 4),
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
                                        _toggleFavorite(surahId, {
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
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

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
  ];

  final List<Map<String, String>> surahs = [
    {
      "name": "Al-Fatihah",
      "arabic": "الفَاتِحَة",
      "origin": "Meccan",
      "verses": "7"
    },
    {
      "name": "Al-Baqarah",
      "arabic": "البَقَرَة",
      "origin": "Medinan",
      "verses": "286"
    },
  ];
}