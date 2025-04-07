import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocationService {
  static const String _cachedCountryCodeKey = 'cached_country_code';
  static const Duration _cacheExpiration = Duration(days: 1);
  static const String _lastUpdateTimeKey = 'last_country_code_update';

  Future<String?> getCurrentCountryCode() async {
    try {
      // Check cache first
      final prefs = await SharedPreferences.getInstance();
      final cachedCode = prefs.getString(_cachedCountryCodeKey);
      final lastUpdateTime = DateTime.fromMillisecondsSinceEpoch(
          prefs.getInt(_lastUpdateTimeKey) ?? 0);

      // Return cached value if it's still valid
      if (cachedCode != null &&
          DateTime.now().difference(lastUpdateTime) < _cacheExpiration) {
        return cachedCode;
      }

      // Request location with lower accuracy for speed
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low,
        timeLimit: const Duration(seconds: 5),
      );

      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        final countryCode = placemarks.first.isoCountryCode;
        // Cache the result
        if (countryCode != null) {
          await prefs.setString(_cachedCountryCodeKey, countryCode);
          await prefs.setInt(
              _lastUpdateTimeKey, DateTime.now().millisecondsSinceEpoch);
        }
        return countryCode;
      }
      return null;
    } catch (e) {
      print('Error getting location: $e');
      // Return cached value as fallback if available
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_cachedCountryCodeKey);
    }
  }
}
