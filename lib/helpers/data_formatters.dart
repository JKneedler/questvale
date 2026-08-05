import 'package:questvale/data/models/todo.dart';

class DataFormatters {
  static const _months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec'
  ];

  static String formatDateTime(DateTime dateTime, bool hasTime) {
    final now = DateTime.now();
    final month = _months[dateTime.month - 1];
    final day = dateTime.day;

    String formatted = '$month $day';

    if (dateTime.year != now.year) {
      formatted += ' ${dateTime.year}';
    }

    if (hasTime) {
      formatted += ' ${formatTime(dateTime)}';
    }

    return formatted;
  }

  static String formatMonthYear(DateTime date) {
    return '${_months[date.month - 1]} ${date.year}';
  }

  static String formatTime(DateTime time) {
    // 24h -> 12h: hour 0 (midnight) and hour 12 (noon) both display as 12,
    // not 0 — time.hour % 12 alone maps both to 0.
    final hour = time.hour % 12 == 0 ? 12 : time.hour % 12;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute$period';
  }

  // Scoped to 1-5 — the only possible occurrence-within-month ordinals —
  // rather than a fully general ordinal formatter.
  static String ordinal(int n) {
    switch (n) {
      case 1:
        return '1st';
      case 2:
        return '2nd';
      case 3:
        return '3rd';
      case 4:
        return '4th';
      case 5:
        return '5th';
      default:
        return '${n}th';
    }
  }

  static const _weekdayNames = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  static String weekdayName(int weekday) => _weekdayNames[weekday - 1];

  // Shared by any hour/day-scale countdown display (skill cooldowns, enemy
  // attack timers): hh:mm once there's at least an hour left, dropping to
  // mm:ss once it's down to minutes so the last stretch reads with
  // second-level precision.
  static String formatCountdown(Duration remaining) {
    final totalSeconds = remaining.inSeconds;
    String pad(int n) => n.toString().padLeft(2, '0');
    if (totalSeconds >= Duration.secondsPerHour) {
      final hours = totalSeconds ~/ Duration.secondsPerHour;
      final minutes =
          (totalSeconds % Duration.secondsPerHour) ~/ Duration.secondsPerMinute;
      return '${pad(hours)}:${pad(minutes)}';
    }
    final minutes = totalSeconds ~/ Duration.secondsPerMinute;
    final seconds = totalSeconds % Duration.secondsPerMinute;
    return '${pad(minutes)}:${pad(seconds)}';
  }

  static String formatRepeatInterval(int interval, HabitTimeframe timeframe) {
    String unit;
    switch (timeframe) {
      case HabitTimeframe.daily:
        unit = 'day';
        break;
      case HabitTimeframe.weekly:
        unit = 'week';
        break;
      case HabitTimeframe.monthly:
        unit = 'month';
        break;
    }
    return 'Every $interval ${interval == 1 ? unit : '${unit}s'}';
  }
}
