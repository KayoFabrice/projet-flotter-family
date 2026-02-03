class NotificationWriteActionPayload {
  const NotificationWriteActionPayload({
    required this.contactId,
    required this.uri,
  });

  final String contactId;
  final Uri uri;
}
