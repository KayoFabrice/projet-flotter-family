class ContactHistoryEntry {
  const ContactHistoryEntry({
    required this.id,
    required this.contactId,
    required this.actionType,
    required this.occurredAt,
  });

  final int id;
  final String contactId;
  final String actionType;
  final String occurredAt;
}
