import 'reminder_deferral_service.dart';

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

class NotificationDeferActionPayload {
  const NotificationDeferActionPayload({
    required this.contactId,
    required this.type,
  });

  final String contactId;
  final ReminderDeferralType type;
}

class NotificationActionPayloadParser {
  const NotificationActionPayloadParser._();

  static Object? tryParse(Object? args) {
    if (args is NotificationWriteActionPayload ||
        args is NotificationCallActionPayload ||
        args is NotificationDeferActionPayload) {
      return args;
    }
    if (args is Map) {
      final action = args['action'] ?? args['type'];
      final contactId = args['contactId'] ?? args['contact_id'];
      final uriValue = args['uri'] ?? args['url'];
      if (action is! String || contactId is! String) {
        return null;
      }
      switch (action) {
        case 'write':
          if (uriValue == null) {
            return null;
          }
          final uri = uriValue is Uri ? uriValue : Uri.tryParse('$uriValue');
          if (uri == null) {
            return null;
          }
          return NotificationWriteActionPayload(
            contactId: contactId,
            uri: uri,
          );
        case 'call':
          if (uriValue == null) {
            return null;
          }
          final uri = uriValue is Uri ? uriValue : Uri.tryParse('$uriValue');
          if (uri == null || uri.scheme != 'tel' || uri.path.isEmpty) {
            return null;
          }
          return NotificationCallActionPayload(
            contactId: contactId,
            uri: uri,
          );
        case 'later':
          return NotificationDeferActionPayload(
            contactId: contactId,
            type: ReminderDeferralType.later,
          );
        case 'not_now':
        case 'not-now':
          return NotificationDeferActionPayload(
            contactId: contactId,
            type: ReminderDeferralType.notNow,
          );
      }
    }
    return null;
  }
}
