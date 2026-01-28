import 'contact_circle.dart';

class ContactCadence {
  const ContactCadence({
    required this.circle,
    required this.cadenceDays,
  });

  final ContactCircle circle;
  final int cadenceDays;

  ContactCadence copyWith({int? cadenceDays}) {
    return ContactCadence(
      circle: circle,
      cadenceDays: cadenceDays ?? this.cadenceDays,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is ContactCadence &&
        other.circle == circle &&
        other.cadenceDays == cadenceDays;
  }

  @override
  int get hashCode => Object.hash(circle, cadenceDays);
}
