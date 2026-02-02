import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/app_database.dart';
import '../../../settings/data/availability_repository.dart';
import '../../../settings/data/key_location_repository.dart';
import '../../../settings/data/settings_flags_repository.dart';
import '../../data/reminders_repository.dart';
import '../../data/rest_window_repository.dart';
import '../../domain/eligibility_log_service.dart';
import '../../domain/eligibility_result.dart';
import '../../domain/reminder_rules.dart';

class EligibilityContext {
  const EligibilityContext({
    required this.currentLocationLabel,
    required this.currentMinuteOfDay,
  });

  final String? currentLocationLabel;
  final int currentMinuteOfDay;
}

final remindersRepositoryProvider = Provider<RemindersRepository>((ref) {
  final keyRepo = KeyLocationRepositoryImpl(AppDatabase.instance);
  final availabilityRepo = AvailabilityRepositoryImpl(AppDatabase.instance);
  final restWindowRepo = RestWindowRepositoryImpl(AppDatabase.instance);
  final settingsFlagsRepo = SettingsFlagsRepositoryImpl(AppDatabase.instance);
  return RemindersRepositoryImpl(
    keyLocationRepository: keyRepo,
    availabilityRepository: availabilityRepo,
    restWindowRepository: restWindowRepo,
    settingsFlagsRepository: settingsFlagsRepo,
  );
});

final reminderRulesProvider = Provider<ReminderRules>((ref) {
  return ReminderRules();
});

final eligibilityLogProvider = Provider<EligibilityLogService>((ref) {
  return EligibilityLogService();
});

final dueRemindersProvider =
    FutureProvider.family<EligibilityDecision, EligibilityContext>(
  (ref, context) async {
    final repository = ref.read(remindersRepositoryProvider);
    final rules = ref.read(reminderRulesProvider);
    final logService = ref.read(eligibilityLogProvider);

    final keyLocations = await repository.fetchKeyLocationLabels();
    final windows = await repository.fetchAvailabilityWindows();
    final restWindows = await repository.fetchRestWindows();

    final result = rules.evaluateEligibility(
      currentLocationLabel: context.currentLocationLabel,
      keyLocations: keyLocations,
      currentMinuteOfDay: context.currentMinuteOfDay,
      windows: windows,
      restWindows: restWindows,
    );

    logService.record(result);
    return EligibilityDecision(result: result);
  },
);
