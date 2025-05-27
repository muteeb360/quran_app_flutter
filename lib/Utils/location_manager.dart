import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocationManager {
  static Future<Map<String, double>> getUserLocation() async {
    // Check if we have a cached location
    final prefs = await SharedPreferences.getInstance();
    double? cachedLatitude = prefs.getDouble('latitude');
    double? cachedLongitude = prefs.getDouble('longitude');

    // Check location service status
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled. Please enable them.');
    }

    // Check and request location permissions
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Please allow location permissions to use this feature.');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permissions are permanently denied. Please enable them in settings.');
    }

    try {
      // Request background location access (if supported)
      // Note: This might still prompt the user on some platforms
      if (permission == LocationPermission.whileInUse) {
        permission = await Geolocator.requestPermission(); // Try to upgrade to "always"
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Cache the new location
      await prefs.setDouble('latitude', position.latitude);
      await prefs.setDouble('longitude', position.longitude);
      return {'latitude': position.latitude, 'longitude': position.longitude};
    } catch (e) {
      // If fetching fails, use cached location if available
      if (cachedLatitude != null && cachedLongitude != null) {
        return {'latitude': cachedLatitude, 'longitude': cachedLongitude};
      }
      throw Exception('Failed to fetch location: $e');
    }
  }

  // Method to get cached location for offline use
  static Future<Map<String, double>?> getCachedLocation() async {
    final prefs = await SharedPreferences.getInstance();
    double? cachedLatitude = prefs.getDouble('latitude');
    double? cachedLongitude = prefs.getDouble('longitude');
    if (cachedLatitude != null && cachedLongitude != null) {
      return {'latitude': cachedLatitude, 'longitude': cachedLongitude};
    }
    return null;
  }
}