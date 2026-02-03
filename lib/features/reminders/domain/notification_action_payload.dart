class NotificationWriteActionPayload {
  const NotificationWriteActionPayload({
    required this.contactId,
    required this.uri,
  });

  final String contactId;
  final Uri uri;
}

class NotificationCallActionPayload {
  const NotificationCallActionPayload({
    required this.contactId,
    required this.uri,
  });

  final String contactId;
  final Uri uri;
}

class NotificationActionPayloadParser {
  const NotificationActionPayloadParser._();

  static Object? tryParse(Object? args) {
    if (args is NotificationWriteActionPayload ||
        args is NotificationCallActionPayload) {
      return args;
    }
    if (args is Map) {
      final action = args['action'] ?? args['type'];
      final contactId = args['contactId'] ?? args['contact_id'];
      final uriValue = args['uri'] ?? args['url'];
      if (action is! String || contactId is! String || uriValue == null) {
        return null;
      }
      final uri = uriValue is Uri ? uriValue : Uri.tryParse('$uriValue');
      if (uri == null) {
        return null;
      }
      switch (action) {
        case 'write':
          return NotificationWriteActionPayload(
            contactId: contactId,
            uri: uri,
          );
        case 'call':
          return NotificationCallActionPayload(
            contactId: contactId,
            uri: uri,
          );
      }
    }
    return null;
  }
}
