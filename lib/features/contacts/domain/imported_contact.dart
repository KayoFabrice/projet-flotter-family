class ImportedContact {
  const ImportedContact({
    required this.id,
    required this.displayName,
    this.phone,
    this.email,
  });

  final String id;
  final String displayName;
  final String? phone;
  final String? email;
}
