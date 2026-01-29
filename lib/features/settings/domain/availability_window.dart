class AvailabilityWindow {
  const AvailabilityWindow({
    required this.startMinute,
    required this.endMinute,
  });

  final int startMinute;
  final int endMinute;

  AvailabilityWindow copyWith({
    int? startMinute,
    int? endMinute,
  }) {
    return AvailabilityWindow(
      startMinute: startMinute ?? this.startMinute,
      endMinute: endMinute ?? this.endMinute,
    );
  }
}
