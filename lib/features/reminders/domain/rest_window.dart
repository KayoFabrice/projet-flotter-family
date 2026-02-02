class RestWindow {
  const RestWindow({
    required this.startMinute,
    required this.endMinute,
  });

  final int startMinute;
  final int endMinute;

  bool contains(int minuteOfDay) {
    if (minuteOfDay < 0 || minuteOfDay > 24 * 60) {
      return false;
    }
    if (startMinute == endMinute) {
      return false;
    }
    if (startMinute < endMinute) {
      return minuteOfDay >= startMinute && minuteOfDay < endMinute;
    }
    return minuteOfDay >= startMinute || minuteOfDay < endMinute;
  }
}
