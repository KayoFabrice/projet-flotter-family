import '../../contacts/domain/contact_circle.dart';
import 'availability_window.dart';
import 'category_settings.dart';

class AvailabilitySettings {
  const AvailabilitySettings({
    required this.windows,
    required this.categorySettings,
  });

  final List<AvailabilityWindow> windows;
  final CategorySettings categorySettings;

  AvailabilitySettings copyWith({
    List<AvailabilityWindow>? windows,
    CategorySettings? categorySettings,
  }) {
    return AvailabilitySettings(
      windows: windows ?? this.windows,
      categorySettings: categorySettings ?? this.categorySettings,
    );
  }

  AvailabilitySettings toggleCategory(ContactCircle circle, bool enabled) {
    final updated = Map<ContactCircle, bool>.from(
      categorySettings.enabledByCircle,
    );
    updated[circle] = enabled;
    return copyWith(
      categorySettings: categorySettings.copyWith(enabledByCircle: updated),
    );
  }
}
