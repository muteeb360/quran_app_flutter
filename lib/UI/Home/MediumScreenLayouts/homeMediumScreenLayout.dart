import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import 'package:adhan_dart/adhan_dart.dart';
import 'package:hidaya_app/UI/Home/MediumScreenLayouts/PDFQuran_firstscreen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hidaya_app/Utils/DatabaseHelper.dart';
import 'package:hidaya_app/Utils/QuranData.dart';
import 'package:hidaya_app/UI/Home/MediumScreenLayouts/prayerTimesScreen.dart';
import 'package:hidaya_app/UI/Home/MediumScreenLayouts/qiblaDirectionScreen.dart';
import 'package:hidaya_app/UI/Home/MediumScreenLayouts/supplicationScreen.dart';
import '../../../l10n/app_localizations.dart';
import '../../theme_provider.dart';
import 'asmaulhusnaScreen.dart';
import 'nabinamesScreen.dart';
import '../../../Utils/colors.dart';
import '../../../Utils/location_manager.dart';

class HomeMediumScreenLayout extends StatefulWidget {
  const HomeMediumScreenLayout({super.key});

  @override
  State<HomeMediumScreenLayout> createState() => _HomeMediumScreenLayoutState();
}

class _HomeMediumScreenLayoutState extends State<HomeMediumScreenLayout> {
  final FocusNode _focusNode = FocusNode();
  final TextEditingController _controller = TextEditingController();
  Color _iconColor = Colors.grey;
  String _currentBackground = "assets/images/noon.png";

  String _currentTime = "12:38 pm";
  String _currentDate = "Fri 25-02-25";
  String _upcomingPrayer = "DHUHR";
  String _currentPrayer = "unknown";
  String _upcomingPrayerTime = "12:38 pm";
  Map<String, String> _prayerTimes = {
    'Fajr': 'Loading...',
    'Sunrise': 'Loading...',
    'Dhuhr': 'Loading...',
    'Asr': 'Loading...',
    'Maghrib': 'Loading...',
    'Isha': 'Loading...',
  };
  Timer? _timer;
  String _selectedJuristicMethod = 'Shafi'; // Default value
  String? _errorMessage;
  Map<String, double>? _coordinates;
  DateTime? _lastCalculationDate;
  Map<String, dynamic>? _verseOfTheDay; // Store the verse data
  String? _verseSurahReference; // Store the Surah reference
  String? _localizedSurahRefrence;

