import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_fonts/google_fonts.dart';

class QiblaDirectionMediumScreen extends StatefulWidget {
  @override
  _QiblaDirectionMediumScreenState createState() => _QiblaDirectionMediumScreenState();
}

class _QiblaDirectionMediumScreenState extends State<QiblaDirectionMediumScreen> {
  double _deviceHeading = 0.0;
  double _qiblaDirection = 0.0; // Angle to Qibla in degrees
  String _currentLocation = 'Fetching location...';
  String _qiblaText = 'Calculating...';
  bool _hasPermissions = false;
  StreamSubscription<CompassEvent>? _compassSubscription; // To hold the subscription

  @override
  void initState() {
    super.initState();
    _checkPermissionsAndFetchLocation();
    _listenToDeviceHeading();
  }

  @override
  void dispose() {
    _compassSubscription?.cancel(); // Cancel the subscription when the widget is disposed
    super.dispose();
  }

  // Check location permissions and fetch the user's location
  Future<void> _checkPermissionsAndFetchLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _showError('Location services are disabled.');
      return;
    }

    // Check location permissions
    permission = await Geolocator.checkPermission();
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

    setState(() {
      _hasPermissions = true;
    });

    // Fetch the user's location
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

  // Calculate the Qibla direction based on user's latitude and longitude
  void _calculateQiblaDirection(double latitude, double longitude) {
    // Kaaba coordinates (Mecca)
    const double kaabaLat = 21.4225; // Latitude of Kaaba
    const double kaabaLong = 39.8262; // Longitude of Kaaba

    // Convert latitude and longitude to radians
    double lat1 = math.pi * latitude / 180.0;
    double long1 = math.pi * longitude / 180.0;
    double lat2 = math.pi * kaabaLat / 180.0;
    double long2 = math.pi * kaabaLong / 180.0;

    // Calculate the difference in longitude
    double dLong = long2 - long1;

    // Calculate the Qibla direction (bearing)
    double y = math.sin(dLong) * math.cos(lat2);
    double x = math.cos(lat1) * math.sin(lat2) -
        math.sin(lat1) * math.cos(lat2) * math.cos(dLong);
    double qiblaAngle = math.atan2(y, x);

    // Convert back to degrees
    qiblaAngle = qiblaAngle * 180.0 / math.pi;

    // Adjust the angle to be between 0 and 360
    if (qiblaAngle < 0) {
      qiblaAngle += 360;
    }

    if (mounted) {
      setState(() {
        _qiblaDirection = qiblaAngle;
        _qiblaText = '${qiblaAngle.round()}° ${_getDirection(qiblaAngle)}';
      });
    }
  }

  // Get the direction (e.g., N, NE, E) based on the heading angle
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

  // Get the location name using geocoding
  Future<void> _getLocationName(double latitude, double longitude) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        String location = '${place.locality ?? ''}, ${place.thoroughfare ?? ''}, ${place.country ?? ''}';
        if (mounted) {
          setState(() {
            _currentLocation = location.isNotEmpty ? location : 'Unknown location';
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _currentLocation = 'Unknown location';
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _currentLocation = 'Failed to fetch location name: $e';
        });
      }
    }
  }

  // Show error messages
  void _showError(String message) {
    if (mounted) {
      setState(() {
        _currentLocation = message;
        _qiblaText = 'Error';
      });
    }
  }

  // Listen to device heading using flutter_compass
  void _listenToDeviceHeading() {
    _compassSubscription = FlutterCompass.events?.listen(
          (CompassEvent event) {
        if (event.heading != null) {
          double normalizedHeading = event.heading! < 0 ? (360 + event.heading!) : event.heading!;
          if (mounted) {
            setState(() {
              _deviceHeading = normalizedHeading;
            });
          }
        }
      },
      onError: (e) {
        print('Compass error: $e');
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      extendBodyBehindAppBar: true, // Allow body to extend behind app bar
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
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
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF44C17B), // Light green at the top
              Color(0xFF2E8B57), // Darker green at the bottom
            ],
          ),
        ),
        child: Stack(
          children: [
            // Bottom mosque silhouette layer
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Image.asset(
                'assets/images/mosque_silhouette.png', // Add this asset (create or use an image with mosque silhouettes)
                fit: BoxFit.cover,
                height: screenHeight * 0.15,
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Display Qibla direction
                Text(
                  'Qibla ${_qiblaText}',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                // Display current location
                Text(
                  _currentLocation,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 8),
                // Display the heading in degrees
                Text(
                  'Heading: ${_deviceHeading.round()}°',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                SizedBox(height: screenHeight * 0.05),
                Center(
                  child: Container(
                    width: screenWidth * 0.8,
                    height: screenWidth * 0.8,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Compass dial (rotates with normalized device heading, reversed direction)
                        Transform.rotate(
                          angle: (-_deviceHeading * math.pi / 180), // Reverse rotation for correct alignment
                          child: Image.asset(
                            'assets/images/compass_background.png',
                            width: screenWidth * 0.8,
                            height: screenWidth * 0.8,
                            fit: BoxFit.cover,
                          ),
                        ),
                        // Compass needle (points to Qibla)
                        Transform.rotate(
                          angle: (-(_deviceHeading + _qiblaDirection) * math.pi / 180), // Adjust needle to Qibla
                          child: Image.asset(
                            'assets/images/compass_needle.png',
                            width: screenWidth * 0.8,
                            height: screenWidth * 0.8,
                            fit: BoxFit.contain,
                          ),
                        ),
                        // Kaaba icon at the needle tip
                        Transform.rotate(
                          angle: (-(_deviceHeading + _qiblaDirection) * math.pi / 180), // Align with needle
                          child: Padding(
                            padding: EdgeInsets.only(bottom: screenWidth * 0.05), // Adjust to position at middle of needle
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