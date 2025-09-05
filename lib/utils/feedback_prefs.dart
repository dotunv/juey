import 'package:shared_preferences/shared_preferences.dart';

class FeedbackPrefs {
  static const _prefixAvg = 'feedback_avg:';
  static const _prefixNudge = 'feedback_nudge:';
  static const _globalKey = 'feedback_global_multiplier';

  static Future<double> getAvg(String normalizedTitle) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble('$_prefixAvg$normalizedTitle') ?? 0.65; // default neutral
  }

  static Future<void> updateAvg(String normalizedTitle, bool accepted) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_prefixAvg$normalizedTitle';
    final prev = prefs.getDouble(key) ?? 0.65;
    // simple moving average with small step
    final target = accepted ? 1.0 : 0.0;
    final updated = (prev * 0.8) + (target * 0.2);
    await prefs.setDouble(key, updated);
  }

  static Future<double> getNudge(String normalizedTitle) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble('$_prefixNudge$normalizedTitle') ?? 1.0;
  }

  static Future<void> adjustNudge(String normalizedTitle, bool accepted) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_prefixNudge$normalizedTitle';
    final prev = prefs.getDouble(key) ?? 1.0;
    final delta = accepted ? 0.05 : -0.05;
    final next = (prev + delta).clamp(0.8, 1.2);
    await prefs.setDouble(key, next);
  }

  static Future<double> getGlobalMultiplier() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_globalKey) ?? 1.0;
  }

  static Future<void> setGlobalMultiplier(double value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_globalKey, value.clamp(0.8, 1.2));
  }

  static double mapAvgToBoost(double avg01) {
    return (0.3 + 0.7 * avg01).clamp(0.3, 1.0);
  }
}