  @override
  void initState() {
    super.initState();
    _currentBackground = "assets/images/noon.png";
    _focusNode.addListener(_onFocusChange);
    _controller.addListener(_onTextChange);

    _updateTimeAndDate();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      _updateTimeAndDate();
    });

    _loadJuristicMethod();
    _listenToJuristicMethodChanges();
    _loadPrayerTimes();
    _scheduleDailyUpdate();
    _loadVerseOfTheDay(); // Load the verse on init
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _controller.removeListener(_onTextChange);
    _focusNode.dispose();
    _controller.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _iconColor = _focusNode.hasFocus ? AppColors.main : Colors.grey;
    });
  }

  void _onTextChange() {
    setState(() {
      _iconColor = _controller.text.isNotEmpty ? AppColors.main : Colors.grey;
    });
  }

  Future<void> _loadJuristicMethod() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedJuristicMethod = prefs.getString('juristic_method') ?? 'Shafi';
    });
  }

  void _listenToJuristicMethodChanges() {
    SharedPreferences.getInstance().then((prefs) {
      Timer.periodic(Duration(seconds: 1), (timer) async {
        String? newMethod = prefs.getString('juristic_method');
        if (newMethod != null && newMethod != _selectedJuristicMethod) {
          setState(() {
            _selectedJuristicMethod = newMethod;
          });
          if (_coordinates != null) {
            _calculatePrayerTimes(_coordinates!['latitude']!, _coordinates!['longitude']!);
          } else {
            _loadPrayerTimes();
          }
        }
      });
    });
  }

  Future<void> _loadPrayerTimes() async {
    setState(() {
      _errorMessage = null;
    });

    try {
      _coordinates = await LocationManager.getUserLocation();
      double latitude = _coordinates!['latitude']!;
      double longitude = _coordinates!['longitude']!;
      _calculatePrayerTimes(latitude, longitude);
    } catch (e) {
      try {
        _coordinates = await LocationManager.getCachedLocation();
        if (_coordinates != null) {
          double latitude = _coordinates!['latitude']!;
          double longitude = _coordinates!['longitude']!;
          _calculatePrayerTimes(latitude, longitude);
        } else {
          setState(() {
            _errorMessage = e.toString();
          });
        }
      } catch (cachedError) {
        setState(() {
          _errorMessage = e.toString();
        });
      }
    }
  }

  Future<void> _calculatePrayerTimes(double latitude, double longitude) async {
    try {
      final now = DateTime.now().toUtc();
      Coordinates coordinates = Coordinates(latitude, longitude);
      CalculationParameters params = CalculationMethod.muslimWorldLeague();
      params.madhab = _selectedJuristicMethod == 'Hanafi' ? Madhab.hanafi : Madhab.shafi;
      PrayerTimes prayerTimes = PrayerTimes(
        coordinates: coordinates,
        date: now,
        calculationParameters: params,
      );

      DateTime fajrLocal = prayerTimes.fajr!.toLocal();
      DateTime sunriseLocal = prayerTimes.sunrise!.toLocal();
      DateTime dhuhrLocal = prayerTimes.dhuhr!.toLocal();
      DateTime asrLocal = prayerTimes.asr!.toLocal();
      DateTime maghribLocal = prayerTimes.maghrib!.toLocal();
      DateTime ishaLocal = prayerTimes.isha!.toLocal();

      setState(() {
        _prayerTimes['Fajr'] = _convertTo12HourFormat(fajrLocal);
        _prayerTimes['Sunrise'] = _convertTo12HourFormat(sunriseLocal);
        _prayerTimes['Dhuhr'] = _convertTo12HourFormat(dhuhrLocal);
        _prayerTimes['Asr'] = _convertTo12HourFormat(asrLocal);
        _prayerTimes['Maghrib'] = _convertTo12HourFormat(maghribLocal);
        _prayerTimes['Isha'] = _convertTo12HourFormat(ishaLocal);
        _lastCalculationDate = DateTime.now();
      });

      _updateUpcomingPrayer();
    } catch (e) {
      setState(() {
        _errorMessage = "Error calculating prayer times: $e";
      });
    }
  }

  void _scheduleDailyUpdate() {
    Timer.periodic(Duration(hours: 24), (timer) async {
      if (_coordinates != null) {
        _calculatePrayerTimes(_coordinates!['latitude']!, _coordinates!['longitude']!);
      } else {
        try {
          _coordinates = await LocationManager.getCachedLocation();
          if (_coordinates != null) {
            _calculatePrayerTimes(_coordinates!['latitude']!, _coordinates!['longitude']!);
          }
        } catch (e) {
          print("Failed to update prayer times: $e");
        }
      }
      await _loadVerseOfTheDay(); // Update verse daily
    });
  }

  String _convertTo12HourFormat(DateTime time) {
    int hour = time.hour;
    final minutes = time.minute.toString().padLeft(2, '0');
    String period = 'AM';

    if (hour == 0) {
      hour = 12;
    } else if (hour == 12) {
      period = 'PM';
    } else if (hour > 12) {
      hour = hour - 12;
      period = 'PM';
    }

    return '$hour:$minutes $period';
  }

  void _updateTimeAndDate() {
    final now = DateTime.now();
    setState(() {
      _currentTime = _formatTime(now);
      _currentDate = _formatDate(now);
    });
    _updateUpcomingPrayer();
  }

  String _formatTime(DateTime dateTime) {
    int hour = dateTime.hour;
    final minutes = dateTime.minute.toString().padLeft(2, '0');
    String period = 'AM';

    if (hour == 0) {
      hour = 12;
    } else if (hour == 12) {
      period = 'PM';
    } else if (hour > 12) {
      hour = hour - 12;
      period = 'PM';
    }

    return '$hour:$minutes $period';
  }

  String _formatDate(DateTime dateTime) {
    final dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final dayName = dayNames[dateTime.weekday - 1];
    final day = dateTime.day.toString().padLeft(2, '0');
    final month = dateTime.month.toString().padLeft(2, '0');
    final year = dateTime.year.toString().substring(2);
    return '$dayName $day-$month-$year';
  }

  void _updateUpcomingPrayer() {
    if (_prayerTimes['Fajr'] == 'Loading...' || _prayerTimes['Fajr'] == 'Error') return;

    final localizations = AppLocalizations.of(context);
    final now = DateTime.now();
    final currentTime = now.hour * 60 + now.minute;

    List<Map<String, dynamic>> prayerList = [
      {'name': 'Fajr', 'time': _prayerTimes['Fajr']!, 'localized': localizations?.fajr},
      {'name': 'Dhuhr', 'time': _prayerTimes['Dhuhr']!, 'localized': localizations?.dhuhr},
      {'name': 'Asr', 'time': _prayerTimes['Asr']!, 'localized': localizations?.asr},
      {'name': 'Maghrib', 'time': _prayerTimes['Maghrib']!, 'localized': localizations?.maghrib},
      {'name': 'Isha', 'time': _prayerTimes['Isha']!, 'localized': localizations?.isha},
    ];

    String currentPrayer = "none"; // Add "none" to .arb files
    String upcomingPrayer = localizations!.fajr;
    String upcomingPrayerTime = _prayerTimes['Fajr']! + ' (${localizations!.tomorrow})';

    for (int i = 0; i < prayerList.length; i++) {
      final prayerTime = _parseTimeToMinutes(prayerList[i]['time']);
      final nextPrayerIndex = (i + 1) % prayerList.length;
      final nextPrayerTime = nextPrayerIndex == 0
          ? _parseTimeToMinutes(_prayerTimes['Fajr']!) + 24 * 60
          : _parseTimeToMinutes(prayerList[nextPrayerIndex]['time']);

      if (currentTime >= prayerTime && currentTime < nextPrayerTime) {
        currentPrayer = prayerList[i]['localized'];
        upcomingPrayer = nextPrayerIndex == 0
            ? localizations.fajr
            : prayerList[nextPrayerIndex]['localized'];
        upcomingPrayerTime = nextPrayerIndex == 0
            ? _prayerTimes['Fajr']! + ' (${localizations.tomorrow})'
            : prayerList[nextPrayerIndex]['time'];
        break;
      }
    }

    setState(() {
      _currentPrayer = currentPrayer;
      _upcomingPrayer = upcomingPrayer;
      _upcomingPrayerTime = upcomingPrayerTime;

      // ADD THIS: Update background based on upcoming prayer
      final prayer = _currentPrayer.toLowerCase();
      if (prayer.contains("fajr") || prayer.contains("none")) {
        _currentBackground = "assets/images/dawn.png";
      } else if (prayer.contains("dhuhr") || prayer.contains("asr")) {
        _currentBackground = "assets/images/noon.png";
      } else if (prayer.contains("maghrib") || prayer.contains("isha")) {
        _currentBackground = "assets/images/night.png";
      } else {
        _currentBackground = "assets/images/noon.png"; // fallback
      }
    });
  }

  int _parseTimeToMinutes(String time) {
    final parts = time.split(' ');
    final timeParts = parts[0].split(':');
    int hour = int.parse(timeParts[0]);
    final minutes = int.parse(timeParts[1]);
    final period = parts[1];

    if (period == 'PM' && hour != 12) {
      hour += 12;
    } else if (period == 'AM' && hour == 12) {
      hour = 0;
    }

    return hour * 60 + minutes;
  }

  void _navigateToScreen(BuildContext context, String itemText) {
    switch (itemText) {
      case 'Prayer Times':
        Navigator.push(context, MaterialPageRoute(builder: (context) => MediumPrayerTimesScreen()));
        break;
      case 'PDF Quran':
        Navigator.push(context, MaterialPageRoute(builder: (context) => PdfquranFirstscreen()));
        break;
      case 'Qibla':
        Navigator.push(context, MaterialPageRoute(builder: (context) => QiblaDirectionMediumScreen()));
        break;
      case 'Dua':
        Navigator.push(context, MaterialPageRoute(builder: (context) => SupplicationScreen()));
        break;
      case 'Asma ul Husna':
        Navigator.push(context, MaterialPageRoute(builder: (context) => AsmaUlHusnaScreenMedium()));
        break;
      case 'Nabi Names':
        Navigator.push(context, MaterialPageRoute(builder: (context) => NabiNamesScreenMedium()));
        break;
    }
  }

  Future<void> _loadVerseOfTheDay() async {
    final prefs = await SharedPreferences.getInstance();
    final lastDate = prefs.getString('verse_of_the_day_date');
    final lastId = prefs.getInt('verse_of_the_day_id');
    final today = DateTime.now().toIso8601String().split('T')[0];

    if (lastDate == today && lastId != null) {
      // Use cached verse if it's the same day
      final db = await DatabaseHelper.database;
      final List<Map<String, dynamic>> ayah = await db.query(
        'ayahs_table',
        where: 'id = ?',
        whereArgs: [lastId],
      );
      if (ayah.isNotEmpty) {
        setState(() {
          _verseOfTheDay = ayah.first;
          _verseSurahReference = _getSurahReference(lastId);
        });
        return;
      }
    }

    // Fetch a new random verse
    try {
      final ayah = await DatabaseHelper.getRandomAyah();
      final id = ayah['id'] as int;
      setState(() {
        _verseOfTheDay = ayah;
        _verseSurahReference = _getSurahReference(id); // Updated method
      });
      await prefs.setString('verse_of_the_day_date', today);
      await prefs.setInt('verse_of_the_day_id', id);
    } catch (e) {
      setState(() {
        _verseOfTheDay = {'arabic_text': 'Error loading verse', 'translation_text': 'Please try again later'};
        _verseSurahReference = 'Unknown';
      });
      print('Failed to load verse of the day: $e');
    }
  }

  // Updated method to map id to Surah reference using QuranData.surahRanges
  String _getSurahReference(int id) {
    int cumulativeAyahCount = 0;
    for (var surah in QuranData.surahRanges) {
      int startAyah = surah['start_ayah'] as int;
      int endAyah = surah['end_ayah'] as int;
      if (id >= startAyah && id <= endAyah) {
        int ayahNumber = id - (startAyah - 1); // Adjust for 1-based ayah numbering within Surah
        return '${surah['name']}, verse $ayahNumber';
      }
      cumulativeAyahCount = endAyah;
    }
    return 'Unknown Surah, verse $id'; // Fallback if id is out of range
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;
// Use AppLocalizations for translated strings
    final localizations = AppLocalizations.of(context);

    final List<Map<String, dynamic>> items = [
      {'image': 'assets/images/Prayer.png', 'text': localizations?.prayerTimes},
      {'image': 'assets/images/Quran_pdf.png', 'text': 'PDF Quran'},
      {'image': 'assets/images/qibla.png', 'text': localizations?.qibla},
      {'image': 'assets/images/hand.png', 'text': localizations?.dua},
      {'image': 'assets/images/Allah.png', 'text': localizations?.asmaUlHusna},
      {'image': 'assets/images/Eid.png', 'text': localizations?.nabiNames},
    ];

    Color getHomeTextColor() {
      final prayer = _currentPrayer.toLowerCase();
      if (prayer.contains("fajr") || prayer.contains("maghrib") || prayer.contains("isha") || prayer.contains("none")) {
        return Colors.white;
      }
      return Colors.black;
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        // actions: [
        //   LanguageSelector(),
        // ],
        title: Text(
          localizations!.home,
          style: GoogleFonts.poppins(
            color: getHomeTextColor(),
            fontSize: 16,
            fontWeight: FontWeight.w700,
          )
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      backgroundColor: Theme.of(context).colorScheme.background,
      //resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          SingleChildScrollView(
            physics: const NeverScrollableScrollPhysics(),
            child: Column(
              children: [
                SizedBox(height: screenHeight * 0.04),
                Column(
                  children: [
                    Container(
                      width: screenWidth,
                      height: screenHeight * 0.25,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage(_currentBackground),
                          fit: BoxFit.fill,
                        ),
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "${localizations?.now} ($_currentPrayer)",
                                  style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: getHomeTextColor(),
                                  ),
                                ),
                                Text(
                                  _currentTime,
                                  textDirection: TextDirection.ltr,
                                  style: GoogleFonts.poppins(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: getHomeTextColor(),
                                    height: 1,
                                  ),
                                ),
                                Text(
                                  _currentDate,
                                  style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: getHomeTextColor(),
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  localizations!.upcomingPrayer,
                                  style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: getHomeTextColor(),
                                  ),
                                ),
                                if (_errorMessage != null)
                                  Container(
                                    width: screenWidth * 0.5,
                                    child: Text(
                                      localizations!.locationPermissionRequired,
                                      style: GoogleFonts.poppins(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                        color: Theme.of(context).colorScheme.onSurface,
                                      ),
                                      textAlign: TextAlign.end,
                                    ),
                                  )
                                else ...[
                                  Text(
                                    _upcomingPrayer,
                                    style: GoogleFonts.poppins(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: getHomeTextColor(),
                                      height: 1,
                                    ),
                                  ),
                                  Text(
                                    _upcomingPrayerTime,
                                    textDirection: TextDirection.ltr,
                                    style: GoogleFonts.poppins(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: getHomeTextColor(),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    Transform.translate(
                      offset: Offset(0, -screenWidth * 0.07),
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.07),
                        child: Card(
                          color: Theme.of(context).colorScheme.surfaceVariant,
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(19),
                          ),
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: TextField(
                              focusNode: _focusNode,
                              controller: _controller,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface,   // 👈 Text color
                              ),
                              decoration: InputDecoration(
                                hintText: localizations!.search,
                                hintStyle: TextStyle(
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                  fontSize: 16,
                                ),
                                border: InputBorder.none,
                                prefixIcon: Icon(Icons.search, color: _iconColor),
                                filled: true,
                                fillColor: Theme.of(context).colorScheme.surfaceVariant, // 👈 Background color
                                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
                  ],
                ),
                Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.08, vertical: screenHeight * 0.01),
                  child: Directionality(
                    textDirection: TextDirection.ltr,
                    child: GridView.builder(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 16.0,
                        mainAxisSpacing: 16.0,
                      ),
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {
                            _navigateToScreen(context, items[index]['text']);
                          },
                          child: Card(
                            color: Theme.of(context).colorScheme.surfaceVariant,
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  items[index]['image'],
                                  width: screenWidth * 0.1,
                                  height: screenHeight * 0.05,
                                  color: Theme.of(context).colorScheme.onSurface,
                                ),
                                SizedBox(height: screenHeight * 0.01),
                                Text(
                                  items[index]['text'],
                                  style: GoogleFonts.poppins(
                                    fontSize: screenWidth * 0.025,
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                SizedBox(height: screenHeight * 0.3),
                SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
                padding: EdgeInsets.only(top: screenHeight * 0.63), // ← here
                child: Container(
                    width: double.infinity,  // ← this forces full width
                    padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.07),
                    child: Card(
                      color: Theme.of(context).colorScheme.surfaceVariant,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                      ),
                      margin: EdgeInsets.zero,
                      child: Padding(
                        padding: EdgeInsets.only(top:screenWidth*0.04, left: screenWidth*0.04, right: screenWidth*0.04),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch, // ← ADD THIS
                          mainAxisSize: MainAxisSize.max,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "${localizations!.verseOfTheDay}:",
                                      style: GoogleFonts.poppins(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context).colorScheme.onSurface,
                                      ),
                                    ),
                                    Text(
                                      _verseSurahReference ?? 'Loading...',
                                      style: GoogleFonts.poppins(
                                        fontSize: 13,
                                        color: Theme.of(context).colorScheme.onSurface,
                                      ),
                                    ),
                                  ],
                                ),

                                SizedBox(height: screenHeight * 0.02),
                                Expanded(
                                  child: SingleChildScrollView(
                                    child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            _verseOfTheDay?['arabic_text'] ?? 'Loading...',
                                            style: GoogleFonts.notoNaskhArabic(
                                                fontSize: screenHeight * 0.02,
                                                fontWeight: FontWeight.bold,
                                                color: Theme.of(context).colorScheme.onSurface,
                                              ),
                                            textDirection: TextDirection.rtl,
                                            maxLines: 100,
                                            overflow: TextOverflow.ellipsis,
                                            ),
                                          SizedBox(height: screenHeight * 0.01),
                                          Text(
                                            _verseOfTheDay?['translation_text'] ?? 'Loading...',
                                            style: GoogleFonts.notoNaskhArabic(
                                              fontSize: screenHeight * 0.016,
                                              color: Theme.of(context).colorScheme.onSurface,
                                            ),
                                            textDirection: TextDirection.rtl,
                                            maxLines: 100,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                  ),
                                ),
                                SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
                              ],
                            ),
                      ),
                    ),
                  ),
              ),
          ),
        ],
      ),
    );
  }
}