import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'dart:async';
import 'package:adhan_dart/adhan_dart.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../Utils/colors.dart';
import '../../../Utils/location_manager.dart';

class MediumPrayerTimesScreen extends StatefulWidget {
  const MediumPrayerTimesScreen({super.key});

  @override
  State<MediumPrayerTimesScreen> createState() => _MediumPrayerTimesScreenState();
}

class _MediumPrayerTimesScreenState extends State<MediumPrayerTimesScreen> {
  String? _location;
  bool _isLoadingLocation = false;
  Map<String, double>? _coordinates;

  // Separate storage for Hanafi and Shafi prayer times
  Map<String, Map<String, String>> _cachedPrayerTimes = {
    'Hanafi': {
      'Fajr': 'Loading...',
      'Sunrise': 'Loading...',
      'Dhuhr': 'Loading...',
      'Asr': 'Loading...',
      'Maghrib': 'Loading...',
      'Isha': 'Loading...',
    },
    'Shafi': {
      'Fajr': 'Loading...',
      'Sunrise': 'Loading...',
      'Dhuhr': 'Loading...',
      'Asr': 'Loading...',
      'Maghrib': 'Loading...',
      'Isha': 'Loading...',
    },
  };

  Map<String, Map<String, String>> _cachedPrayerEndTimes = {
    'Hanafi': {
      'Fajr': 'Loading...',
      'Dhuhr': 'Loading...',
      'Asr': 'Loading...',
      'Maghrib': 'Loading...',
      'Isha': 'Loading...',
    },
    'Shafi': {
      'Fajr': 'Loading...',
      'Dhuhr': 'Loading...',
      'Asr': 'Loading...',
      'Maghrib': 'Loading...',
      'Isha': 'Loading...',
    },
  };

  // Current displayed prayer times
  Map<String, String> _prayerTimes = {
    'Fajr': 'Loading...',
    'Sunrise': 'Loading...',
    'Dhuhr': 'Loading...',
    'Asr': 'Loading...',
    'Maghrib': 'Loading...',
    'Isha': 'Loading...',
  };

  Map<String, String> _prayerEndTimes = {
    'Fajr': 'Loading...',
    'Dhuhr': 'Loading...',
    'Asr': 'Loading...',
    'Maghrib': 'Loading...',
    'Isha': 'Loading...',
  };

  String _upcomingPrayer = 'Dhuhr';
  String _upcomingPrayerTime = '12:38 pm';
  bool _isLoadingPrayerTimes = true;
  String _selectedJuristicMethod = 'Shafi'; // Default value
  String? _errorMessage;
  DateTime? _lastCalculationDate;

  @override
  void initState() {
    super.initState();
    _loadJuristicMethod();
    _checkAndLoadPrayerTimes();
    _scheduleDailyUpdate();
  }

