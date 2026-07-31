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
}
