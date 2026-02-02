import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/app_database.dart';
import '../../../settings/data/settings_flags_repository.dart';
import '../../../settings/domain/cadence_update_service.dart';
import '../../data/cadence_repository.dart';
import '../../domain/cadence_service.dart';
import '../../domain/cadence_suggestion_service.dart';
import '../../domain/contact_circle.dart';

final cadenceRulesProvider =
    FutureProvider<CadenceSuggestionSnapshot>((ref) async {
  final repository = CadenceRepositoryImpl(AppDatabase.instance);
  final service = CadenceService(repository);
  final settingsRepository = SettingsFlagsRepositoryImpl(AppDatabase.instance);
  final updateService = CadenceUpdateService(settingsRepository);
  final suggestionService = CadenceSuggestionService(
    service,
    updateService,
  );
  return suggestionService.loadSnapshot(ContactCircle.values);
});
