import 'contact_circle.dart';

class Contact {
  const Contact({
    required this.id,
    required this.displayName,
    required this.circle,
    required this.createdAt,
    this.phone,
    this.email,
  });

  final String id;
  final String displayName;
  final ContactCircle circle;
  final String createdAt;
  final String? phone;
  final String? email;
}
