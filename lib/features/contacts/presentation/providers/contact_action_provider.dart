import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/contact_call_action_service.dart';
import '../../domain/contact_history_service.dart';
import '../../domain/contact_write_action_service.dart';
import 'contact_detail_provider.dart';

final contactHistoryServiceProvider = Provider<ContactHistoryService>((ref) {
  final repository = ref.read(contactHistoryRepositoryProvider);
  return ContactHistoryService(repository: repository);
});

final contactActionLauncherProvider = Provider<ContactActionLauncher>((ref) {
  return UrlLauncherContactActionLauncher();
});

final contactWriteActionServiceProvider = Provider<ContactWriteActionService>((ref) {
  return ContactWriteActionService(
    historyService: ref.read(contactHistoryServiceProvider),
    launcher: ref.read(contactActionLauncherProvider),
  );
});

final contactCallActionServiceProvider = Provider<ContactCallActionService>((ref) {
  return ContactCallActionService(
    historyService: ref.read(contactHistoryServiceProvider),
    launcher: ref.read(contactActionLauncherProvider),
  );
});
