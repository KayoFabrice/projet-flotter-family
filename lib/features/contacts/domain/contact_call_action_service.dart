import 'contact_history_service.dart';
import 'contact_write_action_service.dart';

enum ContactCallOutcome {
  success,
  unavailable,
  failed,
}

class ContactCallActionService {
  ContactCallActionService({
    required ContactHistoryService historyService,
    required ContactActionLauncher launcher,
  })  : _historyService = historyService,
        _launcher = launcher;

  final ContactHistoryService _historyService;
  final ContactActionLauncher _launcher;

  Future<ContactCallOutcome> launchCall({
    required String contactId,
    required Uri uri,
  }) async {
    await _historyService.recordCallAttempt(contactId: contactId);
    final canLaunch = await _launcher.canLaunch(uri);
    if (!canLaunch) {
      return ContactCallOutcome.unavailable;
    }
    final success = await _launcher.launch(uri);
    if (!success) {
      return ContactCallOutcome.failed;
    }
    await _historyService.recordCallSuccess(contactId: contactId);
    return ContactCallOutcome.success;
  }
}
