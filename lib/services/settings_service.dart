import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static const String notificationsKey = "notifications_enabled";
  static const String tipsKey = "tips_enabled";
  static const String weeklySummaryKey = "weekly_summary_enabled";

  // load settings
  Future<bool> getNotificationsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(notificationsKey) ?? true;
  }

  Future<bool> getTipsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(tipsKey) ?? true;
  }

  Future<bool> getWeeklySummaryEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(weeklySummaryKey) ?? true;
  }

  // save settings
  Future<void> setNotificationsEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(notificationsKey, value);
  }

  Future<void> setTipsEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(tipsKey, value);
  }

  Future<void> setWeeklySummaryEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(weeklySummaryKey, value);
  }
}
