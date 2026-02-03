import '../../contacts/domain/contact_write_action_service.dart';

class NotificationActionHandler {
  NotificationActionHandler({required ContactWriteActionService writeService})
      : _writeService = writeService;

  final ContactWriteActionService _writeService;

  Future<ContactWriteOutcome> handleWriteAction({
    required String contactId,
    required Uri uri,
  }) {
    return _writeService.launchWrite(contactId: contactId, uri: uri);
  }
}
