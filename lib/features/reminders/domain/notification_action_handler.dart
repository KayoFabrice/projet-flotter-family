import '../../contacts/domain/contact_call_action_service.dart';
import '../../contacts/domain/contact_write_action_service.dart';
import 'reminder_deferral_service.dart';

class NotificationActionHandler {
  NotificationActionHandler({
    required ContactWriteActionService writeService,
    required ContactCallActionService callService,
    required ReminderDeferralService deferralService,
  })  : _writeService = writeService,
        _callService = callService,
        _deferralService = deferralService;

  final ContactWriteActionService _writeService;
  final ContactCallActionService _callService;
  final ReminderDeferralService _deferralService;

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

  Future<String> handleDeferralAction({
    required String contactId,
    required ReminderDeferralType type,
  }) {
    return _deferralService.defer(contactId: contactId, type: type);
  }
}
