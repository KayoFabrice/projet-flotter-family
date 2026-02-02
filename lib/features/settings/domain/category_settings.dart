import '../../contacts/domain/contact_circle.dart';

class CategorySettings {
  const CategorySettings({required this.enabledByCircle});

  final Map<ContactCircle, bool> enabledByCircle;

  bool isEnabled(ContactCircle circle) {
    return enabledByCircle[circle] ?? true;
  }

  CategorySettings copyWith({Map<ContactCircle, bool>? enabledByCircle}) {
    return CategorySettings(
      enabledByCircle: enabledByCircle ?? this.enabledByCircle,
    );
  }

  static CategorySettings defaults() {
    return CategorySettings(
      enabledByCircle: {
        for (final circle in ContactCircle.values) circle: true,
      },
    );
  }

  CategorySettings mergeDefaults() {
    final defaults = CategorySettings.defaults().enabledByCircle;
    return CategorySettings(
      enabledByCircle: {
        for (final entry in defaults.entries)
          entry.key: enabledByCircle[entry.key] ?? entry.value,
      },
    );
  }
}
