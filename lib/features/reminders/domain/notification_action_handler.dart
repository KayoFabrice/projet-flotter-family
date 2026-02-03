import '../../contacts/domain/contact_call_action_service.dart';
import '../../contacts/domain/contact_write_action_service.dart';

class NotificationActionHandler {
  NotificationActionHandler({
    required ContactWriteActionService writeService,
    required ContactCallActionService callService,
  })  : _writeService = writeService,
        _callService = callService;

  final ContactWriteActionService _writeService;
  final ContactCallActionService _callService;

  Future<ContactWriteOutcome> handleWriteAction({
    required String contactId,
    required Uri uri,
  }) {
    return _writeService.launchWrite(contactId: contactId, uri: uri);
  }

  Future<ContactCallOutcome> handleCallAction({
    required String contactId,
    required Uri uri,
  }) {
    return _callService.launchCall(contactId: contactId, uri: uri);
  }
}
