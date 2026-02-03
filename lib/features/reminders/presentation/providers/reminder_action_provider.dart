import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../contacts/presentation/providers/contact_action_provider.dart';
import '../../domain/reminder_cooldown_service.dart';
import '../../domain/reminder_deferral_service.dart';
import 'due_reminders_provider.dart';

final reminderCooldownServiceProvider = Provider<ReminderCooldownService>((ref) {
  final repository = ref.read(remindersRepositoryProvider);
  return ReminderCooldownService(repository);
});

final reminderDeferralServiceProvider = Provider<ReminderDeferralService>((ref) {
  return ReminderDeferralService(
    cooldownService: ref.read(reminderCooldownServiceProvider),
    historyService: ref.read(contactHistoryServiceProvider),
  );
});
