import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/app_database.dart';
import '../../data/availability_repository.dart';
import '../../domain/availability_service.dart';
import '../../domain/availability_window.dart';

final availabilityRepositoryProvider = Provider<AvailabilityRepository>((ref) {
  return AvailabilityRepositoryImpl(AppDatabase.instance);
});

final availabilityServiceProvider = Provider<AvailabilityService>((ref) {
  final repository = ref.read(availabilityRepositoryProvider);
  return AvailabilityService(repository);
});

final availabilityProvider =
    AsyncNotifierProvider<AvailabilityNotifier, List<AvailabilityWindow>>(
  AvailabilityNotifier.new,
);

class AvailabilityNotifier extends AsyncNotifier<List<AvailabilityWindow>> {
  @override
  Future<List<AvailabilityWindow>> build() async {
    final service = ref.read(availabilityServiceProvider);
    return service.loadWindows();
  }

  void addWindow(AvailabilityWindow window) {
    final current = state.value ?? const <AvailabilityWindow>[];
    state = AsyncData([...current, window]);
  }

  void updateWindow(int index, AvailabilityWindow window) {
    final current = state.value ?? const <AvailabilityWindow>[];
    if (index < 0 || index >= current.length) {
      return;
    }
    final updated = [...current];
    updated[index] = window;
    state = AsyncData(updated);
  }

  void removeWindow(int index) {
    final current = state.value ?? const <AvailabilityWindow>[];
    if (index < 0 || index >= current.length) {
      return;
    }
    final updated = [...current]..removeAt(index);
    state = AsyncData(updated);
  }

  Future<bool> persist() async {
    final service = ref.read(availabilityServiceProvider);
    final current = state.value ?? const <AvailabilityWindow>[];
    state = const AsyncLoading();
    final nextState = await AsyncValue.guard(() async {
      await service.saveWindows(current);
      return current;
    });
    state = nextState;
    return !nextState.hasError;
  }
}
