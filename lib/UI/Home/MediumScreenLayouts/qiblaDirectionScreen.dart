import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:compassx/compassx.dart';

class QiblaDirectionMediumScreen extends StatefulWidget {
  @override
  _QiblaDirectionMediumScreenState createState() => _QiblaDirectionMediumScreenState();
}

class _QiblaDirectionMediumScreenState extends State<QiblaDirectionMediumScreen> {
  double _deviceHeading = 0.0;  // True heading from fused sensors
  double _qiblaDirection = 0.0;
  String _currentLocation = 'Fetching location...';
  String _qiblaText = 'Calculating...';
  bool _hasPermissions = false;
  bool _needsCalibration = false;
  double? _accuracy;  // Optional: Sensor accuracy (degrees)
  StreamSubscription<CompassXEvent>? _compassSubscription;

  // Kaaba coordinates (precise)
  static const double kaabaLat = 21.422487;
  static const double kaabaLng = 39.826206;

  @override
  void initState() {
    super.initState();
    _checkPermissionsAndFetchLocation();
    _listenToDeviceHeading();
  }

  @override
  void dispose() {
    _compassSubscription?.cancel();
    super.dispose();
  }

  // Same permission/location code (unchanged)
  Future<void> _checkPermissionsAndFetchLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _showError('Location services are disabled.');
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _showError('Location permissions are denied.');
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      _showError('Please allow Location Permissions');
      return;
    }

    setState(() => _hasPermissions = true);

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      _calculateQiblaDirection(position.latitude, position.longitude);
      _getLocationName(position.latitude, position.longitude);
    } catch (e) {
      _showError('Failed to fetch location: $e');
    }
  }

  // Same Qibla calculation (unchanged, but uses precise coords)
  void _calculateQiblaDirection(double latitude, double longitude) {
    double lat1 = math.pi * latitude / 180.0;
    double long1 = math.pi * longitude / 180.0;
    double lat2 = math.pi * kaabaLat / 180.0;
    double long2 = math.pi * kaabaLng / 180.0;

    double dLong = long2 - long1;

    double y = math.sin(dLong) * math.cos(lat2);
    double x = math.cos(lat1) * math.sin(lat2) -
        math.sin(lat1) * math.cos(lat2) * math.cos(dLong);
    double qiblaAngle = math.atan2(y, x);

    qiblaAngle = qiblaAngle * 180.0 / math.pi;
    if (qiblaAngle < 0) qiblaAngle += 360;

    if (mounted) {
      setState(() {
        _qiblaDirection = qiblaAngle;
        _qiblaText = '${qiblaAngle.round()}° ${_getDirection(qiblaAngle)}';
      });
    }
  }

  // Same direction helper (unchanged)
  String _getDirection(double angle) {
    if (angle >= 337.5 || angle < 22.5) return 'N';
    if (angle >= 22.5 && angle < 67.5) return 'NE';
    if (angle >= 67.5 && angle < 112.5) return 'E';
    if (angle >= 112.5 && angle < 157.5) return 'SE';
    if (angle >= 157.5 && angle < 202.5) return 'S';
    if (angle >= 202.5 && angle < 247.5) return 'SW';
    if (angle >= 247.5 && angle < 292.5) return 'W';
    return 'NW';
  }

  // Same location name (unchanged)
  Future<void> _getLocationName(double latitude, double longitude) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        String location = '${place.locality ?? ''}, ${place.thoroughfare ?? ''} ${place.country ?? ''}';
        if (mounted) {
          setState(() => _currentLocation = location.isNotEmpty ? location : 'Unknown location');
        }
      } else {
        if (mounted) setState(() => _currentLocation = 'Unknown location');
      }
    } catch (e) {
      if (mounted) setState(() => _currentLocation = 'Failed to fetch location name: $e');
    }
  }

  void _showError(String message) {
    if (mounted) {
      setState(() {
        _currentLocation = message;
        _qiblaText = 'Error';
      });
    }
  }

  // NEW: Listen to compass events (simple & accurate)
  void _listenToDeviceHeading() {
    _compassSubscription = CompassX.events?.listen(
          (CompassXEvent event) {
        if (event.heading != null && mounted) {
          setState(() {
            _deviceHeading = event.heading!;  // 0–360° true heading
            _needsCalibration = event.shouldCalibrate ?? false;
            _accuracy = event.accuracy;  // Optional: Use for quality indicator
          });
        }
      },
      onError: (e) => print('Compass error: $e'),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Qibla Direction',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF44C17B),
              Color(0xFF2E8B57),
            ],
          ),
        ),
        child: Stack(
          children: [
            // Mosque silhouette (unchanged)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Image.asset(
                'assets/images/mosque_silhouette.png',
                fit: BoxFit.cover,
                height: screenHeight * 0.15,
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Qibla text (unchanged)
                Text(
                  'Qibla $_qiblaText',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                // Location (unchanged)
                Text(
                  _currentLocation,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                // Heading display (now more accurate)
                Text(
                  'Heading: ${_deviceHeading.round()}°',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                if (_needsCalibration) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Calibrate: Move phone in figure-8',
                    style: GoogleFonts.poppins(
                      color: Colors.yellow[100],
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
                SizedBox(height: screenHeight * 0.05),

                // Compass widget (math fixed for correct rotation)
                Center(
                  child: SizedBox(
                    width: screenWidth * 0.8,
                    height: screenWidth * 0.8,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Compass background (rotates opposite to device for "stable" view)
                        Transform.rotate(
                          angle: -(_deviceHeading * math.pi / 180),  // Counter-rotate device
                          child: Image.asset(
                            'assets/images/compass_background.png',
                            width: screenWidth * 0.8,
                            height: screenWidth * 0.8,
                            fit: BoxFit.cover,
                          ),
                        ),
                        // Needle: Points to Qibla (relative to heading)
                        Transform.rotate(
                          angle: ((-_deviceHeading + _qiblaDirection) * math.pi / 180),
                          child: Image.asset(
                            'assets/images/compass_needle.png',
                            width: screenWidth * 0.8,
                            height: screenWidth * 0.8,
                            fit: BoxFit.contain,
                          ),
                        ),
                        // Kaaba icon (aligned with needle)
                        Transform.rotate(
                          angle: ((-_deviceHeading + _qiblaDirection) * math.pi / 180),
                          child: Padding(
                            padding: EdgeInsets.only(bottom: screenWidth * 0.05),
                            child: Image.asset(
                              'assets/images/kaaba_icon.png',
                              width: screenWidth * 0.15,
                              height: screenWidth * 0.15,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}