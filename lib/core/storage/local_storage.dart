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
}