  Future<void> _loadJuristicMethod() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _selectedJuristicMethod = prefs.getString('juristic_method') ?? 'Shafi';
    });
  }

  Future<void> _saveJuristicMethod(String method) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('juristic_method', method);
    if (!mounted) return;
    setState(() {
      _selectedJuristicMethod = method;
      // Load cached prayer times for the selected method
      _prayerTimes = Map.from(_cachedPrayerTimes[method]!);
      _prayerEndTimes = Map.from(_cachedPrayerEndTimes[method]!);
    });
    _updateUpcomingPrayer();
  }

  Future<void> _checkAndLoadPrayerTimes() async {
    final now = DateTime.now();
    // Check if the date has changed since the last calculation
    if (_lastCalculationDate == null ||
        now.day != _lastCalculationDate!.day ||
        now.month != _lastCalculationDate!.month ||
        now.year != _lastCalculationDate!.year) {
      await _loadPrayerTimes();
    }
  }

  Future<void> _loadPrayerTimes() async {
    if (!mounted) return;
    setState(() {
      _isLoadingLocation = true;
      _errorMessage = null;
    });

    try {
      // Try to get the current location
      _coordinates = await LocationManager.getUserLocation();
      double latitude = _coordinates!['latitude']!;
      double longitude = _coordinates!['longitude']!;

      // Get the location name for display and cache it
      await _updateLocationName(latitude, longitude);

      // Calculate prayer times for BOTH methods
      await _calculateBothPrayerTimes(latitude, longitude, DateTime.now());
    } catch (e) {
      // If location fetching fails, try using cached location
      try {
        _coordinates = await LocationManager.getCachedLocation();
        if (_coordinates != null) {
          double latitude = _coordinates!['latitude']!;
          double longitude = _coordinates!['longitude']!;

          // Try to get the cached location name or fetch it
          final prefs = await SharedPreferences.getInstance();
          String? cachedLocationName = prefs.getString('location_name');
          if (cachedLocationName != null) {
            if (!mounted) return;
            setState(() {
              _location = cachedLocationName;
              _isLoadingLocation = false;
            });
          } else {
            // If no cached location name, try to fetch it
            await _updateLocationName(latitude, longitude);
          }

          // Calculate prayer times for BOTH methods
          await _calculateBothPrayerTimes(latitude, longitude, DateTime.now());
        } else {
          if (!mounted) return;
          setState(() {
            _errorMessage = e.toString();
            _isLoadingLocation = false;
            _isLoadingPrayerTimes = false;
          });
        }
      } catch (cachedError) {
        if (!mounted) return;
        setState(() {
          _errorMessage = e.toString();
          _isLoadingLocation = false;
          _isLoadingPrayerTimes = false;
        });
      }
    }
  }

  Future<void> _updateLocationName(double latitude, double longitude) async {
    final prefs = await SharedPreferences.getInstance();
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isNotEmpty) {
        Placemark placemark = placemarks.first;
        String locationName = "${placemark.locality ?? 'Unknown City'}, ${placemark.country ?? 'Unknown Country'}";
        if (!mounted) return;
        setState(() {
          _location = locationName;
          _isLoadingLocation = false;
        });
        // Cache the location name
        await prefs.setString('location_name', locationName);
      } else {
        if (!mounted) return;
        setState(() {
          _location = "Unknown Location";
          _isLoadingLocation = false;
        });
        await prefs.setString('location_name', "Unknown Location");
      }
    } catch (e) {
      // If geocoding fails (e.g., no internet), use a fallback
      String? cachedLocationName = prefs.getString('location_name');
      if (!mounted) return;
      setState(() {
        _location = cachedLocationName ?? "Location unavailable (cached)";
        _isLoadingLocation = false;
      });
    }
  }

  Future<void> _calculateBothPrayerTimes(double latitude, double longitude, DateTime date) async {
    if (!mounted) return;
    setState(() {
      _isLoadingPrayerTimes = true;
    });

    try {
      final utcDate = date.toUtc();
      Coordinates coordinates = Coordinates(latitude, longitude);

      // Calculate for Shafi
      CalculationParameters shafiParams = CalculationMethod.muslimWorldLeague();
      shafiParams.madhab = Madhab.shafi;
      PrayerTimes shafiPrayerTimes = PrayerTimes(
        coordinates: coordinates,
        date: utcDate,
        calculationParameters: shafiParams,
      );

      // Calculate for Hanafi
      CalculationParameters hanafiParams = CalculationMethod.muslimWorldLeague();
      hanafiParams.madhab = Madhab.hanafi;
      PrayerTimes hanafiPrayerTimes = PrayerTimes(
        coordinates: coordinates,
        date: utcDate,
        calculationParameters: hanafiParams,
      );

      // Store Shafi times
      DateTime fajrLocal = shafiPrayerTimes.fajr!.toLocal();
      DateTime sunriseLocal = shafiPrayerTimes.sunrise!.toLocal();
      DateTime dhuhrLocal = shafiPrayerTimes.dhuhr!.toLocal();
      DateTime asrLocal = shafiPrayerTimes.asr!.toLocal();
      DateTime maghribLocal = shafiPrayerTimes.maghrib!.toLocal();
      DateTime ishaLocal = shafiPrayerTimes.isha!.toLocal();

      _cachedPrayerTimes['Shafi'] = {
        'Fajr': _convertTo12HourFormat(fajrLocal),
        'Sunrise': _convertTo12HourFormat(sunriseLocal),
        'Dhuhr': _convertTo12HourFormat(dhuhrLocal),
        'Asr': _convertTo12HourFormat(asrLocal),
        'Maghrib': _convertTo12HourFormat(maghribLocal),
        'Isha': _convertTo12HourFormat(ishaLocal),
      };

      _cachedPrayerEndTimes['Shafi'] = {
        'Fajr': _cachedPrayerTimes['Shafi']!['Sunrise']!,
        'Dhuhr': _cachedPrayerTimes['Shafi']!['Asr']!,
        'Asr': _cachedPrayerTimes['Shafi']!['Maghrib']!,
        'Maghrib': _cachedPrayerTimes['Shafi']!['Isha']!,
        'Isha': "Until Fajr (next day)",
      };

      // Store Hanafi times
      fajrLocal = hanafiPrayerTimes.fajr!.toLocal();
      sunriseLocal = hanafiPrayerTimes.sunrise!.toLocal();
      dhuhrLocal = hanafiPrayerTimes.dhuhr!.toLocal();
      asrLocal = hanafiPrayerTimes.asr!.toLocal();
      maghribLocal = hanafiPrayerTimes.maghrib!.toLocal();
      ishaLocal = hanafiPrayerTimes.isha!.toLocal();

      _cachedPrayerTimes['Hanafi'] = {
        'Fajr': _convertTo12HourFormat(fajrLocal),
        'Sunrise': _convertTo12HourFormat(sunriseLocal),
        'Dhuhr': _convertTo12HourFormat(dhuhrLocal),
        'Asr': _convertTo12HourFormat(asrLocal),
        'Maghrib': _convertTo12HourFormat(maghribLocal),
        'Isha': _convertTo12HourFormat(ishaLocal),
      };

      _cachedPrayerEndTimes['Hanafi'] = {
        'Fajr': _cachedPrayerTimes['Hanafi']!['Sunrise']!,
        'Dhuhr': _cachedPrayerTimes['Hanafi']!['Asr']!,
        'Asr': _cachedPrayerTimes['Hanafi']!['Maghrib']!,
        'Maghrib': _cachedPrayerTimes['Hanafi']!['Isha']!,
        'Isha': "Until Fajr (next day)",
      };
      if (!mounted) return;
      setState(() {
        // Set the displayed times based on the selected method
        _prayerTimes = Map.from(_cachedPrayerTimes[_selectedJuristicMethod]!);
        _prayerEndTimes = Map.from(_cachedPrayerEndTimes[_selectedJuristicMethod]!);
        _isLoadingPrayerTimes = false;
        _lastCalculationDate = DateTime.now();
      });

      _updateUpcomingPrayer();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = "Error calculating prayer times: $e";
        _isLoadingPrayerTimes = false;
      });
    }
  }

  void _scheduleDailyUpdate() {
    Timer.periodic(Duration(hours: 24), (timer) async {
      final now = DateTime.now();
      if (_coordinates != null) {
        await _calculateBothPrayerTimes(_coordinates!['latitude']!, _coordinates!['longitude']!, now);
      } else {
        try {
          _coordinates = await LocationManager.getCachedLocation();
          if (_coordinates != null) {
            double latitude = _coordinates!['latitude']!;
            double longitude = _coordinates!['longitude']!;
            await _updateLocationName(latitude, longitude);
            await _calculateBothPrayerTimes(latitude, longitude, now);
          }
        } catch (e) {
          print("Failed to update prayer times: $e");
        }
      }
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

  void _updateUpcomingPrayer() {
    if (_errorMessage != null) {
      if (!mounted) return;
      setState(() {
        _upcomingPrayer = 'N/A';
        _upcomingPrayerTime = 'N/A';
      });
      return;
    }

    final now = DateTime.now();
    final currentTime = now.hour * 60 + now.minute;

    List<Map<String, dynamic>> prayerList = [
      {'name': 'Fajr', 'time': _prayerTimes['Fajr']!},
      {'name': 'Dhuhr', 'time': _prayerTimes['Dhuhr']!},
      {'name': 'Asr', 'time': _prayerTimes['Asr']!},
      {'name': 'Maghrib', 'time': _prayerTimes['Maghrib']!},
      {'name': 'Isha', 'time': _prayerTimes['Isha']!},
    ];

    for (int i = 0; i < prayerList.length; i++) {
      final prayerTime = _parseTimeToMinutes(prayerList[i]['time']);
      if (currentTime < prayerTime) {
        if (!mounted) return;
        setState(() {
          _upcomingPrayer = prayerList[i]['name'];
          _upcomingPrayerTime = prayerList[i]['time'];
        });
        return;
      }
    }
    if (!mounted) return;
    setState(() {
      _upcomingPrayer = 'Fajr';
      _upcomingPrayerTime = _prayerTimes['Fajr']! + ' (Tomorrow)';
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

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Prayer Times',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
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
      ),
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Juristic Method Dropdown
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Juristic Method: ",
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  DropdownButton<String>(
                    value: _selectedJuristicMethod,
                    items: <String>['Shafi', 'Hanafi'].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(
                          value,
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        _saveJuristicMethod(newValue);
                      }
                    },
                  ),
                ],
              ),
            ),
            Card(
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
                      padding: EdgeInsets.only(
                        left: screenWidth * 0.02,
                        top: screenHeight * 0.035,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                "Upcoming Prayer",
                                style: GoogleFonts.poppins(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                _upcomingPrayer.toUpperCase(),
                                style: GoogleFonts.poppins(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                  height: 0.8,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: screenHeight * 0.04),
                          Row(
                            children: [
                              Text(
                                "Prayer Time",
                                style: GoogleFonts.poppins(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                _upcomingPrayerTime,
                                style: GoogleFonts.poppins(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                  height: 0.8,
                                ),
                              ),
                            ],
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
                              image: AssetImage(
                                'assets/images/praying_man.png',
                              ),
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
            SizedBox(height: screenHeight * 0.03),
            Expanded(
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                color: Theme.of(context).colorScheme.surfaceVariant,
                elevation: 4,
                margin: EdgeInsets.all(16),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.04,
                    vertical: screenHeight * 0.03,
                  ),
                  child: ListView(
                    children: [
                      Center(
                        child: Text(
                          "Prayer Chart",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ),
                      Center(
                        child: Text(
                          _errorMessage != null
                              ? "Please allow location permission"
                              : (_isLoadingLocation ? 'Loading...' : _location ?? 'Fetching location...'),
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 13,
                            color: _errorMessage != null ? Colors.red : Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ),
                      if (_errorMessage != null) ...[
                        PrayerTimeItem(
                          icon: Icons.alarm,
                          title: 'Fajr',
                          time: 'N/A',
                          endTime: 'N/A',
                        ),
                        PrayerTimeItem(
                          icon: Icons.alarm,
                          title: 'Dhuhr',
                          time: 'N/A',
                          endTime: 'N/A',
                        ),
                        PrayerTimeItem(
                          icon: Icons.alarm,
                          title: 'Asr',
                          time: 'N/A',
                          endTime: 'N/A',
                        ),
                        PrayerTimeItem(
                          icon: Icons.alarm,
                          title: 'Maghrib',
                          time: 'N/A',
                          endTime: 'N/A',
                        ),
                        PrayerTimeItem(
                          icon: Icons.alarm,
                          title: 'Isha',
                          time: 'N/A',
                          endTime: 'N/A',
                        ),
                      ] else ...[
                        PrayerTimeItem(
                          icon: Icons.alarm,
                          title: 'Fajr',
                          time: _prayerTimes['Fajr']!,
                          endTime: _prayerEndTimes['Fajr']!,
                        ),
                        PrayerTimeItem(
                          icon: Icons.alarm,
                          title: 'Dhuhr',
                          time: _prayerTimes['Dhuhr']!,
                          endTime: _prayerEndTimes['Dhuhr']!,
                        ),
                        PrayerTimeItem(
                          icon: Icons.alarm,
                          title: 'Asr',
                          time: _prayerTimes['Asr']!,
                          endTime: _prayerEndTimes['Asr']!,
                        ),
                        PrayerTimeItem(
                          icon: Icons.alarm,
                          title: 'Maghrib',
                          time: _prayerTimes['Maghrib']!,
                          endTime: _prayerEndTimes['Maghrib']!,
                        ),
                        PrayerTimeItem(
                          icon: Icons.alarm,
                          title: 'Isha',
                          time: _prayerTimes['Isha']!,
                          endTime: _prayerEndTimes['Isha']!,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PrayerTimeItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String time;
  final String endTime;

  PrayerTimeItem({
    required this.icon,
    required this.title,
    required this.time,
    required this.endTime,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(icon, color: Theme.of(context).colorScheme.onSurface,),
                  SizedBox(width: 8.0),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 19,
                      color: Theme.of(context).colorScheme.onSurface,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    time,
                    style: TextStyle(fontSize: 17, color: Theme.of(context).colorScheme.onSurface,),
                  ),
                  Text(
                    "Until $endTime",
                    style: TextStyle(fontSize: 14, color: AppColors.unselected.withOpacity(0.7)),
                  ),
                ],
              ),
            ],
          ),
          Divider(
            color: Colors.grey,
            thickness: 1,
            height: 20,
          ),
        ],
      ),
    );
  }
}