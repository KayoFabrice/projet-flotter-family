import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../contacts/presentation/providers/contact_action_provider.dart';
import '../../domain/notification_action_handler.dart';
import 'reminder_action_provider.dart';

final notificationActionHandlerProvider = Provider<NotificationActionHandler>((ref) {
  return NotificationActionHandler(
    writeService: ref.read(contactWriteActionServiceProvider),
    callService: ref.read(contactCallActionServiceProvider),
    deferralService: ref.read(reminderDeferralServiceProvider),
  );
});
