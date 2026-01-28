import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/app_database.dart';
import '../../data/cadence_repository.dart';
import '../../domain/cadence_service.dart';
import '../../domain/contact_cadence.dart';
import '../../domain/contact_circle.dart';
import 'selected_circles_provider.dart';

final cadenceRepositoryProvider = Provider<CadenceRepository>((ref) {
  return CadenceRepositoryImpl(AppDatabase.instance);
});

final cadenceServiceProvider = Provider<CadenceService>((ref) {
  final repository = ref.read(cadenceRepositoryProvider);
  return CadenceService(repository);
});

final onboardingCadenceProvider = AsyncNotifierProvider<OnboardingCadenceNotifier, List<ContactCadence>>(
  OnboardingCadenceNotifier.new,
);

class OnboardingCadenceNotifier extends AsyncNotifier<List<ContactCadence>> {
  @override
  Future<List<ContactCadence>> build() async {
    final selectedCircles = await ref.watch(selectedCirclesProvider.future);
    final service = ref.read(cadenceServiceProvider);
    return service.loadCadencesForCircles(selectedCircles);
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
    final service = ref.read(cadenceServiceProvider);
    final current = state.value ?? const <ContactCadence>[];
    state = const AsyncLoading();
    final nextState = await AsyncValue.guard(() async {
      await service.saveCadences(current);
      return current;
    });
    state = nextState;
    return !nextState.hasError;
  }
}
