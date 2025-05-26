import 'package:geolocator/geolocator.dart' as geo;
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  LocalStorage._();
  static final LocalStorage instance = LocalStorage._();

  SharedPreferences? _preferences;

  Future<void> init() async {
    _preferences ??= await SharedPreferences.getInstance();
  }

  Future<void> clear() async {
    await init();
    await _preferences?.clear();
  }

  Future<void> setAccessToken(String token) async {
    await init();
    await _preferences?.setString("access_token", token);
  }

  Future<String?> getAccessToken() async {
    await init();
    return _preferences?.getString("access_token");
  }

  Future<void> setRefreshToken(String token) async {
    await init();
    await _preferences?.setString("Refresh_token", token);
  }

  Future<String?> getRefreshToken() async {
    await init();
    return _preferences?.getString("Refresh_token");
  }

  Future<void> setUserId(int id) async {
    await init();
    await _preferences?.setInt("user_id", id);
  }

  Future<int?> getUserId() async {
    await init();
    return _preferences?.getInt("user_id");
  }

  Future<void> setFcmToken(String token) async {
    await init();
    await _preferences?.setString("fcm_token", token);
  }

  Future<String?> getFcmToken() async {
    await init();
    return _preferences?.getString("fcm_token");
  }

  // set user fake coordinates
  Future<void> setUsingFakeCoordinates(bool value) async {
    await init();
    await _preferences?.setBool("using_fake_coordinates", value);
  }

  // get user fake coordinates
  Future<bool?> getUsingFakeCoordinates() async {
    await init();
    return _preferences?.getBool("using_fake_coordinates");
  }

  Future<void> setFakeCoordinates(double lat, double lng) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('fake_lat', lat);
    await prefs.setDouble('fake_lng', lng);
  }

  Future<geo.Position?> getFakeCoordinates() async {
    final prefs = await SharedPreferences.getInstance();
    final lat = prefs.getDouble('fake_lat') ?? 0.0;
    final lng = prefs.getDouble('fake_lng') ?? 0.0;
    if (lat != 0.0 && lng != 0.0) {
      return geo.Position(
        longitude: lng,
        latitude: lat,
        timestamp: DateTime.now(),
        accuracy: 5.0,
        altitude: 50.0,
        altitudeAccuracy: 3.0,
        heading: 0.0,
        headingAccuracy: 0.1,
        speed: 0.0,
        speedAccuracy: 0.1,
      );
    }
    return null;
  }

  // set base URL
  Future<void> setBaseUrl(String url) async {
    await init();
    await _preferences?.setString("base_url", url);
  }

  // get base URL
  Future<String?> getBaseUrl() async {
    await init();
    return _preferences?.getString("base_url");
  }
}
