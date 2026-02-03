import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/app_database.dart';
import '../../../contacts/data/cadence_repository.dart';
import '../../../contacts/data/contact_history_repository.dart';
import '../../../contacts/data/contacts_repository.dart';
import '../../../settings/data/availability_repository.dart';
import '../../../settings/data/key_location_repository.dart';
import '../../../settings/data/settings_flags_repository.dart';
import '../../../reminders/data/message_catalog_repository.dart';
import '../../../reminders/data/reminders_repository.dart';
import '../../../reminders/data/rest_window_repository.dart';
import '../../../reminders/domain/reminder_suggestion_service.dart';
import '../../../reminders/domain/suggestion_selector.dart';

class SuggestionContext {
  const SuggestionContext({
    required this.currentMinuteOfDay,
    this.currentLocationLabel,
    this.nowUtc,
    this.nowLocal,
    this.messageRandom,
  });

  final int currentMinuteOfDay;
  final String? currentLocationLabel;
  final DateTime? nowUtc;
  final DateTime? nowLocal;
  final Random? messageRandom;
}

final reminderSuggestionServiceProvider = Provider<ReminderSuggestionService>(
  (ref) {
    return ReminderSuggestionService(
      contactsRepository: ContactsRepositoryImpl(AppDatabase.instance),
      cadenceRepository: CadenceRepositoryImpl(AppDatabase.instance),
      historyRepository: ContactHistoryRepositoryImpl(AppDatabase.instance),
      remindersRepository: RemindersRepositoryImpl(
        database: AppDatabase.instance,
        keyLocationRepository: KeyLocationRepositoryImpl(AppDatabase.instance),
        availabilityRepository: AvailabilityRepositoryImpl(AppDatabase.instance),
        restWindowRepository: RestWindowRepositoryImpl(AppDatabase.instance),
        settingsFlagsRepository:
            SettingsFlagsRepositoryImpl(AppDatabase.instance),
      ),
      messageCatalogRepository: MessageCatalogRepositoryImpl(),
    );
  },
);

final suggestionDecisionProvider =
    FutureProvider.family<SuggestionDecision, SuggestionContext>(
  (ref, context) async {
    final service = ref.read(reminderSuggestionServiceProvider);
    return service.selectSuggestion(
      currentLocationLabel: context.currentLocationLabel,
      currentMinuteOfDay: context.currentMinuteOfDay,
      nowUtc: context.nowUtc,
      nowLocal: context.nowLocal,
      messageRandom: context.messageRandom,
    );
  },
);
