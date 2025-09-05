import 'package:timezone/timezone.dart' as tz;

enum DayBucket { morning, midday, afternoon, evening, night }

class TimeContext {
  static DayBucket hourBucket(tz.TZDateTime dt) {
    final h = dt.hour;
    if (h >= 5 && h <= 10) return DayBucket.morning;
    if (h >= 11 && h <= 14) return DayBucket.midday;
    if (h >= 15 && h <= 18) return DayBucket.afternoon;
    if (h >= 19 && h <= 22) return DayBucket.evening;
    return DayBucket.night; // 23–4
  }

  static bool isWeekend(tz.TZDateTime dt) {
    // 6 = Saturday, 7 = Sunday in Dart DateTime? Actually weekday: 1=Mon .. 7=Sun
    return dt.weekday == DateTime.saturday || dt.weekday == DateTime.sunday;
  }

  static tz.TZDateTime toTz(DateTime dt, tz.Location loc) {
    return tz.TZDateTime.from(dt, loc);
  }
}
