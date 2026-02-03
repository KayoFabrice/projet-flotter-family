import '../../contacts/domain/contact_history_service.dart';
import 'reminder_cooldown_service.dart';

enum ReminderDeferralType {
  later,
  notNow,
}

class ReminderDeferralService {
  ReminderDeferralService({
    required ReminderCooldownService cooldownService,
    required ContactHistoryService historyService,
  })  : _cooldownService = cooldownService,
        _historyService = historyService;

  final ReminderCooldownService _cooldownService;
  final ContactHistoryService _historyService;

  Future<String> defer({
    required String contactId,
    required ReminderDeferralType type,
  }) async {
    switch (type) {
      case ReminderDeferralType.later:
        await _historyService.recordReminderSnooze(contactId: contactId);
        break;
      case ReminderDeferralType.notNow:
        await _historyService.recordReminderDismiss(contactId: contactId);
        break;
    }
    return _cooldownService.applyCooldown(contactId: contactId);
  }
}
