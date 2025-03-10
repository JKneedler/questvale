class DataFormatters {
  static String formatDateTime(DateTime dateTime, bool hasTime) {
    final now = DateTime.now();
    final months = [
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
    final month = months[dateTime.month - 1];
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

  static String formatTime(DateTime time) {
    final hour = time.hour > 12 ? time.hour - 12 : time.hour;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute$period';
  }
}
