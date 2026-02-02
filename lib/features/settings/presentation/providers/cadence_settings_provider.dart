import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/app_database.dart';
import '../../../contacts/data/cadence_repository.dart';
import '../../../contacts/domain/cadence_service.dart';
import '../../../contacts/domain/contact_cadence.dart';
import '../../../contacts/domain/contact_circle.dart';
import '../../../contacts/presentation/providers/cadence_rules_provider.dart';
import '../../domain/cadence_update_service.dart';
import 'settings_flags_provider.dart';

final cadenceSettingsRepositoryProvider = Provider<CadenceRepository>((ref) {
  return CadenceRepositoryImpl(AppDatabase.instance);
});

final cadenceSettingsServiceProvider = Provider<CadenceService>((ref) {
  final repository = ref.read(cadenceSettingsRepositoryProvider);
  return CadenceService(repository);
});

final cadenceUpdateServiceProvider = Provider<CadenceUpdateService>((ref) {
  final repository = ref.read(settingsFlagsRepositoryProvider);
  return CadenceUpdateService(repository);
});

final cadenceSettingsProvider =
    AsyncNotifierProvider<CadenceSettingsNotifier, List<ContactCadence>>(
      CadenceSettingsNotifier.new,
    );

class CadenceSettingsNotifier extends AsyncNotifier<List<ContactCadence>> {
  @override
  Future<List<ContactCadence>> build() async {
    final service = ref.read(cadenceSettingsServiceProvider);
    return service.loadCadencesForCircles(ContactCircle.values);
  }

  void updateCadence(ContactCircle circle, int cadenceDays) {
    final current = state.value ?? const <ContactCadence>[];
    final updated = <ContactCadence>[];
    var replaced = false;

    for (final cadence in current) {
      if (cadence.circle == circle) {
        updated.add(cadence.copyWith(cadenceDays: cadenceDays));
        replaced = true;
      } else {
        updated.add(cadence);
      }
    }

    if (!replaced) {
      updated.add(ContactCadence(circle: circle, cadenceDays: cadenceDays));
    }

    state = AsyncData(updated);
  }

  Future<bool> persist() async {
    final service = ref.read(cadenceSettingsServiceProvider);
    final updateService = ref.read(cadenceUpdateServiceProvider);
    final current = state.value ?? const <ContactCadence>[];
    state = const AsyncLoading();
    final nextState = await AsyncValue.guard(() async {
      await service.saveCadences(current);
      await updateService.recordUpdate();
      ref.invalidate(cadenceRulesProvider);
      return current;
    });
    state = nextState;
    return !nextState.hasError;
  }
}
